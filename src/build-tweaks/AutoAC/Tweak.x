#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// --- KHAI BÁO CLASS NỘI BỘ YOUTUBE ---
@interface YTSettingsSectionItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title titleDescription:(NSString *)desc accessibilityIdentifier:(id)arg3 detailTextBlock:(id)arg4 selectBlock:(BOOL (^)(id))block;
@end

@interface YTHeaderLogoView : UIView
@end

@interface YTVideoOverlayView : UIView
@end

// --- BIẾN CẤU HÌNH ---
static BOOL kFastDownload = NO;
static BOOL kRemoveAds = YES;
static NSString *kLastStatus = @"Hệ thống sẵn sàng";

// =========================================================
// 🚫 DIỆT QUẢNG CÁO & TAG BÁN HÀNG
// =========================================================

%hook YTAdSlotContainerView
- (void)layoutSubviews { if (kRemoveAds) return; %orig; }
- (void)setHidden:(BOOL)hidden { %orig(kRemoveAds ? YES : hidden); }
%end

%hook YTSlimVideoMetadataSectionView
- (void)layoutSubviews { 
    %orig; 
    if (kRemoveAds) {
        for (UIView *sub in self.subviews) {
            if ([NSStringFromClass([sub class]) containsString:@"Promotion"]) [sub setHidden:YES];
        }
    }
}
%end

// =========================================================
// 📥 LOGIC TẢI VÀ POPUP CHẤT LƯỢNG
// =========================================================

static void startDownload(NSString *quality) {
    // Thông báo bắt đầu
    kLastStatus = [NSString stringWithFormat:@"Đang tải: %@", quality];
    // Thực thi logic tải video/âm thanh tại đây...
}

%hook YTVideoOverlayView
- (void)layoutSubviews {
    %orig;
    UIButton *dlBtn = [self viewWithTag:999];
    if (!dlBtn) {
        dlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dlBtn.tag = 999;
        [dlBtn setImage:[UIImage systemImageNamed:@"arrow.down.to.line.circle.fill"] forState:UIControlStateNormal];
        dlBtn.tintColor = [UIColor whiteColor];
        dlBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        dlBtn.layer.cornerRadius = 18;
        dlBtn.frame = CGRectMake(self.frame.size.width - 55, 60, 36, 36);
        [dlBtn addTarget:self action:@selector(handleAutoACDownload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dlBtn];
    }
}

%new
- (void)handleAutoACDownload {
    if (kFastDownload) {
        startDownload(@"1080p (Mặc định)");
    } else {
        UIAlertController *picker = [UIAlertController alertControllerWithTitle:@"Tùy chọn tải" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [picker addAction:[UIAlertAction actionWithTitle:@"Video 1080p" style:UIAlertActionStyleDefault handler:^(id a){ startDownload(@"1080p"); }]];
        [picker addAction:[UIAlertAction actionWithTitle:@"Âm thanh (MP3)" style:UIAlertActionStyleDefault handler:^(id a){ startDownload(@"MP3"); }]];
        [picker addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
        
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (top.presentedViewController) top = top.presentedViewController;
        [top presentViewController:picker animated:YES completion:nil];
    }
}
%end

// =========================================================
// ⚙️ TÍCH HỢP CÀI ĐẶT VÀ XEM LẠI TRẠNG THÁI
// =========================================================

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)desc {
    if (category == 1) { // Thêm vào mục Cài đặt Chung
        YTSettingsSectionItem *item = [%c(YTSettingsSectionItem) itemWithTitle:@"AutoAC" titleDescription:@"Bật/tắt tải nhanh và dọn rác" accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL(id arg1) {
            // Hiện bảng cấu hình công tắc ở đây
            return YES;
        }];
        [items addObject:item];
    }
    %orig(items, category, title, desc);
}
%end

%hook YTHeaderLogoView
- (void)layoutSubviews {
    %orig;
    self.userInteractionEnabled = YES;
    if (![self viewWithTag:888]) {
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(reviewStatus)];
        lp.minimumPressDuration = 0.8;
        [self addGestureRecognizer:lp];
        UIView *v = [[UIView alloc] initWithFrame:self.bounds]; v.tag = 888; [self addSubview:v];
    }
}
%new
- (void)reviewStatus {
    // Chỉ hiện khung HUD nhỏ báo trạng thái cuối, vuốt lên để ẩn
    // updateHUD(kLastStatus, NO);
}
%end
