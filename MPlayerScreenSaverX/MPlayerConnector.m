#import "MPlayerConnector.h"
#import "VideoFrameBufferInfo.h"
#import <ScreenSaver/ScreenSaver.h>

NSString * const VideoWillStartNotification   = @"VideoWillStartNotification";
NSString * const VideoHasStopNotification     = @"VideoHasStopNotification";
NSString * const VideoWillRenderNotification  = @"VideoWillRenderNotification";

NSString * const kVSMPlayerNoConfig       = @"-noconfig";
NSString * const kVSMPlayerNoConfigParam  = @"all";
NSString * const kVSMPlayerLoop           = @"-loop";
NSString * const kVSMPlayerLoopParam      = @"0";
NSString * const kVSMPlayerSlave          = @"-slave";
NSString * const kVSMPlayerQuiet          = @"-quiet";
NSString * const kVSMPlayerVFCLR          = @"-vf-clr";
NSString * const kVSMPlayerVO             = @"-vo";
NSString * const kVSMPlayerVOParam        = @"corevideo:shared_buffer:buffer_name=";
NSString * const kVSMPlayerVolume         = @"-volume";
NSString * const kVSMPlayerNoAutoSub      = @"-noautosub";
NSString * const kVSMPlayerNoSub          = @"-nosub";
NSString * const kVSMPlayerNoSound        = @"-nosound";

@implementation MPlayerConnector

- (id)init
{
  DebugLog(@"Initializing MPlayer");
  self = [super init];
  if (self) {
    unsigned int msSine1970 = (unsigned int)(1000 * [[NSDate date] timeIntervalSince1970]);
    sharedIdentifier = [NSString stringWithFormat:@"%@_%u", SharedIdentifierPrefixString, msSine1970];
    
    sharedBuffer = [[SharedMemoryMapper alloc] initWithName:sharedIdentifier];

    mplayerTask = nil;
    mplayerArguments = nil;
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
    mplayerExcutablePath = [bundle pathForAuxiliaryExecutable:@"mplayer"];
      
    DebugLog(@"MPlayer: %@", mplayerExcutablePath);

    mplayerEnvironments = [[[NSProcessInfo processInfo] environment] mutableCopy];
    mplayerEnvironments[@"TERM"] = @"xterm";

    notificationCenter = [NSNotificationCenter defaultCenter];

    DebugLog(@"Establishing service connection [%@]", sharedIdentifier);
    mplayerConnection = [NSConnection serviceConnectionWithName:sharedIdentifier rootObject:self];
    [mplayerConnection retain];
  }
  return self;
}

