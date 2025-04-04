#include <roothide.h>
#include <Foundation/Foundation.h>
#include <Preferences/PSSpecifier.h>
#include <Preferences/PSListController.h>

@interface AppStoreTrollerRootListController : PSListController
@end

@interface NSTask : NSObject
    @property (copy) NSArray *arguments;
    @property (copy) NSString *launchPath;

    - (id)init;
    - (void)launch;
    - (void)waitUntilExit;
@end
