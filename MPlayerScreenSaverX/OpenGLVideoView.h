#ifndef _OpenGLVideoView_h
#define _OpenGLVideoView_h

#import "Common.h"
#import "VideoFrameBufferInfo.h"

@interface OpenGLVideoView : NSOpenGLView

- (ResultType)prepareBuffer:(VideoFrameBufferInfo *)bufferInfo;
- (ResultType)render:(NSNumber*)frame;
- (void)clearBuffer;

@end
#endif
