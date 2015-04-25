#ifndef _MPlayerLaunchInfo_h
#define _MPlayerLaunchInfo_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface MPlayerLaunchInfo : NSObject

@property (readonly) NSString *executablePath;
@property (readonly) NSString *sharedId;
@property (readonly) NSArray  *arguments;
@property (readonly) NSDictionary *environment;

- (void)refresh;

@end
#endif
