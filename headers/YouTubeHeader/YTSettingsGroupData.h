@interface YTSettingsGroupData : NSObject {
    /* instance variables */
    NSString *_title;
    unsigned long long _type;
    NSArray *_orderedCategories;
}

@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) unsigned long long type;
@property (readonly, nonatomic) NSArray *orderedCategories;

/* instance methods */
- (id)initWithGroupType:(unsigned long long)type;
- (id)titleForSettingGroupType:(unsigned long long)type;
- (id)orderedCategoriesForGroupType:(unsigned long long)type;
- (id)accountCategories;
- (id)videoandAudioPreferencesCategories;
- (id)helpAndPoliciesCategories;
- (id)developmentCategories;
- (id)title;
- (unsigned long long)type;
- (id)orderedCategories;

@end

