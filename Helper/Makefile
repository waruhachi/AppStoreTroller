TOOL_NAME = AppStoreTrollerKiller

$(TOOL_NAME)_FILES = $(wildcard *.m)
$(TOOL_NAME)_CFLAGS = -fobjc-arc
$(TOOL_NAME)_INSTALL_PATH = /usr/local/bin
$(TOOL_NAME)_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tool.mk
