ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

INSTALL_TARGET_PROCESSES = Facebook
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FBEnhancer

FBEnhancer_FILES = Tweak.x
FBEnhancer_CFLAGS = -fobjc-arc

SUBPROJECTS += fbenhancerprefs

include $(THEOS_MAKE_PATH)/aggregate.mk
