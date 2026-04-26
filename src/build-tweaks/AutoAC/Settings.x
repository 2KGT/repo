#import <UIKit/UIKit.h>

// Định nghĩa ID riêng cho AutoAC
static const NSInteger AutoACSection = 'aacp';

// Interface tối thiểu để biên dịch không lỗi
@interface YTSettingsSectionItem : NSObject
+ (instancetype)switchItemWithTitle:(id)arg1 titleDescription:(id)arg2 accessibilityIdentifier:(id)arg3 switchOn:(BOOL)arg4 switchBlock:(id)arg5 settingItemId:(int)arg6;
@end

// 1. Đăng ký vị trí hiển thị trong Menu Cài đặt
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = %orig.mutableCopy;
    if (![order containsObject:@(AutoACSection)]) {
        [order insertObject:@(AutoACSection) atIndex:0]; // Cho lên đầu luôn cho oai
    }
    return order.copy;
}
%end

// 2. Vẽ nội dung cho Menu AutoAC
%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == AutoACSection) {
        NSMutableArray *items = [NSMutableArray array];
        Class ItemClass = %c(YTSettingsSectionItem);
        
        // Dòng 1: Bật/Tắt Chặn Ads
        [items addObject:[ItemClass switchItemWithTitle:@"Chặn quảng cáo" 
            titleDescription:@"Tự động dọn dẹp Ads YouTube" 
            accessibilityIdentifier:nil 
            switchOn:YES // Ở đây bạn nên link với biến kRemoveAds
            switchBlock:^BOOL (id cell, BOOL enabled) {
                // Lưu logic vào NSUserDefaults ở đây
                return YES;
            } settingItemId:0]];

        // Gửi danh sách này cho ViewController hiển thị
        id controller = [self valueForKey:@"_settingsViewControllerDelegate"];
        [controller setSectionItems:items forCategory:AutoACSection title:@"AutoAC Settings" titleDescription:nil];
        return;
    }
    %orig;
}
%end
