ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x Settings.x
# Thêm các Framework xử lý hình ảnh và video
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_LIBRARIES = substrate

ADDITIONAL_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk

# Chỉ dùng nếu cậu build Bundle cho máy Jailbreak
# SUBPROJECTS += autoacprefs
# include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube Preferences" || true
