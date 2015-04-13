#import "Common.h"

void DebugLog(const NSString *format, ...) {
#ifdef DEBUG
  va_list args;
  va_start(args, format);
  NSLogv(format, args);
  va_end(args);
#endif
}
void DebugError(const NSString *format, ...) {
  va_list args;
  va_start(args, format);
  NSLogv(format, args);
  va_end(args);
}

const ResultType ResultSuccess = 0;
const ResultType ResultFailed  = 1;

NSString * const BundleIdentifierString       = @"th.in.iammutun.MPlayerScreenSaverX";
NSString * const VideoListItemTypeString      = @"th.in.iammutun.MPlayerScreenSaverX-video-list-item";
NSString * const SharedIdentifierPrefixString = @"mpssx_shared_id";

NSString * const DefaultVideoListKey    = @"Videos";
NSString * const DefaultVideoPathKey    = @"VideoPath";
NSString * const DefaultMuteKey         = @"Mute";
NSString * const DefaultVolumeKey       = @"Volume";
NSString * const DefaultExtentKey       = @"Extent";
NSString * const DefaultShuffleKey      = @"Shuffle";

NSString * const FitToScreenKey     = @"Fit";
NSString * const FillScreenKey      = @"Fill";
NSString * const StretchToScreenKey = @"Stretch";
NSString * const CenterToScreenKey  = @"Center";
