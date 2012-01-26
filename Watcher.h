#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>

@interface Watcher : NSObject {
  NSArray *pathsToWatch;
}

- (id)initWithPaths:(NSArray *)ps;
- (void)eventOccurredOnPath:(char *)path;
@end

void WatcherCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]); 
