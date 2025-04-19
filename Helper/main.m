#include "TSUtil.h"

#include <stdio.h>
#include <roothide.h>
#include <Foundation/Foundation.h>

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
        if (getuid() == 501) {
            if (argc > 1 && strcmp(argv[1], "--child") == 0) {
                exit(1);
            }

            spawnRoot(jbroot(@"/usr/local/bin/AppStoreTrollerKiller"), nil, nil, nil);
            exit(0);
        }

        killall(@"appstored", NO);
        killall(@"installd", YES);
        killall(@"AppStore", YES);

        exit(0);
	}
}
