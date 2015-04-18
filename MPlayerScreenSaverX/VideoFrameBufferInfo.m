#import "VideoFrameBufferInfo.h"

@implementation VideoFrameBufferInfo

@synthesize frameBuffer;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize bufferCount;
@synthesize pixelFormat;

- (id) initWithWidth:(NSUInteger)width
              height:(NSUInteger)height
         bufferCount:(NSUInteger)count
         pixelFormat:(OSType)format
{
  self = [super init];
  if (self)
  {
    frameBuffer = nil;
    imageWidth = width;
    imageHeight = height;
    pixelFormat = format;
    bufferCount = count;
  }
  return self;
}

- (NSUInteger)bytesPerPixel
{
  switch (pixelFormat)
  {
    case kYUVSPixelFormat:   return 2;
    case k24RGBPixelFormat:  return 3;
    case k32ARGBPixelFormat:
    case k32BGRAPixelFormat: return 4;
    default: return 0;
  }
}

- (NSUInteger)bufferSize
{
  return [self bytesPerPixel] * imageWidth * imageHeight;
}

- (NSUInteger)totalBufferSize
{
  return [self bufferSize] * bufferCount;
}
@end
