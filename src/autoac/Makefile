ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0     # <-- Dòng quan trọng nhất

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoC_FILES = Tweak.x
AutoC_CFLAGS = -fobjc-arc
AutoC_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk