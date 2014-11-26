//
//  DHChannelsViewController.m
//  Appetizr
//
//  Created by dasdom on 16.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHChannelsViewController.h"
#import "PRPConnection.h"
#import "DHChannelCell.h"
#import "DHCreateStatusViewController.h"
//#import "DHGlobalObjects.h"
#import "PRPAlertView.h"
//#import "KeychainItemWrapper.h"
#import "SSKeychain.h"
#import "DHAppDelegate.h"
#import "DHMessagesTableViewController.h"
#import "DHWebViewController.h"
#import "ImageHelper.h"
#import "DHActionSheet.h"

#define kScrollViewWidth 80.0f

@interface DHChannelsViewController () <UIActionSheetDelegate>
//@property (nonatomic, strong) DHConnection *channelsConnection;
@property (nonatomic, strong) NSMutableArray *mutableUserConnectionArray;
@property (nonatomic, strong) NSURLSessionDataTask *channelsDataSession;
//@property (nonatomic, strong) NSMutableArray *mutableSessionArray;

@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSArray *pmArray;
@property (nonatomic, strong) NSArray *patterArray;

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *titleScrollView;

@property (nonatomic) CGFloat startOffsetX;
@property (nonatomic, strong) NSMutableDictionary *otherUsersDict;
@property (nonatomic, strong) NSMutableDictionary *problemChannels;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIButton *menuButton;
@end

@implementation DHChannelsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScrollViewWidth, 40.0f)];
    _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScrollViewWidth, 30.0f)];
    CGFloat xPos = 0.0f;
    
    [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:NSLocalizedString(@"pm", nil)]];
    xPos += kScrollViewWidth;
    [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:NSLocalizedString(@"patter", nil)]];
    xPos += kScrollViewWidth;
    
    _titleScrollView.contentSize = CGSizeMake(xPos, 30.0f);
    _titleScrollView.pagingEnabled = YES;
    _titleScrollView.delegate = self;
    _titleScrollView.showsVerticalScrollIndicator = NO;
    _titleScrollView.showsHorizontalScrollIndicator = NO;
    _titleScrollView.tag = 1001;
//    _titleScrollView.contentOffset = CGPointMake(kScrollViewWidth, 0.0f);
    [titleView addSubview:_titleScrollView];

    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 30.0f, kScrollViewWidth, 10.0f)];
    _pageControl.numberOfPages = 2;
    _pageControl.pageIndicatorTintColor = [UIColor blackColor];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.isAccessibilityElement = NO;
//    [titleView addSubview:_pageControl];
    self.navigationItem.titleView = titleView;
    
    self.otherUsersDict = [NSMutableDictionary dictionary];
    self.problemChannels = [NSMutableDictionary dictionary];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
}

- (UILabel*)titleLabelWithXPostion:(CGFloat)xPos andText:(NSString*)textString {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPos, 0.0f, kScrollViewWidth, 40.0f)];
    label.text = textString;
    label.textAlignment = NSTextAlignmentCenter;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        label.textColor = kDarkTextColor;
        label.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
    } else {
        label.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
    }
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
    label.backgroundColor = [UIColor clearColor];
    label.isAccessibilityElement = NO;
    return label;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([(DHAppDelegate*)[[UIApplication sharedApplication] delegate] internetReach].currentReachabilityStatus == NotReachable) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"No Internet", nil) message:NSLocalizedString(@"You don't have connection to the internet.", nil) buttonTitle:@"OK"];
        [self.refreshControl endRefreshing];
        return;
    }
    
    self.mutableUserConnectionArray = [NSMutableArray array];
    
    self.channelsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    
