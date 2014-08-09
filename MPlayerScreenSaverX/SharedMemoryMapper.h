#ifndef _SharedMemoryMapper_h
#define _SharedMemoryMapper_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface SharedMemoryMapper : NSObject
{
  NSString  * name;
  BufferType  bytes;
  NSUInteger  length;
}

@property (assign, readonly) BufferType bytes;

- (id)initWithName:(NSString *)memoryName;
- (ResultType)share:(NSUInteger)size;
- (ResultType)unshare;

@end
#endif
