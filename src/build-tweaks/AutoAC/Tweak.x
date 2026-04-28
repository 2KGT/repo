#import <UIKit/UIKit.h>

// =============================================================
// PHẦN 1: KHAI BÁO GIAO DIỆN (INTERFACE)
// Ta tự định nghĩa vỏ Class để Compiler không bắt bẻ khi thiếu file .h
// =============================================================

@interface YTAdSlotContainerView : UIView
@end

@interface YTAdsInnerTubeContext : NSObject
- (BOOL)isAdInterrupting;
@end

@interface YTAdLayout : NSObject
- (id)init;
@end

// =============================================================
// PHẦN 2: LOGIC TWEAK (CHẶN QUẢNG CÁO)
// =============================================================

static BOOL kRemoveAds = YES;

// Hàm đọc cài đặt từ Prefs
static void loadPrefs() {
    NSDictionary *defaults = @{@"kRemoveAds": @YES};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:@"kRemoveAds"];
    kRemoveAds = val ? [val boolValue] : YES;
}

// 1. Chặn hiển thị View quảng cáo
%hook YTAdSlotContainerView
- (void)layoutSubviews {
    if (kRemoveAds) {
        // Ép kiểu (UIView *) để dùng các hàm hệ thống mà không cần header xịn
        UIView *selfView = (UIView *)self;
        [selfView setHidden:YES];
        [selfView setFrame:CGRectZero]; 
        return; // Biến mất luôn, không chạy %orig
    }
    %orig;
}
%end

// 2. Chặn Logic báo hiệu đang có quảng cáo
%hook YTAdsInnerTubeContext
- (BOOL)isAdInterrupting {
    return kRemoveAds ? NO : %orig;
}
%end

// 3. Chặn khởi tạo Layout quảng cáo (Triệt hạ từ trứng nước)
%hook YTAdLayout
- (id)init {
    if (kRemoveAds) {
        return nil; 
    }
    return %orig;
}
%end

// =============================================================
// PHẦN 3: KHỞI TẠO TWEAK (CONSTRUCTOR)
// =============================================================

%ctor {
    @autoreleasepool {
        loadPrefs();
        
        // Lắng nghe thay đổi nếu ông giáo có làm Settings Panel
        [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification 
                                                          object:nil 
                                                           queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *note) {
            loadPrefs();
        }];
        
        %init;
    }
}
