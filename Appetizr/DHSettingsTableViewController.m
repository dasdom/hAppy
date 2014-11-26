//
//  DHSettingsTableViewController.m
//  Appetizr
//
//  Created by dasdom on 02.11.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHSettingsTableViewController.h"
#import "DHFontCell.h"
#import "DHFontSizeCell.h"
#import "DHIncludeDirecedPostsCell.h"
#import "DDHBrightnessThemeSliderCell.h"
#import "DHFontNamesTableViewController.h"
#import "UserTableViewController.h"
#import "InstapaperLoginViewController.h"
#import "LanguagesTableViewController.h"
#import "EditColorSchemeViewController.h"
#import "ClientFeaturesTableViewController.h"
//#import "PocketAPI.h"
#import "PRPAlertView.h"
#import "NSFileManager+DirectorySize.h"

enum SETTINGS_SECTIONS {
    SETTINGS_USER_SECTION = 0,
    SETTINGS_GENERAL_SECTION,
    SETTINGS_FONT_SECTION,
//    SETTINGS_READ_LATER_SECTION,
//    SETTINGS_FEEDBACK_SECTION,
    SETTINGS_INFO_SECTIONS,
    SETTINGS_NUM_OF_SECTIONS
    } SETTINGS_SECTIONS;

enum SETTINGS_USER_ROWS {
    SETTINGS_SELECTED_USERS = 0,
//    SETTINGS_INSTAPAPER,
    SETTINGS_USER_NUM_OF_ROWS
    } SETTINGS_USER_ROWS;

enum SETTINGS_GENERAL_ROWS {
    SETTINGS_INCLUDE_DIRECT_POSTS = 0,
//    SETTINGS_DONT_LOAD_IMAGES,
    SETTINGS_SHOW_REAL_NAMES,
    SETTINGS_HIDE_SEEN_THREADS,
//    SETTINGS_DARK_MODE,
//    SETTINGS_LIGHT_COLOR,
    SETTINGS_STREAM_MARKER,
    SETTINGS_NORMAL_KEYBOARD,
    SETTINGS_ABSOLUTE_TIME,
    SETTINGS_IGNORE_UNREAD_PATTER,
//    SETTINGS_ACTIVATE_DROPBOX,
    SETTINGS_LANGUAGES,
    SETTINGS_GENERAL_NUM_OF_ROWS
    } SETTINGS_GENERAL_ROWS;

//enum SETTINGS_FONT_ROWS {
//    SETTINGS_FONTNAME = 0,
//    SETTINGS_FONTSIZE,
//    SETTINGS_FONT_NUM_OF_ROWS
//    } SETTINGS_FONT_ROWS;

typedef NS_ENUM(NSUInteger, SETTINGS_APPEARANCE_ROWS) {
    SETTINGS_FONTNAME = 0,
    SETTINGS_FONTSIZE,
    SETTINGS_DONT_LOAD_IMAGES,
    SETTINGS_ONLY_LOAD_IMAGES_IN_WIFI,
    SETTINGS_DARK_MODE,
    SETTINGS_LIGHT_COLOR,
    SETTINGS_SWITCH_THEME_AUTOMATICALLY,
    SETTINGS_HIDE_CLIENT,
    SETTINGS_INLINE_IMAGES,
    SETTINGS_APPEARANCE_NUM_OF_ROWS
};

//enum SETTINGS_READ_LATER_ROWS {
//    SETTINGS_INSTAPAPER = 0,
//    SETTINGS_POCKET,
//    SETTINGS_READ_LATER_NUM_OF_ROWS
//    };

typedef NS_ENUM(NSUInteger, SETTINGS_TAG) {
    SETTINGS_INCLUDE_DIRECTED_POSTS_TAG = 100,
    SETTINGS_DONT_LOAD_IMAGES_TAG,
    SETTINGS_ONLY_LOAD_IMAGES_IN_WIFI_TAG,
    SETTINGS_SHOW_REAL_NAMES_TAG,
    SETTINGS_HIDE_SEEN_THREADS_TAG,
    SETTINGS_DARK_MODE_TAG,
    SETTINGS_AUTOMATIC_THEME_SWITCH_TAG,
    SETTINGS_STREAM_MARKER_TAG,
    SETTINGS_NORMAL_KEYBOARD_TAG,
    SETTINGS_ABSOLUTE_TIME_TAG,
    SETTINGS_IGNORE_UNREAD_PATTER_TAG,
    SETTINGS_FONTSIZE_TAG,
    SETTINGS_HIDE_CLIENT_TAG,
    SETTINGS_INLINE_IMAGES_TAG
};


