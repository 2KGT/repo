export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

TWEAK_NAME = AutoAC
AutoAC_FILES = Tweak.x Settings.x

# SỬA LẠI ĐOẠN NÀY: Dùng -I. để tìm tại chỗ và -I...headers cho đúng tên nhà máy
AutoAC_CFLAGS = -fobjc-arc -I. -I$(THEOS)/include/AutoACheaders
AutoAC_LDFLAGS = -Wl,-segalign,4000

AutoAC_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
