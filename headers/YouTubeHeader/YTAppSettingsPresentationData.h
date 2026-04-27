@interface YTAppSettingsPresentationData : NSObject

/* class methods */
+ (id)settingsCategoryOrder;
+ (id)settingsSectionRowOrder;
+ (id)rowOrderInSection:(unsigned long long)section;
+ (long long)rowIndexOfSetting:(int)setting;
+ (unsigned long long)categoryForSetting:(int)setting;
+ (int)pageVEForSettingsCategory:(unsigned long long)category;
+ (id)availableValuesForSetting:(int)setting;
+ (id)availableOfflineVideoQualitiesWith1080PQualitySupported:(_Bool)supported supportedFormats:(id)formats isForSmartDownloads:(_Bool)downloads;
+ (_Bool)supportsOfflineVideoQuality:(int)quality is1080PFormatOptionAvailable:(_Bool)available supportedFormats:(id)formats;
+ (id)presentationStringForValue:(id)value ofSetting:(int)setting;
+ (id)subtitlePresentationStringForValue:(id)value ofSetting:(int)setting;
+ (id)abbreviatedPresentationStringForValue:(id)value ofSetting:(int)setting;
+ (id)titleDescriptionStringForBackgroundPlaybackMode:(long long)mode;
+ (id)titleStringForPersistentVideoQuality:(int)quality;
+ (id)abbreviatedTitleStringForPersistentVideoQuality:(int)quality;
+ (id)abbreviatedTitleStringForPersistentAudioQuality:(int)quality;
+ (id)titleDescriptionStringForPersistentVideoQuality:(int)quality;
+ (id)titleStringForPersistentAudioQuality:(int)quality;
+ (id)titleDescriptionStringForPersistentAudioQuality:(int)quality;
+ (id)stringForPlayAsYouBrowseSettingState:(long long)state;
+ (id)availableContentRegions;

@end

