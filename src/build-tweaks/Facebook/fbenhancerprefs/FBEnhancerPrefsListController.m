#import <Preferences/PSListController.h>

@interface FBEnhancerPrefsListController : PSListController
@end

@implementation FBEnhancerPrefsListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

@end