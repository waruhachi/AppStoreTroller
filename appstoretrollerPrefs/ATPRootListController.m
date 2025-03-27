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
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"dev.mineek.appstoretroller"];
    
    NSString *prefsPath = @THEOS_PACKAGE_INSTALL_PREFIX "/var/mobile/Library/Preferences/dev.mineek.appstoretroller.plist";
    BOOL enabled = [defaults boolForKey:@"enabled"];
    BOOL updatesEnabled = [defaults boolForKey:@"updatesEnabled"];
    NSString *iOSVersion = [defaults stringForKey:@"iOSVersion"];
    
    NSDictionary *prefs = @{
        @"enabled": @(enabled),
        @"updatesEnabled": @(updatesEnabled),
        @"iOSVersion": iOSVersion
    };

    [prefs writeToFile:prefsPath atomically:YES];
    
    NSTask *t = [[NSTask alloc] init];
    [t setLaunchPath:@THEOS_PACKAGE_INSTALL_PREFIX "/usr/local/bin/appstoretrollerKiller"];
    [t launch];
}

@end
