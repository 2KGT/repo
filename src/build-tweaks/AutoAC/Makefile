# 1. Cấu hình kiến trúc và SDK
ARCHS = arm64 arm64e
TARGET = iphone:clang:15.6:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# --- PHẦN THÊM MỚI ĐỂ NHẬT HEADERS ---
# Trỏ trực tiếp vào thư mục headers ở gốc Repo (cách AutoAC 3 cấp thư mục)
HEADERS_PATH = ../../../headers/YouTubeHeader
AutoAC_CFLAGS = -fobjc-arc \
                -I$(HEADERS_PATH) \
                -Wno-deprecated-declarations \
                -Wno-unused-variable \
                -Wno-error \
                -Wno-module-import-in-extern-c
# ------------------------------------

AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_PRIVATE_FRAMEWORKS = MediaRemote 
AutoAC_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += autoacprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube"
