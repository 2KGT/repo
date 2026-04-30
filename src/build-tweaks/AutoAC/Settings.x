#import <AutoACheaders/AutoACheaders.h>

// --- Định nghĩa kPrefs để lưu cấu hình ---
#define kPrefs [NSUserDefaults standardUserDefaults]

static const NSInteger AutoACSection = 2026;

// --- Khai báo Interface các Class nội bộ YouTube ---
@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(id)title titleDescription:(id)desc accessibilityIdentifier:(id)arg3 switchOn:(BOOL)on switchBlock:(id)block settingItemId:(int)id;
@end

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (![order containsObject:@(AutoACSection)]) {
        // Chèn vào vị trí thứ 1 (dưới mục đầu tiên)
        [order insertObject:@(AutoACSection) atIndex:1];
    }
    return [order copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];

        // Switch 1: Xoá Cache
        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Xoá cache tự động" 
            titleDescription:@"Tự dọn dẹp khi mở App" 
            accessibilityIdentifier:nil 
            switchOn:[kPrefs boolForKey:@"kAutoClearCache"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                return YES;
            } settingItemId:0]];

        // Switch 2: Chặn Ads
        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Chặn quảng cáo & Tag" 
            titleDescription:@"Loại bỏ Ads và Tag sản phẩm" 
            accessibilityIdentifier:nil 
            switchOn:[kPrefs boolForKey:@"kHideEverything"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kHideEverything"];
                return YES;
            } settingItemId:0]];

        // Gán vào View
        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        [settingsVC setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:@"Cấu hình bởi 2KGT"];
        return;
    }
    %orig;
}
%end
