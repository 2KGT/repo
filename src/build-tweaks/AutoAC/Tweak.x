#import <UIKit/UIKit.h>

// --- PHẦN 1: PHƯƠNG PHÁP PHÁP SƯ (FORWARD DECLARATION) ---
// Không dùng #import nữa để né lỗi "File not found" hoặc "Duplicate declaration"
// Ta chỉ khai báo cái "vỏ" để Compiler biết các Class này có tồn tại.

@class YTAdSlotContainerView, YTAdsInnerTubeContext, YTAdLayout;

// --- PHẦN 2: ĐỊNH NGHĨA GIAO DIỆN (CHỈ KHI CẦN GỌI METHOD) ---
@interface YTAdSlotContainerView : UIView
@end

@interface YTAdsInnerTubeContext : NSObject
- (BOOL)isAdInterrupting;
@end

@interface YTAdLayout : NSObject
- (id)init;
@end

// --- PHẦN 3: LOGIC TWEAK ---
static BOOL kRemoveAds = YES;

static void loadPrefs() {
    kRemoveAds = [[NSUserDefaults standardUserDefaults] boolForKey:@"kRemoveAds"];
}

// 1. Chặn hiển thị (Dùng kiểu ép (id) để né Header)
%hook YTAdSlotContainerView
- (void)layoutSubviews {
    if (kRemoveAds) {
        [(UIView *)self setHidden:YES];
        [(UIView *)self setFrame:CGRectZero];
        return; 
    }
    %orig;
}
%end

// 2. Chặn Logic
%hook YTAdsInnerTubeContext
- (BOOL)isAdInterrupting {
    return kRemoveAds ? NO : %orig;
}
%end

%hook YTAdLayout
- (id)init {
    if (kRemoveAds) return nil;
    return %orig;
}
%end

// 3. Khởi tạo
%ctor {
    @autoreleasepool {
        // Mặc định luôn là YES
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"kRemoveAds": @YES}];
        loadPrefs();
        %init;
    }
}
