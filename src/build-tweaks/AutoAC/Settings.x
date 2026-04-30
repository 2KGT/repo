#import <AutoACheaders/AutoACheaders.h>
#define kPrefs [NSUserDefaults standardUserDefaults]

// Thử đổi Section ID sang một số khác (ví dụ 3000)
static const NSInteger AutoACSection = 3000;

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];
    if (![order containsObject:@(AutoACSection)]) {
        // Chèn vào vị trí số 2 cho chắc
        [order insertObject:@(AutoACSection) atIndex:2];
    }
    return [order copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];
        
        // Dùng class %c để bốc class tại thời điểm chạy (Runtime)
        Class itemClass = %c(YTSettingsSectionItem);
        
        [items addObject:[itemClass switchItemWithTitle:@"Xoá cache tự động" 
            titleDescription:@"Tự dọn dẹp khi mở App" 
            switchOn:[kPrefs boolForKey:@"kAutoClearCache"] 
            switchBlock:^BOOL (id cell, BOOL enabled) {
                [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                return YES;
            }]];

        id settingsVC = [self valueForKey:@"_settingsViewControllerDelegate"];
        // Kiểm tra xem delegate có phản hồi hàm này không
        if ([settingsVC respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:)]) {
            [settingsVC setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:@"2KGT"];
        }
        return;
    }
    %orig;
}
%end
