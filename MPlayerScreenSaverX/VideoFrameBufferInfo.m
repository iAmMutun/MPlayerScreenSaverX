#import "VideoFrameBufferInfo.h"

@implementation VideoFrameBufferInfo

@synthesize buffer;
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
    buffer = nil;
    imageWidth = width;
    imageHeight = height;
    pixelFormat = format;
    bufferCount = count;
  }
  return self;
}

- (BufferType)frameBuffer:(NSUInteger)frame
{
  return buffer + [self frameSize] * frame;
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

- (NSUInteger)frameSize
{
  return [self bytesPerPixel] * imageWidth * imageHeight;
}

- (NSUInteger)bufferSize
{
  return [self frameSize] * bufferCount;
}
@end
