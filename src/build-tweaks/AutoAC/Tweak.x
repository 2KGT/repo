#import <UIKit/UIKit.h>

// =============================================================
// PHÁP SƯ TOÀN NĂNG: TỰ ĐÚC XÁC - KHÔNG MƯỢN HEADERS
// =============================================================

// 1. Dùng @class để báo danh (Ngắt đệ quy ngay lập tức)
@class YTAdSlotContainerView, YTAdsInnerTubeContext, YTAdLayout;

// 2. Tự đúc khung xương (Skeleton Interface)
// Ông giáo chỉ cần định nghĩa những gì mình thực sự gọi tới
@interface YTAdSlotContainerView : UIView
@end

@interface YTAdsInnerTubeContext : NSObject
- (BOOL)isAdInterrupting;
@end

@interface YTAdLayout : NSObject
@end

// =============================================================
// PHẦN 2: LOGIC TWEAK (SIÊU NHẸ - KHÔNG PHỤ THUỘC)
// =============================================================

static BOOL kRemoveAds = YES;

%hook YTAdSlotContainerView
- (void)layoutSubviews {
    if (kRemoveAds) {
        // Vì ta đã đúc YTAdSlotContainerView kế thừa UIView ở trên,
        // Compiler sẽ hiểu và cho phép gọi setHidden/setFrame ngay.
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
    // Nếu kRemoveAds là YES, ta trả về nil để "triệt hạ" AdLayout ngay từ lúc khởi tạo
    return kRemoveAds ? nil : %orig;
}
%end

%ctor {
    // Nếu có loadPrefs thì để ở đây, không thì cứ để tweak chạy mặc định
    %init;
}
