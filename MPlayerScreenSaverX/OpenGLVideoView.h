#ifndef _OpenGLVideoView_h
#define _OpenGLVideoView_h

#import "Common.h"
#import <Cocoa/Cocoa.h>
#import "VideoFrameBufferInfo.h"

@interface OpenGLVideoView : NSOpenGLView

- (ResultType)prepareBuffer:(VideoFrameBufferInfo *)bufferInfo;
- (ResultType)render:(NSUInteger)frame;
- (void)clearBuffer;

@end
#endif
