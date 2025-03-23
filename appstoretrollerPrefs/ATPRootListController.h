#import <Preferences/PSListController.h>

@interface ATPRootListController : PSListController

@end

@interface NSTask : NSObject
@property (copy) NSArray *arguments;
@property (copy) NSString *launchPath;
- (id)init;
- (void)waitUntilExit;
- (void)launch;
@end
