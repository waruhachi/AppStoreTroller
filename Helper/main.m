#include "TSUtil.h"

#include <stdio.h>
#include <roothide.h>
#include <Foundation/Foundation.h>

@interface NSTask : NSObject
    @property (copy) NSArray *arguments;
    @property (copy) NSString *launchPath;

    - (id)init;
    - (void)launch;
    - (void)waitUntilExit;
@end


int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
        if (getuid() == 501) {
            spawnRoot(jbroot(@"/usr/local/bin/AppStoreTrollerKiller"), nil, nil, nil);
            exit(0);
        }

        killall(@"appstored", NO);
        killall(@"installd", YES);
        killall(@"AppStore", YES);

        exit(0);
	}
}
