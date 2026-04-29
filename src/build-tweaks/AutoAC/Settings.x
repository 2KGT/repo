#import <UIKit/UIKit.h>

// 1. Đúc khung xương (Thay thế hoàn toàn cho @class)
@interface YTAppSettingsPresentationData : NSObject @end
@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(NSString *)title 
         titleDescription:(NSString *)description 
  accessibilityIdentifier:(id)acc 
                 switchOn:(BOOL)on 
              switchBlock:(BOOL (^)(id cell, BOOL enabled))block 
            settingItemId:(int)itemId;
@end

// Đúc thêm thằng Manager này để không bị lỗi "forward declaration"
@interface YTSettingsSectionItemManager : NSObject @end

// Khai báo Delegate để gọi setSectionItems không bị mắng
@interface NSObject (YTSettingsDelegate)
- (void)setSectionItems:(id)items forCategory:(NSInteger)cat title:(id)title titleDescription:(id)desc;
@end


// =============================================================
// LOGIC CHÈN MENU (GIỮ NGUYÊN NHƯNG SẠCH HEADERS)
// =============================================================

static const NSInteger AutoACSection = 2026; 

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (order && ![order containsObject:@(AutoACSection)]) {
        NSUInteger idx = [order indexOfObject:@(1)]; // General
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Gọi thẳng class gốc thông qua %c
        id switchItem = [%c(YTSettingsSectionItem) 
            switchItemWithTitle:@"Chặn quảng cáo" 
            titleDescription:@"Xoá sạch mọi quảng cáo YouTube" 
            accessibilityIdentifier:nil 
            switchOn:[defaults boolForKey:@"kRemoveAds"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [defaults setBool:enabled forKey:@"kRemoveAds"];
                [defaults synchronize];
                return YES;
            } settingItemId:0];
            
        [items addObject:switchItem];

        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        if (settingsVC) {
            // Ép kiểu id để gọi thoải mái không cần Header xịn
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
