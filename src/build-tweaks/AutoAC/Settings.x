#import <UIKit/UIKit.h>
#import "headers.txt"

@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(id)title titleDescription:(id)desc accessibilityIdentifier:(id)acc switchOn:(BOOL)on switchBlock:(id)block settingItemId:(int)id;
@end

@interface YTSettingsSectionItemManager : NSObject @end
@interface YTAppSettingsPresentationData : NSObject @end

static const NSInteger AutoACSection = 2026;
#define kPrefs [NSUserDefaults standardUserDefaults]

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (![order containsObject:@(AutoACSection)]) {
        [order insertObject:@(AutoACSection) atIndex:1]; // Nằm ngay dưới mục General
    }
    return [order copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];

        // 1. Công tắc Xoá Cache
        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Xoá cache tự động" 
            titleDescription:@"Tự dọn dẹp khi mở App" 
            accessibilityIdentifier:nil 
            switchOn:[kPrefs boolForKey:@"kAutoClearCache"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                return YES;
            } settingItemId:0]];

        // 2. Công tắc Chặn Ads & Tag
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
