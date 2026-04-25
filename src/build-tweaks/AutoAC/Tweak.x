#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTHeaderView : UIView
@end
@interface FBNavigationBarTitleView : UIView
@end

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static NSString *const kRemoveAdsKey = @"AutoC_RemoveAds_Enabled";

// =========================================================
// 🚀 LOGIC XOÁ RÁC CHIẾN LƯỢC
// =========================================================

static void performDeepClean(BOOL isAuto) {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *homePath = NSHomeDirectory();
    
    NSArray *trashPaths = @[@"/Library/Caches", @"/Library/Application Support/YouTube", @"/tmp", @"/Library/Caches/com.facebook.Facebook"];
    
    for (NSString *relPath in trashPaths) {
        NSString *fullPath = [homePath stringByAppendingPathComponent:relPath];
        if ([fm fileExistsAtPath:fullPath]) {
            NSArray *contents = [fm contentsOfDirectoryAtPath:fullPath error:nil];
            for (NSString *file in contents) [fm removeItemAtPath:[fullPath stringByAppendingPathComponent:file] error:nil];
        }
    }

    if (!isAuto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *done = [UIAlertController alertControllerWithTitle:@"Hoàn tất" message:@"Hệ thống đã được làm sạch" preferredStyle:UIAlertControllerStyleAlert];
            [done addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            UIViewController *top = window.rootViewController;
            while(top.presentedViewController) top = top.presentedViewController;
            [top presentViewController:done animated:YES completion:nil];
        });
    }
}

#pragma mark - 💎 GIAO DIỆN CÔNG TẮC (LIQUID GLASS)

@interface AutoACSettingsVC : UIViewController
@end

@implementation AutoACSettingsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Công tắc 1: Tự động tối ưu
    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
    l1.text = @"Tự động tối ưu";
    l1.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:l1];

    UISwitch *sw1 = [[UISwitch alloc] init];
    sw1.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    [sw1 addTarget:self action:@selector(autoCleanChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sw1];
    sw1.translatesAutoresizingMaskIntoConstraints = NO;

    // Công tắc 2: Xoá Ads banner tag
    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 200, 30)];
    l2.text = @"Xoá Ads banner tag";
    l2.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:l2];

    UISwitch *sw2 = [[UISwitch alloc] init];
    sw2.on = [[NSUserDefaults standardUserDefaults] boolForKey:kRemoveAdsKey];
    [sw2 addTarget:self action:@selector(removeAdsChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sw2];
    sw2.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [sw1.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-25],
        [sw1.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10],
        [sw2.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-25],
        [sw2.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:55]
    ]];
}

- (void)autoCleanChanged:(UISwitch *)s {
    [[NSUserDefaults standardUserDefaults] setBool:s.isOn forKey:kAutoCSmartCleanKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAdsChanged:(UISwitch *)s {
    [[NSUserDefaults standardUserDefaults] setBool:s.isOn forKey:kRemoveAdsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

static void showAutoACMenu() {
    // Tiêu đề Tối ưu hệ thống (Chữ thường)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tối ưu hệ thống" message:@"\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    
    AutoACSettingsVC *settingsVC = [[AutoACSettingsVC alloc] init];
    settingsVC.preferredContentSize = CGSizeMake(270, 100);
    [alert setValue:settingsVC forKey:@"contentViewController"];
    
    // --- NÚT XOÁ THỦ CÔNG (DÒNG CHỮ ĐỎ ĐÂY RỒI) ---
    [alert addAction:[UIAlertAction actionWithTitle:@"Dọn dẹp sâu" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean(NO);
    }]];
    
    // Nút Đóng thay cho Hủy bỏ
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];

    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* s in [UIApplication sharedApplication].connectedScenes)
            if (s.activationState == UISceneActivationStateForegroundActive)
                for (UIWindow* w in s.windows) if (w.isKeyWindow) { window = w; break; }
    }
    UIViewController *top = window.rootViewController;
    while(top.presentedViewController) top = top.presentedViewController;
    [top presentViewController:alert animated:YES completion:nil];
}

// --- HOOKS ---
%hook YTHeaderView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    UIView *v = (UIView *)self;
    if ([[touches anyObject] locationInView:v].x < v.frame.size.width / 3.0) showAutoACMenu();
}
%end

%hook FBNavigationBarTitleView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    showAutoACMenu();
}
%end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                performDeepClean(YES);
            });
        }
    }];
}
