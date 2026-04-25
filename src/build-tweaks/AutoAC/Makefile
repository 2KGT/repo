# Thiết lập kiến trúc và mục tiêu
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# Các file nguồn
AutoAC_FILES = Tweak.x

# Cấu hình CFLAGS (Bôi trơn trình biên dịch)
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

# Thư viện và Framework cần thiết
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics
AutoAC_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

# Lệnh dọn dẹp sau khi build xong
after-install::
	install.exec "killall -9 YouTube Facebook" || true
