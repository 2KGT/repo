#import <UIKit/UIKit.h>

// Định nghĩa chuẩn chỉ, không sợ "máy xay" làm hỏng
@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(id)title titleDescription:(id)desc accessibilityIdentifier:(id)acc switchOn:(BOOL)on switchBlock:(id)block settingItemId:(int)id;
@end

@interface YTSettingsSectionItemManager : NSObject
- (void)setSectionItems:(id)items forCategory:(NSInteger)category title:(id)title titleDescription:(id)desc;
@end

@interface YTAppSettingsPresentationData : NSObject
@end

@interface YTHeaderLogoController : UIViewController
@end

@interface YTAdSlotContainerView : UIView
@end

// Tiện ích dùng chung
#define kPrefs [NSUserDefaults standardUserDefaults]
