#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSUserDefaults *prefs;

%group appstoredHooks

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    if ([[self.URL absoluteString] containsString:@"WebObjects/MZBuy.woa/wa/buyProduct"]) {
        if ([field isEqualToString:@"User-Agent"]) {
            value = [value stringByReplacingOccurrencesOfString:@"iOS/.*? " withString:@"iOS/99.0.0 " options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
        }
    }
    %orig(value, field);
}

%end

%end

%ctor {
    prefs = [[NSUserDefaults alloc] initWithSuiteName:@"dev.mineek.appstoretroller"];
    if (![prefs boolForKey:@"enabled"]) {
        return;
    }
    %init(appstoredHooks);
}
