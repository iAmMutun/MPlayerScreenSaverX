#ifndef _Common_h
#define _Common_h

#import <Cocoa/Cocoa.h>

// define as static so we don't pollute the global scope

static NSString * const BundleIdentifierString = @"th.in.iammutun.MPlayerScreenSaverX";

static void (*DebugError)(const NSString*, ...) = NSLog;
#ifdef DEBUG
static void (*DebugLog)(const NSString*, ...) = NSLog;
#else
__attribute__((unused))
static void DebugLog(const NSString* format, ...) {}
#endif

typedef void* BufferType;

typedef enum
{
  ResultFailed  = NO,
  ResultSuccess = YES
}
ResultType;

#endif
