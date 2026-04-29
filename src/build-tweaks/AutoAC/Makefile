# 1. Cấu hình kiến trúc và SDK
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# --- PHẦN CẬP NHẬT ĐỂ ĂN KHỚP VỚI NHÀ MÁY ---
# Không dùng đường dẫn ../../../ nữa. 
# Script Nhập kho sẽ đúc hàng vào $(THEOS)/include/YouTubeHeader
AutoAC_CFLAGS = -fobjc-arc \
                -I$(THEOS)/include/YouTubeHeader \
                -Wno-deprecated-declarations \
                -Wno-unused-variable \
                -Wno-error \
                -Wno-module-import-in-extern-c
# -------------------------------------------

AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_PRIVATE_FRAMEWORKS = MediaRemote 
AutoAC_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += autoacprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube"
