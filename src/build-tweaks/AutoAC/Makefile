ARCHS = arm64 arm64e
# Để iphone:clang:14.5:14.5 để khớp với Patched SDK mình tải trong workflow
TARGET = iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore
AutoAC_LIBRARIES = substrate

# Gộp các cờ biên dịch vào ADDITIONAL_CFLAGS để workflow .yml dễ dàng chèn thêm đường dẫn Header
ADDITIONAL_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk

# Kích hoạt subproject cho Menu Settings (Cho máy Jailbreak)
SUBPROJECTS += autoacprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube Preferences" || true
