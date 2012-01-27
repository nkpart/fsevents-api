#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>

#import "Watcher.h"

int main() {
  char *paths[] = { "/" };
  Watcher *w = WatcherCreate(paths, 1);
  sleep(50);
  WatcherRelease(w);
}
