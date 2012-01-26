#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>

typedef void (*PathCallback)(char *);

@interface Watcher : NSThread {
  NSArray *pathsToWatch;
  PathCallback callback;
}

- (id)initWithPaths:(NSArray *)ps callback:(PathCallback)cb;
- (void)eventOccurredOnPath:(char *)path;
@end

Watcher *WatcherCreate(char *paths[], int numPaths, PathCallback callback);
void WatcherRelease(Watcher *w);
