# 1. Kiến trúc & Target (Giữ nguyên cho iOS hiện đại)
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

# 2. Setup Theos Common
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# 3. File nguồn
AutoAC_FILES = Tweak.x

# 4. Frameworks (Quan trọng: Thêm PhotosUI nếu bạn muốn mở bộ sưu tập ảnh)
AutoAC_FRAMEWORKS = UIKit Foundation Photos CoreGraphics QuartzCore
AutoAC_PRIVATE_FRAMEWORKS = Preferences # Cần thiết nếu bạn muốn lồng menu vào Settings

# 5. Libraries (Sửa đổi để tương thích Sideload)
# Thay vì chỉ dùng 'substrate', ta dùng 'CydiaSubstrate' để các công cụ tiêm dễ nhận diện hơn
AutoAC_LIBRARIES = substrate

# 6. Cấu hình biên dịch (Flag tối ưu)
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

# Tùy chọn: Nếu bạn build bản Sideload, hãy bỏ qua các cảnh báo về thiếu framework hệ thống
AutoAC_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk

# 7. Hậu cài đặt (Chỉ chạy trên máy Jailbreak)
# Dùng '|| true' để không bị báo lỗi khi build trên GitHub Actions
after-install::
	install.exec "killall -9 YouTube" || true

# 8. Vệ sinh sau build
clean::
	rm -rf ./packages/*
