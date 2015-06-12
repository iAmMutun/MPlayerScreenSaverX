#import "VideoItem.h"

static NSString * const DefaultVideoPathKey = @"VideoPath";



@interface VideoItem ()

- (id)initWithPath:(NSString *)path;

@end



@implementation VideoItem

+ (id)videoWithPath:(NSString *)path
{
  return [[VideoItem alloc] initWithPath:path];
}

+ (id)unserialize:(NSDictionary*)dictionary
{
  return [VideoItem videoWithPath:dictionary[DefaultVideoPathKey]];
}

- (NSDictionary*)serialize
{
  return @{DefaultVideoPathKey:_videoPath};
}

- (id)initWithPath:(NSString *)path
{
  self = [super init];
  if (self) {
    _videoPath = path;
  }
  return self;
}

@end
