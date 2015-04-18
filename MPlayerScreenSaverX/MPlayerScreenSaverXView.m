#import "MPlayerScreenSaverXView.h"
#import "MPlayerScreenSaverXConfigureSheet.h"
#import "MPlayerController.h"
#import "OpenGLVideoView.h"
#import "VideoFrameBufferInfo.h"

static NSUInteger gScreens = 0;
static MPlayerController *gMPlayerController = nil;

@interface MPlayerScreenSaverXView ()
{
  BOOL _first;
  OpenGLVideoView   * _glView;
  MPlayerController * _mplayerCtrlr;
  IBOutlet MPlayerScreenSaverXConfigureSheet *sheet;
}
@end



@implementation MPlayerScreenSaverXView

- (id)initWithFrame:(NSRect)frame
          isPreview:(BOOL)isPreview
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self)
  {
    // Is this the first view?
    _first = (isPreview || gScreens == 0);
    gScreens++;

    _glView = [[OpenGLVideoView alloc] init];
    DebugLog(@"Initializing Video Saver");
    
    ScreenSaverDefaults *userDefaults =
      [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
    [userDefaults registerDefaults:@{
      DefaultVideoListKey: [[NSArray alloc] init],
      DefaultVolumeKey: @"5",
      DefaultMuteKey: @"NO",
      DefaultExtentKey: FitToScreenKey,
      DefaultShuffleKey: @"NO"
    }];

    // Initialize only on the main screen.
    if (_first)
    {
      _mplayerCtrlr = [[MPlayerController alloc] init];
      gMPlayerController = _mplayerCtrlr;
    }
    else
    {
      _mplayerCtrlr = gMPlayerController;
    }

    [_mplayerCtrlr addView:_glView];

    DebugLog(@"Initialization complete");
  }
  return self;
}

- (void)setFrameSize:(NSSize)newSize
{
  [_glView setFrameSize:newSize];
  [super setFrameSize:newSize];
}

- (void)startAnimation
{
  [self addSubview:_glView];
  if (_first)
  {
    [_mplayerCtrlr refreshArguments];
    [_mplayerCtrlr launch];
  }
  [super startAnimation];
}

- (void)stopAnimation
{
  if (_first)
  {
    [_mplayerCtrlr terminate];
  }
  [_glView removeFromSuperview];
  [super stopAnimation];
  gScreens = 0;
}

- (BOOL)hasConfigureSheet { return YES; }

- (NSWindow*)configureSheet
{
  if (sheet == nil)
  {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
    DebugLog(@"%@", [bundle bundlePath]);
    [bundle loadNibNamed:@"ConfigureSheet" owner:self topLevelObjects:NULL];
  }
  [sheet reload];
  return sheet;
}

@end
