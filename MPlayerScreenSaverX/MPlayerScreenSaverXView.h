#ifndef _MPlayerScreenSaverXView_h
#define _MPlayerScreenSaverXView_h

#import "Common.h"
#import "MPlayerScreenSaverXConfigureSheet.h"
#import "MPlayerController.h"
#import "OpenGLVideoView.h"
#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>

@interface MPlayerScreenSaverXView : ScreenSaverView
{
  BOOL first;
  OpenGLVideoView   * openglView;
  MPlayerController * mplayerController;
  IBOutlet MPlayerScreenSaverXConfigureSheet * configureSheet;
}

- (id)initWithFrame:(NSRect)frame
          isPreview:(BOOL)isPreview;
- (void)setFrameSize:(NSSize)newSize;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawRect:(NSRect)rect;

- (void)videoStartRequest:(NSNotification *)aNotification;
- (void)videoStopRequest:(NSNotification *)aNotification;
- (void)renderRequest:(NSNotification *)aNotification;

- (BOOL)hasConfigureSheet;
- (NSWindow*)configureSheet;

@end
#endif
