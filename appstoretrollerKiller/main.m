#include <stdio.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
#import "TSUtil.h"

@interface NSTask : NSObject
@property (copy) NSArray *arguments;
@property (copy) NSString *launchPath;
- (id)init;
- (void)waitUntilExit;
- (void)launch;
@end


int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
        if (getuid() == 501) {
            spawnRoot(ROOT_PATH_NS(@"/usr/local/bin/appstoretrollerKiller"), nil, nil, nil);
            exit(0);
        }
        killall(@"appstored", NO);
        killall(@"installd", YES);
        killall(@"AppStore", YES);
        exit(0);
	}
}
