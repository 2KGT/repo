ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_LIBRARIES = substrate

# ADDITIONAL_CFLAGS sẽ được Workflow tự bồi thêm đường dẫn -isystem
ADDITIONAL_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk

# Chỉ dùng nếu cậu muốn làm Menu trong App Cài đặt hệ thống (Jailbreak)
# SUBPROJECTS += autoacprefs
# include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube Preferences" || true
