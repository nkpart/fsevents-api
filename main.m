#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>

#import "Watcher.h"

int main() {
  NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
  Watcher *foo = [[Watcher alloc] initWithPaths:[NSArray arrayWithObjects:@"/", nil]];
  [NSThread detachNewThreadSelector:@selector(threadMain) toTarget:foo withObject:nil];
  [foo release];
  sleep(50);
  [p release];
}
