#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Ép kiểu để trình biên dịch không bắt lỗi class lạ
@interface UIView (AutoAC)
- (UIViewController *)_viewControllerForAncestor;
@end

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static NSString *const kRemoveAdsKey = @"AutoC_RemoveAds_Enabled";

// =========================================================
// 🚀 LOGIC DỌN DẸP
// =========================================================

static void performDeepClean(BOOL isAuto) {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    // Quét sạch các thư mục rác
    NSArray *targets = @[@"com.google.ios.youtube", @"com.facebook.Facebook", @"tmp"];
    for (NSString *target in targets) {
        NSString *path = [cachePath stringByAppendingPathComponent:target];
        [fm removeItemAtPath:path error:nil];
    }
}

#pragma mark - 💎 GIAO DIỆN & KÍCH HOẠT

static void showAutoACMenu(UIView *fromView) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tối ưu hệ thống" 
                                                                   message:@"Thiết lập quản lý tài nguyên" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Dọn dẹp sâu" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean(NO);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];

    // Tìm ViewController để hiển thị
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *top = window.rootViewController;
    while (top.presentedViewController) top = top.presentedViewController;
    [top presentViewController:alert animated:YES completion:nil];
}

// =========================================================
// 🛠 HOOK "DIỆT" LỖI: SỬ DỤNG GESTURE THAY VÌ TOUCHES
// =========================================================

// Hook vào trung tâm tiêu đề của cả 2 app
%hook UINavigationBar
- (void)layoutSubviews {
    %orig;
    
    // Kiểm tra xem đã gắn nút kích hoạt chưa để tránh gắn trùng
    BOOL alreadyHasGesture = NO;
    for (UIGestureRecognizer *g in self.gestureRecognizers) {
        if ([g.name isEqualToString:@"AutoACGesture"]) {
            alreadyHasGesture = YES;
            break;
        }
    }
    
    if (!alreadyHasGesture) {
        // Tạo một vùng nhấn giữ (Long Press) 1 giây vào Header để hiện Menu
        // Cách này cực kỳ ổn định và không sợ nhấn nhầm khi lướt app
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAutoACGesture:)];
        longPress.minimumPressDuration = 1.0;
        longPress.name = @"AutoACGesture";
        [self addGestureRecognizer:longPress];
    }
}

%new
- (void)handleAutoACGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        showAutoACMenu(self);
    }
}
%end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey]) {
            performDeepClean(YES);
        }
    }];
}
