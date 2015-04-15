#ifndef _VideoFrameBufferInfo_h
#define _VideoFrameBufferInfo_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface VideoFrameBufferInfo : NSObject

@property (assign, readonly) BufferType frameBuffer;
@property (assign, readonly) NSUInteger imageWidth;
@property (assign, readonly) NSUInteger imageHeight;
@property (assign, readonly) NSUInteger bytesPerPixel;
@property (assign, readonly) OSType pixelFormat;

- (id) initWithBuffer:(BufferType)buffer
                width:(NSUInteger)width
               height:(NSUInteger)height
                bytes:(NSUInteger)bytes;

@end
#endif
