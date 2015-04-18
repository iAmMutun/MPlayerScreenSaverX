#ifndef _MPlayerController_h
#define _MPlayerController_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@protocol MPlayerOSXVOProto

- (int) startWithWidth:(bycopy NSUInteger)width
            withHeight:(bycopy NSUInteger)height
       withPixelFormat:(bycopy OSType)pixelFormat
            withAspect:(bycopy float)aspect;
- (void) stop;
- (void) render:(bycopy NSUInteger)frameNum;
- (void) toggleFullscreen;
- (void) ontop;

@end

@interface MPlayerController : NSObject <MPlayerOSXVOProto>

- (void)launch;
- (void)terminate;

@end

extern NSString * const VideoWillStartNotification;
extern NSString * const VideoHasStopNotification;
extern NSString * const VideoWillRenderNotification;
#endif
