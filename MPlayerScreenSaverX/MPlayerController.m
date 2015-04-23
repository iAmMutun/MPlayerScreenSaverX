#import "MPlayerController.h"
#import "SharedMemoryMapper.h"
#import "VideoFrameBufferInfo.h"
#import <ScreenSaver/ScreenSaver.h>

NSString * const kMPlayerNoConfig       = @"-noconfig";
NSString * const kMPlayerNoConfigParam  = @"all";
NSString * const kMPlayerLoop           = @"-loop";
NSString * const kMPlayerLoopParam      = @"0";
NSString * const kMPlayerSlave          = @"-slave";
NSString * const kMPlayerIdle           = @"-idle";
NSString * const kMPlayerQuiet          = @"-quiet";
NSString * const kMPlayerVFCLR          = @"-vf-clr";
NSString * const kMPlayerAFCLR          = @"-af-clr";
NSString * const kMPlayerVO             = @"-vo";
NSString * const kMPlayerVOParam        = @"corevideo:shared_buffer:buffer_name=";
NSString * const kMPlayerVolume         = @"-volume";
NSString * const kMPlayerNoAutoSub      = @"-noautosub";
NSString * const kMPlayerNoSub          = @"-nosub";
NSString * const kMPlayerNoSound        = @"-nosound";

@interface MPlayerController ()
{
  NSTask    * _task;
  NSPipe    * _inputPipe;
  NSPipe    * _outputPipe;
  NSString  * _execPath;
  NSConnection    * _connection;
  NSMutableArray  * _args;
  NSMutableDictionary   * _envs;
  NSNotificationCenter  * _notiCenter;
  SharedMemoryMapper  * _sharedBuffer;
  NSString        * _sharedId;
  NSMutableArray  * _videosQueue;
  NSDictionary    * _currentVideo;
  NSString  * _voParam;
  NSString  * _volumeParam;
  NSString  * _muteParam;
  BOOL  _loadFlag;
  BOOL  _playFlag;
  BOOL  _shuffle;
  NSMutableArray *_views;
}
@end



@implementation MPlayerController

- (id)init
{
  DebugLog(@"Initializing MPlayer");
  self = [super init];
  if (self)
  {
    unsigned int msSine1970 = (unsigned int)(1000 * [[NSDate date] timeIntervalSince1970]);
    _sharedId = [NSString stringWithFormat:@"%@_%u", SharedIdentifierPrefixString, msSine1970];
    
    _sharedBuffer = [[SharedMemoryMapper alloc] initWithName:_sharedId];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
    _execPath = [bundle pathForAuxiliaryExecutable:@"mplayer"];
      
    DebugLog(@"MPlayer: %@", _execPath);

    _envs = [[[NSProcessInfo processInfo] environment] mutableCopy];
    _envs[@"TERM"] = @"xterm";

    _notiCenter = [NSNotificationCenter defaultCenter];

    DebugLog(@"Establishing service connection [%@]", _sharedId);
    _connection = [NSConnection serviceConnectionWithName:_sharedId rootObject:self];
    
    _views = [[NSMutableArray alloc] init];

  }
  return self;
}

- (void)addView:(OpenGLVideoView*)view
{
  [_views addObject:view];
}

