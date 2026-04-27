# 1. Cấu hình kiến trúc và SDK
ARCHS = arm64 arm64e
TARGET = iphone:clang:15.6:14.5

include $(THEOS)/makefiles/common.mk

# 2. Cấu hình Tweak chính
TWEAK_NAME = AutoAC

# Tự động nhận diện file nguồn
AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_PRIVATE_FRAMEWORKS = MediaRemote 

# Thư viện liên kết
AutoAC_LIBRARIES = substrate

# CFLAGS tối ưu để lách lỗi Header dump
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-error -Wno-module-import-in-extern-c

include $(THEOS_MAKE_PATH)/tweak.mk

# 3. Cấu hình SUBPROJECTS (Đây là phần quan trọng nhất để build kèm menu cài đặt)
# Nó sẽ nhảy vào thư mục autoacprefs để chạy Makefile trong đó
SUBPROJECTS += autoacprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

# 4. Lệnh hậu kiểm sau khi cài đặt
after-install::
	install.exec "killall -9 YouTube"
