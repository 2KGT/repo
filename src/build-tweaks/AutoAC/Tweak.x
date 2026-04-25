#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTHeaderView : UIView
@end
@interface FBNavigationBarTitleView : UIView
@end

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static BOOL isYouTube = NO;
static BOOL isFacebook = NO;

// =========================================================
// 🚀 HỆ THỐNG DỌN DẸP CHIẾN LƯỢC
// =========================================================

static void performDeepClean(BOOL isAuto) {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *homePath = NSHomeDirectory();
    
    // Các đường dẫn rác mục tiêu
    NSArray *trashPaths = @[
        @"/Library/Caches",
        @"/Library/Application Support/YouTube",
        @"/Library/Application Support/Google/YouTube",
        @"/tmp",
        @"/Library/Caches/com.facebook.Facebook",
        @"/Library/Application Support/FBInternal"
    ];
    
    for (NSString *relPath in trashPaths) {
        NSString *fullPath = [homePath stringByAppendingPathComponent:relPath];
        if ([fm fileExistsAtPath:fullPath]) {
            NSArray *contents = [fm contentsOfDirectoryAtPath:fullPath error:nil];
            for (NSString *file in contents) {
                [fm removeItemAtPath:[fullPath stringByAppendingPathComponent:file] error:nil];
            }
        }
    }

    if (!isAuto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *done = [UIAlertController alertControllerWithTitle:@"Hoàn tất" 
                                            message:@"Hệ thống đã được làm sạch hoàn toàn" 
                                            preferredStyle:UIAlertControllerStyleAlert];
            [done addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            UIViewController *top = window.rootViewController;
            while(top.presentedViewController) top = top.presentedViewController;
            [top presentViewController:done animated:YES completion:nil];
        });
    }
}

#pragma mark - 📱 TỰ ĐỘNG TỐI ƯU (FIXED)

@interface AutoACManager : NSObject
@end
@implementation AutoACManager
+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runAuto) name:UIApplicationDidBecomeActiveNotification object:nil];
}
+ (void)runAuto {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey]) {
        // Tự động chạy lệnh Dọn Sâu sau 3 giây để đảm bảo MB thực sự giảm
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            performDeepClean(YES);
        });
    }
}
@end

#pragma mark - 💎 GIAO DIỆN KÍNH LỎNG (LIQUID GLASS)

static void showAutoACMenu() {
    // Thiết kế tối giản, sạch sẽ, chuẩn ngôn ngữ thiết kế iOS mới
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TỐI ƯU HỆ THỐNG" 
                                            message:@"Thiết lập quản lý tài nguyên" 
                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Nút Dọn dẹp sâu
    [alert addAction:[UIAlertAction actionWithTitle:@"Dọn dẹp sâu" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean(NO);
    }]];
    
    // Nút trạng thái mô phỏng công tắc gạt
    BOOL currentStatus = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    NSString *statusText = currentStatus ? @"Tự động: Đang Bật" : @"Tự động: Đang Tắt";
    
    [alert addAction:[UIAlertAction actionWithTitle:statusText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentStatus forKey:kAutoCSmartCleanKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // Hiện lại menu ngay lập tức để tạo hiệu ứng chuyển đổi kính lỏng
        showAutoACMenu();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy bỏ" style:UIAlertActionStyleCancel handler:nil]];

    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* s in [UIApplication sharedApplication].connectedScenes)
            if (s.activationState == UISceneActivationStateForegroundActive)
                for (UIWindow* w in s.windows) if (w.isKeyWindow) { window = w; break; }
    }
    if(!window) window = [UIApplication sharedApplication].windows.firstObject;
    
    UIViewController *top = window.rootViewController;
    while(top.presentedViewController) top = top.presentedViewController;
    
    [top presentViewController:alert animated:YES completion:nil];
}

// --- HOOK KÍCH HOẠT ---
%hook YTHeaderView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    UIView *v = (UIView *)self;
    CGPoint loc = [[touches anyObject] locationInView:v];
    // Kích hoạt khi chạm vào khu vực logo (1/3 bên trái)
    if (loc.x < v.frame.size.width / 3.0) showAutoACMenu();
}
%end

%hook FBNavigationBarTitleView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

%ctor {
    @autoreleasepool {
        NSString *bid = [[NSBundle mainBundle] bundleIdentifier];
        isYouTube = [bid isEqualToString:@"com.google.ios.youtube"];
        isFacebook = [bid isEqualToString:@"com.facebook.Facebook"];
        if (isYouTube || isFacebook) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoCSmartCleanKey] == nil)
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoCSmartCleanKey];
        }
    }
}
