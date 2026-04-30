TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

AutoAC_FILES = Tweak.x
AutoAC_CFLAGS = -fobjc-arc
AutoAC_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk