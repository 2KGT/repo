#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static UIWindow *win;
static UIButton *btn;
static UIView *panel;
static UIProgressView *progress;

#pragma mark - UI

%hook UIApplication
- (void)didFinishLaunching {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        win = UIApplication.sharedApplication.keyWindow;

        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 200, 60, 60);

        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = btn.bounds;
        blurView.layer.cornerRadius = 30;
        blurView.clipsToBounds = YES;

        [btn addSubview:blurView];

        btn.layer.borderWidth = 0.8;
        btn.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;

        UILabel *icon = [[UILabel alloc] initWithFrame:btn.bounds];
        icon.text = @"⬇️";
        icon.textAlignment = NSTextAlignmentCenter;
        icon.textColor = UIColor.whiteColor;
        [btn addSubview:icon];

        [btn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

        [win addSubview:btn];

        [self createPanel];
    });
}

%new
- (void)createPanel {

    panel = [[UIView alloc] initWithFrame:CGRectMake(60, 150, 270, 220)];
    panel.layer.cornerRadius = 25;
    panel.clipsToBounds = YES;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = panel.bounds;
    [panel addSubview:blurView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 200, 30)];
    title.text = @"FBEnhancer";
    title.textColor = UIColor.whiteColor;
    [panel addSubview:title];

    UIButton *dl = [UIButton buttonWithType:UIButtonTypeSystem];
    dl.frame = CGRectMake(20, 70, 230, 40);
    [dl setTitle:@"Download Video" forState:UIControlStateNormal];
    [dl addTarget:self action:@selector(downloadNow) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:dl];

    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, 150, 230, 10)];
    [panel addSubview:progress];

    panel.hidden = YES;
    [win addSubview:panel];
}

%new
- (void)togglePanel {
    panel.hidden = !panel.hidden;
}

%end

#pragma mark - FIND VIDEO

static NSURL *findVideo(UIView *view) {
    @try {
        id player = [view valueForKey:@"player"];
        if (player) {
            NSURL *url = [player valueForKey:@"URL"];
            if (url) return url;
        }
    } @catch (...) {}

    for (UIView *v in view.subviews) {
        NSURL *u = findVideo(v);
        if (u) return u;
    }
    return nil;
}

%hook UIViewController

%new
- (void)downloadNow {

    NSURL *url = findVideo(self.view);
    if (!url) return;

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];

    AVAssetExportSession *export =
    [[AVAssetExportSession alloc] initWithAsset:asset
                                     presetName:AVAssetExportPresetHighestQuality];

    NSString *path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSString stringWithFormat:@"fb_%d.mp4", arc4random()]];

    export.outputURL = [NSURL fileURLWithPath:path];
    export.outputFileType = AVFileTypeMPEG4;

    [export exportAsynchronouslyWithCompletionHandler:^{

        dispatch_async(dispatch_get_main_queue(), ^{
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
        });
    }];

    [self track:export];
}

%new
- (void)track:(AVAssetExportSession *)export {

    dispatch_async(dispatch_get_global_queue(0,0), ^{

        while (export.status == AVAssetExportSessionStatusExporting) {

            dispatch_async(dispatch_get_main_queue(), ^{
                progress.progress = export.progress;
            });

            [NSThread sleepForTimeInterval:0.2];
        }
    });
}

%end