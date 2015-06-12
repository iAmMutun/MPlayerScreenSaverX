#ifndef _VideoQueue_h
#define _VideoQueue_h

#import "Common.h"
#import "VideoItem.h"

@interface VideoQueue : NSObject

@property (readonly) VideoItem* currentVideo;

- (void)refresh;
- (BOOL)nextVideo;
- (void)discardCurrentVideo;

@end
#endif
