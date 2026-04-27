#import <UIKit/UIKit.h>
// Import các file từ bộ Header xịn của ông
#import <YouTubeHeader/YTAppSettingsPresentationData.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsGroupData.h>

// Định nghĩa ID cho mục cài đặt của ông (aacp = AutoAC)
static const NSInteger AutoACSection = 'aacp';

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    // Chèn ID của mình vào danh sách phân loại cài đặt
    if (order && ![order containsObject:@(AutoACSection)]) {
        // Tìm vị trí của mục General (thường là 1) để chèn ngay dưới nó
        NSUInteger idx = [order indexOfObject:@(1)];
        if (idx != NSNotFound) {
            [order insertObject:@(AutoACSection) atIndex:idx + 1];
        } else {
            [order addObject:@(AutoACSection)];
        }
    }
    return [order copy];
}
%end

%hook YTSettingsGroupData
- (NSArray *)orderedCategories {
    NSMutableArray *cats = [%orig mutableCopy];
    // Đưa mục của mình lên đầu danh sách nhóm cài đặt
    if (cats && ![cats containsObject:@(AutoACSection)]) {
        [cats insertObject:@(AutoACSection) atIndex:0];
    }
    return [cats copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];
        
        // Tạo switch "Chặn quảng cáo"
        YTSettingsSectionItem *switchItem = [%c(YTSettingsSectionItem) 
            switchItemWithTitle:@"Chặn quảng cáo" 
            titleDescription:@"Xoá sạch mọi quảng cáo YouTube" 
            accessibilityIdentifier:nil 
            switchOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"kRemoveAds"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"kRemoveAds"];
                return YES;
            } settingItemId:0];
            
        [items addObject:switchItem];

        // Ép kiểu delegate để gọi hàm đổ dữ liệu vào giao diện
        YTSettingsViewController *settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        if ([settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:)]) {
            [settingsVC setSectionItems:items 
                            forCategory:AutoACSection 
                                  title:@"AutoAC Settings" 
                       titleDescription:nil];
        }
        return;
    }
    %orig;
}
%end
