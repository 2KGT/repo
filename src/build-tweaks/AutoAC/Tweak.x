#import <AutoACheaders/AutoACheaders.h>

#define kPrefs [NSUserDefaults standardUserDefaults]

// 1. Chặn Ads
%hook YTAdSlotContainerView
- (void)setHidden:(BOOL)hidden {
    %orig([kPrefs boolForKey:@"kHideEverything"] ? YES : hidden);
}
%end

// 2. Nhấn giữ Logo hiện Dashboard
%hook YTHeaderLogoController
- (void)viewDidLoad {
    %orig;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handle2KGTMenu:)];
    [self.view addGestureRecognizer:longPress];
}
%end

// ... Các đoạn Hook bên trên ...

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"Trạng thái: Đang hoạt động\nCấu hình bởi 2KGT" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        
        [(UIViewController *)self presentViewController:alert animated:YES completion:nil];
    }
} // <--- Phải có dấu này để đóng hàm %new
%end // <--- Phải có %end để kết thúc Hook Logo

%ctor {
    %init(_ungrouped);

    // 1. Chào sân (Chỉ hiện 1 lần)
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kHasShown71"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            UIViewController *topVC = keyWindow.rootViewController;
            while (topVC.presentedViewController) topVC = topVC.presentedViewController;

            UIAlertController *hello = [UIAlertController alertControllerWithTitle:@"🏮 VÔ ẢNH PHONG THẦN" 
                                        message:@"Chào mừng ông giáo! Phiên bản 7.1 đã nạp thành công." 
                                        preferredStyle:UIAlertControllerStyleAlert];
            [hello addAction:[UIAlertAction actionWithTitle:@"Bắt đầu" style:UIAlertActionStyleDefault handler:nil]];
            [topVC presentViewController:hello animated:YES completion:nil];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHasShown71"];
        });
    }

    // 2. Xoá cache
    if ([kPrefs boolForKey:@"kAutoClearCache"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
            for (NSString *file in files) {
                [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file] error:nil];
            }
        });
    }
} // <--- Dấu ngoặc chốt hạ của %ctor
