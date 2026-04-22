#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTAppDelegate : UIResponder <UIApplicationDelegate>
- (void)smartClearYouTubeCache;
@end

// =============================================
// AUTO C OPTIMIZED - Hiệu suất cao, không nóng máy
// =============================================

%hook YTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    // Chạy dọn dẹp bộ nhớ một lần duy nhất ở luồng nền (Background Thread)
    // Tránh gây đứng hình (stutter) khi khởi động
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self smartClearYouTubeCache];
    });
    
    return result;
}

#pragma mark - 1. Xoá cache (Chạy ngầm 1 lần)
%new
- (void)smartClearYouTubeCache {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cacheBase = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *cacheFolders = @[@"com.google.ios.youtube", @"com.google.ios.youtube/Caches", @"YouTube", @"YTData", @"com.google.youtube"];
    
    for (NSString *folder in cacheFolders) {
        NSString *fullPath = [cacheBase stringByAppendingPathComponent:folder];
        if (![fm fileExistsAtPath:fullPath]) continue;
        
        NSArray *contents = [fm contentsOfDirectoryAtPath:fullPath error:nil];
        for (NSString *file in contents) {
            NSString *itemPath = [fullPath stringByAppendingPathComponent:file];
            NSDictionary *attrs = [fm attributesOfItemAtPath:itemPath error:nil];
            
            if (attrs && ([[NSDate date] timeIntervalSinceDate:[attrs fileModificationDate]] > 259200 || [attrs fileSize] > 20971520 || [file containsString:@"video"] || [file containsString:@"thumbnail"])) {
                [fm removeItemAtPath:itemPath error:nil];
            }
        }
    }
}
%end

#pragma mark - 2. Chặn quảng cáo (Cơ chế Hook trực tiếp - Cực mượt)
%hook UIView

// Hook vào hàm này giúp xử lý ngay khi view vừa xuất hiện trên màn hình
- (void)didMoveToWindow {
    %orig;
    if (!self.window) return; // Chỉ xử lý khi view thực sự hiển thị

    NSString *className = NSStringFromClass([self class]);
    
    // Danh sách từ khoá nhận diện các thành phần rác
    if ([className containsString:@"Shopping"] ||
        [className containsString:@"ProductSticker"] ||
        [className containsString:@"ProductPin"] ||
        [className containsString:@"ytOverlayProductStickerHost"] ||
        [className containsString:@"Sponsored"] ||
        [className containsString:@"Offer"] ||
        [className containsString:@"Merch"] ||
        [className containsString:@"Banner"]) {
        
        self.hidden = YES;
        [self removeFromSuperview];
    }
}
%end
