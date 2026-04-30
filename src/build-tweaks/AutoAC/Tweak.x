#import <AutoACheaders/AutoACheaders.h>

#define kPrefs [NSUserDefaults standardUserDefaults]
static const NSInteger AutoACSection = 2026;

%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (order && ![order containsObject:@(AutoACSection)]) {
        [order insertObject:@(AutoACSection) atIndex:1];  // Chèn sau mục đầu tiên
    }
    return [order copy];
}

%end

%hook YTSettingsSectionItemManager

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];
        Class itemClass = %c(YTSettingsSectionItem);

        if (itemClass) {
            // Switch 1: Xoá cache tự động
            [items addObject:[itemClass switchItemWithTitle:@"Xoá cache tự động"
                                        titleDescription:@"Tự dọn dẹp khi mở App"
                                  accessibilityIdentifier:nil
                                                switchOn:[kPrefs boolForKey:@"kAutoClearCache"]
                                             switchBlock:^BOOL(id cell, BOOL enabled) {
                                                 [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                                                 [kPrefs synchronize];
                                                 return YES;
                                             } settingItemId:0]];

            // Switch 2: Chặn quảng cáo & Tag
            [items addObject:[itemClass switchItemWithTitle:@"Chặn quảng cáo & Tag"
                                        titleDescription:@"Loại bỏ Ads và Tag sản phẩm"
                                  accessibilityIdentifier:nil
                                                switchOn:[kPrefs boolForKey:@"kHideEverything"]
                                             switchBlock:^BOOL(id cell, BOOL enabled) {
                                                 [kPrefs setBool:enabled forKey:@"kHideEverything"];
                                                 [kPrefs synchronize];
                                                 return YES;
                                             } settingItemId:0]];
        }

        // Lấy Settings ViewController
        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        if (!settingsVC) {
            settingsVC = [self valueForKey:@"settingsViewControllerDelegate"];
        }

        if ([settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:)]) {
            [settingsVC setSectionItems:items 
                            forCategory:AutoACSection 
                                  title:@"AutoAC Settings" 
                       titleDescription:@"Cấu hình bởi 2KGT"];
            NSLog(@"[AutoAC] Đã thêm section Settings thành công");
        } else {
            NSLog(@"[AutoAC] Không tìm thấy method setSectionItems");
        }
        return;
    }
    
    %orig;
}

%end

%ctor {
    NSLog(@"[AutoAC] ✅ Settings Tweak đã load - Section ID: %ld", (long)AutoACSection);
}