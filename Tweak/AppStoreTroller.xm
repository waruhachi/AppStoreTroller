#include "AppStoreTroller.h"

%group appstoredHooks

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (iosVersion != nil) {
        if (updatesEnabled == YES) {
            if ([field isEqualToString:@"User-Agent"]) {
                value = [value stringByReplacingOccurrencesOfString:@"iOS/.*? " withString:[NSString stringWithFormat:@"iOS/%@ ", iosVersion] options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
            }
        } else {
            if ([[self.URL absoluteString] containsString:@"WebObjects/MZBuy.woa/wa/buyProduct"]) {
                if ([field isEqualToString:@"User-Agent"]) {
                    value = [value stringByReplacingOccurrencesOfString:@"iOS/.*? " withString:[NSString stringWithFormat:@"iOS/%@ ", iosVersion] options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
                }
            }
        }
    }

    %orig(value, field);
}

%end

%end

%group installdHooks

%hook MIBundle

- (BOOL)_isMinimumOSVersion:(id)arg1 applicableToOSVersion:(id)arg2 requiredOS:(unsigned long long)arg3 error:(id*)arg4 {
    if (iosVersion != nil) {
	    return %orig(arg1, iosVersion, arg3, arg4);
    } else {
        return %orig(arg1, arg2, arg3, arg4);
    }
}

%end

%end

%ctor {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *currentProcessName = [processInfo processName];
    NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:@"dev.mineek.appstoretroller.preferences"];

    enabled = [preferences objectForKey:@"enabled"] ? [preferences boolForKey:@"enabled"] : NO;
    updatesEnabled = [preferences objectForKey:@"updatesEnabled"] ? [preferences boolForKey:@"updatesEnabled"] : NO;
    iosVersion = [preferences objectForKey:@"iOSVersion"] ? [preferences stringForKey:@"iOSVersion"] : @"";

    if (!enabled) {
        return;
    }

    if ([currentProcessName isEqualToString:@"appstored"]) {
        %init(appstoredHooks);
    } else if ([currentProcessName isEqualToString:@"installd"]) {
        %init(installdHooks);
    }
}
