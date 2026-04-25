# Thiết lập kiến trúc và mục tiêu
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# Các file nguồn
AutoAC_FILES = Tweak.x

# Cấu hình CFLAGS (Bôi trơn trình biên dịch)
# -fobjc-arc: Bật quản lý bộ nhớ tự động
# -Wno-deprecated-declarations: Bịt miệng các cảnh báo "lỗi thời" như keyWindow
# -Wno-unused-variable: Bỏ qua cảnh báo biến không sử dụng
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable

# Thư viện liên kết
AutoAC_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

# Lệnh dọn dẹp sau khi build xong cục bộ
after-install::
	install.exec "killall -9 YouTube Facebook" || true