//    if (!self.dataSource) {
//        self.dataSource = [self.channelsArray copy];
//    }
//    dhDebug(@"self.channelsArray: %@", self.channelsArray);
    NSMutableArray *mutablePmArray = [NSMutableArray array];
    NSMutableArray *mutablePatterArray = [NSMutableArray array];
    NSInteger numberOfUnreadChannels = 0;
    NSInteger numberOfUnreadPatter = 0;
    for (NSDictionary *channelsDict in self.channelsArray) {
        if ([[DHGlobalObjects sharedGlobalObjects].mutedChannels containsObject:[channelsDict objectForKey:@"id"]]) {
            continue;
        }
        NSDictionary *recentMessageDict = [channelsDict objectForKey:@"recent_message"];
        NSString *channelTitle = [[recentMessageDict objectForKey:@"user"] objectForKey:@"username"];
        BOOL isPatter = NO;
        if ([[channelsDict objectForKey:@"annotations"] count]) {
            for (NSDictionary *annotationDict in [channelsDict objectForKey:@"annotations"]) {
                if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.patter-app.settings"]) {
                    channelTitle = [NSString stringWithFormat:@"%@ (via patter)", [[annotationDict objectForKey:@"value"] objectForKey:@"name"]];
                    isPatter = YES;
                    break;
                }
            }
        }
        if (isPatter) {
            if ([[channelsDict objectForKey:@"has_unread"] boolValue] && ![[NSUserDefaults standardUserDefaults] boolForKey:kIgnoreUnreadPatter]) {
                numberOfUnreadPatter++;
            }
            [mutablePatterArray addObject:channelsDict];
        } else {
            if ([[channelsDict objectForKey:@"has_unread"] boolValue]) {
                numberOfUnreadChannels++;
            }
            [mutablePmArray addObject:channelsDict];
        }
    }
    
    if (numberOfUnreadChannels+numberOfUnreadPatter) {
        [(UITabBarItem*)[self.navigationController.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d+%d", numberOfUnreadChannels, numberOfUnreadPatter]];
//        [DHGlobalObjects sharedGlobalObjects].unreadMessages = unreadMessages;
//        [DHGlobalObjects sharedGlobalObjects].unreadPatter = unreadPatter;
        UIColor *textColor;
        UIColor *messagesColor;
        UIColor *patterColor;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            messagesColor = numberOfUnreadChannels ? kDarkMarkerColor : kDarkTextColor;
//            patterColor = numberOfUnreadPatter ? kDarkMarkerColor : kDarkTextColor;
//            textColor = kDarkTextColor;
            messagesColor = numberOfUnreadChannels ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
            patterColor = numberOfUnreadPatter ? [DHGlobalObjects sharedGlobalObjects].darkMarkerColor : [DHGlobalObjects sharedGlobalObjects].darkTintColor;
            textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
        } else {
            messagesColor = numberOfUnreadChannels ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
            patterColor = numberOfUnreadPatter ? [DHGlobalObjects sharedGlobalObjects].markerColor : [DHGlobalObjects sharedGlobalObjects].tintColor;
            textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
        }
        [self.menuButton setImage:[ImageHelper menueWithStreamColor:textColor mentionColor:textColor messagesColor:messagesColor patterColor:patterColor] forState:UIControlStateNormal];
    } else {
        [(UITabBarItem*)[self.navigationController.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
    }
     [[NSNotificationCenter defaultCenter] postNotificationName:kNumberOfUnreadMessagesNotification object:self userInfo:@{@"unreadMessages": [NSNumber numberWithInteger:numberOfUnreadChannels], @"unreadPatter": [NSNumber numberWithInteger:numberOfUnreadPatter]}];
    
    self.pmArray = [mutablePmArray copy];
    self.patterArray = [mutablePatterArray copy];
    
    if (self.startPageNumber) {
        self.titleScrollView.contentOffset = CGPointMake(self.titleScrollView.frame.size.width, 0.0f);
        self.pageControl.currentPage = [self.startPageNumber integerValue];
    } else if (self.pageControl.currentPage) {
        self.titleScrollView.contentOffset = CGPointMake(self.titleScrollView.frame.size.width, 0.0f);
    } else {
        self.titleScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    }
    [self changeSource:self.pageControl.currentPage];
    
    self.isLoading = YES;

//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
    NSString *channelType = [_startPageNumber isEqualToNumber:@1] ? @"net.patter-app.room" : @"net.app.core.pm";
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@channels?include_annotations=1&include_recent_message=1&channel_types=%@&count=200&", kBaseURL, channelType];

    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
    
    NSMutableURLRequest *channelRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
    [channelRequest setHTTPMethod:@"GET"];
    [channelRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [_channelsDataSession cancel];
    for (PRPConnection *connection in self.mutableUserConnectionArray) {
        [connection stop];
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *channelSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    __weak DHChannelsViewController *weakSelf = self;
    _channelsDataSession = [channelSession dataTaskWithRequest:channelRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error.code == -999) {
            return;
        }
//        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
//        dhDebug(@"responseDict: %@", responseDict);
        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
//        dhDebug(@"metaDict %@", metaDict);
        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
        weakSelf.channelsArray = [responseDict objectForKey:@"data"];
        dhDebug(@"self.channelsArray.count: %d", weakSelf.channelsArray.count);
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateChannelsArray object:weakSelf userInfo:@{@"channelsArray" : weakSelf.channelsArray}];
        
        NSMutableArray *mutablePmArray = [NSMutableArray array];
        NSMutableArray *mutablePatterArray = [NSMutableArray array];
        NSInteger numberOfUnreadChannels = 0;
        NSInteger numberOfUnreadPatter = 0;
        NSMutableSet *mutableSubscripedChannelsSet = [NSMutableSet set];
        NSMutableArray *mutableChannelsArray = [NSMutableArray array];
        for (NSDictionary *channelsDict in weakSelf.channelsArray) {
//            NSLog(@"channelsDict type: %@", channelsDict[@"type"]);
            [mutableChannelsArray addObject:channelsDict];
            
            [mutableSubscripedChannelsSet addObject:[channelsDict objectForKey:@"id"]];
           
//            NSDictionary *recentMessageDict = [channelsDict objectForKey:@"recent_message"];
//            NSString *channelTitle = [[recentMessageDict objectForKey:@"user"] objectForKey:@"username"];
            BOOL isPatter = NO;
            if ([[channelsDict objectForKey:@"annotations"] count]) {
                for (NSDictionary *annotationDict in [channelsDict objectForKey:@"annotations"]) {
                    if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.patter-app.settings"]) {
                        isPatter = YES;
                        break;
                    }
                }
            }
            
            if (isPatter) {
                if ([[channelsDict objectForKey:@"has_unread"] boolValue] && ![[NSUserDefaults standardUserDefaults] boolForKey:kIgnoreUnreadPatter]) {
                    numberOfUnreadPatter++;
                }
                [mutablePatterArray addObject:channelsDict];
            } else {
                if ([[channelsDict objectForKey:@"has_unread"] boolValue]) {
                    numberOfUnreadChannels++;
                }
                [mutablePmArray addObject:channelsDict];
            }
        }
        weakSelf.channelsArray = [mutableChannelsArray copy];
        
        [DHGlobalObjects sharedGlobalObjects].subscribedChannels = [mutableSubscripedChannelsSet copy];
        [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPrivateMessages = numberOfUnreadChannels;
        [DHGlobalObjects sharedGlobalObjects].numberOfUnreadPatter = numberOfUnreadPatter;
        
        if (numberOfUnreadChannels+numberOfUnreadPatter) {
            [(UITabBarItem*)[weakSelf.navigationController.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d+%d", numberOfUnreadChannels, numberOfUnreadPatter]];
        } else {
            [(UITabBarItem*)[weakSelf.navigationController.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNumberOfUnreadMessagesNotification object:weakSelf userInfo:@{@"unreadMessages": [NSNumber numberWithInteger:numberOfUnreadChannels], @"unreadPatter": [NSNumber numberWithInteger:numberOfUnreadPatter]}];

        weakSelf.pmArray = [mutablePmArray copy];
        weakSelf.patterArray = [mutablePatterArray copy];
        
        [weakSelf changeSource:weakSelf.pageControl.currentPage];
        [NSKeyedArchiver archiveRootObject:weakSelf.channelsArray toFile:[weakSelf archivePath]];
        [weakSelf.tableView reloadData];
        
//        NSMutableArray *mutablePmArray2 = [NSMutableArray array];
//        NSMutableArray *mutablePatterArray2 = [NSMutableArray array];
        for (NSDictionary *channelsDict in weakSelf.channelsArray) {
            if ([weakSelf.otherUsersDict objectForKey:[channelsDict objectForKey:@"id"]]) {
                continue;
            }
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@channels/%@/subscribers?", kBaseURL, [channelsDict objectForKey:@"id"]];
            
            NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
            
            NSMutableURLRequest *usersRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
            [usersRequest setHTTPMethod:@"GET"];
            [usersRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            
            PRPConnection *usersConnection = [PRPConnection connectionWithRequest:usersRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//            [PRPConnection connectionWithRequest:channelRequest progress:^(PRPConnection* connection){} completion:^(PRPConnection *connection, NSError *error) {
            
//            NSURLSession *usersSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
//
//            NSURLSessionDataTask *usersDataTask = [usersSession dataTaskWithRequest:usersRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
                NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//                NSError *jsonError = nil;
//                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                
//                dhDebug(@"responseDict: %@", responseDict);
//                NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
//                dhDebug(@"metaDict %@", metaDict);
                if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
//                    [DHAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                    return;
                }
                
                NSArray *userIdArray = [responseDict objectForKey:@"data"];
                
//                NSMutableDictionary *mutableChannelsDict = [[NSMutableDictionary alloc] initWithDictionary:channelsDict];
//                [mutableChannelsDict setObject:userIdArray forKey:@"otherUsers"];
                
                [weakSelf.otherUsersDict setObject:userIdArray forKey:[channelsDict objectForKey:@"id"]];
                
//                dhDebug(@"**************************************");
                for (NSDictionary *userDict in userIdArray) {
//                    dhDebug(@"username: %@, you_can_subscribe: %@", [userDict objectForKey:@"username"], [userDict objectForKey:@"you_can_subscribe"]);
                    if ([[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey] isEqualToString:[userDict objectForKey:@"username"]]) {
                        continue;
                    }
                    if (![[userDict objectForKey:@"you_can_subscribe"] boolValue]) {
                        [weakSelf.problemChannels setObject:@YES forKey:[channelsDict objectForKey:@"id"]];
                        break;
                    }
                }
//                BOOL isPatter = NO;
//                if ([[channelsDict objectForKey:@"annotations"] count]) {
//                    for (NSDictionary *annotationDict in [channelsDict objectForKey:@"annotations"]) {
//                        if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.patter-app.settings"]) {
//                            isPatter = YES;
//                            break;
//                        }
//                    }
//                }
//                if (isPatter) {
//                    [mutablePatterArray2 addObject:[mutableChannelsDict copy]];
//                } else {
//                    [mutablePmArray2 addObject:[mutableChannelsDict copy]];
//                }
//                
//                if ([mutablePmArray2 count] == [mutablePmArray count]) {
//                    self.pmArray = [mutablePmArray2 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                        NSDate *date1 = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[[obj1 objectForKey:@"recent_message"] objectForKey:@"created_at"]];
//                        NSDate *date2 = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[[obj2 objectForKey:@"recent_message"] objectForKey:@"created_at"]];
//                        return [date2 compare:date1];
//                    }];
//                    
//                    [self changeSource:self.pageControl.currentPage];
//                    [NSKeyedArchiver archiveRootObject:self.channelsArray toFile:[self archivePath]];
//                    [self.tableView reloadData];
//                }
//                if ([mutablePatterArray2 count] == [mutablePatterArray count]) {
//                    self.patterArray = [mutablePatterArray2 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                        NSDate *date1 = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[[obj1 objectForKey:@"recent_message"] objectForKey:@"created_at"]];
//                        NSDate *date2 = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[[obj2 objectForKey:@"recent_message"] objectForKey:@"created_at"]];
//                        return [date2 compare:date1];
//                    }];
            
                    [weakSelf changeSource:weakSelf.pageControl.currentPage];
//                    [NSKeyedArchiver archiveRootObject:self.channelsArray toFile:[self archivePath]];
                    [weakSelf.tableView reloadData];
//                }

            }];
            [self.mutableUserConnectionArray addObject:usersConnection];
            [usersConnection start];
//            [self.mutableSessionArray addObject:usersDataTask];
//            [usersDataTask resume];
        }
    }];
//    [_channelsConnection start];
    [_channelsDataSession resume];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        [self.navigationController.navigationBar setTintColor:kDarkMainColor];
//        self.view.backgroundColor = kDarkCellBackgroundColorDefault;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
        }
        else
        {
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
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
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
        }
        self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
    }

    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftHappend:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightRecognizer];
    
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHappend:)];
//    [self.view addGestureRecognizer:panGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDarkMode:)];
    [self.navigationController.navigationBar addGestureRecognizer:longPressRecognizer];

    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
    [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
    self.menuButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self.channelsConnection stop];
