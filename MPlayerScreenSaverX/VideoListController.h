#ifndef _VideoListController_h
#define _VideoListController_h

#import "Common.h"
#import <Cocoa/Cocoa.h>
#import "VideoItem.h"

@interface VideoListController : NSArrayController

- (NSArray *)videos;
- (void)addVideo:(VideoItem *)video;
- (void)addVideos:(NSArray *)videos;
- (void)insertVideo:(VideoItem *)video atIndex:(NSUInteger)index;
- (void)insertVideos:(NSArray *)videos atIndex:(NSUInteger)index;
- (void)clearVideos;

@end
#endif
