#ifndef _ExtentMode_h
#define _ExtentMode_h

#import "Common.h"

@interface ExtentMode : NSObject

@property (readonly) NSString *stringValue;
@property (readonly) NSString *uiString;

+ (instancetype)extentModeFromString:(NSString*)stringValue;
+ (instancetype)defaultMode;
+ (NSArray*)allExtentModes;

- (NSPoint)boundImage:(NSSize)imageSize toScreen:(NSSize)screenSize;

@end
#endif
