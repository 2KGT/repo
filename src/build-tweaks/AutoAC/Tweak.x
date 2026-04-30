#import <AutoACheaders/AutoACheaders.h>
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>

// --- Khai báo Interface để Compiler nhận diện ---
@interface YTPivotBarItemView : UIView
- (NSString *)accessibilityLabel;
@end

%hook YTPivotBarItemView

- (void)layoutSubviews {
    %orig;
    
    NSString *label = [self accessibilityLabel];
    // Kiểm tra nhãn nút Trang chủ (đa ngôn ngữ)
    if ([label isEqualToString:@"Trang chủ"] || [label isEqualToString:@"Home"] || [label isEqualToString:@"首页"]) {
        
        static char const * const k2KGTGestureKey = "k2KGTGestureKey";
        UILongPressGestureRecognizer *existingGesture = objc_getAssociatedObject(self, k2KGTGestureKey);
        
        if (!existingGesture) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handle2KGTMenu:)];
            longPress.minimumPressDuration = 0.7;
            [self addGestureRecognizer:longPress];
            
            objc_setAssociatedObject(self, k2KGTGestureKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        AudioServicesPlaySystemSound(1519); // Rung Haptic
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"🏮 VÔ ẢNH PHONG THẦN\nCấu hình bởi 2KGT" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        
        // --- Lấy Window chuẩn cho iOS 13+ ---
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in windowScene.windows) {
                        if (w.isKeyWindow) {
                            window = w;
                            break;
                        }
                    }
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;
        
        UIViewController *topVC = window.rootViewController;
        while (topVC.presentedViewController) topVC = topVC.presentedViewController;
        
        [topVC presentViewController:alert animated:YES completion:nil];
    }
}
%end

%ctor {
    %init(_ungrouped);
    // Rung máy báo hiệu tweak đã nạp thành công
    AudioServicesPlaySystemSound(1521); 
}
