#ifndef _VideoFrameBufferInfo_h
#define _VideoFrameBufferInfo_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface VideoFrameBufferInfo : NSObject
{
  BufferType  frameBuffer;
  NSUInteger  imageWidth;
  NSUInteger  imageHeight;
  NSUInteger  bytesPerPixel;
}

@property (assign, readonly) BufferType frameBuffer;
@property (assign, readonly) NSUInteger imageWidth;
@property (assign, readonly) NSUInteger imageHeight;
@property (assign, readonly) NSUInteger bytesPerPixel;

- (id) initWithBuffer:(BufferType)buffer
                width:(NSUInteger)width
               height:(NSUInteger)height
                bytes:(NSUInteger)bytes;
- (OSType) pixelFormat;

@end
#endif
