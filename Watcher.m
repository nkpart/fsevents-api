#import "Watcher.h"

void WatcherCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) {
  int i;
  char **paths = eventPaths;
  Watcher *watcher = clientCallBackInfo;
  for (i = 0; i < numEvents; ++i) {
    [watcher eventOccurredOnPath:paths[i]];
  }
}

Watcher *WatcherCreate(char *paths[], int numPaths, PathCallback callback) {
  int i;
  NSLog(@"Starting. %d", numPaths);
  NSMutableArray *paths_ = [[NSMutableArray alloc] initWithCapacity:numPaths];
  for (i = 0; i < numPaths; i++) {
    NSString *s = [[NSString alloc] initWithCString:paths[i] encoding:[NSString defaultCStringEncoding]];
    [paths_ addObject:s];
    [s release];
  }
  Watcher *watcher = [[Watcher alloc] initWithPaths:paths_ callback:callback];
  [paths_ release];
  [watcher start];
  return watcher;
}

void WatcherRelease(Watcher *w) {
  [w cancel];
  [w release];
}

@implementation Watcher

- (id)initWithPaths:(NSArray *)ps callback:(PathCallback)cb {
  if ((self = [super init])) {
    callback = cb;
    pathsToWatch = [ps retain];
  }
  return self;
}

- (void)dealloc {
  [pathsToWatch release];
  [super dealloc];
}

- (void)eventOccurredOnPath:(char *)path {
    NSLog(@"%s", path);
    callback(path);
}

- (void)main {
  BOOL done = NO;
  CFArrayRef paths = (CFArrayRef) pathsToWatch;

  FSEventStreamContext context; 
  context.info = self;
  FSEventStreamRef stream = FSEventStreamCreate(NULL, &WatcherCallback, &context, paths, kFSEventStreamEventIdSinceNow, 2, 0);
  CFRunLoopRef runLoop = CFRunLoopGetCurrent();
  FSEventStreamScheduleWithRunLoop(stream, runLoop, kCFRunLoopDefaultMode);
  BOOL started = FSEventStreamStart(stream);
  CFRelease(paths);

  do {
    SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
    if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
      done = YES;
  } while (!done);
  FSEventStreamRelease(stream);
}
@end

