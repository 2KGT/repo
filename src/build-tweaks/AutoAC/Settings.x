#import <UIKit/UIKit.h>
// Thêm tên thư mục cha YouTube/ vào trước tên file
#import <YouTube/YTAppSettingsPresentationData.h>
#import <YouTube/YTSettingsViewController.h>
#import <YouTube/YTSettingsSectionItem.h>
#import <YouTube/YTSettingsSectionItemManager.h>
#import <YouTube/YTSettingsGroupData.h>

// ID định danh duy nhất (AACP = AutoAC Prefs)
static const NSInteger AutoACSection = 'aacp';

// 1️⃣ Đăng ký Category vào danh sách của YouTube
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = %orig.mutableCopy;
    if (![order containsObject:@(AutoACSection)]) {
        NSUInteger index = [order indexOfObject:@(1)]; // Mục General (Chung)
        if (index != NSNotFound) [order insertObject:@(AutoACSection) atIndex:index + 1];
        else [order insertObject:@(AutoACSection) atIndex:0];
    }
    return order.copy;
}
%end

%hook YTSettingsGroupData
- (NSArray *)orderedCategories {
    NSMutableArray *categories = %orig.mutableCopy;
    if (![categories containsObject:@(AutoACSection)]) {
        [categories insertObject:@(AutoACSection) atIndex:0];
    }
    return categories.copy;
}
%end

// 2️⃣ Vẽ nội dung Menu khi người dùng nhấn vào AutoAC
%hook YTSettingsSectionItemManager

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *sectionItems = [NSMutableArray array];
        
        // Dòng 1: Switch chặn Ads (Dùng trực tiếp class từ Header)
        YTSettingsSectionItem *adsItem = [%c(YTSettingsSectionItem) 
            switchItemWithTitle:@"Chặn quảng cáo"
            titleDescription:@"Tự động dọn dẹp AdSlot và Promotion"
            accessibilityIdentifier:nil
            switchOn:YES // Link với biến của cậu ở Tweak.x
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"kRemoveAds"];
                return YES;
            }
            settingItemId:0];
        [sectionItems addObject:adsItem];

        // Lấy ViewController từ Delegate để hiển thị
        YTSettingsViewController *settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        
        if ([settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:headerHidden:)]) {
            [settingsVC setSectionItems:sectionItems 
                           forCategory:AutoACSection 
                                 title:@"AutoAC Settings" 
                      titleDescription:nil 
                          headerHidden:NO];
        }
        return;
    }
    %orig;
}
%end
