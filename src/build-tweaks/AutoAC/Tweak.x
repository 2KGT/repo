#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- BIẾN TOÀN CỤC ---
static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static BOOL isYouTube = NO;
static BOOL isFacebook = NO;

// =========================================================
// 🛠 CÔNG CỤ DỌN DẸP "TOP PIG" (THÔNG MINH & SÂU)
// =========================================================

// 1. Dọn dẹp thông minh (Chạy tự động sau 3s)
static void performSmartClean() {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

// 2. Dọn dẹp sâu (Chạy thủ công khi nhấn nút)
static void performDeepClean() {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    // Quét sạch các ổ rác lỳ lợm nhất của cả 2 app
    NSArray *allTrash = @[
        @"com.google.ios.youtube", @"YouTube", @"YTData", @"v3", @"Storage",
        @"com.facebook.Facebook", @"FBCache", @"FBMediaCache", @"FBVideoCache", @"FBInternal", @"MsysQueries"
    ];
    
    for (NSString *folder in allTrash) {
        NSString *fullPath = [cachePath stringByAppendingPathComponent:folder];
        if ([fm fileExistsAtPath:fullPath]) {
            [fm removeItemAtPath:fullPath error:nil];
            [fm createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

#pragma mark - 🚀 QUẢN LÝ TỰ ĐỘNG (DELAY 3S)
@interface AutoACManager : NSObject
@end

@implementation AutoACManager
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self 
            selector:@selector(startAutoClean) 
            name:UIApplicationDidBecomeActiveNotification 
            object:nil];
    });
}

+ (void)startAutoClean {
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    if (isEnabled && (isYouTube || isFacebook)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            performSmartClean();
        });
    }
}
@end

#pragma mark - 📱 GIAO DIỆN ĐIỀU KHIỂN (FIXED FOR iOS 18+)

static void showAutoACMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Optimizer" 
                                                                   message:@"Hệ thống quản lý tài nguyên" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Nút dọn sâu (Deep Clean)
    [alert addAction:[UIAlertAction actionWithTitle:@"🔥 DỌN DẸP SÂU (Thủ công)" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean();
    }]];
    
    // Công tắc tự động (Smart Clean)
    BOOL currentStatus = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    NSString *toggleTitle = currentStatus ? @"✅ Tự động thông minh: BẬT" : @"❌ Tự động thông minh: TẮT";
    
    [alert addAction:[UIAlertAction actionWithTitle:toggleTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentStatus forKey:kAutoCSmartCleanKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];

    // --- XỬ LÝ HIỂN THỊ CHỐNG LỖI DEPRECATED ---
    UIViewController *topController = nil;
    UIWindow *foundWindow = nil;

    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        foundWindow = window;
                        break;
                    }
                }
            }
            if (foundWindow) break;
        }
    }
    
    if (!foundWindow) {
        foundWindow = [UIApplication sharedApplication].windows.firstObject;
    }

    topController = foundWindow.rootViewController;

    if (topController) {
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:alert animated:YES completion:nil];
    }
}

// --- HOOK GIAO DIỆN ---

// YouTube: Nhấn vào Logo
%hook YTHeaderLogoView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

// Facebook: Nhấn vào Thanh điều hướng (Title View)
%hook FBNavigationBarTitleView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

#pragma mark - KHỞI TẠO HỆ THỐNG
%ctor {
    @autoreleasepool {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        if ([bundleID isEqualToString:@"com.google.ios.youtube"]) {
            isYouTube = YES;
        } else if ([bundleID isEqualToString:@"com.facebook.Facebook"]) {
            isFacebook = YES;
        }

        if (isYouTube || isFacebook) {
            // Mặc định bật tự động thông minh khi mới cài đặt
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoCSmartCleanKey] == nil) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoCSmartCleanKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}
