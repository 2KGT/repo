#import <Foundation/Foundation.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface AutoACRootListController : PSListController
@end

@implementation AutoACRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

// Hàm hỗ trợ mở link nếu cần (ví dụ Telegram của bạn)
- (void)openTelegram {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/your_channel"] options:@{} completionHandler:nil];
}

@end
