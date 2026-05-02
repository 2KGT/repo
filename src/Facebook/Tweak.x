#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - PREFS

static BOOL enableDownload = YES;
static BOOL preferHD = YES;

#define PREF_PATH @"/var/mobile/Library/Preferences/com.yourname.fbenhancer.plist"

static void loadPrefs() {
    NSDictionary *p = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    if (p) {
        enableDownload = [p[@"EnableDownload"] boolValue];
        preferHD = [p[@"PreferHD"] boolValue];
    }
}

static void savePref(NSString *key, BOOL value) {
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithContentsOfFile:PREF_PATH] ?: [NSMutableDictionary new];
    p[key] = @(value);
    [p writeToFile:PREF_PATH atomically:YES];
}

#pragma mark - UI

static UIWindow *win;
static UIView *panel;
static UIButton *btn;

%hook UIApplication

- (void)didFinishLaunching {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        loadPrefs();

        win = UIApplication.sharedApplication.keyWindow;

        btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 200, 55, 55);
        btn.layer.cornerRadius = 27;
        btn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [btn setTitle:@"⚙️" forState:UIControlStateNormal];

        [btn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [btn addGestureRecognizer:pan];

        [win addSubview:btn];

        [self createPanel];
    });
}

%new
- (void)createPanel {

    panel = [[UIView alloc] initWithFrame:CGRectMake(70, 180, 260, 190)];
    panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    panel.layer.cornerRadius = 15;
    panel.hidden = YES;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 25)];
    title.text = @"FBEnhancer";
    title.textColor = UIColor.whiteColor;
    [panel addSubview:title];

    UISwitch *sw1 = [[UISwitch alloc] initWithFrame:CGRectMake(10, 50, 0, 0)];
    sw1.on = enableDownload;
    [sw1 addTarget:self action:@selector(toggleDownload:) forControlEvents:UIControlEventValueChanged];
    [panel addSubview:sw1];

    UILabel *lb1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 50, 150, 25)];
    lb1.text = @"Enable Download";
    lb1.textColor = UIColor.whiteColor;
    [panel addSubview:lb1];

    UISwitch *sw2 = [[UISwitch alloc] initWithFrame:CGRectMake(10, 90, 0, 0)];
    sw2.on = preferHD;
    [sw2 addTarget:self action:@selector(toggleHD:) forControlEvents:UIControlEventValueChanged];
    [panel addSubview:sw2];

    UILabel *lb2 = [[UILabel alloc] initWithFrame:CGRectMake(80, 90, 150, 25)];
    lb2.text = @"Prefer HD";
    lb2.textColor = UIColor.whiteColor;
    [panel addSubview:lb2];

    UIButton *dl = [UIButton buttonWithType:UIButtonTypeSystem];
    dl.frame = CGRectMake(10, 130, 230, 40);
    dl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    dl.layer.cornerRadius = 10;
    [dl setTitle:@"⬇ Download Video" forState:UIControlStateNormal];
    [dl addTarget:self action:@selector(downloadCurrent) forControlEvents:UIControlEventTouchUpInside];

    [panel addSubview:dl];

    [win addSubview:panel];
}

%new
- (void)togglePanel {
    panel.hidden = !panel.hidden;
}

%new
- (void)drag:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:win];
    btn.center = CGPointMake(btn.center.x + t.x, btn.center.y + t.y);
    [g setTranslation:CGPointZero inView:win];
}

%new
- (void)toggleDownload:(UISwitch *)sw {
    enableDownload = sw.isOn;
    savePref(@"EnableDownload", enableDownload);
}

%new
- (void)toggleHD:(UISwitch *)sw {
    preferHD = sw.isOn;
    savePref(@"PreferHD", preferHD);
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

    for (UIView *sub in view.subviews) {
        NSURL *u = findVideo(sub);
        if (u) return u;
    }

    return nil;
}

%hook UIViewController

%new
- (void)downloadCurrent {

    if (!enableDownload) return;

    NSURL *url = findVideo(self.view);

    if (!url) {
        NSLog(@"No video found");
        return;
    }

    [self startDownload:url];
}

#pragma mark - DOWNLOAD

%new
- (BOOL)isM3U8:(NSURL *)url {
    return [url.absoluteString containsString:@".m3u8"];
}

%new
- (void)startDownload:(NSURL *)url {

    if ([self isM3U8:url]) {
        [self handleM3U8:url];
    } else {
        [self downloadMP4:url];
    }
}

#pragma mark - M3U8 PARSE

%new
- (void)handleM3U8:(NSURL *)url {

    NSURLSessionDataTask *task =
    [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {

        if (!data) {
            [self exportM3U8:url];
            return;
        }

        NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *lines = [txt componentsSeparatedByString:@"\n"];

        NSString *best = nil;
        int max = 0;

        for (int i=0;i<lines.count;i++) {

            NSString *l = lines[i];

            if ([l containsString:@"BANDWIDTH="]) {

                int bw = [[[l componentsSeparatedByString:@"BANDWIDTH="][1]
                           componentsSeparatedByString:@","][0] intValue];

                if (bw > max && i+1 < lines.count) {
                    max = bw;
                    best = lines[i+1];
                }
            }
        }

        NSURL *finalURL = best ? [NSURL URLWithString:best relativeToURL:url] : url;

        [self exportM3U8:finalURL];
    }];

    [task resume];
}

#pragma mark - EXPORT

%new
- (void)exportM3U8:(NSURL *)url {

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];

    [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{

        AVAssetExportSession *export =
        [[AVAssetExportSession alloc] initWithAsset:asset
                                         presetName:(preferHD ? AVAssetExportPresetHighestQuality : AVAssetExportPresetMediumQuality)];

        NSString *path = [NSTemporaryDirectory()
                          stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"fb_%d.mp4", arc4random()]];

        export.outputURL = [NSURL fileURLWithPath:path];
        export.outputFileType = AVFileTypeMPEG4;

        [export exportAsynchronouslyWithCompletionHandler:^{

            dispatch_async(dispatch_get_main_queue(), ^{
                if (export.status == AVAssetExportSessionStatusCompleted) {
                    UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
                    NSLog(@"Saved video");
                } else {
                    NSLog(@"Export fail: %@", export.error);
                }
            });
        }];
    }];
}

#pragma mark - MP4

%new
- (void)downloadMP4:(NSURL *)url {

    NSURLSessionDownloadTask *task =
    [[NSURLSession sharedSession] downloadTaskWithURL:url
                                   completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {

        if (error) return;

        NSData *data = [NSData dataWithContentsOfURL:location];

        NSString *path = [NSTemporaryDirectory()
                          stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"fb_%d.mp4", arc4random()]];

        [data writeToFile:path atomically:YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
        });
    }];

    [task resume];
}

%end