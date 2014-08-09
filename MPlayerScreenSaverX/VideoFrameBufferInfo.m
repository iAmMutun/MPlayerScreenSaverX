#import "VideoFrameBufferInfo.h"

@implementation VideoFrameBufferInfo

@synthesize frameBuffer;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize bytesPerPixel;

- (id) initWithBuffer:(BufferType)buffer
                width:(NSUInteger)width
               height:(NSUInteger)height
                bytes:(NSUInteger)bytes
{
  self = [super init];
  if (self) {
    frameBuffer = buffer;
    imageWidth = width;
    imageHeight = height;
    bytesPerPixel = bytes;
  }
  return self;
}
- (OSType) pixelFormat {
  switch (bytesPerPixel) {
    case 2: return kYUVSPixelFormat;
    case 3: return k24RGBPixelFormat;
  }
  return k32ARGBPixelFormat;
}
@end
