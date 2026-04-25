#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static BOOL isYouTube = NO;
static BOOL isFacebook = NO;

// =========================================================
// 🛠 CÔNG CỤ DỌN DẸP SÂU & THÔNG MINH
// =========================================================

static void performDeepClean() {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSArray *allTrash = @[
        @"com.google.ios.youtube", @"YouTube", @"YTData", @"v3", @"Storage",
        @"com.facebook.Facebook", @"FBCache", @"FBMediaCache", @"FBVideoCache", @"FBInternal"
    ];
    
    for (NSString *folder in allTrash) {
        NSString *fullPath = [cachePath stringByAppendingPathComponent:folder];
        if ([fm fileExistsAtPath:fullPath]) {
            [fm removeItemAtPath:fullPath error:nil];
            [fm createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

#pragma mark - 📱 GIAO DIỆN ĐIỀU KHIỂN (FIXED)

static void showAutoACMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Optimizer" 
                                                                   message:@"Hệ thống quản lý tài nguyên" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🔥 DỌN DẸP SÂU (Thủ công)" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean();
    }]];
    
    BOOL currentStatus = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    NSString *toggleTitle = currentStatus ? @"✅ Tự động thông minh: BẬT" : @"❌ Tự động thông minh: TẮT";
    
    [alert addAction:[UIAlertAction actionWithTitle:toggleTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentStatus forKey:kAutoCSmartCleanKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];

    // --- XỬ LÝ HIỂN THỊ CHỐNG LỖI DEPRECATED ---
    UIWindow *foundWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) { foundWindow = window; break; }
                }
            }
            if (foundWindow) break;
        }
    }
    if (!foundWindow) foundWindow = [UIApplication sharedApplication].windows.firstObject;

    UIViewController *topController = foundWindow.rootViewController;
    if (topController) {
        while (topController.presentedViewController) topController = topController.presentedViewController;
        [topController presentViewController:alert animated:YES completion:nil];
    }
}

// =========================================================
// 🏗 HOOK GIAO DIỆN THEO CHUẨN MỚI
// =========================================================

// YouTube: Hook vào YTHeaderView (Lớp cha chứa Logo)
%hook YTHeaderView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    // Nhấn vào 1/3 bên trái (Khu vực Logo) để hiện Menu
    if (location.x < self.frame.size.width / 3.0) {
        showAutoACMenu();
    }
}
%end

// Facebook: Hook vào FBNavigationBarTitleView (Thanh tiêu đề chính)
%hook FBNavigationBarTitleView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

#pragma mark - KHỞI TẠO
%ctor {
    @autoreleasepool {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        isYouTube = [bundleID isEqualToString:@"com.google.ios.youtube"];
        isFacebook = [bundleID isEqualToString:@"com.facebook.Facebook"];

        if (isYouTube || isFacebook) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoCSmartCleanKey] == nil) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoCSmartCleanKey];
            }
        }
    }
}
