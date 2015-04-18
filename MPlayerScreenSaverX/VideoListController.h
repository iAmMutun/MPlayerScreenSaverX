#ifndef _VideoListController_h
#define _VideoListController_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface VideoListController : NSArrayController

- (NSArray *)videos;
- (void)addVideo:(NSDictionary *)video;
- (void)addVideos:(NSArray *)videos;
- (void)insertVideo:(NSDictionary *)video atIndex:(NSUInteger)index;
- (void)insertVideos:(NSArray *)videos atIndex:(NSUInteger)index;
- (void)clearVideos;

@end
#endif