- (void)refreshArguments
{
  //validationFlag = YES;
  //validatedVideos = 0;
  DebugLog(@"Loading options");

  ScreenSaverDefaults *userDefaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  videosQueue = [[NSMutableArray alloc] initWithArray:[userDefaults valueForKey:DefaultVideoListKey]];
  voParam = [NSString stringWithFormat:@"%@%@", kVSMPlayerVOParam, sharedIdentifier];
  volumeParam = [userDefaults stringForKey:DefaultVolumeKey];
  BOOL mute = [userDefaults boolForKey:DefaultMuteKey];
  muteParam = (mute ? kVSMPlayerNoSound : nil);

  DebugLog(@"Volume: %@", volumeParam);
  DebugLog(@"Mute: %@", (mute ? @"Muted" : @"Not muted"));
  
  mplayerArguments = [[NSMutableArray alloc] initWithObjects:
                      kVSMPlayerNoConfig, kVSMPlayerNoConfigParam,
                      kVSMPlayerSlave,
                      kVSMPlayerQuiet,
                      kVSMPlayerVFCLR,
                      kVSMPlayerNoAutoSub,
                      kVSMPlayerNoSub,
                      kVSMPlayerVO, voParam,
                      //kVSMPlayerLoop, kVSMPlayerLoopParam,
                      kVSMPlayerVolume, volumeParam,
                      nil];
  if (muteParam != nil)
    [mplayerArguments addObject:muteParam];
  
  shuffle = [userDefaults boolForKey:DefaultShuffleKey];
  if (shuffle) {
    NSUInteger count = [videosQueue count];
    for (NSUInteger i = 0; i < count; i++) {
      u_int32_t left = (u_int32_t)(count - i);
      NSInteger j = i + arc4random_uniform(left);
      [videosQueue exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
  }
  DebugLog(@"Shuffle: %@", (shuffle ? @"On" : @"Off"));
}

- (void)launch
{
  DebugLog(@"Starting MPlayer");
  if ([videosQueue count] == 0) {
    DebugError(@"No video in queue. Halted");
    return;
  }

  NSMutableArray *arguments = [NSMutableArray arrayWithArray:mplayerArguments];
  currentVideo = videosQueue[0];
  [videosQueue removeObjectAtIndex:0];
  NSString *videoPath = [currentVideo valueForKey:DefaultVideoPathKey];
  [arguments addObject:videoPath];

  videoPlayedFlag = NO;
  mplayerOutputPipe = [[NSPipe alloc] init];
  mplayerOutputThread = [[NSThread alloc] initWithTarget:self selector:@selector(analyzeMPlayerOutput:) object:[mplayerOutputPipe fileHandleForReading]];
  [mplayerOutputThread start];
  mplayerTask = [[NSTask alloc] init];
  [notificationCenter addObserver:self selector:@selector(mplayerHasQuit:) name:NSTaskDidTerminateNotification object:mplayerTask];
  [mplayerTask setLaunchPath:mplayerExcutablePath];
  [mplayerTask setEnvironment:mplayerEnvironments];
  [mplayerTask setArguments:arguments];
  [mplayerTask setStandardOutput:mplayerOutputPipe];
  [mplayerTask setStandardError:mplayerOutputPipe];
  [mplayerTask launch];
  DebugLog(@"MPlayer has started");
}

- (void)terminate
{
  if ([mplayerTask isRunning]) {
    [notificationCenter removeObserver:self name:NSTaskDidTerminateNotification object:mplayerTask];
    [mplayerTask terminate];
    [mplayerTask waitUntilExit];
    [mplayerOutputThread cancel];
    mplayerTask = nil;
    mplayerOutputThread = nil;
    mplayerOutputPipe = nil;
    DebugLog(@"MPlayer has stopped normally");
  }
}

- (void)analyzeMPlayerOutput:(NSFileHandle *)outputHandle
{
  while (![[NSThread currentThread] isCancelled]) {
    NSData *data = [outputHandle availableData];
    if ([data length] > 0) {
      NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      DebugLog(@"* %@", message);
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
  }
}

- (void)mplayerHasQuit:(NSNotification *)aNotification
{
  [notificationCenter removeObserver:self name:NSTaskDidTerminateNotification object:mplayerTask];
  [mplayerOutputThread cancel];
  if (videoPlayedFlag) {
    DebugLog(@"MPlayer has stopped");
    if (shuffle && arc4random_uniform(2) == 0) {
      NSUInteger lowerBound = MIN(1, [videosQueue count]);
      NSUInteger upperBound = [videosQueue count];
      NSUInteger range = upperBound - lowerBound;
      NSUInteger i = lowerBound + arc4random_uniform((u_int32_t)range);
      [videosQueue insertObject:currentVideo atIndex:i];
    } else {
      [videosQueue addObject:currentVideo];
    }
  } else {
    DebugError(@"MPlayer has stopped without playing the video [%@]", [currentVideo valueForKey:DefaultVideoPathKey]);
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
  ResultType result = [sharedBuffer share:bufferSize];
  if (result == ResultSuccess) {
    VideoFrameBufferInfo *bufferInfo = [[VideoFrameBufferInfo alloc] initWithBuffer:[sharedBuffer bytes] width:width height:height bytes:bytes];
    NSDictionary *info = @{@"bufferInfo": bufferInfo};
    [notificationCenter postNotificationName:VideoWillStartNotification object:self userInfo:info];
    DebugLog(@"Video has started");
    videoPlayedFlag = YES;
    return 0;
  }
  return 1;
}

- (void)stop
{
  DebugLog(@"Video has stopped");
  [notificationCenter postNotificationName:VideoHasStopNotification object:self];
  [sharedBuffer unshare];
}

- (void)render
{
  [notificationCenter postNotificationName:VideoWillRenderNotification object:self];
}

- (void)toggleFullscreen { }

- (void)ontop { }

@end