@interface DHSettingsTableViewController ()
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) BOOL includeDirectedPosts;
@property (nonatomic, assign) BOOL loadImages;
@property (nonatomic, assign) BOOL onlyLoadImagesInWifi;
@property (nonatomic, assign) BOOL showRealNames;
@property (nonatomic, assign) BOOL darkMode;
@property (nonatomic, assign) BOOL automaticThemeSwitch;
@property (nonatomic, assign) CGFloat brightnessThemeSwitchValue;
@property (nonatomic, assign) CGFloat currentBrighness;
@property (nonatomic, assign) BOOL streamMarker;
@property (nonatomic, assign) BOOL normalKeyboard;
@property (nonatomic, assign) BOOL absoluteTimeStamp;
@property (nonatomic, assign) BOOL ignoreUnreadPatter;
@property (nonatomic, assign) BOOL hideSeenThreads;
@property (nonatomic, assign) BOOL hideClient;
@property (nonatomic, assign) BOOL inlineImages;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSString *currentUserName;

@property (nonatomic, strong) NSString *avatarDirectoryPath;
@end

@implementation DHSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _userDefaults = [NSUserDefaults standardUserDefaults];
//    self.fontSize = [[_userDefaults objectForKey:kFontSize] floatValue];
//    self.includeDirectedPosts = [_userDefaults boolForKey:kIncludeDirecedPosts];
//    self.loadImages = ![_userDefaults boolForKey:kDontLoadImages];
//    self.darkMode = [_userDefaults boolForKey:kDarkMode];
//    self.streamMarker = [_userDefaults boolForKey:kStreamMarker];
//    self.hideSeenThreads = [_userDefaults boolForKey:kHideSeenThreads];
    
    self.currentUserName = [_userDefaults stringForKey:kUserNameDefaultKey];
    
    NSArray *userArray = [_userDefaults objectForKey:kUserArrayKey];
    if (!userArray || [userArray count] < 1) {
        NSString *userName = [_userDefaults stringForKey:kUserNameDefaultKey];
        userArray = @[userName];
        [_userDefaults setObject:userArray forKey:kUserArrayKey];
        
        NSMutableDictionary *userDefaultsDictionaryForCurrentUser = [NSMutableDictionary dictionary];
        [userDefaultsDictionaryForCurrentUser setObject:[self.userDefaults objectForKey:kFontSize] forKey:kFontSize];
        [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:[self.userDefaults boolForKey:kIncludeDirecedPosts]] forKey:kIncludeDirecedPosts];
        [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:[self.userDefaults boolForKey:kDontLoadImages]] forKey:kDontLoadImages];
        [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:[self.userDefaults boolForKey:kDarkMode]] forKey:kDarkMode];
        [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:[self.userDefaults boolForKey:kStreamMarker]] forKey:kStreamMarker];
        [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:[self.userDefaults boolForKey:kHideSeenThreads]] forKey:kHideSeenThreads];
        [userDefaultsDictionaryForCurrentUser setObject:[self.userDefaults objectForKey:kFontName] forKey:kFontName];
