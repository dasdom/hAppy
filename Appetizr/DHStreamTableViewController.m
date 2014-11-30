 //
//  DHUserPostsTableViewController.m
//  Appetizr
//
//  Created by dasdom on 14.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHStreamTableViewController.h"
#import "DHPostCell.h"
#import "DHControllCell.h"
#import "DHStreamDetailTableViewController.h"
#import "DHCreateStatusViewController.h"
#import "DHWebViewController.h"
#import "DHProfileTableViewController.h"
#import "DHUserStreamTableViewController.h"
#import "DHAppDelegate.h"
#import "PRPAlertView.h"
#import "DHMetaDataTableViewController.h"
#import "DHHashtagTableViewController.h"
#import "DHMentionsTableViewController.h"
#import "DHGlobalStreamTableViewController.h"
#import "DHInteractionsViewController.h"
#import "DHMessagesTableViewController.h"
#import "DHActionSheet.h"
#import "DHPostImageViewController.h"
#import "AuthenticationViewController.h"
#import "PostDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SSKeychain.h"
#import "SlideInView.h"
#import "DHOpenWebsiteActivity.h"
#import "MutedHashtagCell.h"
#import "UITableView+PRPSubviewAdditions.h"
#import "UIImage+NormalizedImage.h"
#import "ImageHelper.h"
#import "NSString+ANAPIRangeAdapter.h"
#import "HappyActionIcons.h"
#import "NSAttributedString+HeightCalculation.h"


NSString *const kConentOffsetYDefaultsKey = @"kConentOffsetYDefaultsKey";
NSString *const kNewestIndexPathRowKey = @"kNewestIndexPathRowKey";
NSString *const kNewestIndexPathSectionKey = @"kNewestIndexPathSectionKey";

const CGFloat kSlideInDuration = 2.0;
const CGFloat kSlideInHeight = 20.0;

@interface DHStreamTableViewController () <UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSIndexPath *newestIndexPath;
@property (nonatomic, strong) NSIndexPath *topMostIndexPath;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSString *maxId;
@property (nonatomic, strong) NSString *minId;
@property (nonatomic, strong) UILabel *numberOfNewPostLabel;

@property (nonatomic, strong) NSDictionary *markerDict;
@property (nonatomic, strong) NSDate *retryMarkerAfter;
@property (nonatomic, strong) NSTimer *markerTimer;
@property (nonatomic) BOOL isUpdatingMarker;

@property (nonatomic, strong) NSSet *seenIds;
@property (nonatomic, strong) NSSet *selectedIds;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

//@property (nonatomic, strong) UISearchDisplayController *searchController;
//@property (nonatomic, strong) UISearchBar *searchBar;
//@property (nonatomic, strong) NSArray *searchResultArray;

@property (nonatomic, strong) PRPConnection *streamConnection;
@property (nonatomic, strong) PRPConnection *dhChannelConnection;

@property (nonatomic, strong) SlideInView *languageSlideInView;
@property (nonatomic, strong) NSArray *allUserStreamArray;
@property (nonatomic, strong) NSString *currentLanguageString;

@property (nonatomic, strong) NSMutableDictionary *mutableLabelHeightDictionary;
@property (nonatomic, strong) NSMutableDictionary *mutableImageHeightDictionary;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) NSInteger postIdToShow;

@property (nonatomic, strong) NSIndexPath *lastVisibleIndexPath;

@property (nonatomic, strong) NSString *avatarDirectoryPath;

@property (nonatomic, assign) CGFloat positionCorrection;

@property (nonatomic, assign) BOOL updateNewestIndexPath;
@end

@implementation DHStreamTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.controlIndexPath = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(topLayoutGuide)])
    {
        self.positionCorrection = 64.0f;
    }
    else
    {
        self.positionCorrection = 0.0f;
    }
    
    self.isLoading = NO;
    self.isUpdatingMarker = NO;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
    } else {
        refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
    }
    [refreshControl addTarget:self action:@selector(loadNewPosts:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    _numberOfNewPostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 43.0f)];
    _numberOfNewPostLabel.numberOfLines = 2;
    _numberOfNewPostLabel.alpha = 0.0f;
    _numberOfNewPostLabel.textAlignment = NSTextAlignmentCenter;
    _numberOfNewPostLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _numberOfNewPostLabel.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:kFontName] size:13.0f];
    [self.tableView addSubview:_numberOfNewPostLabel];
    
    [self loadStreamArray];
    
    self.retryMarkerAfter = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataOfTableView:) name:kSettingsChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dissmisData:) name:kUserChangedNotification object:nil];
    
    self.seenIds = [NSSet set];
    self.selectedIds = [NSSet set];
    self.selectedIndexPath = nil;
    
    self.mutableLabelHeightDictionary = [NSMutableDictionary dictionary];
    self.mutableImageHeightDictionary = [NSMutableDictionary dictionary];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _avatarDirectoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatars"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brightnessDidChange:) name:UIScreenBrightnessDidChangeNotification object:nil];
}

- (void)brightnessDidChange:(NSNotification*)notification
{
    [self changeThemeModeIfNeeded];
}

- (void)loadStreamArray {
    if (![self isKindOfClass:([DHProfileTableViewController class])] &&
        ![self isKindOfClass:([DHInteractionsViewController class])] &&
        ![self isKindOfClass:([DHMessagesTableViewController class])]) {
        self.userStreamArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    }
    dhDebug(@"[self.userStreamArray count] %d", [self.userStreamArray count]);
    if (!self.userStreamArray) {
        self.userStreamArray = [NSArray array];
    }
    
    [self.tableView reloadData];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _newestIndexPath = [NSIndexPath indexPathForRow:[userDefaults integerForKey:[self keyForNewestIndexPathRow]] inSection:[userDefaults integerForKey:[self keyForNewestIndexPathSection]]];
    if (!_newestIndexPath) {
        _newestIndexPath = [NSIndexPath indexPathForRow:INT16_MAX inSection:0];
    }
    dhDebug(@"_newestIndexPath: %@", _newestIndexPath);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    NSString *accountString = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey];
//    accountString = [SSKeychain passwordForService:@"de.dasdom.happy" account:kUserNameDefaultKey];
//    dhDebug(@"accountString: %@, defaultKey: %@", accountString, kUserNameDefaultKey);
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:accountString];
    
    if (!accessToken && ![self isKindOfClass:([DHGlobalStreamTableViewController class])]) {
        AuthenticationViewController *authViewController = [[AuthenticationViewController alloc] init];
        UINavigationController *authNavigationController = [[UINavigationController alloc] initWithRootViewController:authViewController];
        [self presentViewController:authNavigationController animated:YES completion:^{}];
        return;
    }
    
    [self.navigationController setToolbarHidden:YES animated:NO];

    [self changeThemeModeIfNeeded];
    [self setColors];
    
    NSString *arrayQualifierString;
    if ([self isMemberOfClass:[DHGlobalStreamTableViewController class]]) {
        arrayQualifierString = @"Global";
    } else {
        arrayQualifierString = @"Stream";
    }
    NSString *languagesKeyString = [NSString stringWithFormat:@"languagesArray_%@", arrayQualifierString];
    NSArray *languagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:languagesKeyString];
    NSMutableString *mutableLanguageString = [NSMutableString string];
    for (NSString *languageString in languagesArray) {
        [mutableLanguageString appendFormat: @"%@,", languageString];
    }
    if ([mutableLanguageString isEqualToString:@""]) {
        [mutableLanguageString appendString: @"all,"];
    }
    self.currentLanguageString = [mutableLanguageString substringToIndex:[mutableLanguageString length]-1];
    
    if (![self isKindOfClass:([DHProfileTableViewController class])]) {
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDarkMode:)];
        [self.navigationController.navigationBar addGestureRecognizer:longPressRecognizer];
    }

//    NSLog(@"88 self.newestIndexPath: %@", self.newestIndexPath);
    dhDebug(@"*************************************************");
    dhDebug(@"contentOffsetY: %f", self.tableView.contentOffset.y);
    dhDebug(@"*************************************************");
    if (self.tableView.contentOffset.y < 1) {
        [self.tableView setContentOffset:CGPointMake(0.0f, [self contentOffsetY]) animated:NO];
    }
//    NSLog(@"99 self.newestIndexPath: %@", self.newestIndexPath);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kHideSeenThreads]) {
        self.seenIds = [NSSet set];
        self.selectedIds = [NSSet set];
        self.selectedIndexPath = nil;
    } else if (self.selectedIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        [[self tableView] reloadData];
        self.selectedIndexPath = nil;
    }
}

- (void)changeThemeModeIfNeeded
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kAutomaticSwitchTheme]) {
        return;
    }
    
    CGFloat screenBrightness = [[UIScreen mainScreen] brightness];
    CGFloat switchThemeBrighnessValue = [userDefaults floatForKey:kBrightnessThemeSwitchValue];
    if (screenBrightness < switchThemeBrighnessValue) {
        if ([userDefaults boolForKey:kDarkMode]) {
            return;
        }
        [userDefaults setBool:YES forKey:kDarkMode];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    } else {
        if (![userDefaults boolForKey:kDarkMode]) {
            return;
        }
        [userDefaults setBool:NO forKey:kDarkMode];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
    [userDefaults synchronize];
    dhDebug(@"screenBrightness: %f, switchThemeBrighnessValue: %f", screenBrightness, switchThemeBrighnessValue);
    [self setColors];
}

