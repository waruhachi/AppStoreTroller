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