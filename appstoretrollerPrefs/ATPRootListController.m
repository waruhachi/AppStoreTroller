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
	NSTask *t = [[NSTask alloc] init];
	[t setLaunchPath:@THEOS_PACKAGE_INSTALL_PREFIX "/usr/bin/killall"];
	[t setArguments:[NSArray arrayWithObjects:@"-9", @"appstored", nil]];
	[t launch];

	t = [[NSTask alloc] init];
	[t setLaunchPath:@THEOS_PACKAGE_INSTALL_PREFIX "/usr/bin/killall"];
	[t setArguments:[NSArray arrayWithObjects:@"AppStore", nil]];
	[t launch];
}

@end
