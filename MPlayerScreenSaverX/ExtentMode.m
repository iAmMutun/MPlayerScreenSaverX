#import "ExtentMode.h"

static NSString * const FitToScreenKey      = @"Fit";
static NSString * const FillScreenKey       = @"Fill";
static NSString * const StretchToScreenKey  = @"Stretch";
static NSString * const CenterToScreenKey   = @"Center";

static NSArray* _extentModes = nil;
static NSMutableDictionary* _extentModesDict = nil;
static NSString* stringExtentFromEnum(ExtentModeEnum enumValue);
static void populateExtentsMode();



@interface ExtentMode ()

- (id)initWithEnum:(ExtentModeEnum)enumValue uiStringDict:(NSDictionary *)dict;

@end



@implementation ExtentMode

+ (instancetype)extentModeWithEnum:(ExtentModeEnum)enumValue
{
  if (_extentModes == nil)
    populateExtentsMode();
  return [_extentModesDict valueForKey:stringExtentFromEnum(enumValue)];
}

+ (instancetype)extentModeWithString:(NSString*)stringValue
{
  if (_extentModes == nil)
    populateExtentsMode();
  return [_extentModesDict valueForKey:stringValue];
}

+ (instancetype)defaultMode
{
  return [ExtentMode extentModeWithEnum:ExtentFit];
}

+ (NSArray*)allExtentModes
{
  if (_extentModes == nil)
    populateExtentsMode();
  return _extentModes;
}

- (id)initWithEnum:(ExtentModeEnum)enumValue uiStringDict:(NSDictionary *)dict
{
  self = [super init];
  if (self)
  {
    _enumValue = enumValue;
    _stringValue = stringExtentFromEnum(enumValue);
    _uiString = [dict objectForKey:_stringValue];
    _extentModesDict[_stringValue] = self;
  }
  return self;
}

- (NSPoint)boundImage:(NSSize)imageSize toScreen:(NSSize)screenSize
{
  NSPoint outBound = {1.0, 1.0};
  CGFloat screenAspect = screenSize.width / screenSize.height;
  CGFloat imageAspect = imageSize.width / imageSize.height;
  
  if(_enumValue == ExtentFit)
  {
    if (imageAspect > screenAspect)
      outBound.y = screenAspect / imageAspect;
    else if (imageAspect < screenAspect)
      outBound.x = imageAspect / screenAspect;
  }
  else if (_enumValue == ExtentFill)
  {
    if (imageAspect > screenAspect)
      outBound.x = imageAspect / screenAspect;
    else if (imageAspect < screenAspect)
      outBound.y = screenAspect / imageAspect ;
  }
  else if (_enumValue == ExtentCenter)
  {
    outBound.x = imageSize.width  / screenSize.width;
    outBound.y = imageSize.height / screenSize.height;
  }
  /*
  else if (_enumValue == ExtentStretch)
  {
    outBound.x = outBound.y = 1.0;
  }
  */
  return outBound;
}

@end



void populateExtentsMode()
{
  NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
  NSString *file = [bundle pathForResource:@"Extent" ofType:@"strings"];
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

  _extentModesDict = [NSMutableDictionary dictionary];
  _extentModes = @[
    [[ExtentMode alloc] initWithEnum:ExtentFit uiStringDict:dict],
    [[ExtentMode alloc] initWithEnum:ExtentFill uiStringDict:dict],
    [[ExtentMode alloc] initWithEnum:ExtentStretch uiStringDict:dict],
    [[ExtentMode alloc] initWithEnum:ExtentCenter uiStringDict:dict],
  ];
}

NSString *stringExtentFromEnum(ExtentModeEnum enumValue)
{
  if (enumValue == ExtentFit)
    return FitToScreenKey;
  
  else
  if (enumValue == ExtentFill)
    return FillScreenKey;

  else
  if (enumValue == ExtentStretch)
    return StretchToScreenKey;

  else
  if (enumValue == ExtentCenter)
    return CenterToScreenKey;
  
  return FitToScreenKey;
}
