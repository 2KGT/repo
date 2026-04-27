ARCHS = arm64 arm64e
TARGET = iphone:clang:15.6:14.5 # Nâng SDK lên một chút để tương thích tốt hơn

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# Tự động tìm tất cả file .x và .m (đề phòng ông thêm file sau này)
AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation CoreImage
AutoAC_PRIVATE_FRAMEWORKS = MediaRemote # YouTube hay dùng cái này để điều khiển nhạc/video

# SUBSTRATE_LIBRARY giúp liên kết đúng đối tượng
AutoAC_LIBRARIES = substrate

# CFLAGS thần thánh để "lách" lỗi header
# -Wno-module-import-in-extern-c: tránh lỗi import trong block extern
# -Wno-unused-variable: bỏ qua khai báo biến không dùng
AutoAC_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-error -Wno-module-import-in-extern-c

include $(THEOS_MAKE_PATH)/tweak.mk

# Lệnh dọn dẹp sau khi build xong cho sạch xưởng
after-install::
	install.exec "killall -9 YouTube"
