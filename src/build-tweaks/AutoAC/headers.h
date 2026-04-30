#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// YouTube Settings Section
@interface YTAppSettingsPresentationData : NSObject
+ (NSArray *)settingsCategoryOrder;
@end

@interface YTSettingsSectionItemManager : NSObject
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry;
@end

@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(NSString *)title
         titleDescription:(NSString *)description
   accessibilityIdentifier:(NSString *)identifier
                 switchOn:(BOOL)switchOn
              switchBlock:(id)block
            settingItemId:(NSInteger)itemId;
@end

@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(NSArray *)items 
            forCategory:(NSInteger)category 
                  title:(NSString *)title 
       titleDescription:(NSString *)description;
@end

// YouTube Tab Bar
@interface YTTabBarController : UIViewController
@property (nonatomic, strong) UITabBar *tabBar;
@end