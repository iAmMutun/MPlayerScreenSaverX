#ifndef _ExtentModeController_h
#define _ExtentModeController_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface ExtentModeController : NSArrayController
{
}

- (void)awakeFromNib;

- (NSString *)extentMode;
- (void)setExtentMode:(NSString *)mode;

@end
#endif