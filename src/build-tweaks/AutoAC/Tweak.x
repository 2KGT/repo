#import <UIKit/UIKit.h>
#import <YouTube/MLHAMPlayerItem.h>
#import <YouTube/MLAVPlayer.h>
#import <YouTube/MLFormat.h>

// Định nghĩa Scenario (Kịch bản mạng)
typedef enum {
    Wifi = 0, Cellular = 1, LowPowerMode = 2, ExternalWifi = 3, ExternalCellular = 4
} Scenario;

static BOOL kRemoveAds = YES;
static int kTargetQuality = 108030; // Mặc định 1080p

// Đọc cấu hình từ Settings
static void loadPrefs() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    kRemoveAds = [defaults objectForKey:@"kRemoveAds"] ? [defaults boolForKey:@"kRemoveAds"] : YES;
    kTargetQuality = [defaults objectForKey:@"kTargetQuality"] ? [[defaults objectForKey:@"kTargetQuality"] intValue] : 108030;
}

// Logic chọn chất lượng gần nhất (PoomSmart style)
static NSString *getClosestQuality(NSArray *formats) {
    int targetRes = kTargetQuality / 100;
    int targetFPS = kTargetQuality % 100;
    int minDiff = INT_MAX;
    NSString *bestLabel = nil;

    for (id format in formats) {
        int res = [format singleDimensionResolution];
        int fps = [format FPS];
        int diff = abs(res - targetRes) + abs(fps - targetFPS);
        if (diff < minDiff) {
            minDiff = diff;
            bestLabel = [format qualityLabel];
        }
    }
    return bestLabel;
}

// --- HOOKS ---

%hook MLHAMPlayerItem
- (void)onSelectableVideoFormats:(NSArray *)formats {
    %orig;
    loadPrefs();
    NSString *label = getClosestQuality(formats);
    if (label) {
        id constraint = [[%c(MLQuickMenuVideoQualitySettingFormatConstraint) alloc] initWithVideoQualitySetting:3 formatSelectionReason:2 qualityLabel:label];
        self.videoFormatConstraint = constraint;
    }
}
%end

%hook YTAdSlotContainerView
- (void)setHidden:(BOOL)hidden { %orig(kRemoveAds ? YES : hidden); }
%end

%ctor {
    loadPrefs();
    %init;
}
