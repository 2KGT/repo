#import <AutoACheaders/AutoACheaders.h>
#import <UIKit/UIKit.h>

#define kPrefs [NSUserDefaults standardUserDefaults]
static const NSInteger AutoACSection = 2026;

// MARK: - Settings Section
%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [[%orig mutableCopy] autorelease];
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

        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"] 
                     ?: [self valueForKey:@"settingsViewControllerDelegate"];

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
@interface YTTabBarController : UITabBarController
@end

%hook YTTabBarController

- (void)viewDidLoad {
    %orig;
    
    // Tìm tab bar và thêm gesture
    UITabBar *tabBar = self.tabBar;
    if (tabBar) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] 
            initWithTarget:self action:@selector(autoAC_handleLongPress:)];
        longPress.minimumPressDuration = 0.5;
        [tabBar addGestureRecognizer:longPress];
        [longPress release];
        
        NSLog(@"[AutoAC] ✅ Long press gesture added to TabBar");
    }
}

%new
- (void)autoAC_handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint location = [gesture locationInView:self.tabBar];
    UITabBar *tabBar = self.tabBar;
    
    // Kiểm tra xem có tap vào nút Home không (thường là tab index 0)
    NSArray *tabBarItems = tabBar.items;
    if (tabBarItems.count == 0) return;
    
    CGFloat itemWidth = tabBar.bounds.size.width / tabBarItems.count;
    NSInteger tappedIndex = (NSInteger)(location.x / itemWidth);
    
    // Chỉ kích hoạt khi nhấn giữ nút Home (index 0)
    if (tappedIndex != 0) return;
    
    NSLog(@"[AutoAC] 🔥 Long press detected on Home tab");
    
    // Tạo Alert Controller
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"AutoAC"
        message:@"Tuỳ chọn nhanh"
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Action 1: Mở Settings
    UIAlertAction *settingsAction = [UIAlertAction 
        actionWithTitle:@"⚙️ Cài đặt AutoAC"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self autoAC_openSettings];
        }];
    [alert addAction:settingsAction];
    
    // Action 2: Xoá Cache
    UIAlertAction *clearCacheAction = [UIAlertAction 
        actionWithTitle:@"🗑️ Xoá bộ đệm cache"
        style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action) {
            [self autoAC_clearCache];
        }];
    [alert addAction:clearCacheAction];
    
    // Action 3: Kiểm tra Download Status
    UIAlertAction *downloadStatusAction = [UIAlertAction 
        actionWithTitle:@"📥 Trạng thái tải xuống"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self autoAC_showDownloadStatus];
        }];
    [alert addAction:downloadStatusAction];
    
    // Action 4: Hủy
    UIAlertAction *cancelAction = [UIAlertAction 
        actionWithTitle:@"Huỷ"
        style:UIAlertActionStyleCancel
        handler:nil];
    [alert addAction:cancelAction];
    
    // iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = tabBar;
        alert.popoverPresentationController.sourceRect = CGRectMake(location.x, location.y, 1, 1);
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

%new
- (void)autoAC_openSettings {
    // Mở YouTube Settings và scroll đến AutoAC section
    // Cách 1: Mở thẳng settings page
    id settingsVC = [[%c(YTSettingsViewController) alloc] init];
    if (settingsVC) {
        [self presentViewController:settingsVC animated:YES completion:^{
            // Post notification để scroll đến section
            [[NSNotificationCenter defaultCenter] 
                postNotificationName:@"AutoACScrollToSection" 
                object:@(AutoACSection)];
        }];
        [settingsVC release];
    }
    
    NSLog(@"[AutoAC] 📱 Opening Settings");
}

%new
- (void)autoAC_clearCache {
    // Xoá cache của YouTube
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths firstObject];
    
    if (cachePath) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:cachePath error:nil];
        
        NSInteger deletedCount = 0;
        unsigned long long totalSize = 0;
        
        for (NSString *file in files) {
            NSString *fullPath = [cachePath stringByAppendingPathComponent:file];
            NSDictionary *attrs = [fm attributesOfItemAtPath:fullPath error:nil];
            totalSize += [attrs fileSize];
            
            if ([fm removeItemAtPath:fullPath error:nil]) {
                deletedCount++;
            }
        }
        
        // Thông báo kết quả
        NSString *message = [NSString stringWithFormat:
            @"Đã xoá %ld files\nGiải phóng: %.2f MB", 
            (long)deletedCount, 
            totalSize / 1024.0 / 1024.0];
        
        UIAlertController *resultAlert = [UIAlertController 
            alertControllerWithTitle:@"✅ Xoá cache thành công"
            message:message
            preferredStyle:UIAlertControllerStyleAlert];
        
        [resultAlert addAction:[UIAlertAction 
            actionWithTitle:@"OK" 
            style:UIAlertActionStyleDefault 
            handler:nil]];
        
        [self presentViewController:resultAlert animated:YES completion:nil];
    }
    
    NSLog(@"[AutoAC] 🗑️ Cache cleared");
}

%new
- (void)autoAC_showDownloadStatus {
    // Kiểm tra trạng thái download
    NSMutableString *status = [NSMutableString string];
    
    // Kiểm tra dung lượng trống
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths firstObject];
    
    if (docPath) {
        NSDictionary *fsAttributes = [[NSFileManager defaultManager] 
            attributesOfFileSystemForPath:docPath error:nil];
        
        unsigned long long freeSpace = [fsAttributes[NSFileSystemFreeSize] unsignedLongLongValue];
        unsigned long long totalSpace = [fsAttributes[NSFileSystemSize] unsignedLongLongValue];
        
        [status appendFormat:@"💾 Tổng: %.2f GB\n", totalSpace / 1024.0 / 1024.0 / 1024.0];
        [status appendFormat:@"✅ Trống: %.2f GB\n", freeSpace / 1024.0 / 1024.0 / 1024.0];
    }
    
    // Kiểm tra downloads folder
    NSString *downloadPath = [docPath stringByAppendingPathComponent:@"Downloads"];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDir] && isDir) {
        NSArray *downloads = [[NSFileManager defaultManager] 
            contentsOfDirectoryAtPath:downloadPath error:nil];
        [status appendFormat:@"📥 Đang tải: %lu files\n", (unsigned long)downloads.count];
    } else {
        [status appendString:@"📥 Không có file đang tải\n"];
    }
    
    UIAlertController *statusAlert = [UIAlertController 
        alertControllerWithTitle:@"📊 Trạng thái tải xuống"
        message:status
        preferredStyle:UIAlertControllerStyleAlert];
    
    [statusAlert addAction:[UIAlertAction 
        actionWithTitle:@"OK" 
        style:UIAlertActionStyleDefault 
        handler:nil]];
    
    [self presentViewController:statusAlert animated:YES completion:nil];
    
    NSLog(@"[AutoAC] 📊 Download status shown");
}

%end

// MARK: - Constructor
%ctor {
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.google.ios.youtube"]) {
        NSLog(@"[AutoAC] ✅ AutoAC v2.0 loaded successfully");
        NSLog(@"[AutoAC] 📱 Features: Settings Section + Long Press Menu");
    }
}