- (void)setColors {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        [self.tabBarController.tabBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
        UIColor *textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        
        [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
        [self.navigationController.navigationBar setTintColor:textColor];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        [self.navigationController.toolbar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
        self.numberOfNewPostLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        self.numberOfNewPostLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        self.tableView.tableFooterView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        [self.menuButton setImage:[ImageHelper menueWithStreamColor:textColor mentionColor:textColor messagesColor:textColor patterColor:textColor] forState:UIControlStateNormal];
        self.refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        self.refreshControl.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        self.tableView.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMarkerColor;
    } else {
        self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        [self.tabBarController.tabBar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
        UIColor *textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        
        [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
        [self.navigationController.navigationBar setTintColor:textColor];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
        [self.navigationController.toolbar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
        self.numberOfNewPostLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        self.numberOfNewPostLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        self.tableView.tableFooterView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        [self.menuButton setImage:[ImageHelper menueWithStreamColor:textColor mentionColor:textColor messagesColor:textColor patterColor:textColor] forState:UIControlStateNormal];
        self.refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        self.refreshControl.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        self.tableView.tintColor = [DHGlobalObjects sharedGlobalObjects].markerColor;
    }
    [self.tableView reloadData];
    [self.view setNeedsDisplay];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeColorsNotification object:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.refreshControl beginRefreshing];
    [self loadNewPosts:nil];
    
    _updateNewestIndexPath = YES;
    [[self tableView] reloadData];
    
    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
        [self.navigationController setHidesBarsOnSwipe:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.streamConnection stop];
    [self.dhChannelConnection stop];
    self.isLoading = NO;
    [self.refreshControl endRefreshing];
    
    dhDebug(@"viewWillDisappear");
    [self updateMarker];
    [self saveContentOffsetY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//    self.userStreamArray = [NSArray array];
    NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
    [imageCache removeAllObjects];
}

- (BOOL)shouldAutorotate {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
//    }
//    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    self.lastVisibleIndexPath = [[self currentTableView].indexPathsForVisibleRows lastObject];
//}
//
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [[self currentTableView] scrollToRowAtIndexPath:self.lastVisibleIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.mutableImageHeightDictionary removeAllObjects];
    [self.mutableLabelHeightDictionary removeAllObjects];
    [self.tableView reloadData];
}


//- (void)refreshTriggered {
- (void)loadNewPosts:(UIRefreshControl*)sender {
    if (self.isLoading) {
        return;
    }
    [self updateMarker];
    
    NSString *sinceIdString;
    if ([self.userStreamArray count] > 0) {
        sinceIdString = [[self.userStreamArray objectAtIndex:0] objectForKey:@"id"];
    }
    dhDebug(@"sinceIdString: %@", sinceIdString);
    [self updateUserStreamArraySinceId:sinceIdString beforeId:nil];
}

- (void)loadNewPostsWithCompletionHandler:(void(^)(BOOL newData))completionHandler {
    NSString *sinceIdString;
    if ([self.userStreamArray count] > 0) {
        sinceIdString = [[self.userStreamArray objectAtIndex:0] objectForKey:@"id"];
    }
    [self updateUserStreamArraySinceId:sinceIdString beforeId:nil withCompletionHandler:completionHandler];
}

- (void)updateUserStreamArraySinceId:(NSString *)sinceId beforeId:(NSString *)beforeId {
    [self updateUserStreamArraySinceId:sinceId beforeId:beforeId withCompletionHandler:nil];
}

- (void)updateUserStreamArraySinceId:(NSString*)sinceId beforeId:(NSString*)beforeId withCompletionHandler:(void(^)(BOOL newData))completionHandler {
    if ([(DHAppDelegate*)[[UIApplication sharedApplication] delegate] internetReach].currentReachabilityStatus == NotReachable) {
        [self.refreshControl endRefreshing];
        return;
    }
    self.isLoading = YES;

    [self changeThemeModeIfNeeded];
    
    [_streamConnection stop];

    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSMutableString *mutableUrlString = [self.urlString mutableCopy];
    if (!mutableUrlString) {
        self.isLoading = NO;
        return;
    }
    
    if ([mutableUrlString rangeOfString:@"?"].location == NSNotFound) {
        [mutableUrlString appendString:@"?"];
    } else {
        [mutableUrlString appendString:@"&"];
    }
    if (sinceId) {
        [mutableUrlString appendFormat:@"since_id=%@&", sinceId];
        [mutableUrlString appendFormat:@"count=%d&", 200];
        [self.mutableLabelHeightDictionary removeAllObjects];
        [self.mutableImageHeightDictionary removeAllObjects];
    }

    if (beforeId) {
        [mutableUrlString appendFormat:@"before_id=%@&", beforeId];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [mutableUrlString appendFormat:@"include_deleted=0&"];
    [mutableUrlString appendFormat:@"include_post_annotations=1&"];
    if ([userDefaults boolForKey:kIncludeDirecedPosts]) {
        [mutableUrlString appendFormat:@"include_directed_posts=1&"];
        
    }
    
    if ([self isKindOfClass:([DHMessagesTableViewController class])]) {
        [mutableUrlString appendFormat:@"include_message_annotations=1&"];
    }
    if (!accessToken) {
        self.isLoading = NO;
        [self.refreshControl endRefreshing];
        return;
    }
    dhDebug(@"mutableUrlString: %@", mutableUrlString);
    
    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", mutableUrlString, accessToken];
    
    NSMutableURLRequest *streamRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
    [streamRequest setHTTPMethod:@"GET"];
    [streamRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    __weak DHStreamTableViewController *weakSelf = self;
    dhDebug(@">>>>>>>>>>> start");
    __block NSInteger numberOfMentions = 0;
//    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *streamSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];

    _streamConnection = [PRPConnection connectionWithRequest:streamRequest progressBlock:^(PRPConnection* connection){
        dhDebug(@"not yet finished");
    } completionBlock:^(PRPConnection *connection, NSError *error) {
//    _streamDataTask = [streamSession dataTaskWithRequest:streamRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
        dhDebug(@">>>>>>>>>>>>> stop");
        if (error.code == -999) {
            return;
        }
        
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
        dhDebug(@"metaDict: %@", metaDict);
        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
            [weakSelf.refreshControl endRefreshing];

            if (!completionHandler) {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Stream could not be loaded", nil) message:error.localizedDescription cancelTitle:@"OK" cancelBlock:^{} otherTitle:@"Retry" otherBlock:^{
                    [weakSelf updateUserStreamArraySinceId:sinceId beforeId:beforeId];
                }];
            }
            return;
        }
        
        weakSelf.maxId = [metaDict objectForKey:@"max_id"];
        weakSelf.minId = [metaDict objectForKey:@"min_id"];
        
        id marker = [metaDict objectForKey:@"marker"];
        if ([marker isKindOfClass:[NSDictionary class]]) {
            weakSelf.markerDict = marker;
        } else if ([marker isKindOfClass:[NSArray class]]) {
            weakSelf.markerDict = [marker firstObject];
        } else {
            weakSelf.markerDict = nil;
        }
        NSLog(@"markerDict: %@", weakSelf.markerDict);
        
        NSMutableArray *mutableArray = [weakSelf.userStreamArray mutableCopy];
        id postsToInsert = [responseDict objectForKey:@"data"];
        if (![postsToInsert isKindOfClass:[NSArray class]] ||
            [postsToInsert count] < 1) {
            dhDebug(@"postsToInsert is not an array");
            weakSelf.isLoading = NO;
            [weakSelf.refreshControl endRefreshing];
            
            if ([weakSelf isKindOfClass:([DHUserStreamTableViewController class])]
                && [userDefaults boolForKey:kStreamMarker] && sinceId) {
                [self srollToMarker];
            }
            
            if (completionHandler) completionHandler(NO);
            return;
        }
        
        if (self.controlIndexPath.section == 0) {
            self.controlIndexPath = [NSIndexPath indexPathForRow:self.controlIndexPath.row+[postsToInsert count] inSection:0];
        }
        
        CGSize contentSizeBefore = weakSelf.tableView.contentSize;
        dhDebug(@"count: %d", [postsToInsert count]);
        
        if ([self isKindOfClass:([DHUserStreamTableViewController class])]) {
            for (NSDictionary *postDict in postsToInsert) {
                NSArray *mentionArray = [[postDict objectForKey:@"entities"] objectForKey:@"mentions"];
                NSString *myName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey];
                BOOL directedToMe = NO;
                for (NSDictionary *mentionDict in mentionArray) {
                    NSString *mentionName = [mentionDict objectForKey:@"name"];
                    if ([mentionName isEqualToString:myName]) {
                        directedToMe = YES;
                        break;
                    }
                }
                if (directedToMe) {
                    [[DHGlobalObjects sharedGlobalObjects] addUnreadMentionWithId:postDict[@"id"]];
                }
            }
            
        }
        numberOfMentions = [[DHGlobalObjects sharedGlobalObjects] numberOfUnreadMentions];
        
        NSArray *filteredPostsToInsert;
        if ([weakSelf isKindOfClass:([DHUserStreamTableViewController class])] ||
            [weakSelf isKindOfClass:([DHGlobalStreamTableViewController class])]) {
            filteredPostsToInsert = [self filterLanguagesForArray:postsToInsert];
        } else {
            filteredPostsToInsert = postsToInsert;
        }
        if (sinceId) {
            NSRange indexRange = {0, [filteredPostsToInsert count]};
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:indexRange];
            [mutableArray insertObjects:filteredPostsToInsert atIndexes:indexSet];
//            NSLog(@"111 self.newestIndexPath: %@", self.newestIndexPath);
            weakSelf.newestIndexPath = [NSIndexPath indexPathForRow:[filteredPostsToInsert count]+weakSelf.newestIndexPath.row inSection:weakSelf.newestIndexPath.section];
            [userDefaults setInteger:weakSelf.newestIndexPath.row forKey:[self keyForNewestIndexPathRow]];
            [userDefaults setInteger:weakSelf.newestIndexPath.section forKey:[self keyForNewestIndexPathSection]];
            [userDefaults synchronize];
        } else {
            [mutableArray addObjectsFromArray:filteredPostsToInsert];
        }
        
        weakSelf.userStreamArray = [mutableArray copy];
        [weakSelf.tableView reloadData];
    
        CGSize contentSizeAfter = weakSelf.tableView.contentSize;
        if (sinceId && ![weakSelf isKindOfClass:([DHHashtagTableViewController class])]
            && ![weakSelf isKindOfClass:([DHProfileTableViewController class])]
            ) {
            CGFloat contentOffsetY = [self contentOffsetY];
            dhDebug(@"11 [self contentOffsetY]: %f", [self contentOffsetY]);
            [weakSelf.tableView setContentOffset:CGPointMake(0.0f, contentOffsetY + (contentSizeAfter.height - contentSizeBefore.height)) animated:NO];
            [self saveContentOffsetY];
            NSIndexPath *indexPathOfBottomCell = [weakSelf.tableView indexPathForCell:[weakSelf.tableView.visibleCells lastObject]];
            NSInteger numberOfShownPost = 40;
            if ([weakSelf isKindOfClass:([DHUserStreamTableViewController class])] ||
                [weakSelf isKindOfClass:([DHGlobalStreamTableViewController class])] ||
                [weakSelf isKindOfClass:([DHMentionsTableViewController class])]) {
                numberOfShownPost = 200;
            }
            if ([mutableArray count] > weakSelf.newestIndexPath.row + numberOfShownPost && [mutableArray count] > indexPathOfBottomCell.row + 41) {
                NSRange indexRangeToRemove = {weakSelf.newestIndexPath.row+numberOfShownPost, [mutableArray count]-(weakSelf.newestIndexPath.row+numberOfShownPost)};
                NSMutableIndexSet *indexSetToRemove = [NSMutableIndexSet indexSetWithIndexesInRange:indexRangeToRemove];
                [mutableArray removeObjectsAtIndexes:indexSetToRemove];
                weakSelf.userStreamArray = [mutableArray copy];
            }
        }

        [weakSelf.tableView reloadData];
        weakSelf.isLoading = NO;
        [weakSelf.refreshControl endRefreshing];

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![weakSelf isKindOfClass:([DHProfileTableViewController class])] &&
                ![weakSelf isKindOfClass:([DHInteractionsViewController class])] &&
                ![weakSelf isKindOfClass:([DHMessagesTableViewController class])]) {
                [NSKeyedArchiver archiveRootObject:weakSelf.userStreamArray toFile:[weakSelf archivePath]];
            }
//        });

        if (completionHandler) {
            completionHandler([postsToInsert count]);
            return;
        }
        
        if ([weakSelf isKindOfClass:([DHUserStreamTableViewController class])]
            && [userDefaults boolForKey:kStreamMarker] && sinceId) {
            [self srollToMarker];
            
        }
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@channels", kBaseURL];
        NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@?include_read=0&channel_types=net.app.core.pm,net.patter-app.room&access_token=%@", urlString, accessToken];
        
        NSMutableURLRequest *channelRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
        [channelRequest setHTTPMethod:@"GET"];
        [channelRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        
//        NSURLSession *channelSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];

        _dhChannelConnection = [PRPConnection connectionWithRequest:channelRequest progressBlock:^(PRPConnection *connection){} completionBlock:^(PRPConnection *connection, NSError *error) {
        
//        _channelDataTask = [channelSession dataTaskWithRequest:channelRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
//            NSError *jsonError;

            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];

            //        dhDebug(@"responseDict: %@", responseDict);
            NSArray *channelsArray = [responseDict objectForKey:@"data"];
            if (channelsArray) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateChannelsArray object:weakSelf userInfo:@{@"channelsArray" : channelsArray}];
            }
            NSInteger unreadMessages = 0;
            NSInteger unreadPatter = 0;
            for (NSDictionary *channelsDict in channelsArray) {
                
                BOOL isPatter = NO;
                //            dhDebug(@"channelsDict: %@", channelsDict);
                if ([[channelsDict objectForKey:@"type"] isEqualToString:@"net.patter-app.room"]) {
                    isPatter = YES;
                }
                if ([[channelsDict objectForKey:@"has_unread"] boolValue]) {
                    if (isPatter) {
                        if (![userDefaults boolForKey:kIgnoreUnreadPatter]) {
                            unreadPatter++;
                        }
                    } else {
                        unreadMessages++;
                    }
                }
            }
            [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPrivateMessages = unreadMessages;
            [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPatter = unreadPatter;
            
            if ((unreadMessages+unreadPatter+numberOfMentions) && ![weakSelf isKindOfClass:([DHMessagesTableViewController class])]) {
                [(UITabBarItem*)[weakSelf.navigationController.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d+%d", unreadMessages, unreadPatter]];
                UIColor *textColor;
                UIColor *mentionColor;
                UIColor *messagesColor;
                UIColor *patterColor;
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
                    mentionColor = numberOfMentions ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
                    messagesColor = unreadMessages ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
                    patterColor = unreadPatter ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
                    textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
                } else {
                    mentionColor = numberOfMentions ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
                    messagesColor = unreadMessages ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
                    patterColor = unreadPatter ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
                    textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
                }
                [weakSelf.menuButton setImage:[ImageHelper menueWithStreamColor:textColor mentionColor:mentionColor messagesColor:messagesColor patterColor:patterColor] forState:UIControlStateNormal];
            } else {
                [(UITabBarItem*)[weakSelf.navigationController.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNumberOfUnreadMessagesNotification object:weakSelf userInfo:@{@"unreadMessages": [NSNumber numberWithInteger:unreadMessages], @"unreadPatter": [NSNumber numberWithInteger:unreadPatter]}];
        }];
        [_dhChannelConnection start];
//         [_channelDataTask resume];

    }];
    [_streamConnection start];
//    [_streamDataTask resume];
    

}

- (void)srollToMarker {
    int i = 0;
    dhDebug(@"srollToMarker");
    for (NSDictionary *postDict in self.userStreamArray) {
        NSString *markerId = [self.markerDict objectForKey:@"id"];
        if ([[postDict objectForKey:@"id"] isEqualToString:markerId]) {
            dhDebug(@">>> marker: %@", [self.markerDict objectForKey:@"id"]);
            dhDebug(@"post id: %@", [postDict objectForKey:@"id"]);
            NSIndexPath *markerIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:markerIndexPath];
            if (![self.tableView.visibleCells containsObject:cell]) {
                NSDictionary *topPostDict = [self.userStreamArray objectAtIndex:self.topMostIndexPath.row];
                if ([topPostDict[@"id"] compare:markerId options:NSNumericSearch] == NSOrderedAscending) {
                    [self.tableView scrollToRowAtIndexPath:markerIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    [self.tableView reloadData];
                }
            }
            break;
        }
        i++;
    }
}

- (NSArray*)currentStreamArray {
//    if ([self.searchResultArray count]) {
//        return self.searchResultArray;
//    } else {
        return self.userStreamArray;
//    }
}

- (void)menuButtonTouched:(UIBarButtonItem*)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuTouchedNotification object:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userStreamArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DHPostCell *postCell;
//    if (tableView == self.tableView) {
        postCell = [DHPostCell cellForTableView:tableView];
//    } else {
//        postCell = [DHPostCell cellForTableView:self.searchDisplayController.searchResultsTableView];
//    }
    
    postCell.isSelectedCell = NO;
    
    NSDictionary *postDict = [self.userStreamArray objectAtIndex:indexPath.row];
    
    NSString *hashtagString;
    NSArray *hashTagArray = [[postDict objectForKey:@"entities"] objectForKey:@"hashtags"];
    for (NSDictionary *hashTagDict in hashTagArray) {
        hashtagString = [hashTagDict objectForKey:@"name"];
        if ([[DHGlobalObjects sharedGlobalObjects].mutedHashtagSet containsObject:hashtagString] && [[postDict objectForKey:@"id"] integerValue] != self.postIdToShow && ![self isKindOfClass:([DHProfileTableViewController class])]) {
            
            MutedHashtagCell *mutedHashtagCell = [MutedHashtagCell cellForTableView:tableView];
            mutedHashtagCell.hashtagLabel.text = [NSString stringWithFormat:@"#%@ by %@", hashtagString, [[postDict objectForKey:@"user"] objectForKey:@"username"]];
            mutedHashtagCell.hashTag = hashtagString;
            [mutedHashtagCell.deleteButton addTarget:self action:@selector(removeHashTag:) forControlEvents:UIControlEventTouchUpInside];
            UITapGestureRecognizer *tapOnHashtagCellRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHashtagHappend:)];
            [mutedHashtagCell addGestureRecognizer:tapOnHashtagCellRecognizer];
            [mutedHashtagCell.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
            mutedHashtagCell.hashtagLabel.accessibilityLabel = [NSString stringWithFormat:@"Post with muted hashtag %@ by %@", hashtagString, [[postDict objectForKey:@"user"] objectForKey:@"username"]];
            
            return mutedHashtagCell;
        }
    }
    NSString *threadId = [postDict objectForKey:@"thread_id"];
    if ([[DHGlobalObjects sharedGlobalObjects].mutedThreadIdSet containsObject:threadId] && [[postDict objectForKey:@"id"] integerValue] != self.postIdToShow && ![self isKindOfClass:([DHProfileTableViewController class])] && ![self isKindOfClass:([DHStreamDetailTableViewController class])]) {
        
        MutedHashtagCell *mutedHashtagCell = [MutedHashtagCell cellForTableView:tableView];
        mutedHashtagCell.hashtagLabel.text = [NSString stringWithFormat:@"post in conv. %@ by %@", threadId, [[postDict objectForKey:@"user"] objectForKey:@"username"]];
        mutedHashtagCell.threadId = threadId;
        [mutedHashtagCell.deleteButton addTarget:self action:@selector(removeThreadId:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tapOnHashtagCellRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHashtagHappend:)];
        [mutedHashtagCell addGestureRecognizer:tapOnHashtagCellRecognizer];
        [mutedHashtagCell.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        mutedHashtagCell.hashtagLabel.accessibilityLabel = [NSString stringWithFormat:@"Post in muted conversation %@ by %@", threadId, [[postDict objectForKey:@"user"] objectForKey:@"username"]];
        
        return mutedHashtagCell;
    }
    
    NSString *clientName = [[postDict objectForKey:@"source"] objectForKey:@"name"];
    if ([[DHGlobalObjects sharedGlobalObjects].mutedClients containsObject:clientName] && [[postDict objectForKey:@"id"] integerValue] != self.postIdToShow && ![self isKindOfClass:([DHProfileTableViewController class])] && ![self isKindOfClass:([DHStreamDetailTableViewController class])]) {
        
        MutedHashtagCell *mutedHashtagCell = [MutedHashtagCell cellForTableView:tableView];
        mutedHashtagCell.hashtagLabel.text = [NSString stringWithFormat:@"post with %@ by %@", clientName, [[postDict objectForKey:@"user"] objectForKey:@"username"]];
        mutedHashtagCell.clientName = clientName;
        [mutedHashtagCell.deleteButton addTarget:self action:@selector(removeClient:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tapOnHashtagCellRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHashtagHappend:)];
        [mutedHashtagCell addGestureRecognizer:tapOnHashtagCellRecognizer];
        [mutedHashtagCell.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        mutedHashtagCell.hashtagLabel.accessibilityLabel = [NSString stringWithFormat:@"Post from muted client %@ by %@", clientName, [[postDict objectForKey:@"user"] objectForKey:@"username"]];
        
        return mutedHashtagCell;
    }
//    if (mutePost && [[postDict objectForKey:@"id"] integerValue] != self.postIdToShow) {
//        MutedHashtagCell *mutedHashtagCell = (MutedHashtagCell*)[tableView dequeueReusableCellWithIdentifier:@"mutedHashtagCell"];
//        mutedHashtagCell.hashtagLabel.text = [NSString stringWithFormat:@"#%@ by %@", hashtagString, [[postDict objectForKey:@"user"] objectForKey:@"username"]];
//        mutedHashtagCell.hashtagLabel.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:kFontName] size:[[[NSUserDefaults standardUserDefaults] objectForKey:kFontSize] floatValue]];
//        mutedHashtagCell.hashtagLabel.textColor = [UIColor grayColor];
//        mutedHashtagCell.hashtagLabel.backgroundColor = [UIColor clearColor];
//        mutedHashtagCell.hashTag = hashtagString;
//        [mutedHashtagCell.deleteButton addTarget:self action:@selector(removeHashTag:) forControlEvents:UIControlEventTouchUpInside];
//        UITapGestureRecognizer *tapOnHashtagCellRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHashtagHappend:)];
//        [mutedHashtagCell addGestureRecognizer:tapOnHashtagCellRecognizer];
//        return mutedHashtagCell;
//    }
    
    [self populatePostCell:postCell withDictionary:postDict forIndexPath:indexPath];
    
    if (![postCell.gestureRecognizers count]) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
        panGestureRecognizer.delegate = self;
        [postCell addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHappend:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [postCell addGestureRecognizer:doubleTapRecognizer];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHappend:)];
        [postCell addGestureRecognizer:longPressRecognizer];
        
        UITapGestureRecognizer *postTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postTextViewTapped:)];
        [postTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [postTapRecognizer requireGestureRecognizerToFail:longPressRecognizer];
        [postCell addGestureRecognizer:postTapRecognizer];
    
//        if (![self isKindOfClass:([DHGlobalStreamTableViewController class])]) {
//            UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftHappend:)];
//            swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//            [postCell addGestureRecognizer:swipeLeftGestureRecognizer];
//
//            UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
//            swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//            [postCell addGestureRecognizer:swipeRightGestureRecognizer];
//        }
    }
    
    [postCell.postTextView setNeedsDisplay];
    [postCell setNeedsDisplay];
    
    return postCell;
}

- (void)populatePostCell:(DHPostCell*)postCell withDictionary:(NSDictionary*)thePostDict forIndexPath:(NSIndexPath*)indexPath {
    NSDictionary *postDict = [thePostDict copy];
    
    NSDictionary *userDict = [postDict objectForKey:@"user"];
//    NSLog(@"userDict: %@", userDict);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *repostOfDict = [postDict objectForKey:@"repost_of"];
    BOOL isRepost = NO;
    if (repostOfDict) {
        isRepost = YES;
        if ([userDefaults boolForKey:kHideClient]) {
            postCell.clientString = [NSString stringWithFormat:NSLocalizedString(@"reposted by %@", nil), [userDict objectForKey:@"username"]];
        } else {
            postCell.clientString = [NSString stringWithFormat:NSLocalizedString(@"reposted by %@ via %@", nil), [userDict objectForKey:@"username"], [[postDict objectForKey:@"source"] objectForKey:@"name"]];
        }
        postDict = repostOfDict;
        userDict = [postDict objectForKey:@"user"];
    } else {
        postCell.clientString = [NSString stringWithFormat:@"via %@", [[postDict objectForKey:@"source"] objectForKey:@"name"]];
    }
    
    if ([userDefaults boolForKey:kShowRealNames]) {
        postCell.nameString = [userDict objectForKey:@"name"];
    } else {
        postCell.nameString = [userDict objectForKey:@"username"];
    }

    if (![self isKindOfClass:[DHGlobalStreamTableViewController class]]) {
        NSMutableSet *mutableUserNameSet = [[[DHGlobalObjects sharedGlobalObjects] userNameSet] mutableCopy];
        [mutableUserNameSet addObject:[userDict objectForKey:@"username"]];
        [[DHGlobalObjects sharedGlobalObjects] setUserNameSet:[mutableUserNameSet copy]];
    }
    
    NSDate *memberSizeDate = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[userDict objectForKey:@"created_at"]];
    CGFloat daysOfMembership = [[NSDate date] timeIntervalSinceDate:memberSizeDate]/(60.0f*60.0f*24.0f);
    dhDebug(@"daysOfMembership: %f", daysOfMembership);
    NSInteger numberOfPosts = [userDict[@"counts"][@"posts"] integerValue];
    dhDebug(@"numberOfPosts: %d", numberOfPosts);
    
    NSInteger followers = [userDict[@"counts"][@"followers"] integerValue];
    NSInteger following = [userDict[@"counts"][@"following"] integerValue];
    
    postCell.idLabel.text = [NSString stringWithFormat:@"User: %@\n%.1f posts per day\n%d followers\n%d following", userDict[@"id"], numberOfPosts/daysOfMembership, followers, following];
    
    if ([postDict[@"num_replies"] integerValue] > 0 || [postDict[@"id"] isEqualToString:postDict[@"thread_id"]] == false) {
        dhDebug(@"id: %@, thread_id: %@", postDict[@"id"], postDict[@"thread_id"]);
        postCell.conversationImageView.hidden = false;
    } else {
        postCell.conversationImageView.hidden = true;
    }
    
    [postCell.replyButton addTarget:self action:@selector(replyOnPost:) forControlEvents:UIControlEventTouchUpInside];
    [postCell.repostButton addTarget:self action:@selector(repostPost:) forControlEvents:UIControlEventTouchUpInside];
    [postCell.starButton addTarget:self action:@selector(starPost:) forControlEvents:UIControlEventTouchUpInside];
    [postCell.conversationButton addTarget:self action:@selector(showConversation:) forControlEvents:UIControlEventTouchUpInside];
    postCell.buttonHostView.hidden = YES;
    
    postCell.faved = [postDict[@"you_starred"] boolValue];
    
    postCell.userId  = [userDict objectForKey:@"id"];
    postCell.iAmFollowing = [[userDict objectForKey:@"you_follow"] boolValue];
    postCell.followsMe = [[userDict objectForKey:@"follows_you"] boolValue];
    postCell.canonical_url = [postDict objectForKey:@"canonical_url"];
    
    NSDate *date = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[postDict objectForKey:@"created_at"]];
    CGFloat secondsSincePost = -[date timeIntervalSinceNow];
    NSString *timeSincePostString;
    NSMutableString *accessibilityString = [postCell.nameString mutableCopy];
    if (secondsSincePost < 60.0f) {
        timeSincePostString = NSLocalizedString(@"now", nil);
        if (repostOfDict) {
            [accessibilityString appendFormat:NSLocalizedString(@" posted now and was %@", nil), postCell.clientString];
        } else {
            [accessibilityString appendFormat:NSLocalizedString(@" posted now %@", nil), postCell.clientString];
        }
    } else if (secondsSincePost < 3600.0f) {
        timeSincePostString = [NSString stringWithFormat:@"%dm", (int)secondsSincePost/60];
        if (repostOfDict) {
            [accessibilityString appendFormat:NSLocalizedString(@" posted %d minutes ago and was %@", nil), (int)secondsSincePost/60, postCell.clientString];
        } else {
            [accessibilityString appendFormat:NSLocalizedString(@" posted %d minutes ago %@", nil), (int)secondsSincePost/60, postCell.clientString];
        }
    } else if (secondsSincePost < 86400.0f) {
        timeSincePostString = [NSString stringWithFormat:@"%dh", (int)secondsSincePost/3600];
        if (repostOfDict) {
            [accessibilityString appendFormat:NSLocalizedString(@" posted %d hours ago and was %@", nil), (int)secondsSincePost/3600, postCell.clientString];
        } else {
            [accessibilityString appendFormat:NSLocalizedString(@" posted %d hours ago %@", nil), (int)secondsSincePost/3600, postCell.clientString];
        }
    } else {
        if (repostOfDict) {
            [accessibilityString appendFormat:NSLocalizedString(@" posted %d days ago and was %@", nil), (int)secondsSincePost/86400, postCell.clientString];
        } else {
        timeSincePostString = [NSString stringWithFormat:@"%dd", (int)secondsSincePost/86400];
            [accessibilityString appendFormat:NSLocalizedString(@" posted %d days ago %@", nil), (int)secondsSincePost/86400, postCell.clientString];
        }
    }
   
    if ([userDefaults boolForKey:kAboluteTimeStamp]) {
        postCell.dateString = [self.dateFormatter stringFromDate:date];
    } else {
        postCell.dateString = timeSincePostString;
    }
    
    postCell.accessibilityLabel = accessibilityString;
    postCell.avatarImage = nil;
   
    postCell.noClient = isRepost ? NO : [userDefaults boolForKey:kHideClient];
    
    if (![userDefaults boolForKey:kDontLoadImages]) {
        postCell.noImages = NO;
        NSDictionary *avatarImageDictionary = [userDict objectForKey:@"avatar_image"];
        
        NSInteger numberOfCells = [self.userStreamArray count];
        __weak DHStreamTableViewController *weakSelf = self;
        dispatch_queue_t avatarDownloaderQueue = dispatch_queue_create("de.dasdom.avatarDownloader", NULL);
        dispatch_async(avatarDownloaderQueue, ^{
            NSString *avatarUrlString = [avatarImageDictionary objectForKey:@"url"];
            NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
            NSString *avatarPath = [self.avatarDirectoryPath stringByAppendingPathComponent:imageKey];
            UIImage *avatarImage = [UIImage imageWithContentsOfFile:avatarPath];
            
            if (!avatarImage) {
//                dhDebug(@"No avatar on Disk");
                CGSize imageSize = CGSizeMake(112.0f, 112.0f);
                avatarImage = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]] resizeImage:imageSize];
                CGRect offsetRect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
                
                UIGraphicsBeginImageContext(offsetRect.size);
                CGContextRef imgContext = UIGraphicsGetCurrentContext();
                
                CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:offsetRect cornerRadius:12.0f].CGPath;
                CGContextAddPath(imgContext, clippingPath);
                CGContextClip(imgContext);
                
                [avatarImage drawInRect:offsetRect];
                UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                if (img) {
//                    [imageCache setObject:avatarImage forKey:imageKey];
                    NSData *imageData = UIImagePNGRepresentation(img);
                    [[NSFileManager defaultManager] createFileAtPath:avatarPath contents:imageData attributes:nil];
                }
                avatarImage = img;
            } else {
//                dhDebug(@"Avatar from Disk");
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                id asyncCell = [[weakSelf tableView] cellForRowAtIndexPath:indexPath];
                if ([asyncCell isKindOfClass:([DHPostCell class])]
                    && numberOfCells == [weakSelf.userStreamArray count]
                    ) {
                    [asyncCell setAvatarImage:avatarImage];
                }
            });
        });
    } else {
        postCell.noImages = YES;
    }

    NSString *postText = [DHUtils stringOrEmpty:postDict[@"text"]];
    NSArray *annotationsArray = postDict[@"annotations"];
    NSDictionary *imageAnnotationDict;
    NSDictionary *videoAnnotationDict;
    NSString *languageString;
    NSDictionary *locationAnnotationDict;
    for (NSDictionary *annotationDict in annotationsArray) {
        if ([annotationDict[@"type"] isEqualToString:@"net.app.core.oembed"]) {
            NSString *annotationType = annotationDict[@"value"][@"type"];
            if ([annotationType isEqualToString:@"photo"]) {
                imageAnnotationDict = annotationDict;
            } else if ([annotationType isEqualToString:@"video"]) {
                dhDebug(@"annotationDict: %@", annotationDict);
                dhDebug(@"postText: %@", postText);
                videoAnnotationDict = annotationDict;
            }
        }
        if ([annotationDict[@"type"] isEqualToString:@"net.app.core.language"]) {
            languageString = annotationDict[@"value"][@"language"];
        }
        if ([annotationDict[@"type"] isEqualToString:@"net.app.core.checkin"]) {
            locationAnnotationDict = annotationDict[@"value"];
        }
    }
    if (languageString) {
        postCell.postTextView.accessibilityLanguage = [languageString stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    }
   
    if (locationAnnotationDict && !isRepost) {
        postCell.clientString = [NSString stringWithFormat:NSLocalizedString(@"%@ from %@", nil), postCell.clientString, [locationAnnotationDict objectForKey:@"locality"]];
    }
    postCell.postImage = nil;
//    postCell.postImageView.layer.borderWidth = 0.0f;
    postCell.postImageURL = nil;
    
    CGFloat widthdiff = 77.0f;
    
    NSDictionary *valueDict = imageAnnotationDict[@"value"] ?: videoAnnotationDict[@"value"];
    if (valueDict) {
        NSString *urlKey = @"url";
        NSString *heightKey = @"height";
        NSString *widthKey = @"width";
        
        if ([valueDict[@"type"] isEqualToString:@"photo"]) {
            postCell.postImageURL = valueDict[@"url"];
            //        postCell.postImageView.layer.borderWidth = 1.0f;
            
            if (valueDict[@"thumbnail_url"] && ![userDefaults boolForKey:kInlineImages] && ![[NSUserDefaults standardUserDefaults] boolForKey:kDontLoadImages]) {
                urlKey = @"thumbnail_url";
                heightKey = @"thumbnail_height";
                widthKey = @"thumbnail_width";
            }
        } else if ([valueDict[@"type"] isEqualToString:@"video"]) {
            postCell.postVideoURL = valueDict[@"embeddable_url"];
            
            urlKey = @"thumbnail_url";
            heightKey = @"thumbnail_height";
            widthKey = @"thumbnail_width";
        }
        
        CGRect postImageFrame;
        if ([userDefaults boolForKey:kInlineImages] && ![userDefaults boolForKey:kDontLoadImages]) {
            postImageFrame = CGRectMake(20.0f, 20.0f, self.view.frame.size.width-40.0f, 56.0f);
        } else {
            widthdiff = 138.0f;
            postImageFrame = CGRectMake(self.view.frame.size.width-63.0f, 20.0f, 56.0f, 56.0f);
        }
        
        if ([[valueDict objectForKey:widthKey] floatValue] > 0.0f) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                postImageFrame = CGRectMake(self.view.frame.size.width-107.0f, 20.0f, 100.0f, 100.0f);
                widthdiff = 182.0f;
            }
            postImageFrame.size.height = (postImageFrame.size.width * [[valueDict objectForKey:heightKey] floatValue] / [[valueDict objectForKey:widthKey] floatValue]);
            postCell.postImageFrame = postImageFrame;
        }
        
        if (![userDefaults boolForKey:kDontLoadImages]) {
    
            NSInteger numberOfCells = [self.userStreamArray count];
            __weak DHStreamTableViewController *weakSelf = self;
            dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("de.dasdom.imageDownloader", NULL);
            dispatch_async(imgDownloaderQueue, ^{
                NSString *avatarUrlString = [valueDict objectForKey:urlKey];
//                NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
                NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
                UIImage *postImage = [imageCache objectForKey:avatarUrlString];
                if (!postImage) {
                    postImage = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]] resizeImage:CGSizeMake(postImageFrame.size.width*2.0f, postImageFrame.size.height*2.0f)];
                    if (postImage) {
                        [imageCache setObject:postImage forKey:avatarUrlString];
                    }
                }
