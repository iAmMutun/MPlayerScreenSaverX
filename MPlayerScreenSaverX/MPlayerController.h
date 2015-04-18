#ifndef _MPlayerController_h
#define _MPlayerController_h

#import "Common.h"
#import <Cocoa/Cocoa.h>
#import "OpenGLVideoView.h"

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

- (void)addView:(OpenGLVideoView*)view;
- (void)refreshArguments;
- (void)launch;
- (void)terminate;

@end
#endif
