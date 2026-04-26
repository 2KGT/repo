ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore
AutoAC_LIBRARIES = substrate
AutoAC_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

# Kích hoạt subproject cho Menu Settings (Jailbreak)
SUBPROJECTS += autoacprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube Preferences" || true
