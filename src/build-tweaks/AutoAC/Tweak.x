#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// =========================================================
// 💎 KHAI BÁO INTERFACE (Sửa lỗi biên dịch & Ép kiểu)
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

// --- BIẾN TOÀN CỤC & HÀM ĐỌC PREFS THÔNG MINH ---
static BOOL kRemoveAds = YES;
static BOOL kFastDownload = NO;
static NSString *kLastStatus = @"Hệ thống sẵn sàng";

static void loadPrefs() {
    // Đường dẫn chuẩn cho máy Jailbreak
    NSString *path = @"/var/mobile/Library/Preferences/com.2kgt.autoac.plist";
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    if (prefs) {
        kRemoveAds = prefs[@"kRemoveAds"] ? [prefs[@"kRemoveAds"] boolValue] : YES;
        kFastDownload = prefs[@"kFastDownload"] ? [prefs[@"kFastDownload"] boolValue] : NO;
    } else {
        // Môi trường Non-Jailbreak hoặc lần đầu cài đặt
        kRemoveAds = YES;
        kFastDownload = NO;
    }
}

// =========================================================
// 🚫 DIỆT QUẢNG CÁO
// =========================================================

%hook YTAdSlotContainerView
- (void)layoutSubviews { if (kRemoveAds) return; %orig; }
- (void)setHidden:(BOOL)hidden { %orig(kRemoveAds ? YES : hidden); }
%end

%hook YTSlimVideoMetadataSectionView
- (void)layoutSubviews { 
    %orig; 
    if (kRemoveAds) {
        for (UIView *sub in [((UIView *)self) subviews]) {
            if ([NSStringFromClass([sub class]) containsString:@"Promotion"]) {
                [sub setHidden:YES];
            }
        }
    }
}
%end

// =========================================================
// 📥 NÚT TẢI THÔNG MINH
// =========================================================

%hook YTVideoOverlayView
- (void)layoutSubviews {
    %orig;
    UIView *overlayView = (UIView *)self;
    UIButton *dlBtn = [overlayView viewWithTag:999];
    if (!dlBtn) {
        dlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dlBtn.tag = 999;
        [dlBtn setImage:[UIImage systemImageNamed:@"arrow.down.to.line.circle.fill"] forState:UIControlStateNormal];
        dlBtn.tintColor = [UIColor whiteColor];
        dlBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        dlBtn.layer.cornerRadius = 18;
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
        UIAlertController *picker = [UIAlertController alertControllerWithTitle:@"AutoAC" message:@"Tùy chọn tải xuống" preferredStyle:UIAlertControllerStyleActionSheet];
        [picker addAction:[UIAlertAction actionWithTitle:@"Tải Video 1080p" style:UIAlertActionStyleDefault handler:^(id a){ kLastStatus = @"Đang tải Video..."; }]];
        [picker addAction:[UIAlertAction actionWithTitle:@"Tải MP3" style:UIAlertActionStyleDefault handler:^(id a){ kLastStatus = @"Đang tải MP3..."; }]];
        [picker addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
        
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (top.presentedViewController) top = top.presentedViewController;
        [top presentViewController:picker animated:YES completion:nil];
    }
}
%end

// =========================================================
// ⚙️ CÀI ĐẶT TRONG APP (Cho cả JB & Non-JB)
// =========================================================

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)desc {
    if (category == 1 || [title isEqualToString:@"General"] || [title isEqualToString:@"Chung"]) {
        Class itemClass = NSClassFromString(@"YTSettingsSectionItem");
        if (itemClass) {
            YTSettingsSectionItem *autoAC = [itemClass itemWithTitle:@"AutoAC Settings" titleDescription:@"Tùy chỉnh tải & Ads" accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL(id arg1) {
                // Hiển thị Menu chỉnh nhanh ngay trong YouTube
                UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"AutoAC" message:@"Cấu hình nhanh" preferredStyle:UIAlertControllerStyleAlert];
                [menu addAction:[UIAlertAction actionWithTitle:(kRemoveAds ? @"Tắt Chặn Ads" : @"Bật Chặn Ads") style:UIAlertActionStyleDefault handler:^(id a){ kRemoveAds = !kRemoveAds; }]];
                [menu addAction:[UIAlertAction actionWithTitle:(kFastDownload ? @"Tắt Tải nhanh" : @"Bật Tải nhanh") style:UIAlertActionStyleDefault handler:^(id a){ kFastDownload = !kFastDownload; }]];
                [menu addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
                
                [self presentViewController:menu animated:YES completion:nil];
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
    NSLog(@"[AutoAC] Status: %@", kLastStatus);
}
%end

// =========================================================
// 🚀 KHỞI CHẠY
// =========================================================

%ctor {
    loadPrefs(); // Nạp cấu hình trước khi chạy
    %init(YTSettingsViewController = NSClassFromString(@"YTSettingsViewController"),
          YTHeaderLogoView = NSClassFromString(@"YTHeaderLogoView") ?: NSClassFromString(@"YTRightAlignedHeaderLogoView"),
          YTVideoOverlayView = NSClassFromString(@"YTVideoOverlayView"));
}
