#import <Foundation/Foundation.h>
#import "ATPRootListController.h"

@implementation ATPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
	self.navigationItem.rightBarButtonItem = respringButton;
}

- (void)respring {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.isKeyWindow) {
            [window endEditing:YES];
            break;
        }
    }
    
    if (access(THEOS_PACKAGE_INSTALL_PREFIX "/var/mobile/Library/Preferences/dev.mineek.appstoretroller.plist", F_OK)) {
        NSString *prefsPath = @THEOS_PACKAGE_INSTALL_PREFIX "/var/mobile/Library/Preferences/dev.mineek.appstoretroller.plist";
        NSDictionary *placeholder = @{};

        NSData *data = [NSPropertyListSerialization dataWithPropertyList:placeholder
                                                                format:NSPropertyListBinaryFormat_v1_0
                                                               options:0
                                                                 error:nil];
        [data writeToFile:prefsPath atomically:YES];
    }
        
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"dev.mineek.appstoretroller"];
        
    NSString *prefsPath = @THEOS_PACKAGE_INSTALL_PREFIX "/var/mobile/Library/Preferences/dev.mineek.appstoretroller.plist";
    BOOL enabled = [defaults boolForKey:@"enabled"];
    BOOL updatesEnabled = [defaults boolForKey:@"updatesEnabled"];
    NSString *iOSVersion = [defaults stringForKey:@"iOSVersion"];
    
    if (!iOSVersion) {
        [defaults setBool:NO forKey:@"enabled"];
        enabled = NO;
    }
    
    if (updatesEnabled == NO) {
        [defaults setBool:NO forKey:@"updatesEnabled"];
    }
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:@{
        @"enabled": @(enabled),
        @"updatesEnabled": @(updatesEnabled)
    }];
    
    if (iOSVersion) {
        prefs[@"iOSVersion"] = iOSVersion;
    }
        
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:prefs
                                                                format:NSPropertyListBinaryFormat_v1_0
                                                               options:0
                                                                 error:nil];
    
    [plistData writeToFile:prefsPath atomically:YES];
    
    NSTask *t = [[NSTask alloc] init];
    [t setLaunchPath:@THEOS_PACKAGE_INSTALL_PREFIX "/usr/local/bin/appstoretrollerKiller"];
    [t launch];
}

@end
