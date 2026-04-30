#import <AutoACheaders/AutoACheaders.h>
#import <AudioToolbox/AudioToolbox.h>

// --- 1. HOOK VÀO THANH ĐIỀU HƯỚNG DƯỚI (PIVOT BAR) ---
%hook YTPivotBarItemView

- (void)layoutSubviews {
    %orig;
    
    // Kiểm tra nếu đây là nút "Trang chủ" (thường có accessibilityIdentifier hoặc label là "Trang chủ" hoặc "Home")
    NSString *label = [self accessibilityLabel];
    if ([label isEqualToString:@"Trang chủ"] || [label isEqualToString:@"Home"]) {
        
        // Kiểm tra xem đã gắn cử chỉ chưa (tránh gắn trùng nhiều lần)
        BOOL hasGesture = NO;
        for (UIGestureRecognizer *gest in self.gestureRecognizers) {
            if ([gest isKindOfClass:[UILongPressGestureRecognizer class]]) {
                hasGesture = YES;
                break;
            }
        }
        
        if (!hasGesture) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handle2KGTMenu:)];
            longPress.minimumPressDuration = 0.8; // Nhấn giữ 0.8 giây là hiện
            [self addGestureRecognizer:longPress];
        }
    }
}

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Rung máy báo hiệu "linh nghiệm"
        AudioServicesPlaySystemSound(1519);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"Cấu hình bởi 2KGT\nNhấn giữ Trang chủ thành công!" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        
        // Tìm ViewController để hiển thị
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (!root) root = [[[[UIApplication sharedApplication] connectedScenes] allObjects].firstObject.windows.firstObject rootViewController];
        
        [root presentViewController:alert animated:YES completion:nil];
    }
}
%end

%ctor {
    %init(_ungrouped);
    NSLog(@"--- [2KGT] Chuyen sang he Cam coc Trang chu ---");
}
