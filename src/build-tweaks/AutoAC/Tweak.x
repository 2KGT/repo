#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// =========================================================
// 💎 KHAI BÁO INTERFACE (Sửa lỗi biên dịch)
// =========================================================
@interface YTAdSlotContainerView : UIView
@end

@interface YTSlimVideoMetadataSectionView : UIView
@end

@interface YTHeaderLogoView : UIView
@end

@interface YTVideoOverlayView : UIView
@end

@interface YTSettingsSectionItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title titleDescription:(NSString *)desc accessibilityIdentifier:(id)arg3 detailTextBlock:(id)arg4 selectBlock:(BOOL (^)(id))block;
@end

@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(NSMutableArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)desc;
@end

// --- BIẾN TOÀN CỤC ---
static BOOL kRemoveAds = YES;
static BOOL kFastDownload = NO;
static NSString *kLastStatus = @"Hệ thống sẵn sàng";

// =========================================================
// 🚫 DIỆT QUẢNG CÁO & BANNER BÁN HÀNG
// =========================================================

%hook YTAdSlotContainerView
- (void)layoutSubviews { if (kRemoveAds) return; %orig; }
- (void)setHidden:(BOOL)hidden { %orig(kRemoveAds ? YES : hidden); }
%end

%hook YTSlimVideoMetadataSectionView
- (void)layoutSubviews { 
    %orig; 
    if (kRemoveAds) {
        // Ép kiểu self về UIView để truy cập .subviews một cách an toàn
        for (UIView *sub in [((UIView *)self) subviews]) {
            if ([NSStringFromClass([sub class]) containsString:@"Promotion"]) {
                [sub setHidden:YES];
            }
        }
    }
}
%end

// =========================================================
// 📥 NÚT TẢI THÔNG MINH (BÊN PHẢI TRÊN)
// =========================================================

%hook YTVideoOverlayView
- (void)layoutSubviews {
    %orig;
    
    // Ép kiểu self về UIView để lấy kích thước khung (frame)
    UIView *overlayView = (UIView *)self;
    
    UIButton *dlBtn = [overlayView viewWithTag:999];
    if (!dlBtn) {
        dlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dlBtn.tag = 999;
        [dlBtn setImage:[UIImage systemImageNamed:@"arrow.down.to.line.circle.fill"] forState:UIControlStateNormal];
        dlBtn.tintColor = [UIColor whiteColor];
        dlBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        dlBtn.layer.cornerRadius = 18;
        
        // Sửa lỗi: Sử dụng overlayView.frame thay vì self.frame để tránh lỗi property not found
        dlBtn.frame = CGRectMake(overlayView.frame.size.width - 55, 65, 36, 36);
        
        [dlBtn addTarget:self action:@selector(handleAutoACDownload) forControlEvents:UIControlEventTouchUpInside];
        [overlayView addSubview:dlBtn];
    }
}

%new
- (void)handleAutoACDownload {
    if (kFastDownload) {
        kLastStatus = @"Đang tải nhanh 1080p...";
    } else {
        UIAlertController *picker = [UIAlertController alertControllerWithTitle:@"Tùy chọn AutoAC" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [picker addAction:[UIAlertAction actionWithTitle:@"Tải Video 1080p" style:UIAlertActionStyleDefault handler:^(id a){ kLastStatus = @"Đ tải Video..."; }]];
        [picker addAction:[UIAlertAction actionWithTitle:@"Tải Âm thanh (MP3)" style:UIAlertActionStyleDefault handler:^(id a){ kLastStatus = @"Đang tải MP3..."; }]];
        [picker addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
        
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (top.presentedViewController) top = top.presentedViewController;
        [top presentViewController:picker animated:YES completion:nil];
    }
}
%end

// =========================================================
// ⚙️ CÀI ĐẶT NATIVE & NHẤN GIỮ LOGO
// =========================================================

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)desc {
    if (category == 1 || [title isEqualToString:@"General"] || [title isEqualToString:@"Chung"]) {
        Class itemClass = NSClassFromString(@"YTSettingsSectionItem");
        if (itemClass) {
            YTSettingsSectionItem *autoAC = [itemClass itemWithTitle:@"Cài đặt AutoAC" titleDescription:@"Cấu hình tải & dọn rác" accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL(id arg1) {
                return YES;
            }];
            [items addObject:autoAC];
        }
    }
    %orig(items, category, title, desc);
}
%end

%hook YTHeaderLogoView
- (void)layoutSubviews {
    %orig;
    
    // Sửa lỗi: Ép kiểu self về UIView để bật userInteractionEnabled
    UIView *logoView = (UIView *)self;
    logoView.userInteractionEnabled = YES;
    
    static BOOL gestureAdded = NO;
    if (!gestureAdded) {
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAutoACReview)];
        lp.minimumPressDuration = 0.7;
        [logoView addGestureRecognizer:lp];
        gestureAdded = YES;
    }
}

%new
- (void)handleAutoACReview {
    UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [haptic impactOccurred];
    // Ghi log để kiểm tra trong Console (hoặc hiện HUD tại đây)
    NSLog(@"[AutoAC] Trạng thái cuối: %@", kLastStatus);
}
%end

// =========================================================
// 🚀 KHỞI CHẠY TWEAK
// =========================================================

%ctor {
    %init(YTSettingsViewController = NSClassFromString(@"YTSettingsViewController"),
          YTHeaderLogoView = NSClassFromString(@"YTHeaderLogoView") ?: NSClassFromString(@"YTRightAlignedHeaderLogoView"),
          YTVideoOverlayView = NSClassFromString(@"YTVideoOverlayView"));
}
