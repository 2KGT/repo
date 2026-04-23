ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0     # <-- Dòng quan trọng nhất

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x
AutoAC_CFLAGS = -fobjc-arc
AutoAC_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk