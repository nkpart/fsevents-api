#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>

#import "Watcher.h"

void watch(char *path) {
  NSLog(@"Event: %s", path);
}

int main() {
  char *paths[] = { "/" };
  Watcher *w = WatcherCreate(paths, 1, &watch);
  sleep(50);
  WatcherRelease(w);
}
