#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- KHAI BÁO THEO PHONG CÁCH IDA ---
@interface YTHeaderLogoView : UIView
@property(retain, nonatomic) UIView *logoButton; // YouTube thường bọc logo trong một button
@end

@interface YTSettingsSectionItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title titleDescription:(NSString *)desc accessibilityIdentifier:(id)arg3 detailTextBlock:(id)arg4 selectBlock:(BOOL (^)(id))block;
@end

// Khai báo thêm để xử lý Menu Cài đặt
@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(NSMutableArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)desc;
@end

// =========================================================
// ⚙️ FIX CÀI ĐẶT (HOOK TRỰC TIẾP VÀO DATA SOURCE)
// =========================================================

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)desc {
    // Chèn vào mục "General" (Thường là category 1)
    if (category == 1) {
        YTSettingsSectionItem *autoACItem = [%c(YTSettingsSectionItem) 
            itemWithTitle:@"AutoAC" 
            titleDescription:@"Cấu hình tải & dọn dẹp" 
            accessibilityIdentifier:nil 
            detailTextBlock:nil 
            selectBlock:^BOOL(id arg1) {
                // Hiện menu cài đặt gọn gàng
                return YES;
            }];
        [items addObject:autoACItem];
    }
    %orig(items, category, title, desc);
}
%end

// =========================================================
// 💎 FIX NHẤN GIỮ (WAKE-UP CƯỠNG BỨC)
// =========================================================

%hook YTHeaderLogoView
- (void)didMoveToWindow {
    %orig;
    if (self.window) {
        self.userInteractionEnabled = YES;
        // YouTube hay dùng một lớp subview để nhận tap, ta hook vào đó
        for (UIView *sub in self.subviews) {
            sub.userInteractionEnabled = NO; // Tắt bớt cản trở nếu cần
        }
        
        // Thêm Gesture trực tiếp vào View chính
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAutoACLongPress:)];
        lp.minimumPressDuration = 0.7;
        [self addGestureRecognizer:lp];
    }
}

%new
- (void)handleAutoACLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Rung nhẹ phản hồi
        UIImpactFeedbackGenerator *haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [haptic impactOccurred];
        
        // Hiện trạng thái cuối (HUD)
        NSLog(@"[AutoAC] Logo Pressed!");
        // Gọi hàm updateHUD của bạn ở đây
    }
}
%end

// =========================================================
// 🚀 CONSTRUCTOR (BẮT BUỘC)
// =========================================================

%ctor {
    // Đảm bảo YouTube đã load xong class
    %init(YTHeaderLogoView = objc_getClass("YTHeaderLogoView") ?: objc_getClass("YTRightAlignedHeaderLogoView"),
          YTSettingsViewController = objc_getClass("YTSettingsViewController"),
          YTSettingsSectionItem = objc_getClass("YTSettingsSectionItem"));
}
