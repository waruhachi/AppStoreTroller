#include <roothide.h>
#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>

@interface MIBundle : NSObject
- (BOOL)isWatchApp;
@end

static BOOL enabled;
static BOOL updatesEnabled;
static NSString *iosVersion;
