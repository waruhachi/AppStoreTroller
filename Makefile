TARGET := iphone:clang:16.5:14.5
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
# THEOS_PACKAGE_SCHEME = rootless

THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = appstoretroller

appstoretroller_FILES = Tweak.xm
appstoretroller_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += appstoretrollerPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
