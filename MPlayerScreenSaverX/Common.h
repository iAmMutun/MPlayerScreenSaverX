#ifndef _Common_h
#define _Common_h

#import <Cocoa/Cocoa.h>

// static to avoid conflict
static void (*DebugError)(const NSString*, ...) = NSLog;
#ifdef DEBUG
static void (*DebugLog)(const NSString*, ...) = NSLog;
#else
__attribute__((unused))
static void DebugLog(const NSString* format, ...) {}
#endif

typedef void * BufferType;

typedef NSInteger ResultType;

extern const ResultType ResultSuccess;
extern const ResultType ResultFailed;

extern NSString * const BundleIdentifierString;
extern NSString * const VideoListItemTypeString;
extern NSString * const SharedIdentifierPrefixString;

extern NSString * const DefaultVideoListKey;
extern NSString * const DefaultVideoPathKey;
extern NSString * const DefaultMuteKey;
extern NSString * const DefaultVolumeKey;
extern NSString * const DefaultExtentKey;

extern NSString * const FitToScreenKey;
extern NSString * const FillScreenKey;
extern NSString * const StretchToScreenKey;
extern NSString * const CenterToScreenKey;
extern NSString * const DefaultShuffleKey;
#endif
