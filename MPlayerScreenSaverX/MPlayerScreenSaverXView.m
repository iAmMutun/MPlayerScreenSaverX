#import "MPlayerScreenSaverXView.h"
#import "VideoFrameBufferInfo.h"

static int gScreens = 0;
static MPlayerController *gMPlayerController;

@implementation MPlayerScreenSaverXView

- (id)initWithFrame:(NSRect)frame
          isPreview:(BOOL)isPreview
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    first = (isPreview || gScreens == 0);
    gScreens++;

    openglView = [[OpenGLVideoView alloc] init];
    DebugLog(@"Initializing Video Saver");
    
    ScreenSaverDefaults *userDefaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
    [userDefaults registerDefaults:@{DefaultVideoListKey: [[NSArray alloc] init],
                                    DefaultVolumeKey: @"5",
                                    DefaultMuteKey: @"NO",
                                    DefaultExtentKey: FitToScreenKey,
                                    DefaultShuffleKey: @"NO"}];
  
    if (first) {
      mplayerController = [[MPlayerController alloc] init];
      gMPlayerController = mplayerController;
    } else {
      mplayerController = gMPlayerController;
    }

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(videoStartRequest:) name:VideoWillStartNotification   object:mplayerController];
    [notificationCenter addObserver:self selector:@selector(videoStopRequest:)  name:VideoHasStopNotification    object:mplayerController];
    [notificationCenter addObserver:self selector:@selector(renderRequest:)     name:VideoWillRenderNotification  object:mplayerController];
    DebugLog(@"Initialization complete");
  }
  return self;
}

- (void)setFrameSize:(NSSize)newSize
{
  
  [openglView setFrameSize:newSize];
  [super setFrameSize:newSize];
}

- (void)startAnimation
{
  [self addSubview:openglView];
  if (first) {
    [mplayerController refreshArguments];
    [mplayerController launch];
  }
  [super startAnimation];
}

- (void)stopAnimation
{
  if (first) {
    [mplayerController terminate];
  }
  [openglView removeFromSuperview];
  [super stopAnimation];
  gScreens = 0;
}

- (void)drawRect:(NSRect)rect
{
  [super drawRect:rect];
  [openglView render];
}

- (void)videoStartRequest:(NSNotification *)aNotification
{
  VideoFrameBufferInfo *bufferInfo = [aNotification userInfo][@"bufferInfo"];
  [openglView prepareBuffer:bufferInfo];
}

- (void)videoStopRequest:(NSNotification *)aNotification
{
  [openglView clearBuffer];
}

- (void)renderRequest:(NSNotification *)aNotification
{
  [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet { return YES; }

- (NSWindow*)configureSheet
{
  if (configureSheet == nil) {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
    DebugLog(@"%@", [bundle bundlePath]);
    [bundle loadNibNamed:@"ConfigureSheet" owner:self topLevelObjects:NULL];
  }
  [configureSheet reload];
  return configureSheet;
}

@end