//    for (DHConnection *connection in self.mutableUserConnectionArray) {
//        [connection stop];
//    }
    
    [_channelsDataSession cancel];
    for (PRPConnection *connection in _mutableUserConnectionArray) {
        [connection stop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menuButtonTouched:(UIBarButtonItem*)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuTouchedNotification object:self];
}

//- (BOOL)shouldAutorotate {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return YES;
//    }
//    return NO;
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChannelCell";
    DHChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (indexPath.row >= [self.dataSource count]) {
        return cell;
    }
    NSDictionary *channelsDict = [self.dataSource objectAtIndex:indexPath.row];
//    dhDebug(@"channelsDict: %@", channelsDict);
    NSDictionary *recentMessageDict = [channelsDict objectForKey:@"recent_message"];
    NSDictionary *userDict = [recentMessageDict objectForKey:@"user"];
    
    NSDictionary *otherUserDict = userDict;
    NSMutableString *mutableUsersString = [NSMutableString stringWithString:@"users: "];
    NSArray *otherUsersArray = [self.otherUsersDict objectForKey:[channelsDict objectForKey:@"id"]];
    for (NSDictionary *userDict in otherUsersArray) {
        [mutableUsersString appendFormat:@"%@ ", [userDict objectForKey:@"username"]];
        if (![[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey] isEqualToString:[userDict objectForKey:@"username"]]) {
            otherUserDict = userDict;
        }
    }
    cell.usersLabel.text = mutableUsersString;
    
    if ([otherUsersArray count] == 2) {
        userDict = otherUserDict;
    }
    
    NSString *channelTitle = [userDict objectForKey:@"username"];
    BOOL isPatter = NO;
    if ([[channelsDict objectForKey:@"annotations"] count]) {
        for (NSDictionary *annotationDict in [channelsDict objectForKey:@"annotations"]) {
            if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.patter-app.settings"]) {
                channelTitle = [NSString stringWithFormat:@"%@ (via patter)", [[annotationDict objectForKey:@"value"] objectForKey:@"name"]];
                isPatter = YES;
                break;
            }
        }
    }
    
    __weak DHChannelsViewController *weakSelf = self;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDontLoadImages]) {
        NSDictionary *avatarImageDictionary = [userDict objectForKey:@"avatar_image"];
        dispatch_queue_t avatarDownloaderQueue = dispatch_queue_create("de.dasdom.avatarDownloader", NULL);
        dispatch_async(avatarDownloaderQueue, ^{
            NSString *avatarUrlString = [avatarImageDictionary objectForKey:@"url"];
            CGFloat width = [[avatarImageDictionary objectForKey:@"width"] floatValue];
            //            dhDebug(@"width: %f", width);
            NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
            NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
            UIImage *avatarImage = [imageCache objectForKey:imageKey];
            if (!avatarImage && width < 2000.0f) {
                avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:35.0f/width];
                //                UIImage *dummyImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:56.0f/width];
                //                avatarImage = [UIImage imageWithData:UIImageJPEGRepresentation(dummyImage, 0.1f)];
                
                if (avatarImage) {
                    [imageCache setObject:avatarImage forKey:imageKey];
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                id asyncCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
                if ([asyncCell isKindOfClass:([DHChannelCell class])]) {
                    [[asyncCell avatarImageView] setImage:avatarImage];
                }
            });
        });
    } else {
        CGFloat blueFloat = (CGFloat)([[userDict objectForKey:@"id"] integerValue]%100)/100.0f;
        CGFloat greenFloat = (CGFloat)(([[userDict objectForKey:@"id"] integerValue]/100)%100)/100.0f;
        CGFloat redFloat = (CGFloat)(([[userDict objectForKey:@"id"] integerValue]/10000)%100)/100.0f;
        //        dispatch_sync(dispatch_get_main_queue(), ^{
        cell.avatarImageView.backgroundColor = [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
        //        });
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        cell.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//        cell.userNameLabel.textColor = kDarkTextColor;
//        cell.dateLabel.textColor = kDarkTextColor;
//        cell.previewLabel.textColor = kDarkTextColor;
//        cell.usersLabel.textColor = kDarkTextColor;
//        cell.customSeparatorView.backgroundColor = kDarkSeparatorColor;
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        cell.userNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.dateLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.previewLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.usersLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        cell.customSeparatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkSeparatorColor;
    } else {
        cell.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        cell.userNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.dateLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.previewLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.usersLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        cell.customSeparatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].separatorColor;
    }
    
    if ([[self.problemChannels objectForKey:[channelsDict objectForKey:@"id"]] boolValue] && !isPatter) {
        UIColor *errorColor = [UIColor redColor];
        cell.userNameLabel.textColor = errorColor;
        cell.dateLabel.textColor = errorColor;
        cell.previewLabel.textColor = errorColor;
        cell.usersLabel.textColor = errorColor;
    }
