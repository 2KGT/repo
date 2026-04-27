include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = autoacprefs

# Tên các file cần build cho Prefs
autoacprefs_FILES = AutoACRootListController.m
autoacprefs_FRAMEWORKS = UIKit
autoacprefs_PRIVATE_FRAMEWORKS = Preferences
# Đường dẫn cài đặt bundle vào hệ thống
autoacprefs_INSTALL_PATH = /Library/PreferenceBundles
autoacprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
