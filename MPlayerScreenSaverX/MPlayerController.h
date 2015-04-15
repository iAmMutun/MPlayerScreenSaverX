#ifndef _MPlayerController_h
#define _MPlayerController_h

#import "Common.h"
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

- (void)refreshArguments;
- (void)launch;
- (void)terminate;

@end

extern NSString * const VideoWillStartNotification;
extern NSString * const VideoHasStopNotification;
extern NSString * const VideoWillRenderNotification;
#endif
