#import <UIKit/UIKit.h>
#import <YouTube/MLHAMPlayerItem.h>
#import <YouTube/MLAVPlayer.h>

static BOOL kRemoveAds = YES;

static void loadPrefs() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    kRemoveAds = [defaults objectForKey:@"kRemoveAds"] ? [defaults boolForKey:@"kRemoveAds"] : YES;
}

%hook YTAdSlotContainerView
- (void)layoutSubviews { if (kRemoveAds) return; %orig; }
- (void)setHidden:(BOOL)hidden { %orig(kRemoveAds ? YES : hidden); }
%end

%ctor {
    loadPrefs();
    %init;
}
