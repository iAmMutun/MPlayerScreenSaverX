#ifndef _MPlayerConnector_h
#define _MPlayerConnector_h

#import "Common.h"
#import "SharedMemoryMapper.h"
#import <Cocoa/Cocoa.h>

@protocol MPlayerOSXVOProto
- (int) startWithWidth: (bycopy int)width
            withHeight: (bycopy int)height
             withBytes: (bycopy int)bytes
            withAspect: (bycopy int)aspect;
- (void) stop;
- (void) render;
- (void) toggleFullscreen;
- (void) ontop;
@end

@interface MPlayerConnector : NSObject <MPlayerOSXVOProto>
{
  NSTask    * mplayerTask;
  NSPipe    * mplayerOutputPipe;
  NSThread  * mplayerOutputThread;
  NSString  * mplayerExcutablePath;
  NSConnection    * mplayerConnection;
  NSMutableArray  * mplayerArguments;
  NSMutableDictionary   * mplayerEnvironments;
  NSNotificationCenter  * notificationCenter;
  SharedMemoryMapper  * sharedBuffer;
  NSString        * sharedIdentifier;
  NSMutableArray  * videosQueue;
  NSDictionary    * currentVideo;
  NSString  * voParam;
  NSString  * volumeParam;
  NSString  * muteParam;
  //BOOL        validationFlag;
  //NSUInteger  validatedVideos;
  BOOL        videoPlayedFlag;
  BOOL        shuffle;
}

- (id)init;
- (void)refreshArguments;
- (void)launch;
- (void)terminate;
- (void)analyzeMPlayerOutput:(NSFileHandle *)outputHandle;
- (void)mplayerHasQuit:(NSNotification *)aNotification;

@end

extern NSString * const VideoWillStartNotification;
extern NSString * const VideoHasStopNotification;
extern NSString * const VideoWillRenderNotification;
#endif
