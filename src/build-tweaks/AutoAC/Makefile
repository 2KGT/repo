ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics
AutoAC_LIBRARIES = substrate
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 YouTube" || true
