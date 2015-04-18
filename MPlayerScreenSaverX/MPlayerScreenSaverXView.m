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

    // Because of the multiple views, we use notification instead of direct call.
    NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
    [noti addObserver:self selector:@selector(videoStartRequest:)
                 name:VideoWillStartNotification
               object:_mplayerCtrlr];
    [noti addObserver:self selector:@selector(videoStopRequest:)
                 name:VideoHasStopNotification
               object:_mplayerCtrlr];
    [noti addObserver:self selector:@selector(renderRequest:)
                 name:VideoWillRenderNotification
               object:_mplayerCtrlr];
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

- (void)drawRect:(NSRect)rect
{
  [super drawRect:rect];
}

- (void)videoStartRequest:(NSNotification *)aNotification
{
  VideoFrameBufferInfo *bufferInfo = [aNotification userInfo][@"bufferInfo"];
  [_glView prepareBuffer:bufferInfo];
}

- (void)videoStopRequest:(NSNotification *)aNotification
{
  [_glView clearBuffer];
}

- (void)renderRequest:(NSNotification *)aNotification
{
  NSNumber* num = [aNotification userInfo][@"f"];
  NSUInteger frame = [num unsignedIntegerValue];
  [_glView render:frame];
  [self setNeedsDisplay:YES];
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
