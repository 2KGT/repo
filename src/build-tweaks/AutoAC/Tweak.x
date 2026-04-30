#import <AutoACheaders/AutoACheaders.h>

#define kPrefs [NSUserDefaults standardUserDefaults]

// --- 1. CHẶN ADS ---
%hook YTAdSlotContainerView
- (void)setHidden:(BOOL)hidden {
    %orig([kPrefs boolForKey:@"kHideEverything"] ? YES : hidden);
}
%end

// --- 2. GÕ 3 PHÁT VÀO LOGO HIỆN DASHBOARD ---
%hook YTHeaderLogoController

- (void)viewDidLoad {
    %orig;
    // Dùng UITapGestureRecognizer thay cho LongPress
    UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle2KGTMenu:)];
    
    // Đặt số lần chạm là 3 (cho chắc ăn, tránh bấm nhầm)
    tripleTap.numberOfTapsRequired = 3;
    
    [self.view addGestureRecognizer:tripleTap];
}

%new
- (void)handle2KGTMenu:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 AutoAC Dashboard" 
                                    message:@"Cấu hình bởi 2KGT\nTrạng thái: Sẵn sàng" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        
        // Hiện Alert
        [(UIViewController *)self presentViewController:alert animated:YES completion:nil];
    }
}
%end

// --- 3. NGÒI NỔ ---
%ctor {
    %init(_ungrouped);
    NSLog(@"--- [2KGT] AutoAC: Da xoa long vu, chuyen sang go cua ---");
}
