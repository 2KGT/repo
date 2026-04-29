#import <AutoACHeader/AutoACHeader.h>
// Sau đó mới đến các logic Hook của ông giáo...

// Chặn Ads
%hook YTAdSlotContainerView
- (void)setHidden:(BOOL)hidden {
    %orig([kPrefs boolForKey:@"kHideEverything"] ? YES : hidden);
}
%end

// Nhấn giữ Logo
%hook YTHeaderLogoController
- (void)viewDidLoad {
    %orig;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handle2KGTMenu:)];
    [self.view addGestureRecognizer:longPress];
}

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"Trạng thái: Đang hoạt động\nCấu hình bởi 2KGT" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
%end

%ctor {
    %init(_ungrouped);
    if ([kPrefs boolForKey:@"kAutoClearCache"]) {
        [[NSFileManager defaultManager] removeItemAtPath:NSTemporaryDirectory() error:nil];
    }
}
