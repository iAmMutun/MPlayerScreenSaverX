#ifndef _VideoFrameBufferInfo_h
#define _VideoFrameBufferInfo_h

#import "Common.h"

@interface VideoFrameBufferInfo : NSObject

@property (assign) BufferType buffer;
@property (assign) NSUInteger imageWidth;
@property (assign) NSUInteger imageHeight;
@property (assign) NSUInteger bufferCount;
@property (assign) OSType pixelFormat;

- (id) initWithWidth:(NSUInteger)width
               height:(NSUInteger)height
          bufferCount:(NSUInteger)count
         pixelFormat:(OSType)format;
- (BufferType)frameBuffer:(NSUInteger)frame;
- (NSUInteger)bytesPerPixel;
- (NSUInteger)frameSize;
- (NSUInteger)bufferSize;

@end
#endif
