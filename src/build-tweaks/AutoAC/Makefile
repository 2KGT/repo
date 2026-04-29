# 1. Cấu hình kiến trúc và SDK
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAC

# --- PHẦN CẬP NHẬT: HỆ PHÁP SƯ TOÀN NĂNG ---
# Không mượn đồ của Google nữa, ta tự đúc xác ngay trong project
AutoAC_CFLAGS = -fobjc-arc \
                -I. \
                -Wno-deprecated-declarations \
                -Wno-unused-variable \
                -Wno-error
# -------------------------------------------

AutoAC_FILES = Tweak.x Settings.x
AutoAC_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation
AutoAC_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += autoacprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 YouTube"
