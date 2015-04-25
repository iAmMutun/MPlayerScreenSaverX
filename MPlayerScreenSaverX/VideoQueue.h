#ifndef _VideoQueue_h
#define _VideoQueue_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface VideoQueue : NSObject

- (void)refresh;
- (BOOL)nextVideo;
- (NSString*)currentVideoPath;
- (void)discardCurrentVideo;

@end
#endif
