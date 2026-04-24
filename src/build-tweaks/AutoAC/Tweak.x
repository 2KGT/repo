#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL isYouTube = NO;
static BOOL isFacebook = NO;

// Bộ nhớ đệm lưu trữ Class (Tăng tốc độ cuộn tối đa)
static NSMutableSet *knownAdClasses = nil;
static NSMutableSet *knownSafeClasses = nil;

// =========================================================
// AUTO C OPTIMIZED - Tích hợp chung YouTube & Facebook (Hiệu suất cao)
// =========================================================

#pragma mark - 1. Xoá cache (Chạy ngầm 1 lần lúc khởi động)
static void smartClearAppCache(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cacheBase = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSArray *cacheFolders = @[
        @"com.google.ios.youtube", @"com.google.ios.youtube/Caches", @"YouTube", @"YTData", @"com.google.youtube",
        @"com.facebook.Facebook", @"FBCache", @"FBMediaCache", @"FBVideoCache"
    ];
    
    for (NSString *folder in cacheFolders) {
        NSString *fullPath = [cacheBase stringByAppendingPathComponent:folder];
        if (![fm fileExistsAtPath:fullPath]) continue;
        
        NSArray *contents = [fm contentsOfDirectoryAtPath:fullPath error:nil];
        for (NSString *file in contents) {
            NSString *itemPath = [fullPath stringByAppendingPathComponent:file];
            NSDictionary *attrs = [fm attributesOfItemAtPath:itemPath error:nil];
            
            if (attrs && ([[NSDate date] timeIntervalSinceDate:[attrs fileModificationDate]] > 259200 || 
                          [attrs fileSize] > 20971520 || 
                          [file containsString:@"video"] || 
                          [file containsString:@"thumbnail"] || 
                          [file containsString:@"image"])) {
                [fm removeItemAtPath:itemPath error:nil];
            }
        }
    }
}

%ctor {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleID isEqualToString:@"com.google.ios.youtube"]) {
        isYouTube = YES;
    } else if ([bundleID isEqualToString:@"com.facebook.Facebook"]) {
        isFacebook = YES;
    }

    // Khởi tạo bộ nhớ đệm
    if (isYouTube || isFacebook) {
        knownAdClasses = [[NSMutableSet alloc] init];
        knownSafeClasses = [[NSMutableSet alloc] init];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        smartClearAppCache();
    });
}

#pragma mark - 2. Chặn quảng cáo (An toàn Layout & Cache Class)
%hook UIView

- (void)didMoveToWindow {
    %orig;
    if (!self.window) return;
    if (!isYouTube && !isFacebook) return;

    NSString *className = NSStringFromClass([self class]);
    
    // 1. Kiểm tra nhanh trong bộ nhớ đệm (Tốc độ O(1), không tốn CPU)
    if ([knownAdClasses containsObject:className]) {
        self.hidden = YES;
        self.alpha = 0;
        self.frame = CGRectZero; // Ép tàng hình và triệt tiêu kích thước, tránh crash UI
        return;
    }
    if ([knownSafeClasses containsObject:className]) {
        return;
    }

    // 2. Nếu Class mới xuất hiện, tiến hành phân tích
    BOOL isAd = NO;

    if (isYouTube) {
        if ([className containsString:@"Shopping"] ||
            [className containsString:@"ProductSticker"] ||
            [className containsString:@"ProductPin"] ||
            [className containsString:@"ytOverlayProductStickerHost"] ||
            [className containsString:@"Sponsored"] ||
            [className containsString:@"Offer"] ||
            [className containsString:@"Merch"] ||
            [className containsString:@"Banner"]) {
            isAd = YES;
        }
    } else if (isFacebook) {
        if ([className containsString:@"Sponsored"] ||
            [className containsString:@"AdView"] ||
            [className containsString:@"Banner"] ||
            [className containsString:@"ProductTag"] ||
            [className containsString:@"Commerce"] ||
            [className containsString:@"Shopping"] ||
            [className containsString:@"MarketplaceAd"] ||
            [className containsString:@"FBAd"]) {
            isAd = YES;
        }
    }

    // 3. Lưu kết quả vào bộ nhớ đệm và thực thi
    if (isAd) {
        [knownAdClasses addObject:className];
        self.hidden = YES;
        self.alpha = 0;
        self.frame = CGRectZero;
    } else {
        [knownSafeClasses addObject:className];
    }
}
%end
