#import "Header.h"

static const NSInteger AutoACSection = 2026;

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (![order containsObject:@(AutoACSection)]) {
        [order insertObject:@(AutoACSection) atIndex:1];
    }
    return [order copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];

        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Xoá cache tự động" 
            titleDescription:@"Tự dọn dẹp khi mở App" 
            accessibilityIdentifier:nil 
            switchOn:[kPrefs boolForKey:@"kAutoClearCache"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                return YES;
            } settingItemId:0]];

        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Chặn quảng cáo & Tag" 
            titleDescription:@"Loại bỏ Ads và Tag sản phẩm" 
            accessibilityIdentifier:nil 
            switchOn:[kPrefs boolForKey:@"kHideEverything"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kHideEverything"];
                return YES;
            } settingItemId:0]];

        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        [settingsVC setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:@"Cấu hình bởi 2KGT"];
        return;
    }
    %orig;
}
%end
