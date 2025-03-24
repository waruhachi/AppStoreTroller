#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSUserDefaults *prefs;

static NSString *iosVersion;

%group appstoredHooks

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    if (iosVersion != nil) {
        if ([field isEqualToString:@"User-Agent"]) {
            // NSLog(@"the spoofed ios is: iOS/%@ ", iosVersion);
            value = [value stringByReplacingOccurrencesOfString:@"iOS/.*? " withString:[NSString stringWithFormat:@"iOS/%@ ", iosVersion] options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
        }
    }
    %orig(value, field);
}

%end

%end

%group installdHooks

%hook MIBundle

-(BOOL)_isMinimumOSVersion:(id)arg1 applicableToOSVersion:(id)arg2 requiredOS:(unsigned long long)arg3 error:(id*)arg4
{
	return true;
}

%end

%end

%ctor {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    
    NSString *currentProcessName = [processInfo processName];
    if ([currentProcessName isEqualToString:@"appstored"]) {
        prefs = [[NSUserDefaults alloc] initWithSuiteName:@"dev.mineek.appstoretroller"];
        if (![prefs boolForKey:@"enabled"]) {
            return;
        }
        iosVersion = [prefs stringForKey:@"iOSVersion"];
        %init(appstoredHooks);
    } else if ([currentProcessName isEqualToString:@"installd"]) {
        %init(installdHooks);
    }
}
