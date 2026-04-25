#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static BOOL isYouTube = NO;
static BOOL isFacebook = NO;

// =========================================================
// 🛠 CÔNG CỤ DỌN DẸP THÔNG MINH & SÂU
// =========================================================

static void performSmartClean() {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

static void performDeepClean() {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
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

#pragma mark - 🚀 TỰ ĐỘNG DỌN DẸP (3 GIÂY)
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

#pragma mark - 📱 GIAO DIỆN ĐIỀU KHIỂN (FIX DEPRECATED)

static void showAutoACMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Optimizer" 
                                                                   message:@"Quản lý tài nguyên ứng dụng" 
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
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];

    // --- ĐOẠN MÃ SỬA LỖI .keyWindow (CÁCH 1) ---
    UIViewController *topController = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        topController = window.rootViewController;
                        break;
                    }
                }
            }
        }
    } else {
        topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }

    if (topController) {
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:alert animated:YES completion:nil];
    }
}

// --- Hook YouTube & Facebook ---
%hook YTHeaderLogoView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

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
        if ([bundleID isEqualToString:@"com.google.ios.youtube"]) {
            isYouTube = YES;
        } else if ([bundleID isEqualToString:@"com.facebook.Facebook"]) {
            isFacebook = YES;
        }

        if (isYouTube || isFacebook) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoCSmartCleanKey] == nil) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoCSmartCleanKey];
            }
        }
    }
}
