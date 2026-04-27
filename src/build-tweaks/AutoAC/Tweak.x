#import <UIKit/UIKit.h>

// Khai báo biến toàn cục
static BOOL kRemoveAds = YES;

// Hàm load settings chuẩn
static void loadPrefs() {
    NSDictionary *defaults = @{@"kRemoveAds": @YES};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    kRemoveAds = [[NSUserDefaults standardUserDefaults] boolForKey:@"kRemoveAds"];
}

// 1. Chặn hiển thị (View)
%hook YTAdSlotContainerView
- (void)layoutSubviews {
    if (kRemoveAds) {
        [self setHidden:YES];
        self.frame = CGRectZero; // Thu nhỏ về 0 để tránh chiếm chỗ
        return; 
    }
    %orig;
}
%end

// 2. Chặn Logic (Dòng dữ liệu quảng cáo)
// Hook vào các class quản lý Ads để báo rằng "không có quảng cáo nào cả"
%hook YTAdsInnerTubeContext
- (BOOL)isAdInterrupting {
    return kRemoveAds ? NO : %orig;
}
%end

%hook YTAdLayout
- (id)init {
    if (kRemoveAds) return nil; // Không cho khởi tạo layout quảng cáo
    return %orig;
}
%end

// 3. Khởi tạo
%ctor {
    @autoreleasepool {
        loadPrefs();
        // Lắng nghe thay đổi settings nếu ông giáo đổi trong App
        [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification 
                                                          object:nil 
                                                           queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *note) {
            loadPrefs();
        }];
        %init;
    }
}
