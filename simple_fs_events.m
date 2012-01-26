#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>

@interface Watcher : NSObject {
  NSArray *pathsToWatch;
}

- (void)eventOccurredOnPath:(char *)path;
@end

void callback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) {
  int i;
  char **paths = eventPaths;
  Watcher *watcher = clientCallBackInfo;
  for (i = 0; i < numEvents; ++i) {
    [watcher eventOccurredOnPath:paths[i]];
  }
}

@implementation Watcher

- (id)initWithPaths:(NSArray *)ps {
  if ((self = [super init])) {
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
}

- (void)threadMain {
  BOOL done = NO;
  CFArrayRef paths = (CFArrayRef) pathsToWatch;

  FSEventStreamContext context; 
  context.info = self;
  FSEventStreamRef stream = FSEventStreamCreate(NULL, &callback, &context, paths, kFSEventStreamEventIdSinceNow, 2, 0);
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

int main() {
  NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
  Watcher *foo = [[Watcher alloc] initWithPaths:[NSArray arrayWithObjects:@"/", nil]];
  [NSThread detachNewThreadSelector:@selector(threadMain) toTarget:foo withObject:nil];
  [foo release];
  sleep(50);
  [p release];
}

