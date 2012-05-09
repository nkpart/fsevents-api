#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <pthread.h>
// #include <FSEvents.h>

typedef void (*PathCallback)(char *);

typedef struct {
  CFArrayRef pathsToWatch;
  FSEventStreamRef stream;
  pthread_t pthread;
} Watcher;

Watcher *WatcherCreate(char *paths[], int numPaths, PathCallback callback);
void WatcherRelease(Watcher *w);
