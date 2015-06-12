#import "VideoQueue.h"
#import "UserOptions.h"
#import "VideoItem.h"

@interface VideoQueue ()
{
  NSMutableArray * _videosQueue;
  BOOL _shuffle;
}
@end



@implementation VideoQueue

- (void)refresh
{
  UserOptions *options = [UserOptions defaultUserOptions];
  
  _videosQueue = [[NSMutableArray alloc] initWithArray:[options videos]];
  _shuffle = [options shuffle];

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
    if (_shuffle)
    {
      NSUInteger lowerBound = MIN(1, [_videosQueue count]);
      NSUInteger upperBound = [_videosQueue count];
      NSUInteger range = upperBound - lowerBound + 1;
      double p = (double)arc4random_uniform(RAND_MAX) / RAND_MAX;
      double q = ((p * p) * (p + 1) * (p + 1)) / 4;
      NSUInteger i = lowerBound + (range - q * range);
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

- (void)discardCurrentVideo
{
  _currentVideo = nil;
}

@end
