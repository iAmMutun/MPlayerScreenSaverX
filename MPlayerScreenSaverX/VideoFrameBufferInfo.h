#ifndef _VideoFrameBufferInfo_h
#define _VideoFrameBufferInfo_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface VideoFrameBufferInfo : NSObject

@property (assign) BufferType frameBuffer;
@property (assign) NSUInteger imageWidth;
@property (assign) NSUInteger imageHeight;
@property (assign) NSUInteger bufferCount;
@property (assign) OSType pixelFormat;

- (id) initWithWidth:(NSUInteger)width
               height:(NSUInteger)height
          bufferCount:(NSUInteger)count
         pixelFormat:(OSType)format;
- (NSUInteger)bytesPerPixel;
- (NSUInteger)bufferSize;
- (NSUInteger)totalBufferSize;

@end
#endif
