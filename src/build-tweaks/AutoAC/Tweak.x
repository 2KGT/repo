#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// --- KHAI BÁO GIAO DIỆN CHUẨN (Sửa lỗi subviews) ---
@interface YTAdSlotContainerView : UIView
@end

@interface YTSlimVideoMetadataSectionView : UIView
@end

@interface YTHeaderLogoView : UIView
@end

@interface YTVideoOverlayView : UIView
@end

// --- BIẾN CẤU HÌNH ---
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
        // Bây giờ self.subviews đã có thể truy cập vì đã khai báo : UIView ở trên
        for (UIView *sub in self.subviews) {
            if ([NSStringFromClass([sub class]) containsString:@"Promotion"]) [sub setHidden:YES];
        }
    }
}
%end

// =========================================================
// 📥 LOGIC TẢI & THÔNG BÁO (Sửa lỗi Rung Haptic)
// =========================================================

static void finalizeDownload(NSURL *fileURL) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // Sửa lỗi: Sử dụng UINotificationFeedbackGenerator cho kiểu Success
                UINotificationFeedbackGenerator *haptic = [[UINotificationFeedbackGenerator alloc] init];
                [haptic notificationOccurred:UINotificationFeedbackTypeSuccess];
                
                kLastStatus = @"Tải về hoàn tất! ✅";
            } else {
                kLastStatus = @"Lỗi lưu video ❌";
            }
            // Gọi hàm cập nhật HUD của bạn ở đây
        });
    }];
}

// ... Các phần còn lại (HUD, Hook Player...) giữ nguyên như bản v5.5 ...
