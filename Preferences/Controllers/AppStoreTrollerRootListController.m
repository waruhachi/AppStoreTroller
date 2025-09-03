#include "AppStoreTrollerRootListController.h"

@implementation AppStoreTrollerRootListController
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

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
}

- (void)respring {
	NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:@"dev.mineek.appstoretroller.preferences"];

    NSString *iOSVersion = [preferences stringForKey:@"iOSVersion"];
    if (!iOSVersion) {
        [preferences setBool:NO forKey:@"enabled"];
        [preferences synchronize];
    }

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:jbroot(@"/usr/local/bin/AppStoreTrollerKiller")];
    [task launch];
}

@end