//                UIImage *postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:postImageFrame.size.width/[[valueDict objectForKey:widthKey] floatValue]];

                dispatch_sync(dispatch_get_main_queue(), ^{
                    id asyncCell = [[weakSelf tableView] cellForRowAtIndexPath:indexPath];
                    if ([asyncCell isKindOfClass:([DHPostCell class])]
                        && numberOfCells == [weakSelf.userStreamArray count]
                        ) {
                        [asyncCell setPostImage:postImage];
                    }
                });
            });
        }    
    }
    
    CGFloat labelHeight = [[self.mutableLabelHeightDictionary objectForKey:[postDict objectForKey:@"id"]] floatValue];
    
    if (labelHeight < 10) {
        CGSize labelSize = [postText sizeWithFont:postCell.postTextView.font constrainedToSize:CGSizeMake(self.view.frame.size.width-widthdiff, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        labelHeight = labelSize.height;
    }
    labelHeight += 8.0f;
    CGRect postTextFrame = postCell.postTextView.frame;
    postTextFrame.size = CGSizeMake(self.view.frame.size.width-widthdiff, labelHeight);
    postCell.postTextView.frame = postTextFrame;
    
    if ([userDefaults boolForKey:kInlineImages] && ![userDefaults boolForKey:kDontLoadImages] && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        CGRect postImageFrame = postCell.postImageFrame;
        postImageFrame.origin.y = MAX(CGRectGetMaxY(postTextFrame), 71.0f);
        postCell.postImageFrame = postImageFrame;
    }
    
    postCell.postTextView.font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
    
    [postCell.postTextView removeAllLinks];
    NSArray *linkArray = [[postDict objectForKey:@"entities"] objectForKey:@"links"];
    for (NSDictionary *linkDict in linkArray) {
        [postCell.postTextView addLinkRange:[postText rangeForEntity:linkDict] forLink:[linkDict objectForKey:@"url"]];
    }
    
    [postCell.postTextView removeAllMentions];
    NSArray *mentionArray = [[postDict objectForKey:@"entities"] objectForKey:@"mentions"];
    NSString *myName = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey];
    BOOL directedToMe = NO;
    for (NSDictionary *mentionDict in mentionArray) {
//        NSRange linkRange = {[[mentionDict objectForKey:@"pos"] integerValue], [[mentionDict objectForKey:@"len"] integerValue]};
        [postCell.postTextView addMentionRange:[postText rangeForEntity:mentionDict] forUserId:[mentionDict objectForKey:@"id"]];
        NSString *mentionName = [mentionDict objectForKey:@"name"];
        if ([mentionName isEqualToString:myName]) {
            directedToMe = YES;
            [[DHGlobalObjects sharedGlobalObjects] removeUnreadMentionWithId:postDict[@"id"]];
        }
        if (![self isKindOfClass:[DHGlobalStreamTableViewController class]]) {
            NSMutableSet *mutableUserNameSet = [[[DHGlobalObjects sharedGlobalObjects] userNameSet] mutableCopy];
            [mutableUserNameSet addObject:mentionName];
            [[DHGlobalObjects sharedGlobalObjects] setUserNameSet:[mutableUserNameSet copy]];
        }
    }
    
    [postCell.postTextView removeAllHashTags];
    NSArray *hashTagArray = [[postDict objectForKey:@"entities"] objectForKey:@"hashtags"];
    for (NSDictionary *hashTagDict in hashTagArray) {
//        NSRange hashTagRange = {[[hashTagDict objectForKey:@"pos"] integerValue], [[hashTagDict objectForKey:@"len"] integerValue]};
        [postCell.postTextView addHashTagRange:[postText rangeForEntity:hashTagDict] forName:[hashTagDict objectForKey:@"name"]];
        
        if (![self isKindOfClass:[DHGlobalStreamTableViewController class]]) {
            NSMutableSet *mutableHashtagSet = [[[DHGlobalObjects sharedGlobalObjects] hashtagSet] mutableCopy];
            [mutableHashtagSet addObject:[hashTagDict objectForKey:@"name"]];
            [[DHGlobalObjects sharedGlobalObjects] setHashtagSet:[mutableHashtagSet copy]];
        }
    }

    [self configureColorsForCell:postCell isDirectedToMe:directedToMe];
    
    postCell.postTextView.isAccessibilityElement = YES;
    [postCell.postTextView setText:postText withDefaultColors:YES];
}

