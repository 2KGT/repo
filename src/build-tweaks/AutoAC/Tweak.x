#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTHeaderView : UIView
@end
@interface FBNavigationBarTitleView : UIView
@end

static NSString *const kAutoCSmartCleanKey = @"AutoC_SmartClean_Enabled";
static NSString *const kRemoveAdsKey = @"AutoC_RemoveAds_Enabled";

// =========================================================
// 🚀 LOGIC HỆ THỐNG (GIỮ NGUYÊN HIỆU NĂNG SÂU)
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
            UIAlertController *done = [UIAlertController alertControllerWithTitle:nil message:@"Hệ thống đã sạch sẽ" preferredStyle:UIAlertControllerStyleAlert];
            [done addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleDefault handler:nil]];
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            UIViewController *top = window.rootViewController;
            while(top.presentedViewController) top = top.presentedViewController;
            [top presentViewController:done animated:YES completion:nil];
        });
    }
}

#pragma mark - 💎 GIAO DIỆN KÍNH LỎNG SIÊU CẤP (LIQUID TABLE)

@interface AutoACSettingsVC : UITableViewController
@end

@implementation AutoACSettingsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UISwitch *sw = [[UISwitch alloc] init];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Tự động tối ưu";
        sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoCSmartCleanKey];
        [sw addTarget:self action:@selector(sw1Changed:) forControlEvents:UIControlEventValueChanged];
    } else {
        cell.textLabel.text = @"Xoá Ads banner tag";
        sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:kRemoveAdsKey];
        [sw addTarget:self action:@selector(sw2Changed:) forControlEvents:UIControlEventValueChanged];
    }
    cell.accessoryView = sw;
    return cell;
}

- (void)sw1Changed:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:kAutoCSmartCleanKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sw2Changed:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:kRemoveAdsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

static void showAutoACMenu() {
    // Action Sheet với thông điệp rỗng để dành chỗ cho TableView
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tối ưu hệ thống" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    AutoACSettingsVC *tableVC = [[AutoACSettingsVC alloc] initWithStyle:UITableViewStylePlain];
    // Chiều cao 110 là vừa khít cho 2 dòng nội dung sắc nét
    tableVC.preferredContentSize = CGSizeMake(270, 110);
    [alert setValue:tableVC forKey:@"contentViewController"];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Dọn dẹp sâu" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        performDeepClean(NO);
    }]];
    
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

// --- HOOK KÍCH HOẠT ---
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
