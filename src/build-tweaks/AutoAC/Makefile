export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x Settings.x
AutoAC_CFLAGS = -fobjc-arc
AutoAC_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
