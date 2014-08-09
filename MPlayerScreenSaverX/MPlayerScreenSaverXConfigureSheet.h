#ifndef _MPlayerScreenSaverXConfigureSheet_h
#define _MPlayerScreenSaverXConfigureSheet_h

#import "Common.h"
#import "VideoListController.h"
#import "ExtentModeController.h"
#import <Cocoa/Cocoa.h>

@interface MPlayerScreenSaverXConfigureSheet : NSPanel
{
  IBOutlet NSSlider *volumeSlider;
  IBOutlet NSButton *muteCheckbox;
  IBOutlet NSTextField *versionLabel;
  IBOutlet NSTextField *copyrightLabel;
  IBOutlet ExtentModeController *extentModeController;
  IBOutlet VideoListController *videoListController;
}

- (void)awakeFromNib;

- (void)reload;
- (IBAction)setMute:(id)sender;
- (IBAction)closeConfigureSheet:(id)sender;
- (IBAction)addVideoDialog:(id)sender;

@end
#endif
