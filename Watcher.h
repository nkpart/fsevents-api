#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>

@interface Watcher : NSThread {
  NSArray *pathsToWatch;
}

- (id)initWithPaths:(NSArray *)ps;
- (void)eventOccurredOnPath:(char *)path;
@end

Watcher *WatcherCreate(char *paths[], int numPaths);
