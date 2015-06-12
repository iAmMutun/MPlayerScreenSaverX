#import "MPlayerLaunchInfo.h"
#import "UserOptions.h"

static NSString * const SharedIdentifierPrefix  = @"mpssx_shared_id";
static NSString * const ParameterNoConfig       = @"-noconfig";
static NSString * const ParameterNoConfigValue  = @"all";
static NSString * const ParameterLoop           = @"-loop";
static NSString * const ParameterLoopValue      = @"0";
static NSString * const ParameterSlave          = @"-slave";
static NSString * const ParameterIdle           = @"-idle";
static NSString * const ParameterQuiet          = @"-quiet";
static NSString * const ParameterVFCLR          = @"-vf-clr";
static NSString * const ParameterAFCLR          = @"-af-clr";
static NSString * const ParameterVO             = @"-vo";
static NSString * const ParameterVOValue        = @"corevideo:shared_buffer:buffer_name=";
static NSString * const ParameterVolume         = @"-volume";
static NSString * const ParameterNoSound        = @"-nosound";
static NSString * const ParameterNoAutoSub      = @"-noautosub";
static NSString * const ParameterNoSub          = @"-nosub";
static NSString * const ParameterFrameDrop      = @"-framedrop";



@implementation MPlayerLaunchInfo

- (id)init
{
  self = [super init];
  if (self)
  {
    unsigned int msSine1970 = (unsigned int)(1000 * [[NSDate date] timeIntervalSince1970]);
    _sharedId = [NSString stringWithFormat:@"%@_%u", SharedIdentifierPrefix, msSine1970];

    NSMutableDictionary *envs = [[[NSProcessInfo processInfo] environment] mutableCopy];
    envs[@"TERM"] = @"xterm";
    _environment = envs;

    NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
    _executablePath = [bundle pathForAuxiliaryExecutable:@"mplayer"];
    
    DebugLog(@"MPlayer: %@", _executablePath);
  }
  return self;
}

- (void)refresh
{
  UserOptions *options = [UserOptions defaultUserOptions];
  
  NSString *voParam = [NSString stringWithFormat:@"%@%@", ParameterVOValue, _sharedId];
  NSString *volumeParam = [options volumeString];
  BOOL mute = [options mute];
  NSString *muteParam = mute ? ParameterNoSound : nil;
  
  DebugLog(@"Volume: %@", volumeParam);
  DebugLog(@"Mute: %@", (mute ? @"Muted" : @"Not muted"));
  
  _arguments = [[NSArray alloc] initWithObjects:
           ParameterNoConfig, ParameterNoConfigValue,
           ParameterSlave, ParameterIdle, ParameterQuiet,
           ParameterVFCLR, ParameterAFCLR,
           ParameterNoAutoSub, ParameterNoSub, ParameterFrameDrop,
           ParameterVO, voParam,
           ParameterVolume, volumeParam, muteParam,
           nil];
}
@end
