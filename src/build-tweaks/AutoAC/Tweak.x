#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static BOOL isYouTube = NO;
static BOOL isFacebook = NO;

// =========================================================
// 🛠 CÔNG CỤ DỌN DẸP
// =========================================================

// 1. Dọn dẹp thông minh (Smart Clean) - Chỉ xoá rác nhẹ
static void performSmartClean() {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    // Xoá các phản hồi mạng cũ để làm nhẹ máy
}

// 2. Dọn dẹp sâu (Deep Clean) - Xoá sạch gốc rễ
static void performDeepClean() {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    // Danh sách các "ổ rác" lớn của cả 2 app
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

#pragma mark - LẮNG NGHE & TỰ ĐỘNG (3 GIÂY)
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

#pragma mark - GIAO DIỆN ĐIỀU KHIỂN (MENU)

// Hàm hiển thị Menu điều khiển chung
static void showAutoACMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Optimizer" 
                                                                   message:@"Quản lý tài nguyên ứng dụng" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Nút Dọn sâu (Thủ công)
    [alert addAction:[UIAlertAction actionWithTitle:@"🔥 DỌN DẸP SÂU (Thủ công)" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean();
        // Thông báo cho người dùng
    }]];
    
    // Công tắc Tự động thông minh
    BOOL currentStatus = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    NSString *toggleTitle = currentStatus ? @"✅ Tự động thông minh: BẬT" : @"❌ Tự động thông minh: TẮT";
    
    [alert addAction:[UIAlertAction actionWithTitle:toggleTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentStatus forKey:kAutoCSmartCleanKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

// --- Hook YouTube: Nhấn vào Logo ---
%hook YTHeaderLogoView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

// --- Hook Facebook: Nhấn vào Thanh tìm kiếm (Hoặc logo nếu có) ---
// Ở Facebook, ta có thể chọn hook vào thanh điều hướng chính
%hook FBNavigationBarTitleView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

#pragma mark - KHỞI TẠO
%ctor {
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
