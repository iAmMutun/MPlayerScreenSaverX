#import "MPlayerLaunchInfo.h"
#import <ScreenSaver/ScreenSaver.h>

NSString * const kMPlayerNoConfig       = @"-noconfig";
NSString * const kMPlayerNoConfigParam  = @"all";
NSString * const kMPlayerLoop           = @"-loop";
NSString * const kMPlayerLoopParam      = @"0";
NSString * const kMPlayerSlave          = @"-slave";
NSString * const kMPlayerIdle           = @"-idle";
NSString * const kMPlayerQuiet          = @"-quiet";
NSString * const kMPlayerVFCLR          = @"-vf-clr";
NSString * const kMPlayerAFCLR          = @"-af-clr";
NSString * const kMPlayerVO             = @"-vo";
NSString * const kMPlayerVOParam        = @"corevideo:shared_buffer:buffer_name=";
NSString * const kMPlayerVolume         = @"-volume";
NSString * const kMPlayerNoAutoSub      = @"-noautosub";
NSString * const kMPlayerNoSub          = @"-nosub";
NSString * const kMPlayerNoSound        = @"-nosound";

@interface MPlayerLaunchInfo ()
{
}
@end



@implementation MPlayerLaunchInfo

- (id)init
{
  self = [super init];
  if (self)
  {
    unsigned int msSine1970 = (unsigned int)(1000 * [[NSDate date] timeIntervalSince1970]);
    _sharedId = [NSString stringWithFormat:@"%@_%u", SharedIdentifierPrefixString, msSine1970];

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
  ScreenSaverDefaults *defaults =
    [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  
  NSString *voParam = [NSString stringWithFormat:@"%@%@", kMPlayerVOParam, _sharedId];
  NSString *volumeParam = [defaults stringForKey:DefaultVolumeKey];
  BOOL mute = [defaults boolForKey:DefaultMuteKey];
  NSString *muteParam = mute ? kMPlayerNoSound : nil;
  
  DebugLog(@"Volume: %@", volumeParam);
  DebugLog(@"Mute: %@", (mute ? @"Muted" : @"Not muted"));
  
  _arguments = [[NSArray alloc] initWithObjects:
           kMPlayerNoConfig, kMPlayerNoConfigParam,
           kMPlayerSlave, kMPlayerIdle, kMPlayerQuiet,
           kMPlayerVFCLR, kMPlayerAFCLR,
           kMPlayerNoAutoSub, kMPlayerNoSub,
           kMPlayerVO, voParam,
           kMPlayerVolume, volumeParam, muteParam,
           nil];
}
@end