- (void)configureColorsForCell:(DHPostCell*)cell isDirectedToMe:(BOOL)directedToMe {
    UIColor *cellBackgroundColor;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (directedToMe) {
        UIColor *textColor;
        UIColor *mentionColor;
        UIColor *messagesColor;
        UIColor *patterColor;
        
        if ([userDefaults boolForKey:kDarkMode]) {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
            
            mentionColor = [[DHGlobalObjects sharedGlobalObjects] numberOfUnreadMentions] ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
            messagesColor = [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPrivateMessages ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
            patterColor = [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPatter ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
            textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
        } else {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
            
            mentionColor = [[DHGlobalObjects sharedGlobalObjects] numberOfUnreadMentions] ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
            messagesColor = [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPrivateMessages ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
            patterColor = [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPatter ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
            textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
        }
        if ([[DHGlobalObjects sharedGlobalObjects] numberOfUnreadMentions] < 1) {
            [self.menuButton setImage:[ImageHelper menueWithStreamColor:textColor mentionColor:mentionColor messagesColor:messagesColor patterColor:patterColor] forState:UIControlStateNormal];
        }
    } else {
        if ([userDefaults boolForKey:kDarkMode]) {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        } else {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        }
    }
    cell.postColor = cellBackgroundColor;
    cell.postTextView.backgroundColor = [UIColor clearColor];
    
    if ([userDefaults boolForKey:kDarkMode]) {
        cell.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.customSeparatorColor = [DHGlobalObjects sharedGlobalObjects].darkSeparatorColor;
        cell.idLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
    } else {
        cell.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.customSeparatorColor = [DHGlobalObjects sharedGlobalObjects].separatorColor;
        cell.idLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    
}

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
- (void)tapOnHashtagHappend:(UITapGestureRecognizer*)sender {
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:(UITableViewCell*)sender.view];
    
    NSDictionary *postDict = [self.userStreamArray objectAtIndex:indexPath.row];

    self.postIdToShow = [[postDict objectForKey:@"id"] integerValue];
    
    [self.tableView beginUpdates];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [[self tableView] insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)removeHashTag:(UIButton*)sender {
    NSIndexPath *indexPath = [[self tableView] prp_indexPathForRowContainingView:sender];
    MutedHashtagCell *mutedHashtagCell = (MutedHashtagCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
    
    NSMutableSet *mutableMutedHashtagSet = [[DHGlobalObjects sharedGlobalObjects].mutedHashtagSet mutableCopy];
    [mutableMutedHashtagSet removeObject:mutedHashtagCell.hashTag];
    [DHGlobalObjects sharedGlobalObjects].mutedHashtagSet = [mutableMutedHashtagSet copy];
    
    [[self tableView] beginUpdates];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [[self tableView] insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [[self tableView] endUpdates];
    
    [[self tableView] reloadRowsAtIndexPaths:[self tableView].indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    
    [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)removeThreadId:(UIButton*)sender {
    NSIndexPath *indexPath = [[self tableView] prp_indexPathForRowContainingView:sender];
    MutedHashtagCell *mutedHashtagCell = (MutedHashtagCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
    
    NSMutableSet *mutableMutedThreadIdSet = [[DHGlobalObjects sharedGlobalObjects].mutedThreadIdSet mutableCopy];
    [mutableMutedThreadIdSet removeObject:mutedHashtagCell.threadId];
    [DHGlobalObjects sharedGlobalObjects].mutedThreadIdSet = [mutableMutedThreadIdSet copy];
    
    [[self tableView] beginUpdates];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [[self tableView] insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [[self tableView] endUpdates];
    
    [[self tableView] reloadRowsAtIndexPaths:[self tableView].indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];

    [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)removeClient:(UIButton*)sender {
    NSIndexPath *indexPath = [[self tableView] prp_indexPathForRowContainingView:sender];
    MutedHashtagCell *mutedHashtagCell = (MutedHashtagCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
    
    NSMutableSet *mutableMutedClientSet = [[DHGlobalObjects sharedGlobalObjects].mutedClients mutableCopy];
    [mutableMutedClientSet removeObject:mutedHashtagCell.clientName];
    [DHGlobalObjects sharedGlobalObjects].mutedClients = [mutableMutedClientSet copy];
    
    [[self tableView] beginUpdates];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [[self tableView] insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [[self tableView] endUpdates];
    
    [[self tableView] reloadRowsAtIndexPaths:[self tableView].indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    
    [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row;

    NSDictionary *postDictionay = [self.userStreamArray objectAtIndex:index];
    
    if ([self.seenIds containsObject:[postDictionay objectForKey:@"id"]] && ![self.selectedIds containsObject:[postDictionay objectForKey:@"id"]]) {
        return 0.0f;
    }
    if ([[postDictionay objectForKey:@"is_deleted"] boolValue]) {
        return 0.0f;
    }
    
    NSString *hashtagString;
    NSArray *hashTagArray = [[postDictionay objectForKey:@"entities"] objectForKey:@"hashtags"];
    if ([[postDictionay objectForKey:@"id"] integerValue] != self.postIdToShow && ![self isKindOfClass:([DHProfileTableViewController class])] && ![self isKindOfClass:([DHStreamDetailTableViewController class])]) {
        
        for (NSDictionary *hashTagDict in hashTagArray) {
            hashtagString = [hashTagDict objectForKey:@"name"];
            if ([[DHGlobalObjects sharedGlobalObjects].mutedHashtagSet containsObject:hashtagString]) {
                return 32.0f;
            }
        }
        NSString *threadId = [postDictionay objectForKey:@"thread_id"];
        NSString *clientName = [[postDictionay objectForKey:@"source"] objectForKey:@"name"];
        if ([[DHGlobalObjects sharedGlobalObjects].mutedThreadIdSet containsObject:threadId] || [[DHGlobalObjects sharedGlobalObjects].mutedClients containsObject:clientName]) {
            return 32.0f;
        }
    }
    
    
    NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
    BOOL isRepost = NO;
    if (repostOfDict) {
        isRepost = YES;
        postDictionay = repostOfDict;
    }
    
    NSArray *annotationsArray = [postDictionay objectForKey:@"annotations"];
    NSDictionary *videoOrImagennotationDict;
    for (NSDictionary *annotationDict in annotationsArray) {
        if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"]) {
            NSString *annotationType = [[annotationDict objectForKey:@"value"] objectForKey:@"type"];
            if ([annotationType isEqualToString:@"photo"]) {
                videoOrImagennotationDict = annotationDict;
            } else if ([annotationType isEqualToString:@"video"]) {
                videoOrImagennotationDict = annotationDict;
            }
        }
    }
    
    CGFloat heightOfCell = [self heightForPostDict:postDictionay withAnnotationDict:[videoOrImagennotationDict objectForKey:@"value"] isRepost:isRepost];

    return heightOfCell;
}

- (CGFloat)heightForPostDict:(NSDictionary*)postDict withAnnotationDict:(NSDictionary*)annotationDict isRepost:(BOOL)isRepost {
    CGFloat labelHeight = 0.0f;
    CGFloat minimalHeightForPostImage = 0.0f;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL inlineImages = [userDefaults boolForKey:kInlineImages];
    BOOL dontLoadImages = [userDefaults boolForKey:kDontLoadImages];
    NSString *postId = [postDict objectForKey:@"id"];
    NSNumber *labelHeightNumber = [self.mutableLabelHeightDictionary objectForKey:postId];
    if (labelHeightNumber) {
        labelHeight = [labelHeightNumber floatValue];
        minimalHeightForPostImage = [[self.mutableImageHeightDictionary objectForKey:postId] floatValue];
    } else {
        NSString *postText = [DHUtils stringOrEmpty:[postDict objectForKey:@"text"]];

        CGFloat widthDiff = 77.0f;
        if (annotationDict) {
            CGFloat imageWidth;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                widthDiff = 182.0f;
                imageWidth = 100.0f;
            } else {
                if (inlineImages && !dontLoadImages) {
                    imageWidth = self.view.frame.size.width-40.0f;
                } else {
                    widthDiff = 138.0f;
                    imageWidth = 56.0f;
                }
            }
            NSString *heightKey = @"height";
            NSString *widthKey = @"width";
            
            if (([annotationDict objectForKey:@"thumbnail_url"] && ![userDefaults boolForKey:kInlineImages] && ![[NSUserDefaults standardUserDefaults] boolForKey:kDontLoadImages]) || [annotationDict[@"type"] isEqualToString:@"video"]) {
                heightKey = @"thumbnail_height";
                widthKey = @"thumbnail_width";
            }

            if ([[annotationDict objectForKey:widthKey] floatValue] > 0.0f) {
                if (inlineImages && !dontLoadImages) {
                    minimalHeightForPostImage = (imageWidth * [[annotationDict objectForKey:heightKey] floatValue] / [[annotationDict objectForKey:widthKey] floatValue]) + 15.0f;
                } else {
                    minimalHeightForPostImage = (imageWidth * [[annotationDict objectForKey:heightKey] floatValue] / [[annotationDict objectForKey:widthKey] floatValue]) + 25.0f;
                }
            }
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postText];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]] range:NSMakeRange(0, attributedString.length)];
        labelHeight = [attributedString heightForWidth:self.view.frame.size.width-widthDiff];
        
        [self.mutableLabelHeightDictionary setObject:[NSNumber numberWithFloat:labelHeight] forKey:postId];
        [self.mutableImageHeightDictionary setObject:[NSNumber numberWithFloat:minimalHeightForPostImage] forKey:postId];
    }
    if (inlineImages && !dontLoadImages && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        if ([userDefaults boolForKey:kHideClient] && !isRepost) {
            return MAX(labelHeight+25.0f, 56.0f+10.0f)+minimalHeightForPostImage;
        } else {
            return MAX(labelHeight+25.0f+17.0f, 56.0f+20.0f)+minimalHeightForPostImage;
        }
    } else {
        if ([userDefaults boolForKey:kHideClient] && !isRepost) {
            return MAX(minimalHeightForPostImage, MAX(labelHeight+25.0f, 56.0f+10.0f));
        } else {
            return MAX(minimalHeightForPostImage, MAX(labelHeight+36.0f+10.0f, 56.0f+14.0f));
        }
    }
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StreamPostDetail"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForCell:sender];
        NSInteger index = indexPath.row;
        
        NSDictionary *postDict = [[self currentStreamArray] objectAtIndex: index];
        dhDebug(@"postDict: %@", postDict);
        
        NSDictionary *repostOfDict = [postDict objectForKey:@"repost_of"];
        if (repostOfDict) {
            postDict = repostOfDict;
        }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults boolForKey:kHideSeenThreads] && [self isKindOfClass:([DHUserStreamTableViewController class])]) {
            
            NSMutableSet *mutableSelectedIds = [self.selectedIds mutableCopy];
            [mutableSelectedIds addObject:[postDict objectForKey:@"id"]];
            self.selectedIds = [mutableSelectedIds copy];
            
            self.selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
            dhDebug(@"self.selectedIndexPath: %@", self.selectedIndexPath);
        }
        
        DHStreamDetailTableViewController *streamDetailTableViewController = segue.destinationViewController;
        if ([self isKindOfClass:([DHUserStreamTableViewController class])]) {
            streamDetailTableViewController.streamTableViewController = self;
        }
        streamDetailTableViewController.postId = postDict[@"id"];
    } else if ([segue.identifier isEqualToString:@"ReplyToPost"]) {
        NSDictionary *postDictionay;
        if ([sender isKindOfClass:([NSDictionary class])]) {
            postDictionay = sender;
        } else {
            NSIndexPath *indexPath = self.controlIndexPath;
//            dhDebug(@"indexPath: %@", indexPath);
            postDictionay = [self postDictionaryForControlCellIndexPath:indexPath];
        }
        NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
        if (repostOfDict) {
            postDictionay = repostOfDict;
        }
        
        NSDictionary *userDict = [postDictionay objectForKey:@"user"];
        DHCreateStatusViewController *createStatusViewController = (DHCreateStatusViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        createStatusViewController.consigneeString = [userDict objectForKey:@"username"];
        if ([sender isKindOfClass:([NSDictionary class])] || [sender isEqualToString:@"reply"]) {
            NSMutableArray *mutableConsigneeArray = [NSMutableArray array];
            NSArray *mentionArray = [[postDictionay objectForKey:@"entities"] objectForKey:@"mentions"];
            for (NSDictionary *mentionDict in mentionArray) {
                [mutableConsigneeArray addObject:[mentionDict objectForKey:@"name"]];
            }
            createStatusViewController.consigneeArray = [mutableConsigneeArray copy];
            
            NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
            NSString *replyToId;
            if (repostOfDict) {
                replyToId = [repostOfDict objectForKey:@"id"];
            } else {
                replyToId = [postDictionay objectForKey:@"id"];
            }

            createStatusViewController.replyToId = replyToId;
            createStatusViewController.replyToText = [postDictionay objectForKey:@"text"];
        } else if ([sender isEqualToString:@"message"]) {
            createStatusViewController.isPrivateMessage = YES;
        } else if ([sender isEqualToString:@"quote"]) {
            NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
            NSString *replyToId;
            if (repostOfDict) {
                replyToId = [repostOfDict objectForKey:@"id"];
            } else {
                replyToId = [postDictionay objectForKey:@"id"];
            }
            
            createStatusViewController.annotationsArray = [postDictionay objectForKey:@"annotations"];
            createStatusViewController.quoteLinksArray = [[[postDictionay objectForKey:@"entities"] objectForKey:@"links"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 objectForKey:@"pos"] compare:[obj2 valueForKey:@"pos"]];
            }];
            createStatusViewController.quoteString = [postDictionay objectForKey:@"text"];
            createStatusViewController.replyToId = replyToId;
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ((UIViewController*)(segue.destinationViewController)).modalPresentationStyle = UIModalPresentationFormSheet;
            ((UIViewController*)(segue.destinationViewController)).view.accessibilityViewIsModal = YES;
        }
    } else if ([segue.identifier isEqualToString:@"ShowWeb"]) {
        DHWebViewController *webViewController = segue.destinationViewController;
        webViewController.linkString = (NSString*)sender;
    } else if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        DHProfileTableViewController *profileTableViewController = segue.destinationViewController;
        profileTableViewController.userId = (NSString*)sender;
        profileTableViewController.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"ShowPostDetail"]) {
        PostDetailsViewController *postDetailViewController = segue.destinationViewController;
        postDetailViewController.postId = (NSString*)sender;
        postDetailViewController.hidesBottomBarWhenPushed = YES;
    }else if ([segue.identifier isEqualToString:@"ShowMetaData"]) {
        NSIndexPath *indexPath = self.controlIndexPath;
        NSDictionary *postDictionay = [self postDictionaryForControlCellIndexPath:indexPath];
        NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
        if (repostOfDict) {
            postDictionay = repostOfDict;
        }
        
//        dhDebug(@"postDictionay: %@", postDictionay);
        DHMetaDataTableViewController *metaDateTableViewController = segue.destinationViewController;
        metaDateTableViewController.mentionsArray = [[postDictionay objectForKey:@"entities"] objectForKey:@"mentions"];
        metaDateTableViewController.linksArray = [[postDictionay objectForKey:@"entities"] objectForKey:@"links"];
        metaDateTableViewController.hashTagArray = [[postDictionay objectForKey:@"entities"] objectForKey:@"hashtags"];
//    } else if ([segue.identifier isEqualToString:@"CreatePost"]) {

    } else if ([segue.identifier isEqualToString:@"ShowHashTag"]) {
        DHHashtagTableViewController *hashTagTableViewController = segue.destinationViewController;
        hashTagTableViewController.hashTagString = (NSString*)sender;
        hashTagTableViewController.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"ShowSettings"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ((UIViewController*)(segue.destinationViewController)).modalPresentationStyle = UIModalPresentationFormSheet;
            ((UIViewController*)(segue.destinationViewController)).view.accessibilityViewIsModal = YES;
        }
    } else if ([segue.identifier isEqualToString:@"CreatePost"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ((UIViewController*)(segue.destinationViewController)).modalPresentationStyle = UIModalPresentationFormSheet;
            ((UIViewController*)(segue.destinationViewController)).view.accessibilityViewIsModal = YES;
        }
    }
    
    if (self.controlIndexPath) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.controlIndexPath.row-1 inSection:self.controlIndexPath.section];
        
        DHPostCell *postCell = (DHPostCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [postCell setActionButtonViewHidden:YES];

    }
    
}

- (NSDictionary*)postDictionaryForControlCellIndexPath:(NSIndexPath*)indexPath {
    if (indexPath) {
        return [self.userStreamArray objectAtIndex:indexPath.row-1];
    } else {
        return [self.userStreamArray objectAtIndex:indexPath.row];
    }
}

#pragma mark - resture recognizer event handler

- (void)doubleTapHappend:(UITapGestureRecognizer*)sender {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if (self.navigationController.view.frame.origin.x > 30) {
            [self menuButtonTouched:nil];
            return;
        }
    }
    
    CGPoint locationInPostText = [sender locationInView:sender.view];
    
    if (locationInPostText.x > sender.view.frame.size.width/2.0f) {
        [self performSegueWithIdentifier:@"StreamPostDetail" sender:sender.view];
    } else {
        if ([self isKindOfClass:([DHProfileTableViewController class])]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        NSIndexPath *indexPath = [[self tableView] indexPathForCell:(UITableViewCell*)sender.view];
        NSInteger index;
//        if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row) {
//            index = indexPath.row-1;
//        } else {
            index = indexPath.row;
//        }
        NSDictionary *postDictionay = [[self currentStreamArray] objectAtIndex:index];
        NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
        if (repostOfDict) {
            postDictionay = repostOfDict;
        }
        
        [self performSegueWithIdentifier:@"ReplyToPost" sender:postDictionay];
    }
}

- (void)longPressHappend:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {

        DHPostCell *postCell = (DHPostCell*)sender.view;
        CGPoint locationInPostText = [sender locationInView:postCell.postTextView];
        CGPoint locationInCell = [sender locationInView:postCell];
        CGRect avatarFrame = [postCell avatarFrame];

        NSString *linkString = [postCell.postTextView linkForPoint:locationInPostText];
        NSString *hashTagString = [postCell.postTextView hashTagForPoint:locationInPostText];
        
        if (!linkString
            //        && !userIdString
            && !hashTagString
            ) {
            locationInPostText.y = locationInPostText.y - 6.0f;
            linkString = [postCell.postTextView linkForPoint:locationInPostText];
            //        userIdString = [postCell.postTextView userIdForPoint:locationInPostText];
            hashTagString = [postCell.postTextView hashTagForPoint:locationInPostText];
            
            if (!linkString
                //            && !userIdString && !hashTagString
                ) {
                locationInPostText.y = locationInPostText.y + 12.0f;
                linkString = [postCell.postTextView linkForPoint:locationInPostText];
                //            userIdString = [postCell.postTextView userIdForPoint:locationInPostText];
                hashTagString = [postCell.postTextView hashTagForPoint:locationInPostText];
            }
        }
        
        if (CGRectContainsPoint(avatarFrame, locationInCell)) {
            NSString *followUnfollowAction = (postCell.iAmFollowing) ? @"unfollow" : @"follow";
            
            DHActionSheet *actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(followUnfollowAction, nil), NSLocalizedString(@"mute", nil), NSLocalizedString(@"mention", nil), nil];
            actionSheet.tag = 103;
            NSIndexPath *indexPath = [[self tableView] indexPathForCell:postCell];
            NSInteger index;
//            if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row) {
//                index = indexPath.row-1;
//            } else {
                index = indexPath.row;
//            }
            
            NSDictionary *postDict = [[self currentStreamArray] objectAtIndex:index];
            NSDictionary *repostOfDict = [postDict objectForKey:@"repost_of"];
            if (repostOfDict) {
                postDict = repostOfDict;
            }
            
            actionSheet.userInfo = postDict;
            if (self.navigationController.tabBarController) {
                [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
            } else {
                [actionSheet showInView:self.view];
            }
            
        } else if (linkString) {

            NSArray *dataToShare = @[linkString];
            
            DHOpenWebsiteActivity *safariActivity = [[DHOpenWebsiteActivity alloc] init];
//            SendToInstapaperActivity *instapaperActivity = [[SendToInstapaperActivity alloc] init];
//            SendToPocketActivity *pocketActivity = [[SendToPocketActivity alloc] init];
//            
            NSMutableArray *activityArray = [NSMutableArray arrayWithObject:safariActivity];
//            if ([[NSUserDefaults standardUserDefaults] stringForKey:kInstapaperUserNameKey]) {
//                [activityArray addObject:instapaperActivity];
//            }
//            if ([[NSUserDefaults standardUserDefaults] stringForKey:kPocketUserNameKey]) {
//                [activityArray addObject:pocketActivity];
//            }
//            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:[activityArray copy]];

            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                activityViewController.popoverPresentationController.sourceView = postCell.postTextView;
                CGRect sourceRect = CGRectMake(locationInPostText.x, locationInPostText.y, 10, 10);
                activityViewController.popoverPresentationController.sourceRect = sourceRect;
                activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
                [self presentViewController:activityViewController animated:YES completion:^{}];
            } else {
                [self presentViewController:activityViewController animated:YES completion:^{}];
            }
            
//            NSIndexPath *indexPath = [[self tableView] indexPathForCell:postCell];
//            NSInteger index;
//            index = indexPath.row;
//            
//            NSDictionary *postDict = [[self currentStreamArray] objectAtIndex:index];
//            
//            NSDictionary *userDict = postDict[@"user"];
//            dhDebug(@"userDict: %@", userDict);
//
//            OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:postDict[@"text"]
//                                                                              authorName:userDict[@"name"]
//                                                                            canonicalURL:linkString
//                                                                                  images:nil];
//            
//            // 2) Setup optional completion and dismissal handlers
//            OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
//            
//            // 3) Create the options dictionary. See OSKActivity.h for more options.
//            NSDictionary *options = @{OSKPresentationOption_ActivityCompletionHandler : completionHandler,
//                                      OSKActivityOption_ExcludedTypes: @[OSKActivityType_API_500Pixels,
//                                                                         OSKActivityType_API_AppDotNet,
//                                                                         OSKActivityType_API_Readability,
//                                                                         OSKActivityType_iOS_Facebook]};
//            
//            [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
//                                                           presentingViewController:self
//                                                                            options:options];
        } else if (hashTagString) {
            
            NSString *messageWithHashtagString = [NSString stringWithFormat:NSLocalizedString(@"use #%@", nil), hashTagString];
            DHActionSheet *actionSheet = [[DHActionSheet alloc] initWithTitle:hashTagString delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"mute", nil), messageWithHashtagString, nil];
            actionSheet.tag = 104;
            NSIndexPath *indexPath = [[self tableView] indexPathForCell:postCell];
            actionSheet.userInfo = @{@"hashtagString": hashTagString, @"indexPath": indexPath};
            if (self.navigationController.tabBarController) {
                [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
            } else {
                [actionSheet showInView:self.view];
            }
            
        } else {
            NSIndexPath *indexPath = [[self tableView] indexPathForCell:postCell];
            NSInteger index;
//            if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row) {
//                index = indexPath.row-1;
//            } else {
                index = indexPath.row;
//            }
            
            NSDictionary *postDict = [[self currentStreamArray] objectAtIndex:index];
            
//            NSString *threadId =  [[[self currentStreamArray] objectAtIndex:index] objectForKey:@"thread_id"];
            DHActionSheet *actionSheet;
            if ([[[postDict objectForKey:@"user"] objectForKey:@"username"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]] && [[self tableView] isEqual:self.tableView]) {
                actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"delete post", nil) otherButtonTitles:NSLocalizedString(@"copy link to post", nil), NSLocalizedString(@"copy post text", nil), NSLocalizedString(@"mute conversation", nil), NSLocalizedString(@"mute client", nil), nil];
            } else {
                actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"report post", nil) otherButtonTitles:NSLocalizedString(@"copy link to post", nil), NSLocalizedString(@"copy post text", nil), NSLocalizedString(@"mute conversation", nil), NSLocalizedString(@"mute client", nil), nil];
            }
            actionSheet.tag = 102;
            actionSheet.userInfo = @{@"postDict": [[self currentStreamArray] objectAtIndex:index], @"indexPath": indexPath};

            if (self.navigationController.tabBarController) {
                [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
            } else {
                [actionSheet showInView:self.view];
            }
        }
    }
}

