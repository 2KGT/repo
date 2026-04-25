#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// --- KHAI BÁO CLASS ---
@interface YTHeaderLogoView : UIView
@end
@interface YTVideoOverlayView : UIView
@end

// --- BIẾN CẤU HÌNH (Mặc định) ---
static BOOL kAutoClean = YES;
static BOOL kFastDownload = NO;
static BOOL kRemoveAds = YES;
static NSString *kLastStatus = @"Sẵn sàng";

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
        for (UIView *sub in self.subviews) {
            if ([NSStringFromClass([sub class]) containsString:@"Promotion"]) [sub setHidden:YES];
        }
    }
}
%end

// =========================================================
// 💎 INTERACTIVE HUD (VUỐT LÊN ĐỂ ẨN)
// =========================================================

@interface AutoACHUDView : UIView
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation AutoACHUDView
- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 240, 75)];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.layer.cornerRadius = 18;
        self.tag = 777;
        
        self.statusLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.statusLabel.textColor = [UIColor whiteColor];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.numberOfLines = 0;
        self.statusLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [self addSubview:self.statusLabel];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHUD)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipe];
    }
    return self;
}
- (void)dismissHUD {
    [UIView animateWithDuration:0.3 animations:^{ self.alpha = 0; self.transform = CGAffineTransformMakeTranslation(0, -100); } completion:^(BOOL f){ [self removeFromSuperview]; }];
}
@end

static void updateHUD(NSString *msg, BOOL autoDismiss) {
    dispatch_async(dispatch_get_main_queue(), ^{
        kLastStatus = msg;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        AutoACHUDView *hud = [window viewWithTag:777];
        if (!hud) {
            hud = [[AutoACHUDView alloc] init];
            hud.center = CGPointMake(window.center.x, 110);
            [window addSubview:hud];
        }
        hud.statusLabel.text = msg;
        if (autoDismiss) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [hud dismissHUD]; });
    });
}

// =========================================================
// 📥 LOGIC TẢI & LƯU THƯ VIỆN
// =========================================================

static void performClean() {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    [[NSFileManager defaultManager] removeItemAtPath:[cachePath stringByAppendingPathComponent:@"com.google.ios.youtube"] error:nil];
    updateHUD(@"Đã dọn dẹp Cache thủ công ✅", YES);
}

static void saveVideoToPhotos(NSURL *url) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError *error) {
        updateHUD(success ? @"Tải về hoàn tất! ✅\nĐã lưu vào Ảnh" : @"Lỗi lưu video ❌", YES);
        if (success) {
            UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleSuccess];
            [haptic impactOccurred];
        }
    }];
}

// =========================================================
// 🛠 HOOK PLAYER & LOGO
// =========================================================

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
        updateHUD(@"Đang tải chất lượng cao...\nVui lòng chờ", NO);
        // Logic gọi link download...
    } else {
        // Hiện Popup chọn MP4/MP3/Chất lượng như các bản trước
    }
}
%end

%hook YTHeaderLogoView
- (void)layoutSubviews {
    %orig;
    self.userInteractionEnabled = YES;
    if (![self viewWithTag:888]) {
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(autoAC_Review)];
        lp.minimumPressDuration = 0.7;
        [self addGestureRecognizer:lp];
        UIView *v = [[UIView alloc] initWithFrame:self.bounds]; v.tag = 888; [self addSubview:v];
    }
}
%new
- (void)autoAC_Review {
    updateHUD([NSString stringWithFormat:@"Trạng thái: %@\n[Vuốt lên để đóng]", kLastStatus], NO);
    // Thêm nút dọn dẹp rác thủ công vào HUD nếu muốn
}
%end
