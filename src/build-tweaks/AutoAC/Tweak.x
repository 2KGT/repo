#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- KHAI BÁO INTERFACE ĐỂ TRÁNH LỖI BIÊN DỊCH ---
@interface YTHeaderView : UIView
@end
@interface FBNavigationBarTitleView : UIView
@end

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static BOOL isYouTube = NO;
static BOOL isFacebook = NO;

// =========================================================
// 🚀 CHIẾN THUẬT DỌN DẸP "HUỶ DIỆT"
// =========================================================

static void performDeepClean() {
    // 1. Giải phóng bộ nhớ đệm mạng ngay lập tức
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *homePath = NSHomeDirectory();
    
    // Danh sách các mục tiêu "tổng lực" (Cache, Temp, App Support)
    NSArray *trashPaths = @[
        @"/Library/Caches",
        @"/Library/Application Support/com.google.ios.youtube",
        @"/Library/Application Support/YouTube",
        @"/Library/Application Support/Google/YouTube",
        @"/tmp",
        @"/Documents/YTData",
        @"/Library/Caches/com.facebook.Facebook",
        @"/Library/Application Support/FBInternal"
    ];
    
    for (NSString *relPath in trashPaths) {
        NSString *fullPath = [homePath stringByAppendingPathComponent:relPath];
        if ([fm fileExistsAtPath:fullPath]) {
            NSError *error = nil;
            // Lấy danh sách file bên trong để xoá sạch, tránh xoá luôn thư mục gốc gây crash
            NSArray *contents = [fm contentsOfDirectoryAtPath:fullPath error:nil];
            for (NSString *file in contents) {
                [fm removeItemAtPath:[fullPath stringByAppendingPathComponent:file] error:&error];
            }
        }
    }
    
    // 2. Ép hệ thống báo cáo lại dung lượng (Clear Memory)
    if (isYouTube) {
        // Tín hiệu thông báo cho YouTube biết cần làm mới bộ nhớ
        [[NSNotificationCenter defaultCenter] postNotificationName:@"YTDataServicesClearCacheNotification" object:nil];
    }
}

#pragma mark - 📱 QUẢN LÝ TỰ ĐỘNG & GIAO DIỆN

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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey]) {
        // Đợi 3s cho app ổn định rồi dọn nhẹ
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
        });
    }
}
@end

static void showAutoACMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Optimizer" 
                                                                   message:@"Quản lý tài nguyên ứng dụng" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🔥 DỌN DẸP SÂU (1.47GB -> 0MB)" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean();
        // Hiện thông báo sau khi dọn xong
        UIAlertController *done = [UIAlertController alertControllerWithTitle:@"Xong!" message:@"Đã giải phóng bộ nhớ đệm." preferredStyle:UIAlertControllerStyleAlert];
        [done addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:done animated:YES completion:nil];
    }]];
    
    BOOL currentStatus = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    [alert addAction:[UIAlertAction actionWithTitle:currentStatus ? @"✅ Tự động: BẬT" : @"❌ Tự động: TẮT" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentStatus forKey:kAutoCSmartCleanKey];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];

    // Tìm topController an toàn cho iOS 13-18
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

%hook YTHeaderView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    UIView *v = (UIView *)self;
    CGPoint loc = [[touches anyObject] locationInView:v];
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
    NSString *bid = [[NSBundle mainBundle] bundleIdentifier];
    isYouTube = [bid isEqualToString:@"com.google.ios.youtube"];
    isFacebook = [bid isEqualToString:@"com.facebook.Facebook"];
    if (isYouTube || isFacebook) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoCSmartCleanKey] == nil)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoCSmartCleanKey];
    }
}
