# Thiết lập kiến trúc và mục tiêu cho iOS hiện đại
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# Các file nguồn (Chỉ cần Tweak.x cho gọn)
AutoAC_FILES = Tweak.x

# Frameworks cần thiết để chạy Giao diện, Lưu ảnh và Đồ họa
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore

# Thư viện liên kết: 
# - substrate: Để Hook
# - yougroupsettings: Để gom nhóm vào cài đặt YouTube như bạn muốn
AutoAC_LIBRARIES = substrate yougroupsettings

# Cấu hình trình biên dịch (Sửa lỗi "unused function" và "deprecated")
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk

# Tự động khởi động lại App sau khi cài đặt để cập nhật Tweak
after-install::
	install.exec "killall -9 YouTube Facebook" || true
