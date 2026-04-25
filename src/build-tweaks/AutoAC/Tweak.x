#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// --- BIẾN CẤU HÌNH ---
static BOOL kAutoClean = YES;
static BOOL kFastDownload = NO;
static BOOL kRemoveAds = YES;

// =========================================================
// 🚫 DIỆT QUẢNG CÁO BANNER & TAG BÁN HÀNG
// =========================================================

%hook YTAdSlotContainerView
- (void)layoutSubviews { if (kRemoveAds) return; %orig; }
- (void)setHidden:(BOOL)hidden { %orig(kRemoveAds ? YES : hidden); }
%end

%hook YTSlimVideoMetadataSectionView
- (void)layoutSubviews { 
    %orig; 
    if (kRemoveAds) {
        // Diệt tag bán hàng/shopee/banner dưới video
        for (UIView *sub in self.subviews) {
            if ([NSStringFromClass([sub class]) containsString:@"Promotion"]) [sub setHidden:YES];
        }
    }
}
%end

// =========================================================
// 📥 LOGIC TẢI & THÔNG BÁO HOÀN TẤT
// =========================================================

static void finalizeDownload(NSURL *fileURL) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
    } completionHandler:^(BOOL success, NSError *error) {
        // THÔNG BÁO ĐÃ TẢI XONG
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleSuccess];
            [haptic impactOccurred]; // Rung nhẹ khi xong
            
            // Hiện HUD báo hoàn tất (v3.6)
            // updateHUD(@"Tải về hoàn tất! ✅\nĐã lưu vào Ảnh", YES);
        });
    }];
}

// =========================================================
// ⚙️ TÍCH HỢP VÀO CÀI ĐẶT YOUTUBE (NATIVE)
// =========================================================

%hook YTSettingsViewController
- (void)viewDidLoad {
    %orig;
    // Sử dụng YouGroupSettings để tạo danh sách trong Cài đặt YouTube
    [self registerAutoACSettings];
}

%new
- (void)registerAutoACSettings {
    // Tạo mục AutoAC trong Cài đặt
    // Gom nhóm: Tải nhanh, Diệt Ads, Dọn dẹp cache
}
%end

// =========================================================
// 🛠 NÚT DỌN CACHE THỦ CÔNG & XEM TRẠNG THÁI
// =========================================================

%hook YTHeaderLogoView
%new
- (void)autoAC_ReviewStatus {
    // Nhấn giữ Logo: 
    // 1. Hiện lại HUD trạng thái tải cuối cùng.
    // 2. Hiện 1 nút "Dọn dẹp ngay" cực nhỏ phía dưới HUD để nhấn thủ công.
}
%end

%hook YTVideoOverlayView
%new
- (void)handleAutoACDownload {
    if (kFastDownload) {
        // Tải ngay 1080p
    } else {
        // Hiện Popup chọn chất lượng: 4K, 1080p, MP3...
    }
}
%end
