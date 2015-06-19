#import "UserOptions.h"
#import <ScreenSaver/ScreenSaver.h>
#import "VideoItem.h"

static NSString * const DefaultVideoListKey = @"Videos";
static NSString * const DefaultMuteKey      = @"Mute";
static NSString * const DefaultVolumeKey    = @"Volume";
static NSString * const DefaultExtentKey    = @"Extent";
static NSString * const DefaultShuffleKey   = @"Shuffle";

@interface UserOptions ()
{
  ScreenSaverDefaults *_defaults;
}
@end


@implementation UserOptions

+ (UserOptions*)defaultUserOptions
{
  return [[UserOptions alloc] init];
}

+ (void)registerDefaults
{
  ScreenSaverDefaults *userDefaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  [userDefaults registerDefaults:@{
    DefaultVideoListKey : @[],
    DefaultVolumeKey    : [NSNumber numberWithInteger:10],
    DefaultMuteKey      : [NSNumber numberWithBool:NO],
    DefaultExtentKey    : [[ExtentMode defaultMode] stringValue],
    DefaultShuffleKey   : [NSNumber numberWithBool:NO]
  }];
}

- (id)init
{
  self = [super init];
  if (self)
  {
    _defaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  }
  return self;
}

- (NSArray*)videos
{
  NSArray *t = [_defaults arrayForKey:DefaultVideoListKey];
  if (t == nil)
    return @[];
  NSMutableArray *videos = [NSMutableArray array];
  [t enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    VideoItem *v = [VideoItem unserialize:obj];
    [videos addObject:v];
  }];
  return videos;
}

- (void)setVideos:(NSArray*)videos
{
  NSMutableArray *t = [NSMutableArray array];
  [videos enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    NSDictionary *d = [(VideoItem*)obj serialize];
    [t addObject:d];
  }];
  [_defaults setObject:t forKey:DefaultVideoListKey];
}

- (ExtentMode*)extent
{
  NSString *extentString = [_defaults stringForKey:DefaultExtentKey];
  return [ExtentMode extentModeFromString:extentString];
}

- (void)setExtent:(ExtentMode*)extent
{
  [_defaults setObject:[extent stringValue] forKey:DefaultExtentKey];
}

- (BOOL)shuffle
{
  return [_defaults boolForKey:DefaultShuffleKey];
}

- (void)setShuffle:(BOOL)shuffle
{
  [_defaults setBool:shuffle forKey:DefaultShuffleKey];
}

- (NSInteger)volume
{
  return [_defaults integerForKey:DefaultVolumeKey];
}

- (NSString*)volumeString
{
  return [_defaults stringForKey:DefaultVolumeKey];
}

- (void)setVolume:(NSInteger)volume
{
  [_defaults setInteger:volume forKey:DefaultVolumeKey];
}

- (BOOL)mute
{
  return [_defaults boolForKey:DefaultMuteKey];
}

- (void)setMute:(BOOL)mute
{
  [_defaults setBool:mute forKey:DefaultMuteKey];
}

- (void)synchronize
{
  [_defaults synchronize];
}

@end