//        [userDefaultsDictionaryForCurrentUser setObject:[self.userDefaults objectForKey:kAccessTokenDefaultsKey] forKey:kAccessTokenDefaultsKey];
        
        [_userDefaults setObject:userDefaultsDictionaryForCurrentUser forKey:userName];
        
        [_userDefaults synchronize];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _avatarDirectoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatars"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.fontSize = [[_userDefaults objectForKey:kFontSize] floatValue];
    self.includeDirectedPosts = [_userDefaults boolForKey:kIncludeDirecedPosts];
    self.loadImages = ![_userDefaults boolForKey:kDontLoadImages];
    self.onlyLoadImagesInWifi = [_userDefaults boolForKey:kOnlyLoadImagesInWifi];
    self.showRealNames = [_userDefaults boolForKey:kShowRealNames];
    self.darkMode = [_userDefaults boolForKey:kDarkMode];
    self.automaticThemeSwitch = [_userDefaults boolForKey:kAutomaticSwitchTheme];
    self.brightnessThemeSwitchValue = [_userDefaults floatForKey:kBrightnessThemeSwitchValue];
    self.streamMarker = [_userDefaults boolForKey:kStreamMarker];
    self.normalKeyboard = [_userDefaults boolForKey:kNormalKeyboard];
    self.absoluteTimeStamp = [_userDefaults boolForKey:kAboluteTimeStamp];
    self.ignoreUnreadPatter = [_userDefaults boolForKey:kIgnoreUnreadPatter];
    self.hideClient = [_userDefaults boolForKey:kHideClient];
    self.hideSeenThreads = [_userDefaults boolForKey:kHideSeenThreads];
    self.inlineImages = [_userDefaults boolForKey:kInlineImages];
    
    self.currentBrighness = [[UIScreen mainScreen] brightness];

    
    if (![[_userDefaults stringForKey:kUserNameDefaultKey] isEqualToString:_currentUserName]) {
        self.currentUserName = [_userDefaults stringForKey:kUserNameDefaultKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangedNotification object:self];
    }
    
    if ([_userDefaults boolForKey:kDarkMode]) {
//        self.navigationController.navigationBar.tintColor = kDarkMainColor;
//        self.view.backgroundColor = kDarkCellBackgroundColorDefault;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
        }
        else
        {
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        }
        self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
    } else {
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].textColor];
        }
        else
        {
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        }
        self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
    }
    
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return SETTINGS_NUM_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows;
    switch (section) {
        case SETTINGS_SELECTED_USERS:
            numberOfRows = SETTINGS_USER_NUM_OF_ROWS;
            break;
        case SETTINGS_GENERAL_SECTION:
            numberOfRows = SETTINGS_GENERAL_NUM_OF_ROWS;
            break;
        case SETTINGS_FONT_SECTION:
            numberOfRows = SETTINGS_APPEARANCE_NUM_OF_ROWS;
            break;
//        case SETTINGS_READ_LATER_SECTION:
//            numberOfRows = SETTINGS_READ_LATER_NUM_OF_ROWS;
//            break;
//        case SETTINGS_FEEDBACK_SECTION:
//            numberOfRows = 1;
//            break;
        case SETTINGS_INFO_SECTIONS:
            numberOfRows = 3;
            break;
        default:
            NSAssert1(false, @"Unsupported section: %d", section);
            numberOfRows = 0;
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    UITableViewCell *cell;
    switch (indexPath.section) {
        case SETTINGS_USER_SECTION:
            switch (indexPath.row) {
                case SETTINGS_SELECTED_USERS:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
                    [self setupColorForCell:cell];
                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
                    cell.textLabel.text = NSLocalizedString(@"User", nil);
                    cell.detailTextLabel.text = [self.userDefaults stringForKey:kUserNameDefaultKey];
                }
                    break;
//                case SETTINGS_INSTAPAPER:
//                {
//                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
//                    [self setupColorForCell:cell];
//                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
//                    cell.textLabel.text = NSLocalizedString(@"read later", nil);
//                    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kInstapaperUserNameKey];
//                    if (userName) {
//                        cell.detailTextLabel.text = @"Instapaper";
//                    } else {
//                        cell.detailTextLabel.text = @"-";
//                    }
//                }
//                    break;
            }
            break;
        case SETTINGS_GENERAL_SECTION:
            switch (indexPath.row) {
                case SETTINGS_INCLUDE_DIRECT_POSTS:
                {
                    CellIdentifier = @"ShowDirectedPostsCell";
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.includeDirectedPosts;
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"show posts directed to people I don't follow", nil);
                    includeDirectedCell.activationSwitch.tag = SETTINGS_INCLUDE_DIRECTED_POSTS_TAG;
                    cell = includeDirectedCell;
                    break;
                }
//                case SETTINGS_DONT_LOAD_IMAGES:
//                {
//                    CellIdentifier = @"ShowDirectedPostsCell";
//                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//                    [self setupColorForIncludeCell:includeDirectedCell];
//                    includeDirectedCell.activationSwitch.on = self.loadImages;
//                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"load images", nil);
//                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
//                    includeDirectedCell.activationSwitch.tag = SETTINGS_DONT_LOAD_IMAGES_TAG;
//                    cell = includeDirectedCell;
//                }
//                    break;
                case SETTINGS_SHOW_REAL_NAMES:
                {
                    CellIdentifier = @"ShowDirectedPostsCell";
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.showRealNames;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"show real names", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_SHOW_REAL_NAMES;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_HIDE_SEEN_THREADS:
                {
                    CellIdentifier = @"ShowDirectedPostsCell";
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.hideSeenThreads;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"hide posts in my stream which I have seen in conversations", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_HIDE_SEEN_THREADS_TAG;
                    cell = includeDirectedCell;
                    break;
                }
//                case SETTINGS_DARK_MODE:
//                {
//                    CellIdentifier = @"ShowDirectedPostsCell";
//                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//                    [self setupColorForIncludeCell:includeDirectedCell];
//                    includeDirectedCell.activationSwitch.on = self.darkMode;
//                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"dark mode", nil);
//                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
//                    includeDirectedCell.activationSwitch.tag = SETTINGS_DARK_MODE_TAG;
//                    cell = includeDirectedCell;
//                }
//                    break;
//                case SETTINGS_LIGHT_COLOR:
//                {
//                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
//                    [self setupColorForCell:cell];
//                    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
//                    cell.textLabel.text = NSLocalizedString(@"custom color scheme", nil);
//                    cell.detailTextLabel.text = @"";
//                    break;
//                }
                case SETTINGS_STREAM_MARKER:
                {
                    CellIdentifier = @"ShowDirectedPostsCell";
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.streamMarker;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"stream marker", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_STREAM_MARKER_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_NORMAL_KEYBOARD:
                {
                    CellIdentifier = @"ShowDirectedPostsCell";
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.normalKeyboard;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"normal keyboard", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_NORMAL_KEYBOARD_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_ABSOLUTE_TIME:
                {
                    CellIdentifier = @"ShowDirectedPostsCell";
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.absoluteTimeStamp;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"absolute time stamp", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_ABSOLUTE_TIME_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_IGNORE_UNREAD_PATTER:
                {
                    CellIdentifier = @"ShowDirectedPostsCell";
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.ignoreUnreadPatter;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"ignore unread patter messages", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_IGNORE_UNREAD_PATTER_TAG;
                    cell = includeDirectedCell;
                    break;
                }
//                case SETTINGS_ACTIVATE_DROPBOX:
//                {
//                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
////                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
//                    if (![[DBSession sharedSession] isLinked]) {
//                        cell.detailTextLabel.text = @"-";
//                    } else {
//                        cell.detailTextLabel.text = @"dropbox";
//                    }
//                    break;
//
//                }
//                    break;
                case SETTINGS_LANGUAGES:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
                    [self setupColorForCell:cell];
                    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
                    cell.textLabel.text = NSLocalizedString(@"language filter", nil);
                    cell.detailTextLabel.text = @"";
                    break;
                }
                default:
                    NSAssert1(false, @"Unsupported row: %d", indexPath.row);
                    break;
            }
            break;
        case SETTINGS_FONT_SECTION:
            switch (indexPath.row) {
                case SETTINGS_FONTNAME:
                {
                    CellIdentifier = @"FontNameCell";
                    DHFontCell *fontCell = (DHFontCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    fontCell.fontLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
                    fontCell.fontLabel.text = [NSString stringWithFormat:NSLocalizedString(@"font: %@", nil), [self.userDefaults objectForKey:kFontName]];
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//                        fontCell.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//                        fontCell.fontLabel.textColor = kDarkTextColor;
//                        fontCell.fontLabel.backgroundColor = kDarkCellBackgroundColorDefault;
                        fontCell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
                        fontCell.fontLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
                        fontCell.fontLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
                    } else {
                        fontCell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
                        fontCell.fontLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
                        fontCell.fontLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
                    }

                    cell = fontCell;
                    break;
                }
                case SETTINGS_FONTSIZE:
                {
                    DHFontSizeCell *fontSizeCell = (DHFontSizeCell*)[tableView dequeueReusableCellWithIdentifier:@"FontSizeCell" forIndexPath:indexPath];
                    fontSizeCell.fontSizeLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
                    NSString *fontSizeString;
                    if (self.fontSize < 14) {
                        fontSizeString = NSLocalizedString(@"tiny", nil);
                    } else if (self.fontSize < 16) {
                        fontSizeString = NSLocalizedString(@"small", nil);
                    } else if (self.fontSize < 18) {
                        fontSizeString = NSLocalizedString(@"medium", nil);
                    } else if (self.fontSize < 20) {
                        fontSizeString = NSLocalizedString(@"big", nil);
                    } else if (self.fontSize < 22) {
                        fontSizeString = NSLocalizedString(@"BIG", nil);
                    } else {
                        fontSizeString = NSLocalizedString(@"crazy", nil);
                    }
                    fontSizeCell.fontSizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"font size: %@", nil), fontSizeString];
                    fontSizeCell.fontSizeStepper.value = self.fontSize;
                    fontSizeCell.fontSizeStepper.tag = SETTINGS_FONTSIZE_TAG;
                    [fontSizeCell.fontSizeStepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//                        fontSizeCell.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//                        fontSizeCell.fontSizeLabel.textColor = kDarkTextColor;
//                        fontSizeCell.fontSizeLabel.backgroundColor = kDarkCellBackgroundColorDefault;
//                        fontSizeCell.fontSizeStepper.tintColor = kDarkMainColor;
                        fontSizeCell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
                        fontSizeCell.fontSizeLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
                        fontSizeCell.fontSizeLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
                        fontSizeCell.fontSizeStepper.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
                    } else {
                        fontSizeCell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
                        fontSizeCell.fontSizeLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
                        fontSizeCell.fontSizeLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
                        fontSizeCell.fontSizeStepper.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
                    }
                    cell = fontSizeCell;
                    break;
                }
                case SETTINGS_DONT_LOAD_IMAGES:
                {
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:@"ShowDirectedPostsCell" forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.loadImages;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"load images", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_DONT_LOAD_IMAGES_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_ONLY_LOAD_IMAGES_IN_WIFI:
                {
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:@"ShowDirectedPostsCell" forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.onlyLoadImagesInWifi;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"only load images in wifi", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_ONLY_LOAD_IMAGES_IN_WIFI_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_DARK_MODE:
                {
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:@"ShowDirectedPostsCell" forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.darkMode;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"dark mode", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_DARK_MODE_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_LIGHT_COLOR:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
                    [self setupColorForCell:cell];
                    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
                    cell.textLabel.text = NSLocalizedString(@"custom color scheme", nil);
                    cell.detailTextLabel.text = @"";
                    break;
                }
                case SETTINGS_SWITCH_THEME_AUTOMATICALLY:
                {
                    DDHBrightnessThemeSliderCell *brightnessCell = (DDHBrightnessThemeSliderCell*)[tableView dequeueReusableCellWithIdentifier:@"BrightnessThemeSliderCell" forIndexPath:indexPath];
                    [self setupColorForBrightnessCell:brightnessCell];
                    brightnessCell.automaticSwitch.on = self.automaticThemeSwitch;
                    [brightnessCell.automaticSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    brightnessCell.automaticSwitch.tag = SETTINGS_AUTOMATIC_THEME_SWITCH_TAG;
                    brightnessCell.brightnessSlider.value = self.brightnessThemeSwitchValue;
                    [brightnessCell.brightnessSlider addTarget:self action:@selector(brightnessSliderChanged:) forControlEvents:UIControlEventValueChanged];
                    brightnessCell.brightnessSlider.minimumValue = 0.0f;
                    brightnessCell.brightnessSlider.maximumValue = 1.0f;
                    CGRect brightnessSliderFrame = brightnessCell.brightnessSlider.frame;
                    CGRect frame = brightnessCell.currentBrighnessView.frame;
                    frame.origin.x = brightnessSliderFrame.origin.x + _currentBrighness * brightnessSliderFrame.size.width;
                    brightnessCell.currentBrighnessView.frame = frame;
                    cell = brightnessCell;
                    break;
                }
                case SETTINGS_HIDE_CLIENT:
                {
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier: @"ShowDirectedPostsCell" forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.hideClient;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"hide client", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_HIDE_CLIENT_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                case SETTINGS_INLINE_IMAGES:
                {
                    DHIncludeDirecedPostsCell *includeDirectedCell = (DHIncludeDirecedPostsCell*)[tableView dequeueReusableCellWithIdentifier:@"ShowDirectedPostsCell" forIndexPath:indexPath];
                    [self setupColorForIncludeCell:includeDirectedCell];
                    includeDirectedCell.activationSwitch.on = self.inlineImages;
                    includeDirectedCell.descriptionLabel.text = NSLocalizedString(@"inline images", nil);
                    [includeDirectedCell.activationSwitch addTarget:self action:@selector(activationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    includeDirectedCell.activationSwitch.tag = SETTINGS_INLINE_IMAGES_TAG;
                    cell = includeDirectedCell;
                    break;
                }
                default:
                    NSAssert1(false, @"Unsupported row: %d", indexPath.row);
                    break;
            }
            break;
//        case SETTINGS_READ_LATER_SECTION:
//        {
//            switch (indexPath.row) {
//                case SETTINGS_INSTAPAPER:
//                {
//                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
//                    [self setupColorForCell:cell];
//                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
//                    cell.textLabel.text = NSLocalizedString(@"Instapaper", nil);
//                    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kInstapaperUserNameKey];
//                    if (userName) {
//                        cell.detailTextLabel.text = NSLocalizedString(@"active", nil);
//                    } else {
//                        cell.detailTextLabel.text = @"-";
//                    }
//                    break;
//                }
//                case SETTINGS_POCKET:
//                {
//                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
//                    [self setupColorForCell:cell];
//                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
//                    cell.textLabel.text = NSLocalizedString(@"pocket", nil);
//                    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kPocketUserNameKey];
//                    if (userName) {
//                        cell.detailTextLabel.text = NSLocalizedString(@"active", nil);
//                    } else {
//                        cell.detailTextLabel.text = @"-";
//                    }
//                    break;
//                }
//                default:
//                    break;
//            }
////            cell = [tableView dequeueReusableCellWithIdentifier:@"ReadLaterCell"];
////            cell.textLabel.text = @"read later via";
////            cell.detailTextLabel.text = @"none";
//            
//            break;
//        }
//        case SETTINGS_FEEDBACK_SECTION:
//            cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
//            cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackCell"];
//            break;
        case SETTINGS_INFO_SECTIONS:
            switch (indexPath.row) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
                    [self setupColorForCell:cell];
                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
                    
                    NSURL *avatarsURL = [[NSURL alloc] initFileURLWithPath:self.avatarDirectoryPath];
                                       
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"delete avatar cache (%.1f MB)", nil), [[NSFileManager defaultManager] contentSizeOfDirectoryAtURL:avatarsURL]/1000.0f/1000.0f];
                    cell.detailTextLabel.text = @"";
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
                    [self setupColorForCell:cell];
                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
                    
                    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
                    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"about (v%@)", nil), version];
                    break;
                }
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"DropBoxCell"];
                    [self setupColorForCell:cell];
                    cell.textLabel.font = [UIFont fontWithName:[self.userDefaults objectForKey:kFontName] size:self.fontSize];
                    cell.textLabel.text = NSLocalizedString(@"unhappy with hAppy?", nil);
                    cell.detailTextLabel.text = nil;
                    break;
                }
            }
            break;
        default:
            NSAssert1(false, @"Unsupported section: %d", indexPath.section);
            break;
    }
    
    return cell;
}

