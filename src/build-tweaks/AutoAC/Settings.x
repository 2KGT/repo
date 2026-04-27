#import <UIKit/UIKit.h>

// ==========================================
// 🛡️ BÙA CHÚ CHỐNG VĂNG (GIA CỐ)
// ==========================================
#ifndef CDUnknownBlockType
typedef void (^CDUnknownBlockType)(void);
#endif

// Khai báo khống các Protocol để lừa hệ thống
@protocol YTResponder <NSObject>
@end
@protocol YTAppSettingsSectionItemDataDelegate <NSObject>
@end
@protocol YTAppSettingsSectionItemControllerDelegate <NSObject>
@end

// Khai báo Class và đảm bảo nó kế thừa từ NSObject/UIView
@interface YTAppSettingsSectionItemController : NSObject
@end

@interface YTAppSettingsPresentationData : NSObject
+ (id)settingsCategoryOrder;
@end

@interface YTSettingsGroupData : NSObject
- (id)orderedCategories;
@end

@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(id)arg1 titleDescription:(id)arg2 accessibilityIdentifier:(id)arg3 switchOn:(BOOL)arg4 switchBlock:(CDUnknownBlockType)arg5 settingItemId:(int)arg6;
@end

// Fix lỗi gọi hàm không tồn tại
@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(id)arg1 forCategory:(unsigned long long)arg2 title:(id)arg3 titleDescription:(id)arg4;
@end
// ==========================================

static const NSInteger AutoACSection = 'aacp';

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (order && ![order containsObject:@(AutoACSection)]) {
        NSUInteger idx = [order indexOfObject:@(1)]; // Chèn sau mục General
        if (idx != NSNotFound) [order insertObject:@(AutoACSection) atIndex:idx + 1];
        else [order addObject:@(AutoACSection)];
    }
    return [order copy];
}
%end

%hook YTSettingsGroupData
- (NSArray *)orderedCategories {
    NSMutableArray *cats = [%orig mutableCopy];
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
        
        // Sử dụng %c để lấy class thật lúc chạy (runtime) tránh lỗi link
        Class itemClass = %c(YTSettingsSectionItem);
        if (itemClass) {
            id switchItem = [itemClass switchItemWithTitle:@"Chặn quảng cáo" 
                titleDescription:@"Xoá sạch mọi quảng cáo YouTube" 
                accessibilityIdentifier:nil 
                switchOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"kRemoveAds"] 
                switchBlock:^BOOL (id cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"kRemoveAds"];
                    return YES;
                } settingItemId:0];
            [items addObject:switchItem];
        }

        // Lấy Delegate an toàn hơn
        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        if (settingsVC && [settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:)]) {
            [settingsVC setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:nil];
        }
        return;
    }
    %orig;
}
%end
