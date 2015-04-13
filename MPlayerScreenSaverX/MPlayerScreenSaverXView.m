#import "MPlayerScreenSaverXView.h"
#import "VideoFrameBufferInfo.h"

static int gScreens = 0;
static MPlayerConnector *gMPlayerConnector;

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
      mplayerConnector = [[MPlayerConnector alloc] init];
      gMPlayerConnector = mplayerConnector;
    } else {
      mplayerConnector = gMPlayerConnector;
    }

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(videoStartRequest:) name:VideoWillStartNotification   object:mplayerConnector];
    [notificationCenter addObserver:self selector:@selector(videoStopRequest:)  name:VideoHasStopNotification    object:mplayerConnector];
    [notificationCenter addObserver:self selector:@selector(renderRequest:)     name:VideoWillRenderNotification  object:mplayerConnector];
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
    [mplayerConnector refreshArguments];
    [mplayerConnector launch];
  }
  [super startAnimation];
}

- (void)stopAnimation
{
  if (first) {
    [mplayerConnector terminate];
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
    [configureSheet retain];
  }
  [configureSheet reload];
  return configureSheet;
}

@end
