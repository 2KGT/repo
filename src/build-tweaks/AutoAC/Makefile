# Thiết lập kiến trúc
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# File nguồn
AutoAC_FILES = Tweak.x

# Frameworks cần thiết cho giao diện, ảnh và đồ họa
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore

# Chỉ dùng substrate để Hook (Tránh lỗi Build trên GitHub)
AutoAC_LIBRARIES = substrate

# Cấu hình trình biên dịch: Bật ARC và bịt miệng các cảnh báo
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk

# Khởi động lại YouTube sau khi cài đặt
after-install::
	install.exec "killall -9 YouTube" || true
