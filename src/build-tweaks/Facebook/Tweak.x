#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// --- KHAI BÁO INTERFACE ĐỂ SỬA LỖI COMPILER ---
@interface UIApplication (FBEnhancer)
- (void)createPanel;
- (void)togglePanel;
@end

@interface UIViewController (FBEnhancer)
- (void)downloadNow;
- (void)track:(AVAssetExportSession *)export;
@end

// --- BIẾN TOÀN CỤC ---
static UIWindow *win = nil;
static UIButton *btn = nil;
static UIView *panel = nil;
static UIProgressView *progress = nil;

#pragma mark - UI

%hook UIApplication

- (void)didFinishLaunching {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        // Sửa lỗi keyWindow: Tìm window đang hoạt động thay vì dùng thuộc tính đã bị khai tử
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in scene.windows) {
                        if (w.isKeyWindow) {
                            win = w;
                            break;
                        }
                    }
                }
            }
        }
        
        if (!win) win = UIApplication.sharedApplication.keyWindow;
        if (!win) return;

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

        // Sửa lỗi gọi selector: Đảm bảo đích đến là UIApplication
        [btn addTarget:UIApplication.sharedApplication action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

        [win addSubview:btn];
        [self createPanel];
    });
}

%new
- (void)createPanel {
    if (panel) return;

    panel = [[UIView alloc] initWithFrame:CGRectMake(60, 150, 270, 220)];
    panel.layer.cornerRadius = 25;
    panel.clipsToBounds = YES;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = panel.bounds;
    [panel addSubview:blurView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 200, 30)];
    title.text = @"FBEnhancer";
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textColor = UIColor.whiteColor;
    [panel addSubview:title];

    UIButton *dl = [UIButton buttonWithType:UIButtonTypeSystem];
    dl.frame = CGRectMake(20, 70, 230, 40);
    [dl setTitle:@"Download Video" forState:UIControlStateNormal];
    [dl setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    dl.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.8];
    dl.layer.cornerRadius = 10;
    
    // Nút download sẽ kích hoạt downloadNow trên UIViewController hiện tại
    [dl addTarget:self action:@selector(triggerDownload) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:dl];

    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, 150, 230, 10)];
    progress.progress = 0;
    [panel addSubview:progress];

    panel.hidden = YES;
    [win addSubview:panel];
}

%new
- (void)togglePanel {
    if (panel) panel.hidden = !panel.hidden;
}

// Hàm phụ trợ để gọi sang UIViewController
%new
- (void)triggerDownload {
    UIViewController *root = win.rootViewController;
    while (root.presentedViewController) root = root.presentedViewController;
    if ([root respondsToSelector:@selector(downloadNow)]) {
        [root performSelector:@selector(downloadNow)];
    }
}

%end

#pragma mark - FIND VIDEO

static NSURL *findVideo(UIView *view) {
    if (!view) return nil;
    @try {
        // Một số trình phát video của FB có thể truy cập qua key "player"
        if ([view respondsToSelector:@selector(valueForKey:)]) {
            id player = [view valueForKey:@"player"];
            if (player && [player respondsToSelector:@selector(valueForKey:)]) {
                NSURL *url = [player valueForKey:@"URL"];
                if (url) return url;
            }
        }
    } @catch (NSException *e) {}

    for (UIView *v in view.subviews) {
        NSURL *u = findVideo(v);
        if (u) return u;
    }
    return nil;
}

#pragma mark - HOOK VIEWCONTROLLER

%hook UIViewController

%new
- (void)downloadNow {
    NSURL *url = findVideo(self.view);
    if (!url) {
        NSLog(@"[FBEnhancer] Không tìm thấy URL video");
        return;
    }

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];

    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"fb_%u.mp4", arc4random()]];
    export.outputURL = [NSURL fileURLWithPath:path];
    export.outputFileType = AVFileTypeMPEG4;

    [export exportAsynchronouslyWithCompletionHandler:^{
        if (export.status == AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
            });
        }
    }];

    [self track:export];
}

%new
- (void)track:(AVAssetExportSession *)export {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (export.status == AVAssetExportSessionStatusExporting) {
            float p = export.progress;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress) progress.progress = p;
            });
            [NSThread sleepForTimeInterval:0.2];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress.progress = (export.status == AVAssetExportSessionStatusCompleted) ? 1.0 : 0.0;
        });
    });
}

%end