- (void)setupColorForCell:(UITableViewCell*)cell {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        cell.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//        cell.textLabel.textColor = kDarkTextColor;
//        cell.detailTextLabel.textColor = kDarkTextColor;
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        cell.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        cell.textLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.detailTextLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
    } else {
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        cell.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        cell.textLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.detailTextLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)setupColorForIncludeCell:(DHIncludeDirecedPostsCell*)cell {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        cell.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//        cell.descriptionLabel.textColor = kDarkTextColor;
//        cell.descriptionLabel.backgroundColor = kDarkCellBackgroundColorDefault;
//        cell.activationSwitch.tintColor = kDarkCellBackgroundColorDefault;
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        cell.descriptionLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.descriptionLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
//        cell.activationSwitch.tintColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
    } else {
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        cell.descriptionLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.descriptionLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
//        cell.activationSwitch.tintColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
    }
}

- (void)setupColorForBrightnessCell:(DDHBrightnessThemeSliderCell*)cell {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
//        cell.automaticSwitch.tintColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        cell.cellLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;

    } else {
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
//        cell.automaticSwitch.tintColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        cell.cellLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *headerString;
//    switch (section) {
//        case SETTINGS_USER_SECTION:
//            headerString = NSLocalizedString(@"User", nil);
//            break;
//        case SETTINGS_GENERAL_SECTION:
//            headerString = NSLocalizedString(@"Stream Behavior", nil);
//            break;
//        case SETTINGS_FONT_SECTION:
//            headerString = NSLocalizedString(@"Appearance", nil);
//            break;
//        case SETTINGS_READ_LATER_SECTION:
//            headerString = NSLocalizedString(@"Read Later", nil);
//            break;
//        case SETTINGS_INFO_SECTIONS:
//            headerString = NSLocalizedString(@"Info", nil);
//            break;
//        default:
//            NSAssert1(false, @"Unsupported section: %d", section);
//            break;
//            
//    }
//    return headerString;
//}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 20.0f)];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        headerLabel.backgroundColor = kDarkMainColor;
//        headerLabel.textColor = kDarkTextColor;
        headerLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        headerLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
    } else {
        headerLabel.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        headerLabel.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
    }
    headerLabel.textAlignment = NSTextAlignmentCenter;
    switch (section) {
        case SETTINGS_USER_SECTION:
            headerLabel.text = NSLocalizedString(@"User", nil);
            break;
        case SETTINGS_GENERAL_SECTION:
            headerLabel.text = NSLocalizedString(@"Stream Behavior", nil);
            break;
        case SETTINGS_FONT_SECTION:
            headerLabel.text = NSLocalizedString(@"Appearance", nil);
            break;
//        case SETTINGS_READ_LATER_SECTION:
//            headerLabel.text = NSLocalizedString(@"Read Later", nil);
//            break;
        case SETTINGS_INFO_SECTIONS:
            headerLabel.text = NSLocalizedString(@"Info", nil);
            break;
        default:
            NSAssert1(false, @"Unsupported section: %d", section);
            break;
            
    }

    return headerLabel;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SETTINGS_USER_SECTION) {
        if (indexPath.row == SETTINGS_SELECTED_USERS) {
            UserTableViewController *userTableViewController = [[UserTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:userTableViewController animated:YES];
        }
//        if (indexPath.row == SETTINGS_INSTAPAPER) {
//            InstapaperLoginViewController *instapaperLoginViewController = [[InstapaperLoginViewController alloc] init];
//            [self.navigationController pushViewController:instapaperLoginViewController animated:YES];
//        }
    } else if (indexPath.section == SETTINGS_GENERAL_SECTION) {
        if (indexPath.row == SETTINGS_LANGUAGES) {
            LanguagesTableViewController *languagesTableViewController = [[LanguagesTableViewController alloc] init];
            [self.navigationController pushViewController:languagesTableViewController animated:YES];
        }
        
    } else if (indexPath.section == SETTINGS_FONT_SECTION) {
        if (indexPath.row == SETTINGS_LIGHT_COLOR) {
            EditColorSchemeViewController *editColorSchemeViewController = [[EditColorSchemeViewController alloc] init];
            [self.navigationController pushViewController:editColorSchemeViewController animated:YES];
        }
//    } else if (indexPath.section == SETTINGS_READ_LATER_SECTION) {
//        if (indexPath.row == SETTINGS_INSTAPAPER) {
//            InstapaperLoginViewController *instapaperLoginViewController = [[InstapaperLoginViewController alloc] init];
//            [self.navigationController pushViewController:instapaperLoginViewController animated:YES];
//        } else if (indexPath.row == SETTINGS_POCKET) {
//            if ([[NSUserDefaults standardUserDefaults] stringForKey:kPocketUserNameKey]) {
//                [[PocketAPI sharedAPI] logout];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPocketUserNameKey];
//            } else {
//                [[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
//                    if (error != nil)
//                    {
//                        [PRPAlertView showWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Could not connect to your pocket account.", nil) buttonTitle:@"Ok"];
//                    }
//                    else
//                    {
//                        [[NSUserDefaults standardUserDefaults] setObject:[API username] forKey:kPocketUserNameKey];
//                        [self.tableView reloadData];
//                    }
//                }];
//            }
//        }
    }
    if (indexPath.section == SETTINGS_INFO_SECTIONS) {
        if(indexPath.row == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:self.avatarDirectoryPath error:nil];
            [[NSFileManager defaultManager] createDirectoryAtPath:self.avatarDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
            [self.tableView reloadData];
        } else if(indexPath.row == 2) {
            ClientFeaturesTableViewController *clientFeaturesTableViewController = [[ClientFeaturesTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:clientFeaturesTableViewController animated:YES];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 44.0f;
    switch (indexPath.section) {
        case SETTINGS_GENERAL_SECTION:
            switch (indexPath.row) {
                case SETTINGS_INCLUDE_DIRECT_POSTS:
                case SETTINGS_HIDE_SEEN_THREADS:
                case SETTINGS_IGNORE_UNREAD_PATTER:
                    heightForRow = 75.0f;
                    break;
                    
                default:
                    break;
            }
            break;
        case SETTINGS_FONT_SECTION:
        {
            switch (indexPath.row) {
                case SETTINGS_SWITCH_THEME_AUTOMATICALLY:
                {
                    heightForRow = 90.0f;
                    break;
                }
            }
            break;
        }
        default:
            break;
    }
    return heightForRow;
}

- (void)activationSwitchChanged:(UISwitch*)sender {
    switch (sender.tag) {
        case SETTINGS_INCLUDE_DIRECTED_POSTS_TAG:
            self.includeDirectedPosts = sender.on;
            break;
        case SETTINGS_DONT_LOAD_IMAGES_TAG:
            self.loadImages = sender.on;
            break;
        case SETTINGS_ONLY_LOAD_IMAGES_IN_WIFI_TAG:
            self.onlyLoadImagesInWifi = sender.on;
            break;
        case SETTINGS_SHOW_REAL_NAMES:
            self.showRealNames = sender.on;
            break;
        case SETTINGS_DARK_MODE_TAG:
            self.darkMode = sender.on;
            [self.userDefaults setBool:self.darkMode forKey:kDarkMode];
            [self.userDefaults synchronize];
            [self.tableView reloadData];
            if (sender.on) {
                if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
                {
                    self.navigationController.navigationBar.barTintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
                    self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
                }
                else
                {
                    self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
                }
                self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
            } else {
                if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
                {
                    self.navigationController.navigationBar.barTintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
                    self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].textColor;
                }
                else
                {
                    self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
                }
                self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
            }
            break;
        case SETTINGS_AUTOMATIC_THEME_SWITCH_TAG:
            self.automaticThemeSwitch = sender.on;
            break;
        case SETTINGS_STREAM_MARKER_TAG:
            self.streamMarker = sender.on;
            break;
        case SETTINGS_NORMAL_KEYBOARD_TAG:
            self.normalKeyboard = sender.on;
            break;
        case SETTINGS_ABSOLUTE_TIME_TAG:
            self.absoluteTimeStamp = sender.on;
            break;
        case SETTINGS_IGNORE_UNREAD_PATTER_TAG:
            self.ignoreUnreadPatter = sender.on;
            break;
        case SETTINGS_HIDE_SEEN_THREADS_TAG:
            self.hideSeenThreads = sender.on;
            break;
        case SETTINGS_HIDE_CLIENT_TAG:
            self.hideClient = sender.on;
            break;
        case SETTINGS_INLINE_IMAGES_TAG:
            self.inlineImages = sender.on;
            break;
        default:
            NSAssert1(false, @"Unsupported sender tag: %d", sender.tag);
            break;
    }
}

- (void)stepperValueChanged:(UIStepper*)sender {
    switch (sender.tag) {
        case SETTINGS_FONTSIZE_TAG:
            self.fontSize = sender.value;
            [self.tableView reloadData];
            break;
        default:
            NSAssert1(false, @"Unsupported sender tag: %d", sender.tag);
            break;
    }
}

- (void)brightnessSliderChanged:(UISlider*)sender {
    self.brightnessThemeSwitchValue = sender.value;
}

- (IBAction)saveButtonTouched:(UIBarButtonItem *)sender {
    [_userDefaults setBool:_includeDirectedPosts forKey:kIncludeDirecedPosts];
    [_userDefaults setBool:!_loadImages forKey:kDontLoadImages];
    [_userDefaults setBool:_onlyLoadImagesInWifi forKey:kOnlyLoadImagesInWifi];
    [_userDefaults setBool:_showRealNames forKey:kShowRealNames];
    [_userDefaults setBool:_darkMode forKey:kDarkMode];
    [_userDefaults setBool:_automaticThemeSwitch forKey:kAutomaticSwitchTheme];
    [_userDefaults setFloat:_brightnessThemeSwitchValue forKey:kBrightnessThemeSwitchValue];
    [_userDefaults setBool:_streamMarker forKey:kStreamMarker];
    [_userDefaults setBool:_normalKeyboard forKey:kNormalKeyboard];
    [_userDefaults setBool:_absoluteTimeStamp forKey:kAboluteTimeStamp];
    [_userDefaults setBool:_ignoreUnreadPatter forKey:kIgnoreUnreadPatter];
    [_userDefaults setBool:_hideSeenThreads forKey:kHideSeenThreads];
    [_userDefaults setBool:_hideClient forKey:kHideClient];
    [_userDefaults setBool:_inlineImages forKey:kInlineImages];
    [_userDefaults setObject:[NSString stringWithFormat:@"%.0f", _fontSize] forKey:kFontSize];
    
    NSMutableDictionary *userDefaultsDictionaryForCurrentUser = [NSMutableDictionary dictionary];
    [userDefaultsDictionaryForCurrentUser setObject:[NSString stringWithFormat:@"%.0f", _fontSize] forKey:kFontSize];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_includeDirectedPosts] forKey:kIncludeDirecedPosts];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:!_loadImages] forKey:kDontLoadImages];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_onlyLoadImagesInWifi] forKey:kOnlyLoadImagesInWifi];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_showRealNames] forKey:kShowRealNames];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_darkMode] forKey:kDarkMode];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_automaticThemeSwitch] forKey:kAutomaticSwitchTheme];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithFloat:_brightnessThemeSwitchValue] forKey:kBrightnessThemeSwitchValue];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_streamMarker] forKey:kStreamMarker];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_normalKeyboard] forKey:kNormalKeyboard];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_absoluteTimeStamp] forKey:kAboluteTimeStamp];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_ignoreUnreadPatter] forKey:kIgnoreUnreadPatter];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_hideSeenThreads] forKey:kHideSeenThreads];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_hideClient] forKey:kHideClient];
    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:_inlineImages] forKey:kInlineImages];
    if ([_userDefaults objectForKey:kFontName]) {
        [userDefaultsDictionaryForCurrentUser setObject:[_userDefaults objectForKey:kFontName] forKey:kFontName];
    }
//    [userDefaultsDictionaryForCurrentUser setObject:[self.userDefaults objectForKey:kAccessTokenDefaultsKey] forKey:kAccessTokenDefaultsKey];
    
    NSString *userName = [self.userDefaults stringForKey:kUserNameDefaultKey];

    [_userDefaults setObject:userDefaultsDictionaryForCurrentUser forKey:userName];

    [_userDefaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsChangedNotification object:self];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowFontNames"]) {
        DHFontNamesTableViewController *fontNamesTableViewController = segue.destinationViewController;
        fontNamesTableViewController.fontSize = _fontSize;
    }
}

@end
