@interface YTSettingsViewController : YTStyledViewController <YTFusedSettingsServiceSessionDelegate, YTNavigationControllerDelegate, YTAppSettingsSectionItemDataDelegate, YTAppSettingsViewControllerDelegate, YTSearchHistoryStatusObserver, YTSeparatorCollectionViewDelegateFlowLayout, YTWatchHistoryStatusObserver, YTWrapperSplitViewControllerContent, UIGestureRecognizerDelegate, YTScreenGraftViewController, YTGraftingViewController> {
    /* instance variables */
    YTCollectionViewController *_collectionViewController;
    NSMutableDictionary *_settingsSectionControllers;
    NSArray *_groupsSectionControllers;
    NSString *_settingsToken;
    _Bool _openedSubmenu;
    _Bool _shouldRefreshOnExit;
    YTFusedSettingsService *_fusedSettingsService;
    YTAppSettingsSectionItemActionController *_sectionItemActionController;
    id <YTPageStyleController> _pageStyleController;
    unsigned long long _categoryToScrollTo;
    YTSettingsSectionController *_sectionControllerToScrollTo;
    YTSettingsSectionController *_offlineController;
    YTSettingsSectionController *_smartDownloadsSectionController;
    YTSearchableSettingsViewController *_searchableSettingsViewController;
    _Bool _shouldShowSearchBar;
    _Bool _navigateToDefaultRightPanelOnAppearanceTypeDidChange;
    _Bool _hasNavigatedToDefaultRightPanel;
    _Bool _hasNavigatedToCategoryToScrollTo;
    _Bool _allowDeeplinkingNavigation;
    _Bool _enableSplitViewControllerOverride;
    _Bool _viewDidAppear;
    _Bool _settingsResponseReceived;
    NSNumber *_detailsCategoryID;
    long long _selectedLeftPanelCategoryID;
    unsigned long long _splitViewAppearanceType;
    id <YTResponder> _parentResponder;
    long long _appearance;
    UIViewController *_showViewControllerDelegate;
    id <GIPAccountID> _accountID;
    YTICommand *_navigationEndpoint;
}

@property (retain, nonatomic) YTICommand *navigationEndpoint;
@property (retain, nonatomic) id <GIPAccountID> accountID;
@property (nonatomic) long long appearance;
@property (weak, nonatomic) UIViewController *showViewControllerDelegate;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithAccountID:(id)id parentResponder:(id)responder;
- (void)dealloc;
- (void)loadView;
- (id)startSession;
- (void)viewDidLoad;
- (id)settingsSectionControllers;
- (void)viewWillAppear:(_Bool)appear;
- (_Bool)shouldNavigateToDefaultDetails;
- (void)viewDidAppear:(_Bool)appear;
- (void)viewDidDisappear:(_Bool)disappear;
- (void)showSettingsPickerWithNavTitle:(id)title pickerSectionTitle:(id)title items:(id)items selectedItemIndex:(unsigned long long)index selectBlock:(id /* block */)block;
- (id)settings;
- (void)sendSettingsNavigationEndpointForCategory:(unsigned long long)category;
- (id)settingsView;
- (void)showOrPushViewController:(id)controller;
- (void)pushViewController:(id)controller;
- (void)customizeAndPushOSSViewController:(id)controller parentResponder:(id)responder;
- (void)setShouldRefreshOnExit:(_Bool)exit;
- (void)updateSettingsNavigationBarPageStyle;
- (void)updateSettings:(int)settings withServerSideSwitch:(unsigned long long)_switch;
- (void)setSmartDownloadsCategoryWithSectionItems:(id)items title:(id)title defaultDownloadQuality:(int)quality;
- (void)setSectionItems:(id)items forCategory:(unsigned long long)category title:(id)title icon:(id)icon titleDescription:(id)description headerHidden:(_Bool)hidden;
- (void)updateSettingsItemWithId:(int)id forCategory:(unsigned long long)category settingsItem:(id)item;
- (id)sectionItemModelForSettingId:(int)id fromCategory:(unsigned long long)category;
- (void)updateSettingsSectionControllersForCategory:(unsigned long long)category withSettingController:(id)controller sectionItems:(id)items headerHidden:(_Bool)hidden;
- (void)removeSectionControllerForSettingCategory:(unsigned long long)category;
- (void)reloadData;
- (void)updateDebugAndQASections:(unsigned long long)qasections withEntry:(id)entry;
- (_Bool)collectionView:(id)view layout:(id)layout itemIsHiddenAtIndexPath:(id)path;
- (struct SeparatorAttributes { _Bool x0; float x1; float x2; float x3; })collectionView:(id)view layout:(id)layout separatorAttributesAtSection:(long long)section;
- (struct UIEdgeInsets { double x0; double x1; double x2; double x3; })collectionView:(id)view layout:(id)layout insetForSectionAtIndex:(long long)index;
- (void)searchHistoryStatusDidChange;
- (void)watchHistoryPauseStatusDidChange;
- (id)navigationEndpoint;
- (void)relogScreen;
- (_Bool)gestureRecognizerShouldBegin:(id)begin;
- (void)loadWithModel:(id)model fromView:(id)view;
- (id)model;
- (void)canBePushedWithBlock:(id /* block */)block;
- (void)setupInteractionLoggingHandlersAtResponder:(id)responder;
- (void)navigationControllerWasDismissed:(id)dismissed;
- (_Bool)isReadyToNavigateToCategoryToScrollTo;
- (id)layoutForCollectionViewController;
- (void)handleAppSettingChange:(id)change;
- (void)maybeSendRefreshRequest;
- (void)dismiss;
- (id)collectionViewController;
- (void)enumerateSectionControllersWithBlock:(id /* block */)block;
- (void)updateCategoriesIfNeeded:(id)needed;
- (void)showSettingsTextFieldWithNavTitle:(id)title textTitle:(id)title text:(id)text textChangeBlock:(id /* block */)block;
- (id)createItemFromSectionController:(id)controller categoryId:(unsigned long long)id;
- (void)appearanceTypeDidChangeFromType:(unsigned long long)type toType:(unsigned long long)type hasLoadedSecondView:(_Bool)view;
- (_Bool)splitLayoutBasedOnBoundsRatio;
- (void)setHasOfflineContent:(_Bool)content;
- (void)updateSectionForCategory:(unsigned long long)category withEntry:(id)entry;
- (void)organizeSectionControllersInGroups;
- (void)organizesectionControllersInLine;
- (void)willSetSectionControllers;
- (void)didProcessGetSettingsResponse;
- (void)setSectionControllers;
- (void)updateSelectedItem;
- (void)updateSelectedItemForGroupedSettings;
- (id)groupedSettingsIndexPathForSettingCategoryId:(unsigned long long)id;
- (void)navigateToDefaultRightPanel;
- (void)maybeNavigateToCategoryToScrollTo;
- (void)sendSettingsNavigationEndpointForDetails:(int)details;
- (id)settingsToken;
- (void)didReceiveDrillDownItem:(id)item;
- (id)parentResponder;
- (long long)appearance;
- (void)setAppearance:(long long)appearance;
- (id)showViewControllerDelegate;
- (void)setShowViewControllerDelegate:(id)delegate;
- (id)accountID;
- (void)setAccountID:(id)id;
- (void)setNavigationEndpoint:(id)endpoint;

@end

@interface YTSettingsViewControllerRegistrationProvider : NSObject <YTInnerTubeTopControllerRegistrationProvider>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)topControllersToRegisterWithExtension;
- (id)topControllersToRegister;

@end

