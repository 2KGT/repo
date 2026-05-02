#import <UIKit/UIKit.h>

static BOOL enableDownload = YES;
static BOOL enableUI = YES;

static void loadPrefs() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:
        @"/var/mobile/Library/Preferences/com.yourname.fbenhancer.plist"];

    if (prefs) {
        enableDownload = [prefs[@"EnableDownload"] boolValue];
        enableUI = [prefs[@"EnableUI"] boolValue];
    }
}

%ctor {
    loadPrefs();
}

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (!enableUI) return;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 120, 120, 40);

    [btn setTitle:@"⬇ Download" forState:UIControlStateNormal];

    [btn addTarget:self action:@selector(fb_downloadAction)
         forControlEvents:UIControlEventTouchUpInside];

    btn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    btn.layer.cornerRadius = 10;

    [self.view addSubview:btn];
}

%new
- (void)fb_downloadAction {

    if (!enableDownload) return;

    NSURL *url = [self fb_findVideoURL];

    if (!url) {
        NSLog(@"[FBEnhancer] No video found");
        return;
    }

    [self fb_download:url];
}

%new
- (NSURL *)fb_findVideoURL {

    // scan view hierarchy (safe method)
    for (UIView *view in self.view.subviews) {
        id player = [view valueForKey:@"player"];

        if (player) {
            NSURL *url = [player valueForKey:@"URL"];
            if (url) return url;
        }
    }

    return nil;
}

%new
- (void)fb_download:(NSURL *)url {

    NSURLSessionDownloadTask *task =
    [[NSURLSession sharedSession] downloadTaskWithURL:url
                                   completionHandler:^(NSURL *location,
                                                       NSURLResponse *response,
                                                       NSError *error) {

        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:location];

            NSString *path = [NSTemporaryDirectory()
                              stringByAppendingPathComponent:@"video.mp4"];

            [data writeToFile:path atomically:YES];

            dispatch_async(dispatch_get_main_queue(), ^{
                UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
            });
        }
    }];

    [task resume];
}

%end
