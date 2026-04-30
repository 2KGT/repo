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
    
    // Thêm check Class Name cho chắc chắn là trúng đích
    if ([self.class.description containsString:@"YTPivotBarItemView"]) {
        NSString *label = [self accessibilityLabel];
        if ([label isEqualToString:@"Trang chủ"] || [label isEqualToString:@"Home"] || [label isEqualToString:@"首页"]) {
            
            static char const * const k2KGTGestureKey = "k2KGTGestureKey";
            if (!objc_getAssociatedObject(self, k2KGTGestureKey)) {
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] 
                    initWithTarget:self action:@selector(handle2KGTMenu:)];
                longPress.minimumPressDuration = 0.7;
                [self addGestureRecognizer:longPress];
                objc_setAssociatedObject(self, k2KGTGestureKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
}

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        AudioServicesPlaySystemSound(1519);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"🏮 VÔ ẢNH PHONG THẦN\nCấu hình bởi 2KGT" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;
        
        UIViewController *topVC = window.rootViewController;
        while (topVC.presentedViewController) topVC = topVC.presentedViewController;
        [topVC presentViewController:alert animated:YES completion:nil];
    }
}
%end

%ctor {
    %init(_ungrouped);
    AudioServicesPlaySystemSound(1521); 
}
