#import "VideoListController.h"

@interface VideoListController ()
{
  IBOutlet NSTableView* tableView;
}
@end



@implementation VideoListController

- (void) awakeFromNib
{
  [tableView registerForDraggedTypes:@[VideoListItemTypeString, NSFilenamesPboardType]];
}

- (NSArray *)videos
{
  return [[self arrangedObjects] copy];
}

- (void)addVideo:(NSDictionary *)video
{
  [self addVideos:@[video]];
}

- (void)addVideos:(NSArray *)videos
{
  [self insertVideos:videos atIndex:[[self arrangedObjects] count]];
}

- (void)insertVideo:(NSDictionary *)video atIndex:(NSUInteger)index
{
  [self insertVideos:@[video] atIndex:index];
}

- (void)insertVideos:(NSArray *)videos atIndex:(NSUInteger)index
{
  NSRange range = NSMakeRange(index, [videos count]);
  NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
  [self insertObjects:videos atArrangedObjectIndexes:indexSet];
  [self setSelectionIndexes:indexSet];
}

- (void)clearVideos
{
  NSRange range = NSMakeRange(0, [[self arrangedObjects] count]);
  NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
  [self removeObjectsAtArrangedObjectIndexes:indexSet];
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
{
  NSArray *rows = [self rowsFromIndexSet:rowIndexes];
  [pboard declareTypes:@[VideoListItemTypeString] owner:self];
  [pboard setPropertyList:rows forType:VideoListItemTypeString];
  return YES;
}

- (NSDragOperation)tableView:(NSTableView*)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
  [aTableView setDropRow:row dropOperation:NSTableViewDropAbove];

  if ([info draggingSource] == aTableView)
  {
    return  NSDragOperationMove;
  }
  else
  {
    NSPasteboard* pboard = [info draggingPasteboard];
    NSArray* urls = [pboard propertyListForType:NSFilenamesPboardType];
    if ([urls count] > 0)
      return  NSDragOperationMove;
  }
  
  return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
  if (row < 0)
    row = 0;
  
  NSPasteboard* pboard = [info draggingPasteboard];

  if ([info draggingSource] == aTableView)
  {
    NSArray *rows = [pboard propertyListForType:VideoListItemTypeString];
    NSIndexSet *indexSet = [self indexSetFromRows:rows];
    [self moveFromIndexes:indexSet toIndex:row];
    return YES;
  }
  else
  {
    NSArray* files = [pboard propertyListForType:NSFilenamesPboardType];
    if ([files count] > 0)
    {
      [self dropFiles:files atIndex:row];
      return YES;
    }
  }
  
  return NO;
}

- (NSIndexSet *)indexSetFromRows:(NSArray *)rows
{
  NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
  [rows enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    [indexSet addIndex:[obj intValue]];
  }];
  return indexSet;
}

- (NSArray *)rowsFromIndexSet:(NSIndexSet *)indexSet
{
  NSMutableArray *rows = [NSMutableArray array];
  [indexSet enumerateIndexesUsingBlock:
    ^(NSUInteger idx, BOOL *stop)
  {
    [rows addObject:@(idx)];
  }];
  return rows;
}

- (void)moveFromIndexes:(NSIndexSet *)indexSet toIndex:(NSUInteger)index
{
  __block NSUInteger above = 0;
  [indexSet enumerateIndexesUsingBlock:
    ^(NSUInteger idx, BOOL *stop)
  {
    if (idx < index)
      above++;
  }];
  NSArray *videos = [[self arrangedObjects] objectsAtIndexes:indexSet];
  [self removeObjectsAtArrangedObjectIndexes:indexSet];
  [self insertVideos:videos atIndex:index - above];
}
     
- (void)dropFiles:(NSArray *)files atIndex:(NSUInteger)index
{
  NSMutableArray *videos = [NSMutableArray array];
  [files enumerateObjectsUsingBlock:
    ^(id obj, NSUInteger idx, BOOL *stop)
  {
    NSString* path = obj;
    [videos addObject:@{DefaultVideoPathKey: path}];
  }];
  [self insertVideos:videos atIndex:index];
}

@end
