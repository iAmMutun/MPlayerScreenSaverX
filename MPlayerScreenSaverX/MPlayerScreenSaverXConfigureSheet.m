#import "MPlayerScreenSaverXConfigureSheet.h"
#import "VideoListController.h"
#import "UserOptions.h"
#import "Version.h"

@interface MPlayerScreenSaverXConfigureSheet ()
{
  IBOutlet NSSlider *volumeSlider;
  IBOutlet NSButton *muteCheckbox;
  IBOutlet NSTextField *versionLabel;
  IBOutlet NSTextField *copyrightLabel;
  IBOutlet NSArrayController *extentModeController;
  IBOutlet VideoListController *videoListController;
  IBOutlet NSButton * shuffleCheckbox;
}

- (IBAction)setMute:(id)sender;
- (IBAction)saveAndClose:(id)sender;
- (IBAction)closeWithoutSave:(id)sender;
- (IBAction)addVideoDialog:(id)sender;
- (void)closeSheet;

@end



@implementation MPlayerScreenSaverXConfigureSheet

- (void)awakeFromNib
{
  [versionLabel setStringValue:@MPSSX_VERSION_READ];
  [copyrightLabel setStringValue:@MPSSX_COPY];
  [extentModeController addObjects:[ExtentMode allExtentModes]];
}

- (void)reload
{
  DebugLog(@"Initializing configure sheet");
  UserOptions *options = [UserOptions defaultUserOptions];

  [videoListController clearVideos];
  [videoListController addVideos:[options videos]];
  [videoListController setSelectionIndexes:nil];
  
  [extentModeController setSelectedObjects:@[[options extent]]];

  BOOL mute = [options mute];
  [muteCheckbox setState:(mute ? NSOnState : NSOffState)];
  [volumeSlider setEnabled:!mute];

  NSInteger volume = [options volume];
  [volumeSlider setIntegerValue:volume];
  
  BOOL shuffle = [options shuffle];
  [shuffleCheckbox setState:(shuffle ? NSOnState : NSOffState)];
}

- (IBAction)setMute:(id)sender
{
  [volumeSlider setEnabled:([muteCheckbox state] != NSOnState)];
}

- (IBAction)saveAndClose:(id)sender
{
  DebugLog(@"Saving configuration");
  UserOptions *options = [UserOptions defaultUserOptions];
  [options setVideos:[videoListController videos]];
  [options setShuffle:([shuffleCheckbox state] == NSOnState)];
  [options setExtent:[extentModeController selectedObjects][0]];
  [options setVolume:[volumeSlider integerValue]];
  [options setMute:([muteCheckbox state] == NSOnState)];
  [options synchronize];
  [self closeSheet];
}

- (IBAction)closeWithoutSave:(id)sender
{
  [self closeSheet];
}

- (void)closeSheet
{
  DebugLog(@"Closing configure sheet");
  [[NSApplication sharedApplication] endSheet:self];
}

- (IBAction)addVideoDialog:(id)sender
{
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel beginSheetModalForWindow:self completionHandler:
    ^(NSInteger result)
  {
    if (result == NSFileHandlingPanelOKButton)
    {
      NSMutableArray *videos = [NSMutableArray array];
      [[openPanel URLs] enumerateObjectsUsingBlock:
        ^(id obj, NSUInteger idx, BOOL *stop)
      {
        NSString *path = [(NSURL*)obj path];
        [videos addObject:[VideoItem videoWithPath:path]];
      }];
      [videoListController addVideos:videos];
    }
  }];
}

@end
