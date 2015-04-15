#import "MPlayerScreenSaverXConfigureSheet.h"
#import "VideoListController.h"
#import "ExtentModeController.h"
#import <ScreenSaver/ScreenSaver.h>
#import "Version.h"

@interface MPlayerScreenSaverXConfigureSheet ()
{
  IBOutlet NSSlider *volumeSlider;
  IBOutlet NSButton *muteCheckbox;
  IBOutlet NSTextField *versionLabel;
  IBOutlet NSTextField *copyrightLabel;
  IBOutlet ExtentModeController *extentModeController;
  IBOutlet VideoListController *videoListController;
  IBOutlet NSButton * shuffleCheckbox;
}

- (IBAction)setMute:(id)sender;
- (IBAction)closeConfigureSheet:(id)sender;
- (IBAction)addVideoDialog:(id)sender;

@end



@implementation MPlayerScreenSaverXConfigureSheet

- (void)awakeFromNib
{
  [versionLabel setStringValue:@MPSSX_VERSION_READ];
  [copyrightLabel setStringValue:@MPSSX_COPY];
}

- (void)reload
{
  DebugLog(@"Initializing configure sheet");
  ScreenSaverDefaults *userDefaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];

  [videoListController clearVideos];
  [videoListController addVideos:[userDefaults arrayForKey:DefaultVideoListKey]];
  [videoListController setSelectionIndexes:nil];

  [extentModeController setExtentMode:[userDefaults stringForKey:DefaultExtentKey]];

  BOOL mute = [userDefaults boolForKey:DefaultMuteKey];
  [muteCheckbox setState:(mute ? NSOnState : NSOffState)];
  [volumeSlider setEnabled:!mute];

  NSInteger volume = [userDefaults integerForKey:DefaultVolumeKey];
  [volumeSlider setIntegerValue:volume];
  
  BOOL shuffle = [userDefaults boolForKey:DefaultShuffleKey];
  [shuffleCheckbox setState:(shuffle ? NSOnState : NSOffState)];
}

- (IBAction)setMute:(id)sender
{
  [volumeSlider setEnabled:([muteCheckbox state] != NSOnState)];
}

- (IBAction)closeConfigureSheet:(id)sender
{
  DebugLog(@"Closing configure sheet");
  ScreenSaverDefaults *userDefaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  [userDefaults setValue:[extentModeController extentMode] forKey:DefaultExtentKey];
  [userDefaults setBool:([muteCheckbox state] == NSOnState) forKey:DefaultMuteKey];
  [userDefaults setInteger:[volumeSlider integerValue] forKey:DefaultVolumeKey];
  [userDefaults setObject:[videoListController videos] forKey:DefaultVideoListKey];
  [userDefaults setBool:([shuffleCheckbox state] == NSOnState) forKey:DefaultShuffleKey];
  [userDefaults synchronize];
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
        NSDictionary *video = @{DefaultVideoPathKey: path};
        [videos addObject:video];
      }];
      [videoListController addVideos:videos];
    }
  }];
}

@end
