#ifndef _MPlayerController_h
#define _MPlayerController_h

#import "Common.h"
#import "OpenGLVideoView.h"

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

- (void)addView:(OpenGLVideoView*)view;
- (void)launch;
- (void)terminate;

@end
#endif
