TARGET := iphone:clang:16.5:14.5
ARCHS = arm64 arm64e
# THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = appstoretrollerPrefs

appstoretrollerPrefs_FILES = ATPRootListController.m
appstoretrollerPrefs_FRAMEWORKS = UIKit
appstoretrollerPrefs_PRIVATE_FRAMEWORKS = Preferences
appstoretrollerPrefs_INSTALL_PATH = /Library/PreferenceBundles
appstoretrollerPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
