#import "OpenGLVideoView.h"
#import <OpenGL/gl.h>
#import <ScreenSaver/ScreenSaver.h>
#import <CoreVideo/CoreVideo.h>

@interface OpenGLVideoView ()
{
  NSSize  _imgSize;
  NSPoint _bound;
  NSUInteger _bufferCount;
  CVOpenGLBufferRef     * _buffers;
  CVOpenGLTextureCacheRef _cache;
}
@end



@implementation OpenGLVideoView
- (id)init
{
  DebugLog(@"Initializing OpenGL");
  NSOpenGLPixelFormatAttribute attributes[] = {
    NSOpenGLPFAAccelerated, NSOpenGLPFADoubleBuffer,
    NSOpenGLPFABackingStore, NO,
    NSOpenGLPFAMaximumPolicy, 0};
  NSOpenGLPixelFormat *format =
    [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
  self = [super initWithFrame:NSZeroRect pixelFormat:format];
  format = nil;
  if (self)
  {
    _imgSize.width  = 0;
    _imgSize.height = 0;
    _buffers = nil;
    _cache  = nil;
    glClearColor(0, 0, 0, 0);
    const GLint swapInterval = 1;
    [self.openGLContext setValues:&swapInterval
                     forParameter:NSOpenGLCPSwapInterval];
  }
  return self;
}

- (BOOL)isOpaque { return NO; }

- (ResultType)prepareBuffer:(VideoFrameBufferInfo *)bufferInfo
{
  DebugLog(@"Setting up OpenGL buffer");
  
  _imgSize.width   = [bufferInfo imageWidth];
  _imgSize.height  = [bufferInfo imageHeight];
  
  _buffers = malloc([bufferInfo bufferCount] * sizeof(CVOpenGLBufferRef));
  CVReturn result;
  _bufferCount = [bufferInfo bufferCount];
  for (NSUInteger i = 0; i < _bufferCount; i++)
  {
    result = CVPixelBufferCreateWithBytes(
               NULL, _imgSize.width, _imgSize.height,
               [bufferInfo pixelFormat], [bufferInfo frameBuffer],
               _imgSize.width * [bufferInfo bytesPerPixel],
               NULL, NULL, NULL, &_buffers[i]);
    if (result != kCVReturnSuccess)
    {
      DebugError(@"Frame buffer creation failed");
      return ResultFailed;
    }
  }
  CGLContextObj context = [self.openGLContext CGLContextObj];
  result = CVOpenGLTextureCacheCreate(NULL, NULL, context,
             CGLGetPixelFormat(context), NULL, &_cache);
  if (result != kCVReturnSuccess)
  {
    DebugError(@"Texture cache creation failed");
    return ResultFailed;
  }

  NSSize screenSize = [self bounds].size;
  CGFloat screenAspect = screenSize.width / screenSize.height;
  CGFloat imageAspect = _imgSize.width / _imgSize.height;

  _bound.x = 1.0;
  _bound.y = 1.0;

  ScreenSaverDefaults *userDefaults =
    [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  NSString *extentMode = [userDefaults stringForKey:DefaultExtentKey];

  DebugLog(@"Extent mode: %@", extentMode);

  if([extentMode isEqualToString:FitToScreenKey])
  {
    if (imageAspect > screenAspect)
      _bound.y = screenAspect / imageAspect;
    else if (imageAspect < screenAspect)
      _bound.x = imageAspect / screenAspect;
  }
  else if ([extentMode isEqualToString:FillScreenKey])
  {
    if (imageAspect > screenAspect)
      _bound.x = imageAspect / screenAspect;
    else if (imageAspect < screenAspect)
      _bound.y = screenAspect / imageAspect ;
  }
  else if ([extentMode isEqualToString:CenterToScreenKey])
  {
    _bound.x = _imgSize.width  / screenSize.width;
    _bound.y = _imgSize.height / screenSize.height;
  }

  return ResultSuccess;
}

- (void)clearBuffer
{
  DebugLog(@"Cleaning up OpenGL buffer");
  if (_cache)
  {
    CVOpenGLTextureCacheRelease(_cache);
    _cache = NULL;
  }
  if (_buffers)
  {
    for (NSUInteger i = 0; i < _bufferCount; i++)
    {
      CVOpenGLBufferRelease(_buffers[i]);
    }
    free(_buffers);
    _buffers = NULL;
  }
}

- (ResultType)render:(NSUInteger)frame
{
  [self.openGLContext makeCurrentContext];
  glClear(GL_COLOR_BUFFER_BIT);
  if (frame < _bufferCount && _buffers[frame])
  {
    CVOpenGLTextureRef texture;
    CVReturn result = CVOpenGLTextureCacheCreateTextureFromImage(
                        NULL, _cache, _buffers[frame], NULL, &texture);
    if (result != kCVReturnSuccess)
    {
      [self.openGLContext flushBuffer];
      return ResultFailed;
    }

    GLenum target = CVOpenGLTextureGetTarget(texture);    
    glEnable(target);
    glBindTexture(target, CVOpenGLTextureGetName(texture));

    glBegin(GL_QUADS);
    glTexCoord2f(             0,               0); glVertex2f(-_bound.x,  _bound.y);
    glTexCoord2f(             0, _imgSize.height); glVertex2f(-_bound.x, -_bound.y);
    glTexCoord2f(_imgSize.width, _imgSize.height); glVertex2f( _bound.x, -_bound.y);
    glTexCoord2f(_imgSize.width,               0); glVertex2f( _bound.x,  _bound.y);
    glEnd();

    glDisable(target);

    CVOpenGLTextureRelease(texture);
  }
  [self.openGLContext flushBuffer];
  return ResultSuccess;
}
@end
