#import <UIKit/UIKit.h>
#import <YouTubeHeader/YTAppSettingsPresentationData.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>

// Dùng một con số đủ lớn để tránh trùng với mục mặc định của YT
static const NSInteger AutoACSection = 2026; 

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (order && ![order containsObject:@(AutoACSection)]) {
        // Chèn vào sau mục General (1)
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

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];
        
        // Sử dụng NSUserDefaults với bộ lọc chuẩn
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        YTSettingsSectionItem *switchItem = [%c(YTSettingsSectionItem) 
            switchItemWithTitle:@"Chặn quảng cáo" 
            titleDescription:@"Xoá sạch mọi quảng cáo YouTube" 
            accessibilityIdentifier:nil 
            switchOn:[defaults boolForKey:@"kRemoveAds"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [defaults setBool:enabled forKey:@"kRemoveAds"];
                [defaults synchronize]; // Đảm bảo dữ liệu được ghi xuống đĩa
                return YES;
            } settingItemId:0];
            
        [items addObject:switchItem];

        // Lấy delegate an toàn hơn
        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        if (settingsVC && [settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:)]) {
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