//    NSMutableString *channelTitle = [[[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"username"] mutableCopy];
//    if ([[[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"channelType"] isEqualToString:@"patter"]) {
//        [channelTitle appendFormat:@" (via patter)"];
//    }
    cell.userNameLabel.text = channelTitle;
    cell.previewLabel.text = [recentMessageDict objectForKey:@"text"];
    CGSize previewLabelSize = [cell.previewLabel.text sizeWithFont:cell.previewLabel.font constrainedToSize:CGSizeMake(228.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect previewLabelFrame = cell.previewLabel.frame;
    previewLabelFrame.size.height = MIN(previewLabelSize.height, 35.0f);
    cell.previewLabel.frame = previewLabelFrame;
    
    NSDate *date = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[recentMessageDict objectForKey:@"created_at"]];
    CGFloat secondsSincePost = -[date timeIntervalSinceNow];
    NSString *timeSincePostString;
//    NSMutableString *accessibilityString = [postCell.nameLabel.text mutableCopy];
    if (secondsSincePost < 60.0f) {
        timeSincePostString = @"now";
//        [accessibilityString appendString:@" posted now"];
    } else if (secondsSincePost < 3600.0f) {
        timeSincePostString = [NSString stringWithFormat:@"%dm", (int)secondsSincePost/60];
//        [accessibilityString appendFormat:@" posted %d minutes ago", (int)secondsSincePost/60];
    } else if (secondsSincePost < 86400.0f) {
        timeSincePostString = [NSString stringWithFormat:@"%dh", (int)secondsSincePost/3600];
//        [accessibilityString appendFormat:@" posted %d hours ago", (int)secondsSincePost/3600];
    } else {
        timeSincePostString = [NSString stringWithFormat:@"%dd", (int)secondsSincePost/86400];
//        [accessibilityString appendFormat:@" posted %d days ago", (int)secondsSincePost/86400];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAboluteTimeStamp]) {
        cell.dateLabel.text = [self.dateFormatter stringFromDate:date];
    } else {
        cell.dateLabel.text = timeSincePostString;
    }

    if ([[[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"has_unread"] boolValue]) {
        cell.indicatorImageView.image = [UIImage imageNamed:@"newMessagesIcon"];
    } else {
        cell.indicatorImageView.image = nil;
    }
    
    cell.customSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHappend:)];
    [cell addGestureRecognizer:longPressRecognizer];
    
    return cell;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowMessages"]) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideMenuNotification object:nil];
        }
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DHMessagesTableViewController *messagesTableViewController = segue.destinationViewController;
        [messagesTableViewController setValue:[[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"id"] forKey:@"channelId"];
//        if ([[[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"channelType"] isEqualToString:@"patter"]) {
//            [segue.destinationViewController setValue:[[self.dataSource objectAtIndex:indexPath.row] objectForKey:@"username"] forKey:@"channelName"];
//        }
        NSDictionary *channelsDict = [self.dataSource objectAtIndex:indexPath.row];
        dhDebug(@"channelsDict: %@", channelsDict);
        NSDictionary *recentMessageDict = [channelsDict objectForKey:@"recent_message"];
        NSDictionary *userDict = [recentMessageDict objectForKey:@"user"];
        NSString *channelTitle = [userDict objectForKey:@"username"];
        BOOL isPatter = NO;
        if ([[channelsDict objectForKey:@"annotations"] count]) {
            for (NSDictionary *annotationDict in [channelsDict objectForKey:@"annotations"]) {
                if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.patter-app.settings"]) {
                    channelTitle = [NSString stringWithFormat:@"%@ (via patter)", [[annotationDict objectForKey:@"value"] objectForKey:@"name"]];
                    isPatter = YES;
                    break;
                }
            }
        }
        [messagesTableViewController setValue:channelTitle forKey:@"channelName"];
        messagesTableViewController.isPatter = isPatter;
    } else if ([segue.identifier isEqualToString:@"CreateChannel"]) {
        DHCreateStatusViewController *createStatusViewController = ((UINavigationController*)segue.destinationViewController).viewControllers[0];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ((UIViewController*)segue.destinationViewController).modalPresentationStyle = UIModalPresentationFormSheet;
            ((UIViewController*)segue.destinationViewController).view.accessibilityViewIsModal = YES;
        }
        createStatusViewController.isPrivateMessage = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag != 1001) {
        return;
    }
    NSInteger index = (NSInteger)(scrollView.contentOffset.x/scrollView.frame.size.width);
    self.pageControl.currentPage = index;
    [self changeSource:index];
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    if (direction == UIAccessibilityScrollDirectionLeft) {
        if (self.pageControl.currentPage == self.pageControl.numberOfPages-1) {
            self.pageControl.currentPage = 0;
        } else {
            self.pageControl.currentPage = self.pageControl.currentPage+1;
        }
    } else if (direction == UIAccessibilityScrollDirectionRight) {
        if (self.pageControl.currentPage == 0) {
            self.pageControl.currentPage = self.pageControl.numberOfPages-1;
        } else {
            self.pageControl.currentPage = self.pageControl.currentPage-1;
        }
    } else {
        return NO;
    }
    [self changeSource:self.pageControl.currentPage];
    
    NSString *messageString;
    if (self.pageControl.currentPage == 0) {
        messageString = [NSString stringWithFormat:NSLocalizedString(@"page %d of %d, %@", nil), self.pageControl.currentPage+1, self.pageControl.numberOfPages, NSLocalizedString(@"pm", nil)];
    } else {
        messageString = [NSString stringWithFormat:NSLocalizedString(@"page %d of %d, %@", nil), self.pageControl.currentPage+1, self.pageControl.numberOfPages, NSLocalizedString(@"patter", nil)];
    }
    UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, messageString);
    return YES;
}

