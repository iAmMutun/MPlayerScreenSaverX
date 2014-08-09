#import "MPlayerScreenSaverXConfigureSheet.h"
#import <ScreenSaver/ScreenSaver.h>

@implementation MPlayerScreenSaverXConfigureSheet

- (void)awakeFromNib
{
  NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
  NSDictionary *infoDict = [bundle infoDictionary];
  NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
  [versionLabel setStringValue:version];
  NSString *copyright = [infoDict objectForKey:@"NSHumanReadableCopyright"];
  [copyrightLabel setStringValue:copyright];
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
  [userDefaults synchronize];
  [[NSApplication sharedApplication] endSheet:self];
}

- (IBAction)addVideoDialog:(id)sender
{
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelOKButton) {
      NSMutableArray *videos = [NSMutableArray array];
      [[openPanel URLs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *path = [(NSURL*)obj path];
        NSDictionary *video = @{DefaultVideoPathKey: path};
        [videos addObject:video];
      }];
      [videoListController addVideos:videos];
    }
  }];
}

@end
