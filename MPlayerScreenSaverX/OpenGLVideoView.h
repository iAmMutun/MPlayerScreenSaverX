#ifndef _OpenGLVideoView_h
#define _OpenGLVideoView_h

#import "Common.h"
#import "VideoFrameBufferInfo.h"
#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>

@interface OpenGLVideoView : NSOpenGLView
{
  NSSize  imageSize;
  NSPoint textureBound;
  CVOpenGLBufferRef       textureBuffer;
  CVOpenGLTextureCacheRef textureCache;
}

- (id)init;
- (BOOL)isOpaque;
- (ResultType)prepareBuffer:(VideoFrameBufferInfo *)bufferInfo;
- (void)clearBuffer;
- (ResultType)render;

@end
#endif
