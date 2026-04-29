export ARCHS = arm64 arm64e
# Đặt target thấp hơn một chút (14.0) để tăng độ tương thích cho nhiều máy
export TARGET = iphone:clang:latest:14.0

TWEAK_NAME = AutoAC

# Tự động nhận diện file .x để ông giáo đỡ phải khai báo bằng tay
AutoAC_FILES = $(wildcard *.x)

# 🧠 TRÍ THÔNG MINH BỔ SUNG Ở ĐÂY:
# 1. -I. : Tìm file header ngay tại thư mục hiện tại (Chấp cả Header.h lẫn headers.h)
# 2. -I$(THEOS)/include/$(TWEAK_NAME)headers : Tự động khớp với nhà máy Phong Thần
AutoAC_CFLAGS = -fobjc-arc -I. -I$(THEOS)/include/$(TWEAK_NAME)headers

# 🚀 CHỐNG VĂNG (Dành cho Sideload/Non-Jailbreak)
# Dòng này cực kỳ quan trọng để tweak chạy được trên App đã được Sideload
AutoAC_LDFLAGS = -Wl,-segalign,4000

AutoAC_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