- (void)changeSource:(NSInteger)index {
    if (index == 0) {
        self.dataSource = self.pmArray;
//        self.navigationItem.leftBarButtonItem = nil;
    } else {
        self.dataSource = self.patterArray;
        UIBarButtonItem *patterChannelsBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"patter-app.net", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(showPatterChannels:)];
        self.navigationItem.rightBarButtonItem = patterChannelsBarButton;
    }
    [self.tableView reloadData];
}

- (void)toggleDarkMode:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults boolForKey:kDarkMode]) {
            [userDefaults setBool:NO forKey:kDarkMode];
            self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
            [self.tabBarController.tabBar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
            if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
            {
                [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
                [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].textColor];
            }
            else
            {
                [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
            }
            [self.navigationController.toolbar setTintColor:[DHGlobalObjects sharedGlobalObjects].textColor];
            self.tableView.tableFooterView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
            self.refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        } else {
            [userDefaults setBool:YES forKey:kDarkMode];
//            self.view.backgroundColor = kDarkCellBackgroundColorDefault;
//            [self.tabBarController.tabBar setTintColor:kDarkMainColor];
//            [self.navigationController.navigationBar setTintColor:kDarkMainColor];
//            [self.navigationController.toolbar setTintColor:kDarkTextColor];
//            self.tableView.tableFooterView.backgroundColor = kDarkCellBackgroundColorDefault;
//            self.refreshControl.tintColor = kDarkMainColor;
            self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
            [self.tabBarController.tabBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
            if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
            {
                [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
                [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
            }
            else
            {
                [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
            }
            [self.navigationController.toolbar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
            self.tableView.tableFooterView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
            self.refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        }
        [userDefaults synchronize];
        [self.tableView reloadData];
        [self.view setNeedsDisplay];
        
        NSArray *viewControllers = self.splitViewController.viewControllers;
        if ([viewControllers count]) {
            [((UINavigationController*)[viewControllers objectAtIndex:0]).visibleViewController performSelector:@selector(setColors)];
        }
    }
}


- (NSString*)archivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:NSStringFromClass([self class])];
}

- (void)swipeRightHappend:(UISwipeGestureRecognizer*)sender {
//    [UIView animateWithDuration:0.25f animations:^{
//        self.titleScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
//    } completion:^(BOOL finished) {
//        self.pageControl.currentPage = 0;
//        [self changeSource:0];
//    }];
   
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.navigationController.view.frame.origin.x < 30) {
        [self menuButtonTouched:nil];
    }
}

- (void)swipeLeftHappend:(UISwipeGestureRecognizer*)sender {
//    [UIView animateWithDuration:0.25f animations:^{
//        self.titleScrollView.contentOffset = CGPointMake(self.titleScrollView.frame.size.width, 0.0f);
//    } completion:^(BOOL finished) {
//        self.pageControl.currentPage = 1;
//        [self changeSource:1];
//    }];
    
    if (self.navigationController.view.frame.origin.x > 30) {
        [self menuButtonTouched:nil];
        return;
    }
}

//- (void)panHappend:(UIPanGestureRecognizer*)sender {
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        self.startOffsetX = self.titleScrollView.contentOffset.x;
//    } else if (sender.state == UIGestureRecognizerStateChanged) {
//        self.titleScrollView.contentOffset = CGPointMake(self.startOffsetX-([sender translationInView:self.view].x*1.5f), 0.0f);
//    } else {
//        if (self.titleScrollView.contentOffset.x < self.titleScrollView.frame.size.width/2.0f) {
//            [self.titleScrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
//            self.pageControl.currentPage = 0;
//            [self changeSource:0];
//        } else {
//            [self.titleScrollView setContentOffset:CGPointMake(self.titleScrollView.frame.size.width, 0.0f) animated:YES];
//            self.pageControl.currentPage = 1;
//            [self changeSource:1];
//        }
//    }
//}

- (void)showPatterChannels:(UIBarButtonItem*)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    DHWebViewController *webViewController = [storyBoard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.linkString = @"http://patter-app.net";
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)longPressHappend:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender.view];
        NSDictionary *channelsDict = [self.dataSource objectAtIndex:indexPath.row];
        dhDebug(@"channelsDict: %@", channelsDict);
        
        NSString *channelActionName;
        NSNumber *channelIsMuted;
        if ([[DHGlobalObjects sharedGlobalObjects].mutedChannels containsObject:[channelsDict objectForKey:@"id"]]) {
            channelActionName = NSLocalizedString(@"show new messages", nil);
            channelIsMuted = @YES;
        } else {
            channelActionName = NSLocalizedString(@"ignore new messages", nil);
            channelIsMuted = @NO;
        }
        DHActionSheet *actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:channelActionName, nil];
        actionSheet.tag = 101;
        actionSheet.userInfo = @{@"channelsDict": channelsDict, @"channelIsMuted": channelIsMuted};
        [actionSheet showInView:self.view];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    dhDebug(@"buttonIndex: %d", buttonIndex);
    if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
            NSDictionary *channelsDict = [((DHActionSheet*)actionSheet).userInfo objectForKey:@"channelsDict"];
            NSMutableSet *mutabelSet = [[DHGlobalObjects sharedGlobalObjects].mutedChannels mutableCopy];
            if ([[((DHActionSheet*)actionSheet).userInfo objectForKey:@"channelIsMuted"] boolValue]) {
                [mutabelSet removeObject:[channelsDict objectForKey:@"id"]];
            } else {
                [mutabelSet addObject:[channelsDict objectForKey:@"id"]];
            }
            [DHGlobalObjects sharedGlobalObjects].mutedChannels = mutabelSet;
        } else if (buttonIndex == 1) {
            
        }
    }
}

