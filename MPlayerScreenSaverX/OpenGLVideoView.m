#import "OpenGLVideoView.h"
#import <OpenGL/gl.h>
#import <ScreenSaver/ScreenSaver.h>

@implementation OpenGLVideoView
- (id)init
{
  DebugLog(@"Initializing OpenGL");
  NSOpenGLPixelFormatAttribute attributes[] = {
    NSOpenGLPFAAccelerated, NSOpenGLPFADoubleBuffer,
    NSOpenGLPFABackingStore, NO,
    NSOpenGLPFAMaximumPolicy, 0};
  NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
  self = [super initWithFrame:NSZeroRect pixelFormat:format];
  format = nil;
  if (self) {
    imageSize.width  = 0;
    imageSize.height = 0;
    textureBuffer = nil;
    textureCache  = nil;
    glClearColor(0, 0, 0, 0);
    const GLint swapInterval = 1;
    [self.openGLContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
  }
  return self;
}

- (BOOL)isOpaque { return NO; }

- (ResultType)prepareBuffer:(VideoFrameBufferInfo *)bufferInfo
{
  DebugLog(@"Setting up OpenGL buffer");
  
  imageSize.width   = [bufferInfo imageWidth];
  imageSize.height  = [bufferInfo imageHeight];

  CVReturn result = CVPixelBufferCreateWithBytes(NULL, imageSize.width, imageSize.height, [bufferInfo pixelFormat], [bufferInfo frameBuffer],
                                                 imageSize.width * [bufferInfo bytesPerPixel], NULL, NULL, NULL, &textureBuffer);
  if (result != kCVReturnSuccess) {
    DebugError(@"Frame buffer creation failed");
    return ResultFailed;
  }
  CGLContextObj context = [self.openGLContext CGLContextObj];
  result = CVOpenGLTextureCacheCreate(NULL, NULL, context, CGLGetPixelFormat(context), NULL, &textureCache);
  if (result != kCVReturnSuccess) {
    DebugError(@"Texture cache creation failed");
    return ResultFailed;
  }

  NSSize screenSize = [self bounds].size;
  CGFloat screenAspect = screenSize.width / screenSize.height;
  CGFloat imageAspect = imageSize.width / imageSize.height;

  textureBound.x = 1.0;
  textureBound.y = 1.0;

  ScreenSaverDefaults *userDefaults = [ScreenSaverDefaults defaultsForModuleWithName:BundleIdentifierString];
  NSString *extentMode = [userDefaults stringForKey:DefaultExtentKey];

  DebugLog(@"Extent mode: %@", extentMode);

  if([extentMode isEqualToString:FitToScreenKey]) {
    if (imageAspect > screenAspect)
      textureBound.y = screenAspect / imageAspect;
    else if (imageAspect < screenAspect)
      textureBound.x = imageAspect / screenAspect;
  } else if ([extentMode isEqualToString:FillScreenKey]) {
    if (imageAspect > screenAspect)
      textureBound.x = imageAspect / screenAspect;
    else if (imageAspect < screenAspect)
      textureBound.y = screenAspect / imageAspect ;
  } else if ([extentMode isEqualToString:CenterToScreenKey]) {
    textureBound.x = imageSize.width  / screenSize.width;
    textureBound.y = imageSize.height / screenSize.height;
  }

  return ResultSuccess;
}

- (void)clearBuffer
{
  DebugLog(@"Cleaning up OpenGL buffer");
  if (textureCache) {
    CVOpenGLTextureCacheRelease(textureCache);
    textureCache = NULL;
  }
  if (textureBuffer) {
    CVOpenGLBufferRelease(textureBuffer);
    textureBuffer = NULL;
  }
}

- (ResultType)render
{
  [self.openGLContext makeCurrentContext];
  glClear(GL_COLOR_BUFFER_BIT);
  if (textureBuffer) {
    CVOpenGLTextureRef texture;
		CVReturn result = CVOpenGLTextureCacheCreateTextureFromImage(NULL, textureCache, textureBuffer, NULL, &texture);
    if (result != kCVReturnSuccess) {
      [self.openGLContext flushBuffer];
      return ResultFailed;
    }

    GLenum target = CVOpenGLTextureGetTarget(texture);    
    glEnable(target);
    glBindTexture(target, CVOpenGLTextureGetName(texture));

    glBegin(GL_QUADS);
    glTexCoord2f(              0,                0); glVertex2f(-textureBound.x,  textureBound.y);
    glTexCoord2f(              0, imageSize.height); glVertex2f(-textureBound.x, -textureBound.y);
    glTexCoord2f(imageSize.width, imageSize.height); glVertex2f( textureBound.x, -textureBound.y);
    glTexCoord2f(imageSize.width,                0); glVertex2f( textureBound.x,  textureBound.y);
    glEnd();

    glDisable(target);

    CVOpenGLTextureRelease(texture);
  }
  [self.openGLContext flushBuffer];
  return ResultSuccess;
}
@end
