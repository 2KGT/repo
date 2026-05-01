#import <AutoACheaders/AutoACheaders.h>
#import <UIKit/UIKit.h>

#define kPrefs [NSUserDefaults standardUserDefaults]
static const NSInteger AutoACSection = 2026;

#pragma mark - Interfaces

@interface YTSettingsSectionItem : NSObject
+ (id)switchItemWithTitle:(id)arg1
       titleDescription:(id)arg2
 accessibilityIdentifier:(id)arg3
             switchOn:(BOOL)arg4
          switchBlock:(id)arg5
       settingItemId:(int)arg6;
@end

@interface UIViewController (AutoAC)
- (void)setSectionItems:(id)items
           forCategory:(NSInteger)category
                 title:(id)title
      titleDescription:(id)description;
@end

@interface YTTabBarController : UITabBarController
@property (nonatomic, readonly) UITabBar *tabBar;
@end

#pragma mark - Settings Hook

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSMutableArray *order = [%orig mutableCopy];

    if (order && ![order containsObject:@(AutoACSection)]) {
        [order insertObject:@(AutoACSection) atIndex:1];
    }
    return [order copy];
}
%end

%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {

    if (category == AutoACSection) {

        Class itemClass = %c(YTSettingsSectionItem);
        if (!itemClass) {
            return %orig;
        }

        NSMutableArray *items = [NSMutableArray array];

        [items addObject:[itemClass switchItemWithTitle:@"Xoá cache tự động"
                                      titleDescription:@"Tự dọn khi mở app"
                                accessibilityIdentifier:nil
                                              switchOn:[kPrefs boolForKey:@"kAutoClearCache"]
                                           switchBlock:^BOOL(id cell, BOOL enabled) {
                                               [kPrefs setBool:enabled forKey:@"kAutoClearCache"];
                                               return YES;
                                           }
                                         settingItemId:0]];

        id currentSelf = (id)self;
        id settingsVC =
        [currentSelf valueForKey:@"_settingsViewControllerDelegate"]
        ?: [currentSelf valueForKey:@"settingsViewControllerDelegate"];

        if (settingsVC) {
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

#pragma mark - TAB BAR FIX LONG PRESS

%hook YTTabBarController

- (void)viewDidLoad {
    %orig;

    NSLog(@"[AutoAC] TabBar loaded");

    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(autoAC_handleLongPress:)];

    longPress.minimumPressDuration = 0.5;
    longPress.cancelsTouchesInView = NO;

    [self.tabBar addGestureRecognizer:longPress];
}

%new
- (void)autoAC_handleLongPress:(UILongPressGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"[AutoAC] Long press detected");

        [self autoAC_openSettings];
    }
}

%new
- (void)autoAC_openSettings {

    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"AutoAC"
                                        message:@"Long press hoạt động ✅"
                                 preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

%end