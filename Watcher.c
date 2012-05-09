#include "Watcher.h"

typedef signed char     BOOL; 
// BOOL is explicitly signed so @encode(BOOL) == "c" rather than "C" 
// even if -funsigned-char is used.
#define OBJC_BOOL_DEFINED
#define YES             (BOOL)1
#define NO              (BOOL)0

void *WatcherMain(void *d) {
  Watcher w = *(Watcher *)d;
  BOOL done = NO;
  CFRunLoopRef runLoop = CFRunLoopGetCurrent();
  FSEventStreamScheduleWithRunLoop(w.stream, runLoop, kCFRunLoopDefaultMode);
  BOOL started = FSEventStreamStart(w.stream);
  do {
    SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
    if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
      done = YES;
  } while (!done);
  return NULL;
}

void WatcherCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) {
  int i;
  char **paths = eventPaths;
  PathCallback cb = clientCallBackInfo;
  for (i = 0; i < numEvents; ++i) {
    cb(paths[i]);
  }
}

CFMutableArrayRef CreatePathsArray(char *paths[], int numPaths) {
  int i;
  CFMutableArrayRef paths_ = CFArrayCreateMutable(NULL, numPaths, NULL);
  for (i = 0; i < numPaths; i++) {
    CFStringRef str = CFStringCreateWithCString(NULL, paths[i], kCFStringEncodingUTF8);
    CFArrayAppendValue(paths_, str);
    CFRelease(str);
  }
  return paths_;
}

void StartWatcher(Watcher *watcher) {
  pthread_attr_t  attr;
  pthread_t       posixThreadID;
  int             returnVal;

  returnVal = pthread_attr_init(&attr);
  assert(!returnVal);
  returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  assert(!returnVal);

  int     threadError = pthread_create(&posixThreadID, &attr, &WatcherMain, watcher);

  returnVal = pthread_attr_destroy(&attr);
  assert(!returnVal);

  watcher->pthread = posixThreadID;
  if (threadError != 0)
  {
       // Report an error.
  }
}

void CancelWatcher(Watcher *w) {
  pthread_cancel(w->pthread);
}


Watcher *WatcherCreate(char *paths[], int numPaths, PathCallback callback) {
  int i;
  CFMutableArrayRef paths_ = CreatePathsArray(paths, numPaths);
  Watcher *watcher = malloc(sizeof *watcher);
  watcher->pathsToWatch = paths_;
  FSEventStreamContext context = {};
  context.info = callback;
  watcher->stream = FSEventStreamCreate(NULL, &WatcherCallback, &context, paths_, kFSEventStreamEventIdSinceNow, 2, 0);
  StartWatcher(watcher);
  return watcher;
}


void WatcherRelease(Watcher *w) {
  CancelWatcher(w);
  FSEventStreamRelease(w->stream);
  CFRelease(w->pathsToWatch);
}

