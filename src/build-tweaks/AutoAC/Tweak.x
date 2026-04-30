#import <AutoACheaders/AutoACheaders.h>
#import <AudioToolbox/AudioToolbox.h>

%hook YTPivotBarItemView

- (void)layoutSubviews {
    %orig;
    
    // Feather + Dev Cert đôi khi làm chậm quá trình nạp, dùng thêm check tên class cho chắc
    NSString *label = [self accessibilityLabel];
    if ([label isEqualToString:@"Trang chủ"] || [label isEqualToString:@"Home"] || [label isEqualToString:@"首页"]) {
        
        static char const * const k2KGTGestureKey = "k2KGTGestureKey";
        UILongPressGestureRecognizer *existingGesture = objc_getAssociatedObject(self, k2KGTGestureKey);
        
        if (!existingGesture) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handle2KGTMenu:)];
            longPress.minimumPressDuration = 0.7; // Giảm xuống 0.7s cho nhạy
            [self addGestureRecognizer:longPress];
            
            // Dùng Associated Object để chặn trùng lặp cử chỉ
            objc_setAssociatedObject(self, k2KGTGestureKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        AudioServicesPlaySystemSound(1519); // Rung báo hiệu
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"🏮 VÔ ẢNH PHONG THẦN\nCấu hình bởi 2KGT" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        
        // Cách hiện Alert "bất tử" cho mọi loại chứng chỉ
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
    // Rung máy ngay khi nạp xong để ông giáo biết Feather đã tiêm thành công
    AudioServicesPlaySystemSound(1521); 
}