//- (OSKActivityCompletionHandler)activityCompletionHandler {
//    OSKActivityCompletionHandler activityCompletionHandler = ^(OSKActivity *activity, BOOL successful, NSError *error){
//        if (successful) {
//            SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Sharing successful", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
//            [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
//        } else {
//            SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Sharing failed", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
//            [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
//        }
//    };
//    return activityCompletionHandler;
//}

#pragma mark - button event handler

- (void)showProfile:(UIButton*)sender {
    if ([self isKindOfClass:([DHProfileTableViewController class])]) {
        return;
    }
    CGPoint buttonOrigin = [[self tableView] convertPoint:sender.frame.origin fromView:sender.superview];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:buttonOrigin];
//    dhDebug(@"indexPath: %@", indexPath);
    NSDictionary *postDictionay = [self postDictionaryForControlCellIndexPath:indexPath];
    NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
    if (repostOfDict) {
        postDictionay = repostOfDict;
    }
    
    NSDictionary *userDict = [postDictionay objectForKey:@"user"];
    [self performSegueWithIdentifier:@"ShowProfile" sender:[userDict objectForKey:@"id"]];
}

- (void)showPostDetail:(UIButton*)sender {
//    if ([self isKindOfClass:([DHProfileTableViewController class])]) {
//        return;
//    }
    CGPoint buttonOrigin = [[self tableView] convertPoint:sender.frame.origin fromView:sender.superview];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:buttonOrigin];
    NSDictionary *postDictionay = [self postDictionaryForControlCellIndexPath:indexPath];
    NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
    if (repostOfDict) {
        postDictionay = repostOfDict;
    }
    
