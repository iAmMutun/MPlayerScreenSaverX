#import "SharedMemoryMapper.h"
#import <sys/mman.h>

@implementation SharedMemoryMapper

@synthesize bytes;

- (id)initWithName:(NSString *)memoryName
{
  self = [super init];
  if (self)
    name = [memoryName copy];
  return self;
}

- (ResultType)share:(NSUInteger)size {
  DebugLog(@"Mapping shared memory [%@]", name);
  length = size;
  int shared_memory_id = shm_open([name cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY, S_IRUSR);
  if (shared_memory_id == -1) {
    DebugError(@"Shared memory mapping failed [shm_open]");
    return ResultFailed;
  }
  bytes = mmap(NULL, (size_t)length, PROT_READ, MAP_SHARED, shared_memory_id, 0);
  close(shared_memory_id);
  if (bytes == MAP_FAILED) {
    bytes = NULL;
    DebugError(@"Shared memory mapping failed [mmap]");
    return ResultFailed;
  }
  return ResultSuccess;
}

- (ResultType)unshare
{
  DebugLog(@"Unmapping shared memory [%@]", name);
	if (bytes) {
		if (munmap(bytes, length) != 0) {
      DebugError(@"Shared memory unmapping failed");
      return ResultFailed;
    }
    bytes = NULL;
	}
  return ResultSuccess;
}
@end
