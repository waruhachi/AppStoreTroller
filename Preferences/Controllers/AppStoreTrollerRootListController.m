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
    NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:@"dev.mineek.appstoretroller.preferences"];
    [preferences setObject:value forKey:specifier.properties[@"key"]];

    [super setPreferenceValue:value specifier:specifier];
}

- (void)respring {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:jbroot(@"/usr/local/bin/AppStoreTrollerKiller")];
    [task launch];
}

@end
