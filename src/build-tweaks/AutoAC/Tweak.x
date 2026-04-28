#import <UIKit/UIKit.h>

// --- PHẦN 1: IMPORT HEADERS (Cực kỳ quan trọng) ---
// Đây là những file con Bot đã bốc về kho headers/YouTubeHeader/
#import "YouTubeHeader/YTAdSlotContainerView.h"
#import "YouTubeHeader/YTAdsInnerTubeContext.h"
#import "YouTubeHeader/YTAdLayout.h"

// --- PHẦN 2: KHAI BÁO BỔ SUNG (Dành cho những Class chưa có Header) ---
// Nếu build vẫn báo thiếu, ta dùng Interface để "định hình" cho Compiler
@interface YTAdSlotContainerView : UIView
@end

@interface YTAdsInnerTubeContext : NSObject
- (BOOL)isAdInterrupting;
@end

@interface YTAdLayout : NSObject
@end

// --- PHẦN 3: LOGIC TWEAK ---
static BOOL kRemoveAds = YES;

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
        [self setFrame:CGRectZero]; // Dùng [self setFrame:] thay vì self.frame để an toàn hơn
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
        loadPrefs();
        [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification 
                                                          object:nil 
                                                           queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *note) {
            loadPrefs();
        }];
        %init;
    }
}
