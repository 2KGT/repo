#import <AutoACheaders/AutoACheaders.h>
#import <UIKit/UIKit.h>

// - Cập nhật Menu cài đặt AutoAC tương thích ARC
// - Sửa lỗi forward declaration cho YTSettingsSectionItemManager
// + Loại bỏ hoàn toàn release/autorelease để build với -fobjc-arc
// + Cập nhật UI_USER_INTERFACE_IDIOM sang UIDevice tiêu chuẩn

#define kPrefs [NSUserDefaults standardUserDefaults]
static const NSInteger AutoACSection = 2026;

@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(id)arg1 titleDescription:(id)arg2 accessibilityIdentifier:(id)arg3 switchOn:(BOOL)arg4 switchBlock:(id)arg5 settingItemId:(int)arg6;
@end

// MARK: - Settings Section
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (order && ![order containsObject:@(AutoACSection)]) {
        [order insertObject:@(AutoACSection) atIndex:1];
    }
    return [order copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        Class itemClass = %c(YTSettingsSectionItem);
        if (!itemClass) {
            %orig;
            return;
        }

        NSMutableArray *items = [NSMutableArray array];

        [items addObject:[itemClass switchItemWithTitle:@"Xoá cache tự động"
                                    titleDescription:@"Tự dọn dẹp khi mở App"
                              accessibilityIdentifier:nil
                                            switchOn:[kPrefs boolForKey:@"kAutoClearCache"]
                                         switchBlock:^BOOL(id cell, BOOL enabled) {
                                             [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                                             return YES;
                                         } settingItemId:0]];

        [items addObject:[itemClass switchItemWithTitle:@"Chặn quảng cáo & Tag"
                                    titleDescription:@"Loại bỏ Ads và Tag sản phẩm"
                              accessibilityIdentifier:nil
                                            switchOn:[kPrefs boolForKey:@"kHideEverything"]
                                         switchBlock:^BOOL(id cell, BOOL enabled) {
                                             [kPrefs setBool:enabled forKey:@"kHideEverything"];
                                             return YES;
                                         } settingItemId:0]];

        // Sửa lỗi forward declaration bằng cách ép kiểu sang id
        id currentSelf = (id)self;
        id settingsVC = [currentSelf valueForKey:@"_settingsViewControllerDelegate"] 
                     ?: [currentSelf valueForKey:@"settingsViewControllerDelegate"];

        if ([settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:)]) {
            [settingsVC setSectionItems:items 
                            forCategory:AutoACSection 
                                  title:@"AutoAC Settings" 
                       titleDescription:@"Cấu hình bởi 2KGT"];
        }
        return;
    }
    %orig;
}
%end

// MARK: - Long Press Home Button
%hook YTTabBarController
- (void)viewDidLoad {
    %orig;
    UITabBar *tabBar = self.tabBar;
    if (tabBar) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] 
            initWithTarget:self action:@selector(autoAC_handleLongPress:)];
        longPress.minimumPressDuration = 0.5;
        [tabBar addGestureRecognizer:longPress];
        // Đã xóa [longPress release] vì dùng ARC
        NSLog(@"[AutoAC] ✅ Đã gắn Long press");
    }
}

%new
- (void)autoAC_handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    
    UITabBar *tabBar = self.tabBar;
    CGPoint location = [gesture locationInView:tabBar];
    
    NSArray *tabBarItems = tabBar.items;
    if (tabBarItems.count == 0) return;
    
    CGFloat itemWidth = tabBar.bounds.size.width / tabBarItems.count;
    NSInteger tappedIndex = (NSInteger)(location.x / itemWidth);
    
    if (tappedIndex != 0) return; 
    
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"AutoAC"
        message:@"Tuỳ chọn nhanh"
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"⚙️ Cài đặt AutoAC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self autoAC_openSettings];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🗑️ Xoá bộ đệm cache" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self autoAC_clearCache];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"📥 Trạng thái tải xuống" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self autoAC_showDownloadStatus];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleCancel handler:nil]];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = tabBar;
        alert.popoverPresentationController.sourceRect = CGRectMake(location.x, location.y, 1, 1);
    }
    [self presentViewController:alert animated:YES completion:nil];
}

%new
- (void)autoAC_openSettings {
    id settingsVC = [[%c(YTSettingsViewController) alloc] init];
    if (settingsVC) {
        [self presentViewController:settingsVC animated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AutoACScrollToSection" object:@(AutoACSection)];
        }];
        // Đã xóa [settingsVC release] vì dùng ARC
    }
}

%new
- (void)autoAC_clearCache {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths firstObject];
    if (cachePath) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:cachePath error:nil];
        unsigned long long totalSize = 0;
        for (NSString *file in files) {
            NSString *fullPath = [cachePath stringByAppendingPathComponent:file];
            totalSize += [[fm attributesOfItemAtPath:fullPath error:nil] fileSize];
            [fm removeItemAtPath:fullPath error:nil];
        }
        
        NSString *message = [NSString stringWithFormat:@"Đã giải phóng: %.2f MB", totalSize / 1024.0 / 1024.0];
        UIAlertController *res = [UIAlertController alertControllerWithTitle:@"✅ Đã dọn dẹp" message:message preferredStyle:UIAlertControllerStyleAlert];
        [res addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:res animated:YES completion:nil];
    }
}

%new
- (void)autoAC_showDownloadStatus {
    NSMutableString *status = [NSMutableString string];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths firstObject];
    
    if (docPath) {
        NSDictionary *fs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:docPath error:nil];
        unsigned long long free = [fs[NSFileSystemFreeSize] unsignedLongLongValue];
        [status appendFormat:@"✅ Còn trống: %.2f GB\n", free / 1024.0 / 1024.0 / 1024.0];
    }
    
    UIAlertController *st = [UIAlertController alertControllerWithTitle:@"📊 Trạng thái" message:status preferredStyle:UIAlertControllerStyleAlert];
    [st addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:st animated:YES completion:nil];
}
%end

%ctor {
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.google.ios.youtube"]) {
        NSLog(@"[AutoAC] ✅ AutoAC v2.0 ARC Ready");
    }
}
