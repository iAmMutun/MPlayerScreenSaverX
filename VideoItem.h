#ifndef _VideoItem_h
#define _VideoItem_h

#import "Common.h"

@interface VideoItem : NSObject

@property (readonly) NSString* videoPath;

+ (id)videoWithPath:(NSString*)path;

+ (id)unserialize:(NSDictionary*)dictionary;
- (NSDictionary*)serialize;

@end
#endif
