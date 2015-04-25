#import "VideoQueue.h"
#import <ScreenSaver/ScreenSaver.h>

@interface VideoQueue ()
{
  NSMutableArray  * _videosQueue;
  NSDictionary    * _currentVideo;
  BOOL _shuffle;
}
@end



@implementation VideoQueue

- (void)refresh
{
  ScreenSaverDefaults *defaults =
    [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  
  _videosQueue = [[NSMutableArray alloc] initWithArray:[defaults valueForKey:DefaultVideoListKey]];
  _shuffle = [defaults boolForKey:DefaultShuffleKey];

  DebugLog(@"Shuffle: %@", (_shuffle ? @"On" : @"Off"));

  if (_shuffle)
  {
    NSUInteger count = [_videosQueue count];
    for (NSUInteger i = 0; i < count; i++)
    {
      u_int32_t left = (u_int32_t)(count - i);
      NSInteger j = i + arc4random_uniform(left);
      [_videosQueue exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
  }
  _currentVideo = nil;
}

- (BOOL)nextVideo
{
  if (_currentVideo != nil)
  {
    if (_shuffle && arc4random_uniform(2) == 0)
    {
      NSUInteger lowerBound = MIN(1, [_videosQueue count]);
      NSUInteger upperBound = [_videosQueue count];
      NSUInteger range = upperBound - lowerBound;
      NSUInteger i = lowerBound + arc4random_uniform((u_int32_t)range);
      [_videosQueue insertObject:_currentVideo atIndex:i];
    }
    else
    {
      [_videosQueue addObject:_currentVideo];
    }
  }
  
  if ([_videosQueue count] == 0)
    return NO;

  _currentVideo = _videosQueue[0];
  [_videosQueue removeObjectAtIndex:0];
  return YES;
}

- (NSString*)currentVideoPath
{
  return [_currentVideo valueForKey:DefaultVideoPathKey];
}

- (void)discardCurrentVideo
{
  _currentVideo = nil;
}

@end
