#import <UIKit/UIKit.h>
#import "headers.txt"

#define kPrefs [NSUserDefaults standardUserDefaults]

// --- Hook Chặn Ads ---
%hook YTAdSlotContainerView
- (void)setHidden:(BOOL)hidden {
    %orig([kPrefs boolForKey:@"kHideEverything"] ? YES : hidden);
}
%end

// --- Hook Nhấn giữ Logo (Hiện Dashboard) ---
%hook YTHeaderLogoController
- (void)viewDidLoad {
    %orig;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handle2KGTMenu:)];
    [self.view addGestureRecognizer:longPress];
}

%new
- (void)handle2KGTMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Status" 
                                    message:@"Mọi thứ đang hoạt động tốt!" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [((UIViewController *)self) presentViewController:alert animated:YES completion:nil];
    }
}
%end

%ctor {
    %init;
    // Tự động dọn rác nếu bật công tắc
    if ([kPrefs boolForKey:@"kAutoClearCache"]) {
        [[NSFileManager defaultManager] removeItemAtPath:NSTemporaryDirectory() error:nil];
    }
}
