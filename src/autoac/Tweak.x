#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// =============================================
// AUTO C - YouTube Tweak (Luôn bật - Xoá cache mạnh hơn)
// =============================================

%hook YTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self smartClearYouTubeCache];
        [self hideShoppingElements];
    });
    
    return result;
}

#pragma mark - 1. Xoá cache thông minh (phiên bản tăng cường)
%new
- (void)smartClearYouTubeCache {
    NSLog(@"[AutoC] Bắt đầu xoá cache YouTube - Phiên bản mạnh...");
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheBase = [paths firstObject];
    
    // Các thư mục cache chính của YouTube
    NSArray *cacheFolders = @[
        @"com.google.ios.youtube",
        @"com.google.ios.youtube/Caches",
        @"YouTube",
        @"YTData",
        @"com.google.youtube"
    ];
    
    NSInteger filesDeleted = 0;
    unsigned long long totalSizeCleared = 0;
    
    for (NSString *folder in cacheFolders) {
        NSString *fullPath = [cacheBase stringByAppendingPathComponent:folder];
        
        if (![fm fileExistsAtPath:fullPath]) continue;
        
        NSError *error = nil;
        NSArray *contents = [fm contentsOfDirectoryAtPath:fullPath error:&error];
        if (error) continue;
        
        for (NSString *file in contents) {
            NSString *itemPath = [fullPath stringByAppendingPathComponent:file];
            NSDictionary *attrs = [fm attributesOfItemAtPath:itemPath error:nil];
            if (!attrs) continue;
            
            unsigned long long fileSize = [attrs fileSize];
            NSDate *modDate = [attrs fileModificationDate];
            
            BOOL shouldDelete = NO;
            
            // Tăng cường logic:
            if (modDate && [[NSDate date] timeIntervalSinceDate:modDate] > 3 * 24 * 60 * 60) {  // cũ hơn 3 ngày (giảm từ 7 ngày)
                shouldDelete = YES;
            } else if (fileSize > 20 * 1024 * 1024) {   // lớn hơn 20MB (giảm từ 50MB)
                shouldDelete = YES;
            } else if ([file containsString:@"video"] || 
                       [file containsString:@"thumbnail"] || 
                       [file containsString:@"cache"]) {
                shouldDelete = YES;   // Ưu tiên xoá file video/thumbnail/cache
            }
            
            if (shouldDelete) {
                if ([fm removeItemAtPath:itemPath error:nil]) {
                    filesDeleted++;
                    totalSizeCleared += fileSize;
                }
            }
        }
    }
    
    double mbCleared = totalSizeCleared / (1024.0 * 1024.0);
    NSLog(@"[AutoC] ✅ Đã xoá %ld file, giải phóng ≈ %.2f MB", (long)filesDeleted, mbCleared);
}

#pragma mark - 2. Ẩn ghim sản phẩm & banner bán hàng (giữ nguyên)
%new
- (void)hideShoppingElements {
    for (UIScene *scene in [[UIApplication sharedApplication] connectedScenes]) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                [self hideViewsInView:window];
            }
        }
    }
    [self performSelector:@selector(hideShoppingElements) withObject:nil afterDelay:1.0];
}

%new
- (void)hideViewsInView:(UIView *)view {
    if (!view) return;
    for (UIView *subview in view.subviews) {
        NSString *className = NSStringFromClass([subview class]);
        if ([className containsString:@"Shopping"] ||
            [className containsString:@"ProductSticker"] ||
            [className containsString:@"ProductPin"] ||
            [className containsString:@"ytOverlayProductStickerHost"] ||
            [className containsString:@"Sponsored"] ||
            [className containsString:@"Offer"] ||
            [className containsString:@"Merch"] ||
            [className containsString:@"Banner"]) {
            
            subview.hidden = YES;
            [subview removeFromSuperview];
        }
        [self hideViewsInView:subview];
    }
}

%end