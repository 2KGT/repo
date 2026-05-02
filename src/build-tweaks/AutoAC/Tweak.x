#import <AutoACheaders/AutoACheaders.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

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

#pragma mark - Settings

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
        if (!itemClass) return %orig;

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
            [(id)settingsVC setSectionItems:items
                               forCategory:AutoACSection
                                     title:@"AutoAC Settings"
                          titleDescription:@"Cấu hình bởi 2KGT"];
        }

        return;
    }

    %orig;
}
%end

#pragma mark - LONG PRESS (REAL WORKING)

%hook UITabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;

    if (self) {

        NSLog(@"[AutoAC] UITabBar init");

        BOOL added = objc_getAssociatedObject(self, @selector(autoAC_handleLongPress:)) != nil;

        if (!added) {

            UILongPressGestureRecognizer *lp =
            [[UILongPressGestureRecognizer alloc]
             initWithTarget:self
             action:@selector(autoAC_handleLongPress:)];

            lp.minimumPressDuration = 0.5;
            lp.cancelsTouchesInView = NO;

            [self addGestureRecognizer:lp];

            objc_setAssociatedObject(self,
                                     @selector(autoAC_handleLongPress:),
                                     @(YES),
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);

            NSLog(@"[AutoAC] Gesture added");
        }
    }

    return self;
}

%new
- (void)autoAC_handleLongPress:(UILongPressGestureRecognizer *)gesture {

    if (gesture.state != UIGestureRecognizerStateBegan) return;

    NSLog(@"[AutoAC] ✅ LONG PRESS DETECTED");

    UIWindow *window = nil;

    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *ws = (UIWindowScene *)scene;

            if (ws.activationState == UISceneActivationStateForegroundActive) {
                window = ws.windows.firstObject;
                break;
            }
        }
    }

    if (!window) return;

    UIViewController *rootVC = window.rootViewController;

    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }

    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"AutoAC"
                                        message:@"Long press OK ✅"
                                 preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    [rootVC presentViewController:alert animated:YES completion:nil];
}

%end