//    NSDictionary *userDict = [postDictionay objectForKey:@"user"];
    [self performSegueWithIdentifier:@"ShowPostDetail" sender:[postDictionay objectForKey:@"id"]];
}

- (void)swipeRightHappend:(UISwipeGestureRecognizer*)sender {
//    CGPoint locationPoint = [sender locationInView:sender.view];
//    
//    if (locationPoint.x < 61.0f) {
    
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.navigationController.view.frame.origin.x < 30) {
        [self menuButtonTouched:nil];
    }
//    } else {
//        if ([self isKindOfClass:([DHProfileTableViewController class])]) {
//            [self.navigationController popViewControllerAnimated:YES];
//            return;
//        }
//        NSIndexPath *indexPath = [[self currentTableView] indexPathForCell:(UITableViewCell*)sender.view];
//        NSInteger index;
//        if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row) {
//            index = indexPath.row-1;
//        } else {
//            index = indexPath.row;
//        }
//        NSDictionary *postDictionay = [[self currentStreamArray] objectAtIndex:index];
//        NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
//        if (repostOfDict) {
//            postDictionay = repostOfDict;
//        }
//        
//        [self performSegueWithIdentifier:@"ReplyToPost" sender:postDictionay];
//    }
}

- (void)showConversation:(UIButton*)sender {
    CGPoint buttonOrigin = [[self tableView] convertPoint:sender.frame.origin fromView:sender.superview];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:buttonOrigin];
    DHPostCell *postCell = (DHPostCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    [self performSegueWithIdentifier:@"StreamPostDetail" sender:postCell];
}

- (void)swipeLeftHappend:(UISwipeGestureRecognizer*)sender {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if (self.navigationController.view.frame.origin.x > 30) {
            [self menuButtonTouched:nil];
            return;
        }
    }
    
    if ([self isKindOfClass:([DHStreamDetailTableViewController class])]) {
        return;
    }
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender.view];
//    NSLog(@"indexPath: %@", indexPath);
    [self performSegueWithIdentifier:@"StreamPostDetail" sender:sender.view];
}

- (void)replyOnPost:(UIButton*)sender {
//    [self performSegueWithIdentifier:@"ReplyToPost" sender:sender];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"reply or private message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"reply", nil), NSLocalizedString(@"private message", nil), nil];
    actionSheet.tag = 100;
    if (self.navigationController.tabBarController) {
        [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    } else {
        [actionSheet showInView:self.view];
    }
}

- (void)starPost:(UIButton*)sender {
    NSIndexPath *indexPath = self.controlIndexPath;
//    dhDebug(@"indexPath: %@", indexPath);
//    DHControllCell *controlCell = (DHControllCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
//    [controlCell.activityIndicatorView startAnimating];
    NSDictionary *postDictionay = [self postDictionaryForControlCellIndexPath:indexPath];
    NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
    if (repostOfDict) {
        postDictionay = repostOfDict;
    }
    
    NSString *postId = [postDictionay objectForKey:@"id"];
    
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];

    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/star?access_token=%@", kBaseURL, kPostsSubURL, postId, accessToken];
    
    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    BOOL youStarred = [[postDictionay objectForKey:@"you_starred"] boolValue];
    if (youStarred) {
        [postRequest setHTTPMethod:@"DELETE"];
        youStarred = NO;
    } else {
        [postRequest setHTTPMethod:@"POST"];
        youStarred = YES;
    }
    
    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//        NSDictionary *userDict = [connection dictionaryFromDownloadedData];
//        dhDebug(@"userDict: %@", userDict);
        
//        DHControllCell *controlCell = (DHControllCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
//        if (youStarred) {
//            [controlCell.starButton setImage:[UIImage imageNamed:@"starredIcon2"] forState:UIControlStateNormal];
//            [controlCell.starButton setImage:[UIImage imageNamed:@"starredIconSelected2"] forState:UIControlStateHighlighted];
//        } else {
//            [controlCell.starButton setImage:[UIImage imageNamed:@"unstarredIcon2"] forState:UIControlStateNormal];
//            [controlCell.starButton setImage:[UIImage imageNamed:@"unstarredIconSelected2"] forState:UIControlStateHighlighted];
//        }
        NSMutableArray *mutablePostArray = [NSMutableArray array];
        for (int i = 0; i < [[self currentStreamArray] count]; i++) {
            NSDictionary *postDict = [[self currentStreamArray] objectAtIndex:i];
//            NSDictionary *repostOfDict = [postDict objectForKey:@"repost_of"];
//            if (repostOfDict) {
//                postDict = repostOfDict;
//            }
            if ([postId isEqualToString:[postDict objectForKey:@"id"]]) {
                NSMutableDictionary *mutablePostDict = [postDict mutableCopy];
                if (youStarred) {
                    SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully starred", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                    [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
                    [mutablePostDict setValue:@"1" forKey:@"you_starred"];
                } else {
                    SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully unstarred", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                    [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
                    [mutablePostDict setValue:@"0" forKey:@"you_starred"];
                }
                [mutablePostArray addObject:mutablePostDict];
            } else {
                [mutablePostArray addObject:postDict];
            }
        }
//        if ([self.searchResultArray count]) {
//            self.searchResultArray = [mutablePostArray copy];
//        } else {
            self.userStreamArray = [mutablePostArray copy];
//        }
//        if (self.controlIndexPath) {
//            [[self tableView] beginUpdates];
//            NSIndexPath *indexPathOfPost = [NSIndexPath indexPathForRow:self.controlIndexPath.row-1 inSection:self.controlIndexPath.section];
//            
//            [[self tableView] deleteRowsAtIndexPaths:@[ self.controlIndexPath ] withRowAnimation:UITableViewRowAnimationLeft];
//            self.controlIndexPath = nil;
//            
//            [[self tableView] reloadRowsAtIndexPaths:@[indexPathOfPost] withRowAnimation:UITableViewRowAnimationNone];
//            [[self tableView] endUpdates];
//        }
//        [controlCell.activityIndicatorView stopAnimating];
//        [self updateUserStreamArraySinceId:nil beforeId:nil];
        
        if (self.controlIndexPath) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.controlIndexPath.row-1 inSection:self.controlIndexPath.section];
            
            DHPostCell *postCell = (DHPostCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            postCell.faved = youStarred;
            [postCell setActionButtonViewHidden:YES];
            
        }
        
    }];
    [dhConnection start];
}

- (void)repostPost:(UIButton*)sender {
    NSIndexPath *indexPath = self.controlIndexPath;
//    dhDebug(@"indexPath: %@", indexPath);

    NSDictionary *postDictionay = [self postDictionaryForControlCellIndexPath:indexPath];
    NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
    if (repostOfDict) {
        postDictionay = repostOfDict;
    }
    BOOL youReposted = [[postDictionay objectForKey:@"you_reposted"] boolValue];

    if (youReposted) {
        [self repostPostForIndexPath:indexPath fromAccountWithName:nil];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"repost or quote", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"repost", nil), NSLocalizedString(@"quote", nil), nil];
        actionSheet.tag = 101;
        if (self.navigationController.tabBarController) {
            [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
        } else {
            [actionSheet showInView:self.view];
        }
    }
}

- (void)repostPostFrom:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSArray *accountsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUserArrayKey];
        dhDebug(@"accountsArray: %@", accountsArray);
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"repost from", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
        for (NSString *accountName in accountsArray) {
            [actionSheet addButtonWithTitle:accountName];
        }
        
        actionSheet.tag = 111;
        if (self.navigationController.tabBarController) {
            [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
        } else {
            [actionSheet showInView:self.view];
        }
    }
}

- (void)repostPostForIndexPath:(NSIndexPath*)indexPath fromAccountWithName:(NSString*)accountName {
    NSDictionary *postDictionay = [self postDictionaryForControlCellIndexPath:indexPath];
    NSDictionary *repostOfDict = [postDictionay objectForKey:@"repost_of"];
    if (repostOfDict) {
        postDictionay = repostOfDict;
    }
    
    BOOL youReposted = [[postDictionay objectForKey:@"you_reposted"] boolValue];
    
    NSString *postId = [postDictionay objectForKey:@"id"];

    NSString *accessToken;
    if (accountName) {
        accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:accountName];

    } else {
        accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/repost?access_token=%@", kBaseURL, kPostsSubURL, postId, accessToken];
    
    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    if (youReposted) {
        [postRequest setHTTPMethod:@"DELETE"];
        youReposted = NO;
    } else {
        [postRequest setHTTPMethod:@"POST"];
        youReposted = YES;
    }
    
//    DHControllCell *controlCell = (DHControllCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
//    [controlCell.activityIndicatorView startAnimating];
    
    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
    
//        DHControllCell *controlCell = (DHControllCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
//        if (youReposted) {
//            [controlCell.repostButton setImage:[UIImage imageNamed:@"trashIcon"] forState:UIControlStateNormal];
//            [controlCell.repostButton setImage:[UIImage imageNamed:@"trashIconSelected"] forState:UIControlStateHighlighted];
//        } else {
//            [controlCell.repostButton setImage:[UIImage imageNamed:@"repostIcon2"] forState:UIControlStateNormal];
//            [controlCell.repostButton setImage:[UIImage imageNamed:@"repostIconSelected2"] forState:UIControlStateHighlighted];
//        }
        NSMutableArray *mutablePostArray = [NSMutableArray array];
        for (int i = 0; i < [[self currentStreamArray] count]; i++) {
            NSDictionary *postDict = [[self currentStreamArray] objectAtIndex:i];
//            NSDictionary *repostOfDict = [postDict objectForKey:@"repost_of"];
//            if (repostOfDict) {
//                postDict = repostOfDict;
//            }
            if ([postId isEqualToString:[postDict objectForKey:@"id"]]) {
                NSMutableDictionary *mutablePostDict = [postDict mutableCopy];
                if (youReposted) {
                    SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully reposted", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                    [slideInView showWithTimer:kSlideInDuration inView:[self tableView] from:SlideInViewLeft];
                    [mutablePostDict setValue:@"1" forKey:@"you_reposted"];
                } else {
                    SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully unreposted", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                    [slideInView showWithTimer:kSlideInDuration inView:[self tableView] from:SlideInViewLeft];
                    [mutablePostDict setValue:@"0" forKey:@"you_reposted"];
                }
                [mutablePostArray addObject:mutablePostDict];
            } else {
                [mutablePostArray addObject:postDict];
            }
        }
//        if ([self.searchResultArray count]) {
//            self.searchResultArray = [mutablePostArray copy];
//        } else {
            self.userStreamArray = [mutablePostArray copy];
//        }
//        if (self.controlIndexPath) {
//            [[self tableView] beginUpdates];
//            NSIndexPath *indexPathOfPost = [NSIndexPath indexPathForRow:self.controlIndexPath.row-1 inSection:self.controlIndexPath.section];
//
//            [[self tableView] deleteRowsAtIndexPaths:@[ self.controlIndexPath ] withRowAnimation:UITableViewRowAnimationLeft];
//            self.controlIndexPath = nil;
//            
//            [[self tableView] reloadRowsAtIndexPaths:@[indexPathOfPost] withRowAnimation:UITableViewRowAnimationNone];
//            [[self tableView] endUpdates];
//        }
//        [controlCell.activityIndicatorView stopAnimating];
    }];
    [dhConnection start];

}

- (void)postTextViewTapped:(UITapGestureRecognizer*)sender {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if (self.navigationController.view.frame.origin.x > 30) {
            [self menuButtonTouched:nil];
            return;
        }
    }
    
    DHPostCell *postCell = (DHPostCell*)sender.view;
    
    if (postCell.isFocused) {
        if ([self isKindOfClass:([DHProfileTableViewController class])]) {
            return;
        }
        [self performSegueWithIdentifier:@"ShowProfile" sender:postCell.userId];
        return;
    }
    
    UIView *postContentView = postCell.postContentView;

    CGPoint locationInCell = [sender locationInView:postContentView];
    CGRect avatarFrame = [postCell avatarFrame];
    if (CGRectContainsPoint(avatarFrame, locationInCell)) {
        if ([self isKindOfClass:([DHProfileTableViewController class])]) {
            return;
        }
        [self performSegueWithIdentifier:@"ShowProfile" sender:postCell.userId];
        return;
    }
    if (postCell.postImageURL) {
        CGRect postImageFrame = postCell.postImageFrame;
        if (CGRectContainsPoint(postImageFrame, locationInCell)) {
            DHPostImageViewController *postImageViewController = [[DHPostImageViewController alloc] initWithPostImageURL:postCell.postImageURL];
            postImageViewController.hidesBottomBarWhenPushed = YES;
            postImageViewController.postImage = postCell.postImage;
            [self.navigationController pushViewController:postImageViewController animated:YES];
            return;
        }
    } else if (postCell.postVideoURL) {
        [self performSegueWithIdentifier:@"ShowWeb" sender:postCell.postVideoURL];
        return;
    }
    
    CGPoint locationInPostText = [sender locationInView:postCell.postTextView];
