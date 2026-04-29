#import <UIKit/UIKit.h>

// Khai báo để Compiler nhận diện
@interface YTSettingsSectionItemManager : NSObject @end
@interface YTAppSettingsPresentationData : NSObject @end
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        // Công tắc Xoá Cache
        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Xoá cache tự động" 
            switchOn:[defaults boolForKey:@"kAutoClearCache"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [defaults setBool:enabled forKey:@"kAutoClearCache"];
                return YES;
            } settingItemId:0]];

        // Công tắc Chặn Ads/Tags
        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Chặn quảng cáo & Tag" 
            switchOn:[defaults boolForKey:@"kHideAds"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [defaults setBool:enabled forKey:@"kHideAds"];
                return YES;
            } settingItemId:0]];

        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        [settingsVC setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:@"Cấu hình bởi 2KGT"];
        return;
    }
    %orig;
}
%end
