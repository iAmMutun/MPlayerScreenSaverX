#ifndef _VideoListController_h
#define _VideoListController_h

#import "Common.h"
#import <Cocoa/Cocoa.h>

@interface VideoListController : NSArrayController
{
  IBOutlet NSTableView* tableView;
}

- (void)awakeFromNib;

- (NSArray *)videos;
- (void)addVideo:(NSDictionary *)video;
- (void)addVideos:(NSArray *)videos;
- (void)insertVideo:(NSDictionary *)video atIndex:(NSUInteger)index;
- (void)insertVideos:(NSArray *)videos atIndex:(NSUInteger)index;
- (void)clearVideos;

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;
- (BOOL)tableView:(NSTableView*)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation;

- (void)moveFromIndexes:(NSIndexSet *)indexSet toIndex:(NSUInteger)index;
- (void)dropFiles:(NSArray *)files atIndex:(NSUInteger)index;
- (NSIndexSet *)indexSetFromRows:(NSArray *)rows;
- (NSArray *)rowsFromIndexSet:(NSIndexSet *)indexSet;

@end
#endif