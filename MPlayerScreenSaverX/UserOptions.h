#ifndef _UserOptions_h
#define _UserOptions_h

#import "Common.h"
#import "VideoQueue.h"
#import "ExtentMode.h"

@interface UserOptions : NSObject

+ (UserOptions*)defaultUserOptions;
+ (void)registerDefaults;

- (NSArray*)videos;
- (void)setVideos:(NSArray*)videos;

- (BOOL)shuffle;
- (void)setShuffle:(BOOL)shuffle;

- (ExtentMode*)extent;
- (void)setExtent:(ExtentMode*)extent;

- (NSInteger)volume;
- (NSString*)volumeString;
- (void)setVolume:(NSInteger)volume;

- (BOOL)mute;
- (void)setMute:(BOOL)mute;

- (void)synchronize;

@end
#endif
