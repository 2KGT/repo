#import <UIKit/UIKit.h>

static UIWindow *fbWindow;
static UIView *panel;
static BOOL menuVisible = NO;

%hook UIApplication

- (void)didFinishLaunching {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        fbWindow = [UIApplication sharedApplication].keyWindow;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 200, 50, 50);
        btn.layer.cornerRadius = 25;
        btn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];

        [btn setTitle:@"⚙️" forState:UIControlStateNormal];

        [btn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];

        [fbWindow addSubview:btn];

        [self createPanel];
    });
}

%new
- (void)createPanel {

    panel = [[UIView alloc] initWithFrame:CGRectMake(50, 150, 250, 200)];
    panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    panel.layer.cornerRadius = 15;
    panel.hidden = YES;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    title.text = @"FBEnhancer";
    title.textColor = UIColor.whiteColor;

    [panel addSubview:title];

    UISwitch *downloadSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 60, 0, 0)];
    downloadSwitch.on = YES;

    [panel addSubview:downloadSwitch];

    [fbWindow addSubview:panel];
}

%new
- (void)toggleMenu {
    menuVisible = !menuVisible;
    panel.hidden = !menuVisible;
}

%end