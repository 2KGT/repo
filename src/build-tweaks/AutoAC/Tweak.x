#import <UIKit/UIKit.h>
#import <YouTube/MLHAMPlayerItem.h>
#import <YouTube/MLAVPlayer.h>
#import <YouTube/MLFormat.h>

static BOOL kRemoveAds = YES;

static void loadPrefs() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    kRemoveAds = [defaults objectForKey:@"kRemoveAds"] ? [defaults boolForKey:@"kRemoveAds"] : YES;
}

%hook YTAdSlotContainerView
- (void)layoutSubviews { if (kRemoveAds) return; %orig; }
- (void)setHidden:(BOOL)hidden { %orig(kRemoveAds ? YES : hidden); }
%end

%hook YTSlimVideoMetadataSectionView
- (void)layoutSubviews { 
    %orig; 
    if (kRemoveAds) {
        for (UIView *sub in [((UIView *)self) subviews]) {
            if ([NSStringFromClass([sub class]) containsString:@"Promotion"]) {
                [sub setHidden:YES];
            }
        }
    }
}
%end

%ctor {
    loadPrefs();
    %init;
}
