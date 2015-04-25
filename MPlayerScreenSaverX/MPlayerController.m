#import "MPlayerController.h"
#import "SharedMemoryMapper.h"
#import "VideoFrameBufferInfo.h"
#import "MPlayerLaunchInfo.h"
#import "VideoQueue.h"
#import <ScreenSaver/ScreenSaver.h>

@interface MPlayerController ()
{
  NSTask * _task;
  NSPipe * _inputPipe;
  NSPipe * _outputPipe;
  NSConnection       * _connection;
  MPlayerLaunchInfo  * _launchInfo;
  SharedMemoryMapper * _sharedBuffer;
  VideoQueue         * _videoQueue;
  NSMutableArray     * _views;
  BOOL _loadFlag;
  BOOL _playFlag;
}
@end



@implementation MPlayerController

- (id)init
{
  DebugLog(@"Initializing MPlayer");
  self = [super init];
  if (self)
  {
    _launchInfo = [[MPlayerLaunchInfo alloc] init];
    NSString *sharedId = [_launchInfo sharedId];

    DebugLog(@"Establishing service connection [%@]", sharedId);
    _connection = [NSConnection serviceConnectionWithName:sharedId rootObject:self];
    [_connection runInNewThread];

    _sharedBuffer = [[SharedMemoryMapper alloc] initWithName:sharedId];
    _videoQueue = [[VideoQueue alloc] init];
    
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
}

- (void)launch
{
  DebugLog(@"Loading options");
  [_launchInfo refresh];
  [_videoQueue refresh];

  DebugLog(@"Starting MPlayer");
  NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];

  _loadFlag = NO;
  _inputPipe = [[NSPipe alloc] init];
  _outputPipe = [[NSPipe alloc] init];
  NSFileHandle *outputHandle = [_outputPipe fileHandleForReading];
  [notiCenter addObserver:self
                  selector:@selector(mplayerOutput:)
                      name:NSFileHandleDataAvailableNotification
                    object:outputHandle];
  [outputHandle waitForDataInBackgroundAndNotify];
  
  _task = [[NSTask alloc] init];
  [notiCenter addObserver:self selector:@selector(mplayerHasQuit:)
                             name:NSTaskDidTerminateNotification
                           object:_task];
  [_task setLaunchPath:[_launchInfo executablePath]];
  [_task setEnvironment:[_launchInfo environment]];
  [_task setArguments:[_launchInfo arguments]];
  [_task setStandardInput:_inputPipe];
  [_task setStandardOutput:_outputPipe];
  [_task setStandardError:_outputPipe];
  [_task launch];
  DebugLog(@"MPlayer has started");
  [self loadNextVideo];
}

- (void)terminate
{
  if ([_task isRunning])
  {
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter removeObserver:self
                           name:NSTaskDidTerminateNotification
                         object:_task];
    [_task terminate];
    [_task waitUntilExit];
    [notiCenter removeObserver:self
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
  NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
  [notiCenter removeObserver:self
                         name:NSTaskDidTerminateNotification
                       object:_task];
  [notiCenter removeObserver:self
                         name:NSFileHandleDataAvailableNotification
                       object:[_outputPipe fileHandleForReading]];
}

- (void)loadNextVideo
{
  _playFlag = NO;
  if (![_videoQueue nextVideo])
  {
    DebugError(@"No video in queue. Halted");
    [self terminate];
    return;
  }
  NSString *videoPath = [_videoQueue currentVideoPath];
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
      OpenGLVideoView* view = (OpenGLVideoView*)obj;
      [view performSelectorOnMainThread:@selector(prepareBuffer:)
                             withObject:bufferInfo
                          waitUntilDone:NO];
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
      OpenGLVideoView* view = (OpenGLVideoView*)obj;
      [view performSelectorOnMainThread:@selector(clearBuffer)
                             withObject:nil
                          waitUntilDone:NO];
    }];

    [_sharedBuffer unshare];
    DebugLog(@"Video has stopped");
  }
  else
  {
    DebugError(@"MPlayer can't play the file [%@]", [_videoQueue currentVideoPath]);
    [_videoQueue discardCurrentVideo];
  }
  [self loadNextVideo];
}

- (void)render:(bycopy NSUInteger)frameNum;
{
  [_views  enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
   {
     OpenGLVideoView* view = (OpenGLVideoView*)obj;
     [view performSelectorOnMainThread:@selector(render:)
                            withObject:[NSNumber numberWithUnsignedInteger:frameNum]
                         waitUntilDone:NO];
  }];
}

- (void)toggleFullscreen { }

- (void)ontop { }

@end
