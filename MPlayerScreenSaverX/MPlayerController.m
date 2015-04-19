#import "MPlayerController.h"
#import "SharedMemoryMapper.h"
#import "VideoFrameBufferInfo.h"
#import <ScreenSaver/ScreenSaver.h>

NSString * const kMPlayerNoConfig       = @"-noconfig";
NSString * const kMPlayerNoConfigParam  = @"all";
NSString * const kMPlayerLoop           = @"-loop";
NSString * const kMPlayerLoopParam      = @"0";
NSString * const kMPlayerSlave          = @"-slave";
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
  NSPipe    * _outputPipe;
  NSThread  * _outputThread;
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
                      kMPlayerSlave, kMPlayerQuiet,
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
  DebugLog(@"Starting MPlayer");
  if ([_videosQueue count] == 0)
  {
    DebugError(@"No video in queue. Halted");
    return;
  }

  NSMutableArray *arguments = [NSMutableArray arrayWithArray:_args];
  _currentVideo = _videosQueue[0];
  [_videosQueue removeObjectAtIndex:0];
  NSString *videoPath = [_currentVideo valueForKey:DefaultVideoPathKey];
  [arguments addObject:videoPath];

  _playFlag = NO;
  _outputPipe = [[NSPipe alloc] init];
  _outputThread = [[NSThread alloc]
                         initWithTarget:self
                         selector:@selector(analyzeMPlayerOutput:)
                         object:[_outputPipe fileHandleForReading]];
  [_outputThread start];
  _task = [[NSTask alloc] init];
  [_notiCenter addObserver:self selector:@selector(mplayerHasQuit:)
                             name:NSTaskDidTerminateNotification
                           object:_task];
  [_task setLaunchPath:_execPath];
  [_task setEnvironment:_envs];
  [_task setArguments:arguments];
  [_task setStandardOutput:_outputPipe];
  [_task setStandardError:_outputPipe];
  [_task launch];
  DebugLog(@"MPlayer has started");
}

- (void)terminate
{
  if ([_task isRunning])
  {
    [_notiCenter removeObserver:self name:NSTaskDidTerminateNotification object:_task];
    [_task terminate];
    [_task waitUntilExit];
    [_outputThread cancel];
    _task = nil;
    _outputThread = nil;
    _outputPipe = nil;
    DebugLog(@"MPlayer has stopped normally");
  }
}

- (void)analyzeMPlayerOutput:(NSFileHandle *)outputHandle
{
  while (![[NSThread currentThread] isCancelled])
  {
    NSData *data = [outputHandle availableData];
    if ([data length] > 0)
    {
      NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      DebugLog(@"* %@", message);
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
  }
}

- (void)mplayerHasQuit:(NSNotification *)aNotification
{
  [_notiCenter removeObserver:self name:NSTaskDidTerminateNotification object:_task];
  [_outputThread cancel];
  if (_playFlag)
  {
    DebugLog(@"MPlayer has stopped");
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
    DebugError(@"MPlayer has stopped without playing the video [%@]", [_currentVideo valueForKey:DefaultVideoPathKey]);
  }
  [self launch];
}

- (int)startWithWidth:(bycopy int)width
           withHeight:(bycopy int)height
            withBytes:(bycopy int)bytes
           withAspect:(bycopy int)aspect
{
  DebugLog(@"Receiving message from MPlayer");
  NSUInteger bufferSize = bytes * width * height;
  ResultType result = [_sharedBuffer share:bufferSize];
  if (result == ResultSuccess) {
    VideoFrameBufferInfo *bufferInfo = [[VideoFrameBufferInfo alloc]
                                        initWithBuffer:[_sharedBuffer bytes]
                                        width:width height:height bytes:bytes];
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
  DebugLog(@"Video has stopped");
  [_views  enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    [(OpenGLVideoView*)(obj) clearBuffer];
  }];
  [_sharedBuffer unshare];
}

- (void)render
{
  [_views  enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    [(OpenGLVideoView*)(obj) render];
  }];
}

- (void)toggleFullscreen { }

- (void)ontop { }

@end
