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
// 🚀 LOGIC XOÁ RÁC
// =========================================================

static void performDeepClean(BOOL isAuto) {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *homePath = NSHomeDirectory();
    
    NSArray *trashPaths = @[@"/Library/Caches", @"/Library/Application Support/YouTube", @"/Library/Application Support/Google/YouTube", @"/tmp", @"/Library/Caches/com.facebook.Facebook"];
    
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
            
            UIViewController *top = [UIApplication sharedApplication].windows.firstObject.rootViewController;
            while(top.presentedViewController) top = top.presentedViewController;
            [top presentViewController:done animated:YES completion:nil];
        });
    }
}

#pragma mark - 💎 GIAO DIỆN CÔNG TẮC GẠT (LIQUID SWITCH)

@interface AutoACSwitchVC : UIViewController
@property (nonatomic, strong) UISwitch *toggle;
@end

@implementation AutoACSwitchVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Tạo nhãn văn bản
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 150, 30)];
    label.text = @"Tự động tối ưu";
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];

    // Tạo nút công tắc gạt chuẩn iOS
    self.toggle = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 150, 10, 0, 0)];
    self.toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.toggle];
    
    // Tự động căn chỉnh nút gạt sang phải (Auto Layout đơn giản)
    self.toggle.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.toggle.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-25],
        [self.toggle.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)switchChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:kAutoCSmartCleanKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

static void showAutoACMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tối ưu hệ thống" message:@"\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Chèn ViewController chứa nút gạt vào Action Sheet
    AutoACSwitchVC *switchVC = [[AutoACSwitchVC alloc] init];
    switchVC.preferredContentSize = CGSizeMake(270, 50);
    [alert setValue:switchVC forKey:@"contentViewController"];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Dọn dẹp sâu" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean(NO);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy bỏ" style:UIAlertActionStyleCancel handler:nil]];

    UIViewController *top = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* s in [UIApplication sharedApplication].connectedScenes)
            if (s.activationState == UISceneActivationStateForegroundActive)
                for (UIWindow* w in s.windows) if (w.isKeyWindow) { top = w.rootViewController; break; }
    }
    while(top.presentedViewController) top = top.presentedViewController;
    [top presentViewController:alert animated:YES completion:nil];
}

// --- HOOKS ---
%hook YTHeaderView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    CGPoint loc = [[touches anyObject] locationInView:(UIView *)self];
    if (loc.x < ((UIView *)self).frame.size.width / 3.0) showAutoACMenu();
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
    
    NSString *bid = [[NSBundle mainBundle] bundleIdentifier];
    isYouTube = [bid isEqualToString:@"com.google.ios.youtube"];
    isFacebook = [bid isEqualToString:@"com.facebook.Facebook"];
}
