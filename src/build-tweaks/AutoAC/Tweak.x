#import <AutoACheaders/AutoACheaders.h>
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>

@interface YTPivotBarItemView : UIView
- (NSString *)accessibilityLabel;
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender;
@end

%hook YTPivotBarItemView

- (void)layoutSubviews {
    %orig;
    
    // Tối ưu nhận diện: Kiểm tra label của nút dưới đáy
    NSString *label = [self accessibilityLabel];
    if ([label isEqualToString:@"Trang chủ"] || [label isEqualToString:@"Home"] || [label isEqualToString:@"首页"]) {
        
        static char const * const k2KGTGestureKey = "k2KGTGestureKey";
        UILongPressGestureRecognizer *existingGesture = objc_getAssociatedObject(self, k2KGTGestureKey);
        
        if (!existingGesture) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] 
                initWithTarget:self action:@selector(handle2KGTMenu:)];
            longPress.minimumPressDuration = 0.7; // 0.7 giây để kích hoạt
            [self addGestureRecognizer:longPress];
            
            objc_setAssociatedObject(self, k2KGTGestureKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        AudioServicesPlaySystemSound(1519); // Rung nhẹ báo hiệu
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"🏮 VÔ ẢNH PHONG THẦN\nCấu hình bởi 2KGT" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        
        // Tìm cửa sổ để hiện Alert (Chống văng trên iOS 14+)
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in windowScene.windows) {
                        if (w.isKeyWindow) { window = w; break; }
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
    // Rung 1521 (Success) để ông giáo biết tweak đã tiêm vào thành công
    AudioServicesPlaySystemSound(1521); 
}
