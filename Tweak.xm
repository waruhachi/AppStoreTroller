#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

static NSString *iosVersion = nil;
static BOOL updatesEnabled = NO;

%group appstoredHooks

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    if (iosVersion != nil) {
        if (updatesEnabled == YES) {
            if ([field isEqualToString:@"User-Agent"]) {
                // NSLog(@"the spoofed ios is: iOS/%@ ", iosVersion);
                value = [value stringByReplacingOccurrencesOfString:@"iOS/.*? " withString:[NSString stringWithFormat:@"iOS/%@ ", iosVersion] options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
            }
        } else {
            if ([[self.URL absoluteString] containsString:@"WebObjects/MZBuy.woa/wa/buyProduct"]) {
                if ([field isEqualToString:@"User-Agent"]) {
                    // NSLog(@"the spoofed ios is: iOS/%@ ", iosVersion);
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

-(BOOL)_isMinimumOSVersion:(id)arg1 applicableToOSVersion:(id)arg2 requiredOS:(unsigned long long)arg3 error:(id*)arg4
{
    // NSLog(@"arg1: %@ arg2: %@ arg3: %llu", arg1, arg2, arg3);
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

    [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions: @(0644)} ofItemAtPath:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/dev.mineek.appstoretroller.plist") error:nil];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/dev.mineek.appstoretroller.plist")];
    updatesEnabled = [[prefs objectForKey:@"updatesEnabled"] boolValue];
    if (![[prefs objectForKey:@"enabled"] boolValue]) {
        // NSLog(@"[appstoretroller] Not enabled.");
        return;
    }
    iosVersion = [prefs objectForKey:@"iOSVersion"];

    if ([currentProcessName isEqualToString:@"appstored"]) {
        %init(appstoredHooks);
    } else if ([currentProcessName isEqualToString:@"installd"]) {
        %init(installdHooks);
    }
}
