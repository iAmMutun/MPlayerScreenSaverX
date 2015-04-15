#import "VideoFrameBufferInfo.h"

@implementation VideoFrameBufferInfo

@synthesize frameBuffer;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize bytesPerPixel;
@synthesize pixelFormat;

- (id) initWithBuffer:(BufferType)buffer
                width:(NSUInteger)width
               height:(NSUInteger)height
                bytes:(NSUInteger)bytes
{
  self = [super init];
  if (self)
  {
    frameBuffer = buffer;
    imageWidth = width;
    imageHeight = height;
    bytesPerPixel = bytes;
    switch (bytesPerPixel)
    {
      case 2:   pixelFormat = kYUVSPixelFormat;   break;
      case 3:   pixelFormat = k24RGBPixelFormat;  break;
      default:  pixelFormat = k32ARGBPixelFormat; break;
    }
  }
  return self;
}
@end
