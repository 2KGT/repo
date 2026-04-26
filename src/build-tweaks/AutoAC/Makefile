ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x Settings.x
# Thêm AVFoundation và CoreImage để hỗ trợ logic chọn chất lượng Video
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_LIBRARIES = substrate

# Cờ biên dịch chuẩn
ADDITIONAL_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk

# Menu Settings cho máy Jailbreak
SUBPROJECTS += autoacprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube Preferences" || true
