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

@interface MPlayerController : NSObject <MPlayerOSXVOProto>

- (id)init;
- (void)launch;
- (void)terminate;

@end

extern NSString * const VideoWillStartNotification;
extern NSString * const VideoHasStopNotification;
extern NSString * const VideoWillRenderNotification;
#endif
