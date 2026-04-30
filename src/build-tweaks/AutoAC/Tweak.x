#import <AutoACheaders/AutoACheaders.h>
#import <UIKit/UIKit.h>

// --- BẮT BUỘC PHẢI ĐẶT Ở ĐÂY (TRÊN CÙNG) ---
#define kPrefs [NSUserDefaults standardUserDefaults]
static const NSInteger AutoACSection = 2026;

// Định nghĩa Interface để compiler không báo lỗi "no known instance method"
@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(id)arg1 titleDescription:(id)arg2 accessibilityIdentifier:(id)arg3 switchOn:(BOOL)arg4 switchBlock:(id)arg5 settingItemId:(int)arg6;
@end

@interface YTTabBarController : UITabBarController
@property (nonatomic, readonly) UITabBar *tabBar;
- (void)autoAC_handleLongPress:(UILongPressGestureRecognizer *)gesture;
- (void)autoAC_openSettings;
- (void)autoAC_clearCache;
- (void)autoAC_showDownloadStatus;
@end

// Khai báo thêm phương thức để tránh lỗi "no known instance method" ở dòng 67
@interface UIViewController (AutoAC)
- (void)setSectionItems:(id)items forCategory:(NSInteger)category title:(id)title titleDescription:(id)description;
@end

// ------------------------------------------

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    // Giờ đây AutoACSection đã được định nghĩa ở trên nên sẽ không lỗi nữa
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
        // kPrefs đã được định nghĩa ở đầu file
        [items addObject:[itemClass switchItemWithTitle:@"Xoá cache tự động"
                                    titleDescription:@"Tự dọn dẹp khi mở App"
                              accessibilityIdentifier:nil
                                            switchOn:[kPrefs boolForKey:@"kAutoClearCache"]
                                         switchBlock:^BOOL(id cell, BOOL enabled) {
                                             [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                                             return YES;
                                         } settingItemId:0]];

        id currentSelf = (id)self;
        id settingsVC = [currentSelf valueForKey:@"_settingsViewControllerDelegate"] 
                     ?: [currentSelf valueForKey:@"settingsViewControllerDelegate"];

        if (settingsVC) {
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

// ... Các phần %hook YTTabBarController giữ nguyên như cũ ...
