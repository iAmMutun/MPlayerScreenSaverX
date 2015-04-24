#import "AppDelegate.h"
#import <ScreenSaver/ScreenSaver.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) NSBundle *bundle;
@property (strong) ScreenSaverView *screenSaverView;
@property (readonly) BOOL canOpenConfigureSheet;

@end

@implementation AppDelegate

@synthesize canOpenConfigureSheet;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  
    _bundle = nil;
    _screenSaverView = nil;
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    for(NSUInteger i = 1; i < [arguments count]; i++)
    {
        NSString *path = (NSString*)[arguments objectAtIndex:i];
        if ([[path pathExtension] isEqualToString:@"saver"] &&
                [self tryOpenBundleAt:path])
        {
            break;
        }
    }
    
    if (_bundle == nil)
    {
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"saver"]];
        [openPanel beginSheetModalForWindow:_window
                          completionHandler:^(NSInteger result)
         {
             if (result != NSFileHandlingPanelOKButton ||
                 ![self tryOpenBundleAt:[[openPanel URL] path]])
             {
                 [_window performClose:self];
             }
         }];
    }
    
    NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
    [noti addObserver:self selector:@selector(windowDidRezie:)
                 name:NSWindowDidEndLiveResizeNotification object:_window];
    [noti addObserver:self selector:@selector(windowDidRezie:)
                 name:NSWindowDidEnterFullScreenNotification object:_window];
    [noti addObserver:self selector:@selector(windowDidRezie:)
                 name:NSWindowDidExitFullScreenNotification object:_window];
}

- (BOOL)tryOpenBundleAt:(NSString*)path
{
    _bundle = [NSBundle bundleWithPath:path];
    if (_bundle != nil)
    {
        Class viewClass = [_bundle principalClass];
        if ([viewClass isSubclassOfClass:[ScreenSaverView class]]) {
            NSRect rect = [_window contentLayoutRect];
            _screenSaverView = [[viewClass alloc] initWithFrame:rect isPreview:YES];
            canOpenConfigureSheet = [_screenSaverView hasConfigureSheet];
            [_window setContentView:_screenSaverView];
            [_screenSaverView startAnimation];
            return YES;
        }
    }
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [_screenSaverView stopAnimation];
}

- (IBAction)openConfigureSheet:(id)sender
{
    [_screenSaverView stopAnimation];
    [NSApp beginSheet:[_screenSaverView configureSheet]
       modalForWindow:_window
        modalDelegate:self
       didEndSelector:@selector(endConfigureSheet:returnCode:contextInfo:)
          contextInfo:nil];
}

- (void)endConfigureSheet:(NSWindow *)sheet
               returnCode:(NSInteger)returnCode
              contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    [_screenSaverView startAnimation];
}

- (void)windowDidRezie:(NSNotification *)notification
{
    [_screenSaverView setFrameSize:[_window contentLayoutRect].size];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
