#import <AutoACheaders/AutoACheaders.h>

#define kPrefs [NSUserDefaults standardUserDefaults]
static const NSInteger AutoACSection = 2026;

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (![order containsObject:@(AutoACSection)]) {
        // Chèn vào ngay dưới mục đầu tiên của YouTube
        [order insertObject:@(AutoACSection) atIndex:1];
    }
    return [order copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];
        
        // Sử dụng runtime để lấy class Switch Item
        Class itemClass = %c(YTSettingsSectionItem);

        // Tham số đầy đủ 7 dòng để tránh lỗi 'no known class method'
        [items addObject:[itemClass switchItemWithTitle:@"Xoá cache tự động" 
            titleDescription:@"Tự dọn dẹp khi mở App" 
            accessibilityIdentifier:nil 
            switchOn:[kPrefs boolForKey:@"kAutoClearCache"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                return YES;
            } settingItemId:0]];

        [items addObject:[itemClass switchItemWithTitle:@"Chặn quảng cáo & Tag" 
            titleDescription:@"Loại bỏ Ads và Tag sản phẩm" 
            accessibilityIdentifier:nil 
            switchOn:[kPrefs boolForKey:@"kHideEverything"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kHideEverything"];
                return YES;
            } settingItemId:0]];

        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        
        // Gọi hàm hiển thị của YouTube
        if ([settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:)]) {
            [settingsVC setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:@"Cấu hình bởi 2KGT"];
        }
        return;
    }
    %orig;
}
%end
