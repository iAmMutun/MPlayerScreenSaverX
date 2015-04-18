#import "ExtentModeController.h"

@implementation ExtentModeController

- (void) awakeFromNib
{
  NSArray *keys = @[FitToScreenKey, FillScreenKey, StretchToScreenKey, CenterToScreenKey];
  
  NSBundle *bundle = [NSBundle bundleWithIdentifier:BundleIdentifierString];
  NSString *file = [bundle pathForResource:@"Extent" ofType:@"strings"];
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

  [keys enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    NSString *key = (NSString *)obj;
    NSString *label = dict[key];
    if (label == nil)
      label = key;
    [self addObject:@{@"Key":key, @"Label":label}];
  }];
}

- (NSString *)extentMode
{
  return [(NSDictionary*)[self selection] valueForKey:@"Key"];
}

- (void)setExtentMode:(NSString *) mode
{
  [[self arrangedObjects] enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    if ([mode compare:[(NSDictionary*)obj valueForKey:@"Key"]] == NSOrderedSame)
    {
      [self setSelectionIndex:idx];
      *stop = YES;
    }
  }];
}

@end
