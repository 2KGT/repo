#import <UIKit/UIKit.h>
#import <YouTube/YTAppSettingsPresentationData.h>
#import <YouTube/YTSettingsViewController.h>
#import <YouTube/YTSettingsSectionItem.h>
#import <YouTube/YTSettingsSectionItemManager.h>
#import <YouTube/YTSettingsGroupData.h>

static const NSInteger AutoACSection = 'aacp';

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = %orig.mutableCopy;
    if (![order containsObject:@(AutoACSection)]) {
        NSUInteger idx = [order indexOfObject:@(1)];
        if (idx != NSNotFound) [order insertObject:@(AutoACSection) atIndex:idx + 1];
    }
    return order.copy;
}
%end

%hook YTSettingsGroupData
- (NSArray *)orderedCategories {
    NSMutableArray *cats = %orig.mutableCopy;
    if (![cats containsObject:@(AutoACSection)]) [cats insertObject:@(AutoACSection) atIndex:0];
    return cats.copy;
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];
        
        // Mục 1: Bật/Tắt Ads
        [items addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:@"Chặn quảng cáo" 
            titleDescription:@"Xoá sạch mọi quảng cáo YouTube" 
            accessibilityIdentifier:nil 
            switchOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"kRemoveAds"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"kRemoveAds"];
                return YES;
            } settingItemId:0]];

        YTSettingsViewController *settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        [settingsVC setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:nil];
        return;
    }
    %orig;
}
%end
