#ifndef _ExtentMode_h
#define _ExtentMode_h

#import "Common.h"

typedef enum
{
  ExtentFit,
  ExtentFill,
  ExtentStretch,
  ExtentCenter
}
ExtentModeEnum;

@interface ExtentMode : NSObject

@property (readonly) ExtentModeEnum enumValue;
@property (readonly) NSString *stringValue;
@property (readonly) NSString *uiString;

+ (instancetype)extentModeWithEnum:(ExtentModeEnum)enumValue;
+ (instancetype)extentModeWithString:(NSString*)stringValue;
+ (instancetype)defaultMode;
+ (NSArray*)allExtentModes;

- (NSPoint)boundImage:(NSSize)imageSize toScreen:(NSSize)screenSize;

@end
#endif
