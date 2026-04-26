ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_LIBRARIES = substrate

ADDITIONAL_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 YouTube" || true