//    dhDebug(@"locationInPostText: %@", [NSValue valueWithCGPoint:locationInPostText]);
    
    NSString *linkString = [postCell.postTextView linkForPoint:locationInPostText];
    NSString *userIdString = [postCell.postTextView userIdForPoint:locationInPostText];
    NSString *hashTagString = [postCell.postTextView hashTagForPoint:locationInPostText];
    
    if (!linkString && !userIdString && !hashTagString) {
        locationInPostText.y = locationInPostText.y - 6.0f;
        linkString = [postCell.postTextView linkForPoint:locationInPostText];
        userIdString = [postCell.postTextView userIdForPoint:locationInPostText];
        hashTagString = [postCell.postTextView hashTagForPoint:locationInPostText];

        if (!linkString && !userIdString && !hashTagString) {
            locationInPostText.y = locationInPostText.y + 12.0f;
            linkString = [postCell.postTextView linkForPoint:locationInPostText];
            userIdString = [postCell.postTextView userIdForPoint:locationInPostText];
            hashTagString = [postCell.postTextView hashTagForPoint:locationInPostText];
        }
    }
    
    if (linkString) {
        if ([linkString rangeOfString:@"https://alpha.app.net/"].location != NSNotFound &&
            [linkString rangeOfString:@"post"].location != NSNotFound) {
            NSString *postId = [linkString lastPathComponent];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *conversationViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
            [conversationViewController setValue:postId forKey:@"postId"];
            [self.navigationController pushViewController:conversationViewController animated:YES];
        } else if ([linkString rangeOfString:@"patter-app.net"].location != NSNotFound) {
            NSString *channelId = [[[linkString lastPathComponent] componentsSeparatedByString:@"channel="] objectAtIndex:1];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            DHMessagesTableViewController *messagesViewController = [storyboard instantiateViewControllerWithIdentifier:@"DHMessagesTableViewController"];
            messagesViewController.channelId = channelId;
            messagesViewController.isPatter = YES;
            
            [self.navigationController pushViewController:messagesViewController animated:YES];
        } else {
            dhDebug(@"text: %@", postCell.postTextView.text);
            dhDebug(@"link: %@", linkString);
            [self performSegueWithIdentifier:@"ShowWeb" sender:linkString];
        }
    } else if (userIdString) {
        if (![self isKindOfClass:([DHProfileTableViewController class])]) {
            [self performSegueWithIdentifier:@"ShowProfile" sender:userIdString];
        }
    } else if (hashTagString) {
        if (![self isKindOfClass:([DHHashtagTableViewController class])]) {
            [self performSegueWithIdentifier:@"ShowHashTag" sender:hashTagString];
        }
    } else if ([self respondsToSelector:@selector(postCellTapped:)]) {
        [self postCellTapped:postCell];
    } else {
//        UIView *postContentView = postCell.postContentView;
        
//        CGRect postContentViewFrame = postContentView.frame;
//        CGFloat alphaOfHostView = 0.0f;
//        
//        BOOL actionsVisible = (postContentViewFrame.origin.y < 0);
//        if (actionsVisible) {
//            postContentViewFrame.origin.y = 0.0f;
//            alphaOfHostView = 0.0f;
//        } else {
//            postContentViewFrame.origin.y = -40.0f;
//            alphaOfHostView = 1.0f;
//            postCell.buttonHostView.hidden = NO;
//            
//            NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
//            self.controlIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
//        }
//        
//        [UIView animateWithDuration:0.2f animations:^{
//            postContentView.frame = postContentViewFrame;
//        } completion:^(BOOL finished) {
//            
//            BOOL actionsVisible = (postContentViewFrame.origin.y < 0);
//            if (!actionsVisible) {
//                postCell.buttonHostView.hidden = YES;
//            }
//        }];
        
        
        if ([postCell toggleActionButtonView]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
            [self.tableView scrollRectToVisible:postCell.frame animated:YES];
            self.controlIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        }
    }
    
}


- (void)showMetaData:(UIButton*)sender {
//    NSLog(@"MetaData touched");
    [self performSegueWithIdentifier:@"ShowMetaData" sender:sender];
}

- (void)panCell:(UIPanGestureRecognizer*)sender {
    DHPostCell *cell = (DHPostCell*)sender.view;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    CGPoint translation = [sender translationInView:cell];
    
    NSInteger actionWidth = 30;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        actionWidth = 50;
    }

    UIView *postContentView = cell.postContentView;
    if (sender.state == UIGestureRecognizerStateEnded) {
       
        cell.idLabel.alpha = 0.0f;

        self.controlIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        
        
        if (translation.x > -1*actionWidth) {
            dhDebug(@"no action");
        } else if (translation.x > -2*actionWidth) {
//            [self replyOnPost:nil];
            [self performSegueWithIdentifier:@"ReplyToPost" sender:@"reply"];
        } else if (translation.x > -3*actionWidth) {
            [self repostPost:nil];
        } else if (translation.x > -4*actionWidth) {
            [self starPost:nil];
        } else
            //if (translation.x > -150)
        {
            if (![self isMemberOfClass:[DHStreamDetailTableViewController class]]) {
                [self performSegueWithIdentifier:@"StreamPostDetail" sender:cell];
            }
        }
        
        CGRect postContentViewFrame = postContentView.frame;
        postContentViewFrame.origin.x = translation.x > 0 ? 0.0f : -(actionWidth+10);
        [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:kNilOptions animations:^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
                cell.actionImageView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkerColor;
                cell.actionImageView.tintColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
            } else {
                cell.actionImageView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markerColor;
                cell.actionImageView.tintColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
            }
            postContentView.frame = postContentViewFrame;
        } completion:^(BOOL finished) {
            CGRect postContentViewFrame = postContentView.frame;
            postContentViewFrame.origin.x = 0.0f;
            [UIView animateWithDuration:0.2 delay:0.2 options:kNilOptions animations:^{
                postContentView.frame = postContentViewFrame;
            } completion:^(BOOL finished) {
                cell.actionImageView.backgroundColor = [UIColor clearColor];
                cell.actionImageView.tintColor = nil;
               
            }];
        }];
    } else {
        CGRect postContentViewFrame = postContentView.frame;
        postContentViewFrame.origin.x = translation.x;
        postContentView.frame = postContentViewFrame;
        
        if (translation.x < 0) {
            UIImageView *actionImageView = cell.actionImageView;
            if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                if (self.navigationController.view.frame.origin.x > 30) {
                    [self menuButtonTouched:nil];
                    return;
                }
            }
            if (translation.x > -1*actionWidth) {
                if (actionImageView.tag != 0) {
                    actionImageView.image = nil;
                    actionImageView.tag = 0;
                }
            } else if (translation.x > -2*actionWidth) {
                if (actionImageView.tag != 1) {
                    actionImageView.image = [HappyActionIcons imageOfReplyWithSize:CGSizeMake(30.0f, 30.0f)];
                    actionImageView.tag = 1;
                }
            } else if (translation.x > -3*actionWidth) {
                if (actionImageView.tag != 2) {
                    actionImageView.image = [HappyActionIcons imageOfRepostWithSize:CGSizeMake(30.0f, 30.0f)];
                    actionImageView.tag = 2;
                }
            } else if (translation.x > -4*actionWidth) {
                if (actionImageView.tag != 4) {
                    NSDictionary *postDict = [self.userStreamArray objectAtIndex:indexPath.row];
                    if ([postDict[@"you_starred"] boolValue]) {
                        actionImageView.image = [HappyActionIcons imageOfFavedWithSize:CGSizeMake(30.0f, 30.0f)];
                    } else {
                        actionImageView.image = [HappyActionIcons imageOfFavWithSize:CGSizeMake(30.0f, 30.0f)];
                    }
                    actionImageView.tag = 4;
                }
            } else
//                if (translation.x > -5*actionWidth)
            {
                if (![self isMemberOfClass:[DHStreamDetailTableViewController class]]) {
                    if (actionImageView.tag != 3) {
                        actionImageView.image = [HappyActionIcons imageOfConversationWithSize:CGSizeMake(30.0f, 30.0f)];
                        actionImageView.tag = 3;
                    }
                } else {
                    if (actionImageView.tag != 0) {
                        actionImageView.image = nil;
                        actionImageView.tag = 0;
                    }
                }
            }
        } else {
            if (translation.x > 150) {
                [self swipeRightHappend:nil];
            }
            
            CGFloat alphaValue = MIN(1.0f, translation.x/100.0f);
            cell.idLabel.alpha = alphaValue;

        }
    }
}

#pragma mark - UIGestureRecogniser
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [((UIPanGestureRecognizer*)gestureRecognizer) translationInView:gestureRecognizer.view];
    return fabsf(translation.x) > fabsf(translation.y);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    [self.pongRefreshControl scrollViewDidScroll];

    if ([self.allUserStreamArray count] > 0) {
        self.numberOfNewPostLabel.alpha = 0.0f;
        return;
    }
    if (scrollView.contentOffset.y + 300.0f > self.tableView.contentSize.height-self.tableView.frame.size.height && !self.isLoading && [self.userStreamArray count] > 0) {
        dhDebug(@"self.minId: %@", self.minId);
        self.isLoading = YES;
        if ([self.urlString rangeOfString:@"stars"].location != NSNotFound
            || [self isMemberOfClass:([DHHashtagTableViewController class])]
            ) {
            [self updateUserStreamArraySinceId:nil beforeId:self.minId];
        } else {
            [self updateUserStreamArraySinceId:nil beforeId:[[self.userStreamArray lastObject] objectForKey:@"id"]];
        }
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSArray *visibleCells = self.tableView.visibleCells;
//        if (!visibleCells || [visibleCells count] < 1) {
//            return;
//        }
    NSArray *indexPathOfVisibleRows = [self.tableView indexPathsForVisibleRows];
    
    if (!indexPathOfVisibleRows || [indexPathOfVisibleRows count] < 1) {
        return;
    }
//    NSLog(@"indexPathOfVisibleRows: %@", indexPathOfVisibleRows);
    NSIndexPath *indexPathOfTopMostCell = [indexPathOfVisibleRows objectAtIndex:0];
    CGFloat alphaOfNewPostsLabel = 0.0f;
    if (indexPathOfTopMostCell.row < self.newestIndexPath.row && _updateNewestIndexPath) {
        dhDebug(@"indexPathOfTopMostCell: %@", indexPathOfTopMostCell);
        self.newestIndexPath = [NSIndexPath indexPathForRow:indexPathOfTopMostCell.row inSection:indexPathOfTopMostCell.section];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:_newestIndexPath.row forKey:[self keyForNewestIndexPathRow]];
        [userDefaults setInteger:_newestIndexPath.section forKey:[self keyForNewestIndexPathSection]];
        [userDefaults synchronize];
        alphaOfNewPostsLabel = 0.9f;
        
//    } else if (indexPathOfTopMostCell.row > self.newestIndexPath.row) {
//        if (self.numberOfNewPostLabel.alpha > 0.01f) {
//            alphaOfNewPostsLabel = 0.0f;
//        }
    }
    self.topMostIndexPath = indexPathOfTopMostCell;
    if ([scrollView isEqual:self.tableView]) {
        [self.markerTimer invalidate];
        self.markerTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    }
    if (self.newestIndexPath.row == 0) {
        
        if ([self isKindOfClass:[DHMentionsTableViewController class]]) {
            [[DHGlobalObjects sharedGlobalObjects] removeAllUnreadMentions];
        }
        if (alphaOfNewPostsLabel > 0.0f && [scrollView isEqual:self.tableView]) {
            [self updateMarker];
        }
        alphaOfNewPostsLabel = 0.0f;
    } else {
        alphaOfNewPostsLabel = 0.8f;
    }
    
    
    if (self.numberOfNewPostLabel.alpha != alphaOfNewPostsLabel) {
        [UIView animateWithDuration:0.25f animations:^{
            self.numberOfNewPostLabel.alpha = alphaOfNewPostsLabel;
        } completion:^(BOOL finished){}];
    }
    
    self.numberOfNewPostLabel.text = [NSString stringWithFormat:NSLocalizedString(@" \n%d (%@)", nil), self.newestIndexPath.row, self.currentLanguageString];
    
    if ([self.userStreamArray count] < self.newestIndexPath.row) {
        return;
    }
    CGRect newestIndexPathRect = [self.tableView rectForRowAtIndexPath:self.newestIndexPath];
    CGRect newPostsLabelFrame = self.numberOfNewPostLabel.frame;
    
//    dhDebug(@"navigationBar.isHidden: %@", self.navigationController.navigationBar.isHidden ? @YES : @NO);
    newPostsLabelFrame.origin.y = MIN(scrollView.contentOffset.y-20.0f, newestIndexPathRect.origin.y+newestIndexPathRect.size.height)+self.positionCorrection;
    if (self.navigationController.navigationBar.isHidden) {
        newPostsLabelFrame.origin.y -= 44.0f;
    }
    
    self.numberOfNewPostLabel.frame = newPostsLabelFrame;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self saveContentOffsetY];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self.pongRefreshControl scrollViewDidEndDragging];

    if (!decelerate) {
        [self saveContentOffsetY];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self saveContentOffsetY];
}

