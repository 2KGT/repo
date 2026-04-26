#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- KHAI BÁO GIAO DIỆN ---
@interface YTSettingsSectionItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title titleDescription:(NSString *)desc accessibilityIdentifier:(id)arg3 detailTextBlock:(id)arg4 selectBlock:(BOOL (^)(id))block;
@end

@interface YTHeaderLogoView : UIView
@end

// =========================================================
// ⚙️ TÍCH HỢP CÀI ĐẶT (Sửa lỗi không hiển thị)
// =========================================================

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)desc {
    
    // Thay vì check số 1, ta check tiêu đề "General" (Chung) để đảm bảo luôn đúng mục
    if ([title isEqualToString:@"General"] || [title isEqualToString:@"Chung"] || category == 1) {
        
        YTSettingsSectionItem *autoACItem = [%c(YTSettingsSectionItem) 
            itemWithTitle:@"Cài đặt AutoAC" 
            titleDescription:@"Tải video, âm thanh và dọn rác" 
            accessibilityIdentifier:nil 
            detailTextBlock:nil 
            selectBlock:^BOOL(id arg1) {
                // Hiện thông báo test để biết cài đặt đã hoạt động
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AutoAC" message:@"Cài đặt đã sẵn sàng!" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [((UIViewController *)self) presentViewController:alert animated:YES completion:nil];
                return YES;
            }];
            
        [items addObject:autoACItem];
    }
    %orig(items, category, title, desc);
}
%end

// =========================================================
// 💎 NHẤN GIỮ LOGO (Sửa lỗi không phản hồi)
// =========================================================

%hook YTHeaderLogoView
- (void)layoutSubviews {
    %orig;
    self.userInteractionEnabled = YES; // Ép logo nhận tương tác
    
    // Kiểm tra nếu chưa có Gesture thì mới thêm vào để tránh trùng lặp
    BOOL hasGesture = NO;
    for (UIGestureRecognizer *g in self.gestureRecognizers) {
        if ([g isKindOfClass:[UILongPressGestureRecognizer class]]) {
            hasGesture = YES;
            break;
        }
    }
    
    if (!hasGesture) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAutoACLongPress:)];
        longPress.minimumPressDuration = 0.6; // Giảm xuống một chút để nhạy hơn
        [self addGestureRecognizer:longPress];
    }
}

%new
- (void)handleAutoACLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Rung nhẹ một cái để biết là đã nhận lệnh
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [feedback impactOccurred];
        
        // Hiện thông báo nhanh (HUD)
        UIAlertController *statusAlert = [UIAlertController alertControllerWithTitle:nil message:@"AutoAC: Đang kiểm tra trạng thái..." preferredStyle:UIAlertControllerStyleAlert];
        
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (top.presentedViewController) top = top.presentedViewController;
        
        [top presentViewController:statusAlert animated:YES completion:nil];
        
        // Tự đóng sau 1.5 giây
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [statusAlert dismissViewControllerAnimated:YES completion:nil];
        });
    }
}
%end

// =========================================================
// 🚀 KHỞI TẠO (QUAN TRỌNG NHẤT)
// =========================================================

%ctor {
    %init;
    // Đảm bảo Tweak được nạp vào đúng tiến trình YouTube
    NSLog(@"[AutoAC] Tweak đã được nạp thành công!");
}