- (void)refreshArguments
{
  DebugLog(@"Loading options");

  ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  _videosQueue = [[NSMutableArray alloc] initWithArray:[defaults valueForKey:DefaultVideoListKey]];
  _voParam = [NSString stringWithFormat:@"%@%@", kMPlayerVOParam, _sharedId];
  _volumeParam = [defaults stringForKey:DefaultVolumeKey];
  BOOL mute = [defaults boolForKey:DefaultMuteKey];
  _muteParam = (mute ? kMPlayerNoSound : nil);

  DebugLog(@"Volume: %@", _volumeParam);
  DebugLog(@"Mute: %@", (mute ? @"Muted" : @"Not muted"));

  _args = [[NSMutableArray alloc] initWithObjects:
                      kMPlayerNoConfig, kMPlayerNoConfigParam,
                      kMPlayerSlave, kMPlayerIdle, kMPlayerQuiet,
                      kMPlayerVFCLR, kMPlayerAFCLR,
                      kMPlayerNoAutoSub, kMPlayerNoSub,
                      kMPlayerVO, _voParam,
                      kMPlayerVolume, _volumeParam,
                      nil];
  if (_muteParam != nil)
    [_args addObject:_muteParam];
  
  _shuffle = [defaults boolForKey:DefaultShuffleKey];
  if (_shuffle)
  {
    NSUInteger count = [_videosQueue count];
    for (NSUInteger i = 0; i < count; i++)
    {
      u_int32_t left = (u_int32_t)(count - i);
      NSInteger j = i + arc4random_uniform(left);
      [_videosQueue exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
  }
  DebugLog(@"Shuffle: %@", (_shuffle ? @"On" : @"Off"));
}

- (void)launch
{
  [self refreshArguments];
  DebugLog(@"Starting MPlayer");
  if ([_videosQueue count] == 0)
  {
    DebugError(@"No video in queue. Halted");
    return;
  }

  _loadFlag = NO;
  _inputPipe = [[NSPipe alloc] init];
  _outputPipe = [[NSPipe alloc] init];
  NSFileHandle *outputHandle = [_outputPipe fileHandleForReading];
  [_notiCenter addObserver:self
                  selector:@selector(mplayerOutput:)
                      name:NSFileHandleDataAvailableNotification
                    object:outputHandle];
  [outputHandle waitForDataInBackgroundAndNotify];
  _task = [[NSTask alloc] init];
  [_notiCenter addObserver:self
                  selector:@selector(mplayerHasQuit:)
                      name:NSTaskDidTerminateNotification
                    object:_task];
  [_task setLaunchPath:_execPath];
  [_task setEnvironment:_envs];
  [_task setArguments:_args];
  [_task setStandardInput:_inputPipe];
  [_task setStandardOutput:_outputPipe];
  [_task setStandardError:_outputPipe];
  [_task launch];
  DebugLog(@"MPlayer has started");
  [self nextVideo];
}

- (void)terminate
{
  if ([_task isRunning])
  {
    [_notiCenter removeObserver:self
                           name:NSTaskDidTerminateNotification
                         object:_task];
    [_task terminate];
    [_task waitUntilExit];
    [_notiCenter removeObserver:self
                           name:NSFileHandleDataAvailableNotification
                         object:[_outputPipe fileHandleForReading]];
    _task = nil;
    _inputPipe = nil;
    _outputPipe = nil;
    DebugLog(@"MPlayer has stopped normally");
  }
}

- (void)mplayerOutput:(NSNotification *)aNotification
{
  NSFileHandle *outputHandle = [aNotification object];
  NSData *data = [outputHandle availableData];
  if ([data length] == 0)
    return;
  NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  DebugLog(@"> %@", message);
  if (_loadFlag && [message containsString:@"ANS_path="])
  {
    _loadFlag = NO;
    if([message containsString:@"ANS_path=(null)"])
    {
      [self stop];
    }
  }
  [outputHandle waitForDataInBackgroundAndNotify];
}

- (void)mplayerHasQuit:(NSNotification *)aNotification
{
  DebugError(@"MPlayer has crashed");
  [_notiCenter removeObserver:self
                         name:NSTaskDidTerminateNotification
                       object:_task];
  [_notiCenter removeObserver:self
                         name:NSFileHandleDataAvailableNotification
                       object:[_outputPipe fileHandleForReading]];
}

- (void)nextVideo
{
  _playFlag = NO;
  if ([_videosQueue count] == 0)
  {
    DebugError(@"No video in queue. Halted");
    [self terminate];
    return;
  }
  _currentVideo = _videosQueue[0];
  [_videosQueue removeObjectAtIndex:0];
  NSString *videoPath = [_currentVideo valueForKey:DefaultVideoPathKey];
  NSString *cmd = [NSString stringWithFormat:@"loadfile \"%@\" 1\n", videoPath];
  [self writeToMPlayer:cmd];
  [self writeToMPlayer:@"get_property path\n"];
  _loadFlag = YES;
}

- (void)writeToMPlayer:(NSString *)cmd
{
  NSFileHandle *fh = [_inputPipe fileHandleForWriting];
  [fh writeData:[cmd dataUsingEncoding:NSUTF8StringEncoding]];
  DebugLog(@"< %@", cmd);
}

- (int)startWithWidth:(bycopy NSUInteger)width
           withHeight:(bycopy NSUInteger)height
      withPixelFormat:(bycopy OSType)pixelFormat
           withAspect:(bycopy float)aspect
{
  DebugLog(@"Receiving message from MPlayer");
  VideoFrameBufferInfo *bufferInfo = [[VideoFrameBufferInfo alloc]
                                       initWithWidth:width
                                              height:height
                                         bufferCount:2
                                         pixelFormat:pixelFormat];
  NSUInteger bufferSize = [bufferInfo bufferSize];
  ResultType result = [_sharedBuffer share:bufferSize];
  if (result == ResultSuccess)
  {
    [bufferInfo setBuffer:[_sharedBuffer bytes]];
    [_views  enumerateObjectsUsingBlock:
      ^(id obj, NSUInteger idx, BOOL *stop)
    {
      [(OpenGLVideoView*)(obj) prepareBuffer:bufferInfo];
    }];
    DebugLog(@"Video has started");
    _playFlag = YES;
    return 0;
  }
  return 1;
}

- (void)stop
{
  if (_playFlag)
  {
    [_views  enumerateObjectsUsingBlock:
      ^(id obj, NSUInteger idx, BOOL *stop)
    {
      [(OpenGLVideoView*)(obj) clearBuffer];
    }];

    [_sharedBuffer unshare];
    DebugLog(@"Video has stopped");
    
    if (_shuffle && arc4random_uniform(2) == 0)
    {
      NSUInteger lowerBound = MIN(1, [_videosQueue count]);
      NSUInteger upperBound = [_videosQueue count];
      NSUInteger range = upperBound - lowerBound;
      NSUInteger i = lowerBound + arc4random_uniform((u_int32_t)range);
      [_videosQueue insertObject:_currentVideo atIndex:i];
    }
    else
    {
      [_videosQueue addObject:_currentVideo];
    }
  }
  else
  {
    DebugError(@"MPlayer can't play the file [%@]", [_currentVideo valueForKey:DefaultVideoPathKey]);
  }
  [self nextVideo];
}

- (void)render:(bycopy NSUInteger)frameNum;
{
  [_views  enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    [(OpenGLVideoView*)(obj) render:frameNum];
  }];
}

- (void)toggleFullscreen { }

- (void)ontop { }

@end
