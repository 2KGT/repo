#import <UIKit/UIKit.h>

// Logic nhấn giữ Logo & Nút tải
%hook YTHeaderLogoController
- (void)viewDidLoad {
    %orig;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAutoACDashboard:)];
    [self.view addGestureRecognizer:longPress];
}

%new
- (void)handleAutoACDashboard:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Hiện thông báo trạng thái hoặc nút dọn rác nhanh
    }
}
%end

// Thực thi Chặn Ads (Lấy giá trị từ Settings.x qua NSUserDefaults)
%hook YTAdSlotContainerView
- (void)setHidden:(BOOL)hidden {
    BOOL shouldHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideAds"];
    %orig(shouldHide ? YES : hidden);
}
%end

%ctor {
    %init;
    // Tự động dọn rác nếu bật công tắc
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoClearCache"]) {
        [[NSFileManager defaultManager] removeItemAtPath:NSTemporaryDirectory() error:nil];
    }
}