//- (void)updateWithMessageId:(NSString*)messageId {
//    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
//    
//    
//    NSString *urlString = [NSString stringWithFormat:@"%@posts/marker", kBaseURL];
//    
//    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//    [postRequest setHTTPMethod:@"POST"];
//    
//    NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
//    [postRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
//    [postRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    
//    NSDictionary *postDict = @{@"name" : [self.markerDict objectForKey:@"name"], @"last_read_id" : [NSNumber numberWithInteger:newestPostId], @"id": [NSNumber numberWithInteger:topMostPostId]};
//    
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil];
//    [postRequest setHTTPBody:postData];
//    
//    DHConnection *dhConnection = [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//        dhDebug(@"error: %@", error);
//        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        //            NSLog(@"responseDict: %@", responseDict);
//        
//        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
//        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
//            dhDebug(@"Could not update the marker");
//            if ([[metaDict objectForKey:@"code"] integerValue] == 429) {
//                self.retryMarkerAfter = [NSDate dateWithTimeIntervalSinceNow:[[connection.responseHeaders objectForKey:@"Retry-After"] integerValue]];
//            }
//        } else {
//            self.markerDict = [responseDict objectForKey:@"data"];
//        }
//        self.isUpdatingMarker = NO;
//    }];
//    
//    [dhConnection start];
//}

@end