#pragma mark - Save Content Offset y-Value
- (void)saveContentOffsetY {
    if ([self isMemberOfClass:[DHUserStreamTableViewController class]]) {
        NSString *keyString = [NSString stringWithFormat:@"%@_%@", kConentOffsetYDefaultsKey, NSStringFromClass([self class])];
        dhDebug(@"11111 keyString: %@ self.tableView.contentOffset.y: %f", keyString, self.tableView.contentOffset.y);
        [[NSUserDefaults standardUserDefaults] setFloat:self.tableView.contentOffset.y forKey:keyString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CGFloat)contentOffsetY {
    if ([self isMemberOfClass:[DHUserStreamTableViewController class]]) {
        NSString *keyString = [NSString stringWithFormat:@"%@_%@", kConentOffsetYDefaultsKey, NSStringFromClass([self class])];
        dhDebug(@"22222 keyString: %@ contentOffset.y: %f", keyString, [[NSUserDefaults standardUserDefaults] floatForKey:keyString]);
        return [[NSUserDefaults standardUserDefaults] floatForKey:keyString];
    }
    return self.tableView.contentOffset.y;
}

#pragma mark - Timer
- (void)timerFired:(NSTimer*)timer {
//    NSLog(@"timerFired");
    [self updateMarker];
}

#pragma mark - Marker
- (void)updateMarker {
    dhDebug(@"updateMarker, self: %@", self);
    if ((![[NSUserDefaults standardUserDefaults] boolForKey:kStreamMarker] &&
        ![self isKindOfClass:[DHMessagesTableViewController class]]) ||
        [self isKindOfClass:[DHStreamDetailTableViewController class]]
//        || [self isKindOfClass:[DHMentionsTableViewController class]]
        ) {
        return;
    }
    if ([self.userStreamArray count] < 1) {
        return;
    }
    NSDate *now = [NSDate date];
    if ([self.retryMarkerAfter compare:now] == NSOrderedDescending) {
        dhDebug(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!Too many update of the stream marker!!!!!!!!!!!!!!!!!");
        return;
    }
    
//    if (!self.topMostIndexPath || !self.newestIndexPath) {
//        return;
//    }
    
    NSInteger topMostPostId;
    NSInteger newestPostId;
    if ((self.topMostIndexPath.row < [self.userStreamArray count]-1) &&
        ![self isKindOfClass:([DHMessagesTableViewController class])]) {
        topMostPostId = [[[self.userStreamArray objectAtIndex:self.topMostIndexPath.row+1] objectForKey:@"id"] integerValue];
    } else {
        topMostPostId = [[[self.userStreamArray objectAtIndex:0] objectForKey:@"id"] integerValue];
    }
    if (self.newestIndexPath.row < [self.userStreamArray count]) {
        newestPostId = [[[self.userStreamArray objectAtIndex:self.newestIndexPath.row] objectForKey:@"id"] integerValue];
    } else {
        newestPostId = [[[self.userStreamArray objectAtIndex:0] objectForKey:@"id"] integerValue];
    }
//    dhDebug(@"marker: %d newestPostId: %d, topMostPostId: %d", [[self.markerDict objectForKey:@"id"] integerValue], newestPostId, topMostPostId);
//    dhDebug(@"self.topMostIndexPath: %@", self.topMostIndexPath);
//    NSLog(@"self.markerDict: %@", self.markerDict);
    if (self.markerDict && [[self.markerDict objectForKey:@"id"] integerValue] != topMostPostId && !self.isUpdatingMarker) {
        self.isUpdatingMarker = YES;
        
//        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
        NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];

        
        NSString *urlString = [NSString stringWithFormat:@"%@posts/marker", kBaseURL];
        
        NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [postRequest setHTTPMethod:@"POST"];
        
        NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
        [postRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
        [postRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableArray *array = [NSMutableArray array];
        NSDictionary *postDict = @{@"name" : self.markerDict[@"name"], @"last_read_id" : [NSNumber numberWithInteger:newestPostId], @"id": [NSNumber numberWithInteger:topMostPostId]};
        [array addObject:postDict];
        if ([self.markerDict[@"name"] isEqualToString:@"unified"]) {
            postDict = @{@"name" : @"my_stream", @"last_read_id" : [NSNumber numberWithInteger:newestPostId], @"id": [NSNumber numberWithInteger:topMostPostId]};
            [array addObject:postDict];
        }

        NSData *postData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
        [postRequest setHTTPBody:postData];
        
        PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//            dhDebug(@"error: %@", error);
            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
            NSLog(@"responseDict: %@", responseDict);
            
            NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
            if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                dhDebug(@"Could not update the marker");
                if ([[metaDict objectForKey:@"code"] integerValue] == 429) {
                    self.retryMarkerAfter = [NSDate dateWithTimeIntervalSinceNow:[[connection.responseHeaders objectForKey:@"Retry-After"] integerValue]];
                }
            } else {
                id marker = [responseDict objectForKey:@"data"];
                if ([marker isKindOfClass:[NSDictionary class]]) {
                    self.markerDict = marker;
                } else if ([marker isKindOfClass:[NSArray class]]) {
                    self.markerDict = [marker firstObject];
                } else {
                    self.markerDict = nil;
                }
            }
            self.isUpdatingMarker = NO;
        }];
        
        [dhConnection start];
    }
}

#pragma mark -
- (void)reloadDataOfTableView:(NSNotification*)sender {
    [[self tableView] reloadData];
}

- (void)dissmisData:(NSNotification*)note {
    self.userStreamArray = [NSArray array];
    [self.tableView reloadData];
}

#pragma mark - Save For Later
- (void)instapaperNotification:(NSNotification*)notification {
    BOOL success = [[notification.userInfo objectForKey:@"success"] boolValue];
    if (success) {
        SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"send to Instapaper succeeded", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
        [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
    } else {
        SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"send to Instapaper failed", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
        [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
    }
}

- (void)pocketNotification:(NSNotification*)notification {
    BOOL success = [[notification.userInfo objectForKey:@"success"] boolValue];
    if (success) {
        SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"send to pocket succeeded", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
        [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
    } else {
        SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"send to pocket failed", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
        [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
    }
}

- (void)addSeenId:(NSString*)idString {
    if (!idString)
    {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:kHideSeenThreads]) {
        NSMutableSet *mutableSeenIds = [self.seenIds mutableCopy];
        [mutableSeenIds addObject:idString];
        self.seenIds = [mutableSeenIds copy];
    }
}

//- (void)createPost:(NSNotification*)notification {
//    [self performSegueWithIdentifier:@"CreatePost" sender:self];
//}

- (NSString*)archivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey], NSStringFromClass([self class])]];
}

//- (NSString*)userNameArchivePath {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userNameSetArchive"];
//}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(DHActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            [self performSegueWithIdentifier:@"ReplyToPost" sender:@"reply"];
        } else if (buttonIndex == 1) {
            [self performSegueWithIdentifier:@"ReplyToPost" sender:@"message"];
        }
    } else if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
            [self repostPostForIndexPath:self.controlIndexPath fromAccountWithName:nil];
        } else if (buttonIndex == 1) {
            [self performSegueWithIdentifier:@"ReplyToPost" sender:@"quote"];
        }
    } else if (actionSheet.tag == 102) {
        NSDictionary *postDict = [actionSheet.userInfo objectForKey:@"postDict"];
        if (buttonIndex == 1) {
            [[UIPasteboard generalPasteboard] setString:[postDict objectForKey:@"canonical_url"]];
        } else if (buttonIndex == 2) {
            [[UIPasteboard generalPasteboard] setString:[postDict objectForKey:@"text"]];
        } else if (buttonIndex == 3) {
            NSString *threadId = [postDict objectForKey:@"thread_id"];
            NSMutableSet *mutableMutedThreadIdSet = [[DHGlobalObjects sharedGlobalObjects].mutedThreadIdSet mutableCopy];
            [mutableMutedThreadIdSet addObject:threadId];
            [DHGlobalObjects sharedGlobalObjects].mutedThreadIdSet = [mutableMutedThreadIdSet copy];
            [[self tableView] reloadData];
            [[self tableView] scrollToRowAtIndexPath:[actionSheet.userInfo objectForKey:@"indexPath"] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        } else if (buttonIndex == 4) {
            NSString *clientName = [[postDict objectForKey:@"source"] objectForKey:@"name"];
            NSMutableSet *mutableMutedClientSet = [[DHGlobalObjects sharedGlobalObjects].mutedClients mutableCopy];
            [mutableMutedClientSet addObject:clientName];
            [DHGlobalObjects sharedGlobalObjects].mutedClients = [mutableMutedClientSet copy];
            [[self tableView] reloadData];
            [[self tableView] scrollToRowAtIndexPath:[actionSheet.userInfo objectForKey:@"indexPath"] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        } else if (buttonIndex == 0) {
            NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
            
            NSString *postId = [postDict objectForKey:@"id"];
            
            if ([[[postDict objectForKey:@"user"] objectForKey:@"username"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]]) {
                
                NSString *urlString = [NSString stringWithFormat:@"%@%@%@?access_token=%@", kBaseURL, kPostsSubURL, postId, accessToken];
                
                NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                [postRequest setHTTPMethod:@"DELETE"];
                
                __weak DHStreamTableViewController *weakSelf = self;
                PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//                [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
                
                    NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
                    NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
                    if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                        [PRPAlertView showWithTitle:NSLocalizedString(@"Post couldn't be deleted", nil) message:error.localizedDescription buttonTitle:@"OK"];
                        return;
                    }
                    
                    NSMutableArray *mutableStreamArray = [NSMutableArray array];
                    for (NSDictionary *postDict in weakSelf.userStreamArray) {
                        NSMutableDictionary *mutablePostDict = [postDict mutableCopy];
                        if ([[postDict objectForKey:@"id"] isEqualToString:postId]) {
                            [mutablePostDict setObject:@"" forKey:@"text"];
                            [mutablePostDict setObject:@"1" forKey:@"is_deleted"];
                        }
                        [mutableStreamArray addObject:mutablePostDict];
                    }
                    weakSelf.userStreamArray = [mutableStreamArray copy];
                    [weakSelf.tableView reloadData];
                    
                    [NSKeyedArchiver archiveRootObject:weakSelf.userStreamArray toFile:[weakSelf archivePath]];
                    
                    SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully deleted", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                    [slideInView showWithTimer:kSlideInDuration inView:weakSelf.tableView from:SlideInViewLeft];
                    
                    
                }];
                [dhConnection start];
            } else {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Report Post?", nil) message:NSLocalizedString(@"Do you really want to report this post?", nil) cancelTitle:NSLocalizedString(@"Cancel", nil) cancelBlock:^{} otherTitle:NSLocalizedString(@"Report", nil) otherBlock:^{
                    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/report?access_token=%@", kBaseURL, kPostsSubURL, postId, accessToken];
                    
                    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    [postRequest setHTTPMethod:@"POST"];
                    
                    __weak DHStreamTableViewController *weakSelf = self;
                    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//                    [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
                    
                        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
                        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
                        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                            return;
                        }
                        
                        SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully reported", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                        [slideInView showWithTimer:kSlideInDuration inView:weakSelf.tableView from:SlideInViewLeft];
                    }];
                    [dhConnection start];
                }];
            }
        }
    } else if (actionSheet.tag == 103) {
        NSDictionary *userDict = [actionSheet.userInfo objectForKey:@"user"];
        
        NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];

        if (buttonIndex == 0) {
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@%@/follow?access_token=%@", kBaseURL, kUsersSubURL, [userDict objectForKey:@"id"], accessToken];
            
            NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            if ([[userDict objectForKey:@"you_follow"] boolValue]) {
                [postRequest setHTTPMethod:@"DELETE"];
            } else {
                [postRequest setHTTPMethod:@"POST"];
            }
            
    //        UIActivityIndicatorView *activitiIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //        activitiIndicatorView.frame = sender.bounds;
    //        [sender addSubview:activitiIndicatorView];
    //        [activitiIndicatorView startAnimating];
            
            PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//            [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
                //        NSDictionary *userDict = [connection dictionaryFromDownloadedData];
                //        dhDebug(@"userDict: %@", userDict);
                
                if ([[userDict objectForKey:@"you_follow"] boolValue]) {
                    SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully unfollowed", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                    [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
    //                [self.followButton setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
    //                self.youFollow = NO;
                } else {
                    SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully followed", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                    [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
    //                [self.followButton setTitle:NSLocalizedString(@"unfollow", nil) forState:UIControlStateNormal];
    //                self.youFollow = YES;
                }
    //            [activitiIndicatorView stopAnimating];
    //            [activitiIndicatorView removeFromSuperview];
    //            
    //            sender.enabled = YES;
            }];
            [dhConnection start];
        } else if (buttonIndex == 1) {
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@%@/mute?access_token=%@", kBaseURL, kUsersSubURL, [userDict objectForKey:@"id"], accessToken];
            
            NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            [postRequest setHTTPMethod:@"POST"];
            
//            UIActivityIndicatorView *activitiIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//            activitiIndicatorView.frame = sender.bounds;
//            [sender addSubview:activitiIndicatorView];
//            [activitiIndicatorView startAnimating];
            
            PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//            [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
                //        NSDictionary *userDict = [connection dictionaryFromDownloadedData];
                //        dhDebug(@"userDict: %@", userDict);
                
                SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully muted", nil) andSize:CGSizeMake(self.view.frame.size.width, kSlideInHeight)];
                [slideInView showWithTimer:kSlideInDuration inView:self.tableView from:SlideInViewLeft];
                                
            }];
            [dhConnection start];
        } else if (buttonIndex == 2) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *createPostViewController = [storyBoard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
            [createPostViewController setValue:[NSString stringWithFormat:@"@%@", [userDict objectForKey:@"username"]] forKey:@"draftText"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                createPostViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                createPostViewController.view.accessibilityViewIsModal = YES;
            }
            [self presentViewController:createPostViewController animated:YES completion:^{}];
        }
    } else if (actionSheet.tag == 104) {
        if (buttonIndex == 0) {
            NSMutableSet *mutableMutedHashtagSet = [[DHGlobalObjects sharedGlobalObjects].mutedHashtagSet mutableCopy];
            [mutableMutedHashtagSet addObject:[actionSheet.userInfo objectForKey:@"hashtagString"]];
            [DHGlobalObjects sharedGlobalObjects].mutedHashtagSet = [mutableMutedHashtagSet copy];
            [[self tableView] reloadData];
            [[self tableView] scrollToRowAtIndexPath:[actionSheet.userInfo objectForKey:@"indexPath"] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        } else if (buttonIndex == 1) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *createPostViewController = [storyBoard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
            [createPostViewController setValue:[NSString stringWithFormat:@"#%@", [actionSheet.userInfo objectForKey:@"hashtagString"]] forKey:@"draftText"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                createPostViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                createPostViewController.view.accessibilityViewIsModal = YES;
            }
            [self presentViewController:createPostViewController animated:YES completion:^{}];
        }
    } else if (actionSheet.tag == 111) {
        if (buttonIndex) {
            [self repostPostForIndexPath:self.controlIndexPath fromAccountWithName:[actionSheet buttonTitleAtIndex:buttonIndex]];
        }
    }

}

- (void)toggleDarkMode:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults boolForKey:kDarkMode]) {
            [userDefaults setBool:NO forKey:kDarkMode];
        } else {
            [userDefaults setBool:YES forKey:kDarkMode];
        }
        [userDefaults synchronize];
        [self setColors];
    }
}

- (NSArray*)filterLanguagesForArray:(NSArray*)inputArray {
    NSArray *languagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"languagesArray_Stream"];
//    dhDebug(@"languagesArray: %@", languagesArray);
    if ([languagesArray count] < 1 || [languagesArray containsObject:@"all"]) {
        return inputArray;
    }
    NSMutableArray *mutableUserStreamArray = [NSMutableArray array];
    for (NSDictionary *postDict in inputArray) {
        NSArray *annotationArray = [postDict objectForKey:@"annotations"];
        BOOL hasLanguageAnnotation = NO;
        for (NSDictionary *annotationDict in annotationArray) {
            if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.language"]) {
                hasLanguageAnnotation = YES;
                NSString *languageString = [[annotationDict objectForKey:@"value"] objectForKey:@"language"];
                NSString *languageShortString;
                if ([languageString rangeOfString:@"zh"].location == NSNotFound) {
                    languageShortString = [[[[annotationDict objectForKey:@"value"] objectForKey:@"language"] componentsSeparatedByString:@"_"] objectAtIndex:0];
                } else {
                    languageShortString = languageString;
                }
                if ([languagesArray containsObject:languageShortString]) {
                    [mutableUserStreamArray addObject:postDict];
                }
            }
        }
        if (!hasLanguageAnnotation && [languagesArray containsObject:@"w/o"]) {
            [mutableUserStreamArray addObject:postDict];
        }
    }
    return mutableUserStreamArray;
}

- (NSString*)keyForNewestIndexPathRow {
    return [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), kNewestIndexPathRowKey];
}

- (NSString*)keyForNewestIndexPathSection {
    return [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), kNewestIndexPathSectionKey];
}

@end
