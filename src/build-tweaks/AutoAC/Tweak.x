#import <UIKit/UIKit.h>

// =============================================================
// CÁCH GỌI LẺ TỪ KHO (Sau khi đã chạy Nhà máy)
// =============================================================

// Ông giáo chỉ cần import những thứ đã liệt kê trong headers.txt
#import <YouTubeHeader/YTMEThumbnailPickerViewController.h>
#import <YouTubeHeader/YTAdSlotContainerView.h>
#import <YouTubeHeader/YTAdsInnerTubeContext.h>
#import <YouTubeHeader/YTAdLayout.h>

// Bây giờ không cần @interface ... @end nữa vì Nhà máy đã đúc sẵn cho ông giáo rồi!

// =============================================================
// PHẦN 2: LOGIC TWEAK (VẪN GIỮ NGUYÊN)
// =============================================================

static BOOL kRemoveAds = YES;

// ... (Giữ nguyên hàm loadPrefs) ...

%hook YTAdSlotContainerView
- (void)layoutSubviews {
    if (kRemoveAds) {
        // Nhờ có Header đã đúc, ông giáo có thể gọi [self setHidden:] thoải mái 
        // mà không cần phải ép kiểu (UIView *)self nữa (vì Header đã định nghĩa nó là UIView rồi)
        [self setHidden:YES];
        [self setFrame:CGRectZero]; 
        return;
    }
    %orig;
}
%end

%hook YTAdsInnerTubeContext
- (BOOL)isAdInterrupting {
    return kRemoveAds ? NO : %orig;
}
%end

%hook YTAdLayout
- (id)init {
    return kRemoveAds ? nil : %orig;
}
%end

// ... (Giữ nguyên %ctor) ...
