//
//  DHStreamDetailTableViewController.m
//  Appetizr
//
//  Created by dasdom on 18.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHStreamDetailTableViewController.h"
#import "DHPostCell.h"
#import "PRPAlertView.h"
#import "DHWebViewController.h"
#import "DHControllCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SSKeychain.h"
#import "DHAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "NSString+ANAPIRangeAdapter.h"
#import "ImageHelper.h"

@interface DHStreamDetailTableViewController () <MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *replyToArray;
@property (nonatomic, strong) NSMutableArray *replyArray;
@property (nonatomic, strong) NSDateFormatter *iso8601DateFormatter;
@property (nonatomic, strong) NSIndexPath *toHighlightIndexPath;
//@property (nonatomic, strong) NSIndexPath *highlightedIndexPath;
@property (nonatomic, strong) NSIndexPath *answerIndexPath;
@end

@implementation DHStreamDetailTableViewController

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
//    _replyArray = [NSMutableArray array];
//    _replyToArray = [NSMutableArray array];
//     NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
//    
//    NSString *urlString;
//    if (self.postDictionary) {
//        urlString = [NSString stringWithFormat:@"%@%@%@/replies?count=200&include_post_annotations=1&access_token=%@", kBaseURL, kPostsSubURL, [self.postDictionary objectForKey:@"id"], accessToken];
//    } else {
//        urlString = [NSString stringWithFormat:@"%@%@%@/replies?count=200&include_post_annotations=1&access_token=%@", kBaseURL, kPostsSubURL, self.postId, accessToken];
//    }
//    NSMutableURLRequest *conversationRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//    [conversationRequest setHTTPMethod:@"GET"];
//    [conversationRequest setValue:@"Accept-Encoding" forHTTPHeaderField:@"gzip"];
//
//    DHConnection *dhConnection = [DHConnection connectionWithRequest:conversationRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//       
//        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
////        NSLog(@"responseDict: %@", responseDict);
//        if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
//            [DHAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
//            return;
//        }
//        
//        id theArray = [responseDict objectForKey:@"data"];
//        if (![theArray isKindOfClass:[NSArray class]]) {
////            NSLog(@"theArray is not an array");
//            return;
//        }
//        
//        BOOL isBeforePost = YES;
//        for (NSDictionary *postDict in theArray) {
////            dhDebug(@"postDict text: %@", [postDict objectForKey:@"text"]);
//            if ([[postDict objectForKey:@"id"] isEqualToString:[self.postDictionary objectForKey:@"id"]]) {
//                isBeforePost = NO;
//                continue;
//            } else if ([self.postId isEqualToString:[postDict objectForKey:@"id"]]) {
//                isBeforePost = NO;
//                self.postDictionary = postDict;
//                continue;
//            }
//            if (isBeforePost) {
//                [_replyArray addObject:postDict];
//            } else {
//                [_replyToArray addObject:postDict];
//            }
//        }
//        
//        [self.tableView reloadData];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//
//    }];
//    [dhConnection start];
    
    _iso8601DateFormatter = [[NSDateFormatter alloc] init];
    _iso8601DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    _iso8601DateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    self.toHighlightIndexPath = nil;
//    self.highlightedIndexPath = nil;
    self.controlIndexPath = nil;
    self.answerIndexPath = nil;
    
    [self loadPosts:nil];
}

//- (void)loadPostWithId:(NSString*)postId {
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
//    NSString *urlString = [NSString stringWithFormat:@"%@%@%@?access_token=%@", kBaseURL, kPostsSubURL, postId, accessToken];
//    dhDebug(@"urlString: %@", urlString);
//    DHConnection *dhConnection = [DHConnection connectionWithURL:[NSURL URLWithString:urlString] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//        NSDictionary *dict = [connection dictionaryFromDownloadedData];
//        [self.replyToArray addObject:dict];
//        
//        NSString *replay_to = [dict objectForKey:@"reply_to"];
//        if (replay_to) {
//            [self loadPostWithId:replay_to];
//        } else {
//            [self.tableView reloadData];
//        }
//    }];
//    [dhConnection start];
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        self.view.backgroundColor = kDarkCellBackgroundColorDefault;
        self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
    } else {
        self.view.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
    }
    
//    dhDebug(@"[self.navigationController.viewControllers count]: %d", [self.navigationController.viewControllers count]);
    if ([self.navigationController.viewControllers count] < 2) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
    
    UIBarButtonItem *actionBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
    self.navigationItem.rightBarButtonItem = actionBarButton;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"loading new posts", nil)];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        //        refreshControl.tintColor = kDarkMainColor;
        refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        refreshControl.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
    } else {
        refreshControl.tintColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        refreshControl.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
    }
    [refreshControl addTarget:self action:@selector(loadPosts:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadPosts:(id)sender
{
    _replyArray = [NSMutableArray array];
    _replyToArray = [NSMutableArray array];
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSString *urlString;
    if (self.postDictionary) {
        urlString = [NSString stringWithFormat:@"%@%@%@/replies?count=200&include_post_annotations=1&access_token=%@", kBaseURL, kPostsSubURL, [self.postDictionary objectForKey:@"id"], accessToken];
    } else {
        urlString = [NSString stringWithFormat:@"%@%@%@/replies?count=200&include_post_annotations=1&access_token=%@", kBaseURL, kPostsSubURL, self.postId, accessToken];
    }
    NSMutableURLRequest *conversationRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [conversationRequest setHTTPMethod:@"GET"];
    [conversationRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:conversationRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:conversationRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
    
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
        if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
        
        id theArray = [responseDict objectForKey:@"data"];
        if (![theArray isKindOfClass:[NSArray class]]) {
            //            NSLog(@"theArray is not an array");
            return;
        }
        
        BOOL isBeforePost = YES;
        NSMutableArray *indexPathsArray = [NSMutableArray array];
        if (!self.postDictionary) {
            [indexPathsArray addObject:[NSIndexPath indexPathForRow:0 inSection:1]];
        }
        int i = 0;
        int j = 0;
        for (NSDictionary *postDict in theArray) {
            //            dhDebug(@"postDict text: %@", [postDict objectForKey:@"text"]);
            if ([[postDict objectForKey:@"id"] isEqualToString:[self.postDictionary objectForKey:@"id"]]) {
                isBeforePost = NO;
                continue;
            } else if ([self.postId isEqualToString:[postDict objectForKey:@"id"]]) {
                isBeforePost = NO;
                self.postDictionary = postDict;
                continue;
            }
            if (isBeforePost) {
                [_replyArray addObject:postDict];
                [indexPathsArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                i++;
            } else {
                [_replyToArray addObject:postDict];
                [indexPathsArray addObject:[NSIndexPath indexPathForRow:j inSection:2]];
                j++;
            }
        }
//        [self.tableView beginUpdates];
//        [self.tableView insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView endUpdates];
        [self.tableView reloadData];
        if (!sender) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } else {
            [(UIRefreshControl*)sender endRefreshing];
        }
    }];
    [dhConnection start];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = [self.replyArray count];
            break;
        case 1:
            numberOfRows = self.postDictionary ? 1 : 0;
            break;
        case 2:
            numberOfRows = [self.replyToArray count];
            break;
        default:
            break;
    }
//    if (self.controlIndexPath && section == self.controlIndexPath.section) {
//        numberOfRows++;
//    }
    return numberOfRows;
}

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
    headerLabel.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:kFontName] size:13.0f];
    switch (section) {
        case 0:
            headerLabel.text = NSLocalizedString(@"replies", nil);
            break;
        case 1:
            headerLabel.text = NSLocalizedString(@"post", nil);
            break;
        case 2:
            headerLabel.text = NSLocalizedString(@"in reply to", nil);
            break;
            
        default:
            break;
    }
    return headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 20.0f;
    switch (section) {
        case 0:
            headerHeight = [self.replyArray count] == 0 ? 0 : 20.0f;
            break;
        case 1:
            headerHeight = 20.0f;
            break;
        case 2:
            headerHeight = [self.replyToArray count] == 0 ? 0 : 20.0f;
            break;
        default:
            break;
    }

    return headerHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.controlIndexPath && [indexPath isEqual: self.controlIndexPath]) {
//        DHControllCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ControllCell"];
//        [cell.profileButton addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.repostButton addTarget:self action:@selector(repostPost:) forControlEvents:UIControlEventTouchUpInside];
////        [cell.conversationButton addTarget:self action:@selector(showConversation:) forControlEvents:UIControlEventTouchUpInside];
//        cell.conversationButton.hidden = YES;
//        [cell.starButton addTarget:self action:@selector(starPost:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.replyButton addTarget:self action:@selector(replyOnPost:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.metaDataButton addTarget:self action:@selector(showMetaData:) forControlEvents:UIControlEventTouchUpInside];
//
//        NSDictionary *postDict;
//        switch (indexPath.section) {
//            case 0:
//                postDict = [self.replyArray objectAtIndex:indexPath.row-1];
//                break;
//            case 1:
//                postDict = self.postDictionary;
//                break;
//            case 2:
//                postDict = [self.replyToArray objectAtIndex:indexPath.row-1];
//                break;
//            default:
//                NSAssert(false, @"unsupported indexPath.section");
//                break;
//        }
//
////        dhDebug(@"postDict %@", postDict);
////        if ([[postDict objectForKey:@"you_starred"] boolValue]) {
////            [cell.starButton setImage:[UIImage imageNamed:@"starredIcon2"] forState:UIControlStateNormal];
////            [cell.starButton setImage:[UIImage imageNamed:@"starredIconSelected2"] forState:UIControlStateHighlighted];
////        } else {
////            [cell.starButton setImage:[UIImage imageNamed:@"unstarredIcon2"] forState:UIControlStateNormal];
////            [cell.starButton setImage:[UIImage imageNamed:@"unstarredIconSelected2"] forState:UIControlStateHighlighted];
////        }
////        if ([[postDict objectForKey:@"you_reposted"] boolValue]) {
////            [cell.repostButton setImage:[UIImage imageNamed:@"trashIcon"] forState:UIControlStateNormal];
////            [cell.repostButton setImage:[UIImage imageNamed:@"trashIconSelected"] forState:UIControlStateHighlighted];
////        } else {
////            [cell.repostButton setImage:[UIImage imageNamed:@"repostIcon2"] forState:UIControlStateNormal];
////            [cell.repostButton setImage:[UIImage imageNamed:@"repostIconSelected2"] forState:UIControlStateHighlighted];
////        }
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
////            [cell.replyButton setImage:[ImageHelper replyWithStrokeColor:kDarkTintColor] forState:UIControlStateNormal];
////            [cell.replyButton setImage:[ImageHelper replyWithStrokeColor:kDarkMainColor] forState:UIControlStateHighlighted];
////            [cell.conversationButton setImage:[ImageHelper conversationWithStrokeColor:kDarkTintColor] forState:UIControlStateNormal];
////            [cell.conversationButton setImage:[ImageHelper conversationWithStrokeColor:kDarkMainColor] forState:UIControlStateHighlighted];
////            [cell.profileButton setImage:[ImageHelper infoWithStrokeColor:kDarkTintColor] forState:UIControlStateNormal];
////            [cell.profileButton setImage:[ImageHelper infoWithStrokeColor:kDarkMainColor] forState:UIControlStateHighlighted];
////            if ([[postDict objectForKey:@"you_reposted"] boolValue]) {
////                [cell.repostButton setImage:[ImageHelper trashWithStrokeColor:kDarkTintColor] forState:UIControlStateNormal];
////                [cell.repostButton setImage:[ImageHelper trashWithStrokeColor:kDarkMainColor] forState:UIControlStateHighlighted];
////            } else {
////                [cell.repostButton setImage:[ImageHelper repostWithStrokeColor:kDarkTintColor] forState:UIControlStateNormal];
////                [cell.repostButton setImage:[ImageHelper repostWithStrokeColor:kDarkMainColor] forState:UIControlStateHighlighted];
////            }
////            if ([[postDict objectForKey:@"you_starred"] boolValue]) {
////                [cell.starButton setImage:[ImageHelper starWithStrokeColor:kDarkTintColor filled:YES] forState:UIControlStateNormal];
////                [cell.starButton setImage:[ImageHelper starWithStrokeColor:kDarkMainColor filled:YES] forState:UIControlStateHighlighted];
////            } else {
////                [cell.starButton setImage:[ImageHelper starWithStrokeColor:kDarkTintColor filled:NO] forState:UIControlStateNormal];
////                [cell.starButton setImage:[ImageHelper starWithStrokeColor:kDarkMainColor filled:NO] forState:UIControlStateHighlighted];
////            }
////            cell.numberOfRepostsLabel.textColor = kDarkTintColor;
////            cell.numberOfStarsLabel.textColor = kDarkTintColor;
////            cell.numberOfRepliesLabel.textColor = kDarkMainColor;
//            [cell.replyButton setImage:[ImageHelper replyWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTintColor] forState:UIControlStateNormal];
//            [cell.replyButton setImage:[ImageHelper replyWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor] forState:UIControlStateHighlighted];
//            [cell.conversationButton setImage:[ImageHelper conversationWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTintColor] forState:UIControlStateNormal];
//            [cell.conversationButton setImage:[ImageHelper conversationWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor] forState:UIControlStateHighlighted];
//            [cell.profileButton setImage:[ImageHelper infoWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTintColor] forState:UIControlStateNormal];
//            [cell.profileButton setImage:[ImageHelper infoWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor] forState:UIControlStateHighlighted];
//            if ([[postDict objectForKey:@"you_reposted"] boolValue]) {
//                [cell.repostButton setImage:[ImageHelper trashWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTintColor] forState:UIControlStateNormal];
//                [cell.repostButton setImage:[ImageHelper trashWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor] forState:UIControlStateHighlighted];
//            } else {
//                [cell.repostButton setImage:[ImageHelper repostWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTintColor] forState:UIControlStateNormal];
//                [cell.repostButton setImage:[ImageHelper repostWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor] forState:UIControlStateHighlighted];
//            }
//            if ([[postDict objectForKey:@"you_starred"] boolValue]) {
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTintColor filled:YES] forState:UIControlStateNormal];
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor filled:YES] forState:UIControlStateHighlighted];
//            } else {
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTintColor filled:NO] forState:UIControlStateNormal];
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor filled:NO] forState:UIControlStateHighlighted];
//            }
//            cell.numberOfRepostsLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
//            cell.numberOfStarsLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
//            cell.numberOfRepliesLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
//
//        } else {
//            [cell.replyButton setImage:[ImageHelper replyWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].tintColor] forState:UIControlStateNormal];
//            [cell.replyButton setImage:[ImageHelper replyWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].mainColor] forState:UIControlStateHighlighted];
//            [cell.conversationButton setImage:[ImageHelper conversationWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].tintColor] forState:UIControlStateNormal];
//            [cell.conversationButton setImage:[ImageHelper conversationWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].mainColor] forState:UIControlStateHighlighted];
//            [cell.profileButton setImage:[ImageHelper infoWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].tintColor] forState:UIControlStateNormal];
//            [cell.profileButton setImage:[ImageHelper infoWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].mainColor] forState:UIControlStateHighlighted];
//            if ([[postDict objectForKey:@"you_reposted"] boolValue]) {
//                [cell.repostButton setImage:[ImageHelper trashWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].tintColor] forState:UIControlStateNormal];
//                [cell.repostButton setImage:[ImageHelper trashWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].mainColor] forState:UIControlStateHighlighted];
//            } else {
//                [cell.repostButton setImage:[ImageHelper repostWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].tintColor] forState:UIControlStateNormal];
//                [cell.repostButton setImage:[ImageHelper repostWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].mainColor] forState:UIControlStateHighlighted];
//            }
//            if ([[postDict objectForKey:@"you_starred"] boolValue]) {
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].tintColor filled:YES] forState:UIControlStateNormal];
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].mainColor filled:YES] forState:UIControlStateHighlighted];
//            } else {
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].tintColor filled:NO] forState:UIControlStateNormal];
//                [cell.starButton setImage:[ImageHelper starWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].mainColor filled:NO] forState:UIControlStateHighlighted];
//            }
//            cell.numberOfRepostsLabel.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
//            cell.numberOfStarsLabel.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
//            cell.numberOfRepliesLabel.textColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
//        }
//
//        
//        cell.numberOfRepostsLabel.text = [NSString stringWithFormat:@"%@", [postDict objectForKey:@"num_reposts"]];
//        cell.numberOfStarsLabel.text = [NSString stringWithFormat:@"%@", [postDict objectForKey:@"num_stars"]];
//        cell.numberOfRepliesLabel.text = [NSString stringWithFormat:@"%@", [postDict objectForKey:@"num_replies"]];
//        cell.userIdLabel.text = [NSString stringWithFormat:@"id %@", [[postDict objectForKey:@"user"] objectForKey:@"id"]];
//        return cell;
//    }
    
    DHPostCell *postCell = [DHPostCell cellForTableView:tableView];
    NSDictionary *postDict;
    
    NSInteger index;
//    if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row && indexPath.section == self.controlIndexPath.section) {
//        index = indexPath.row-1;
//    } else {
        index = indexPath.row;
//    }
    
//    CGFloat cellWidth = self.tableView.frame.size.width;
    switch (indexPath.section) {
        case 0:
        {            
            CGRect frame = postCell.postTextView.frame;
            frame.origin = CGPointMake(5.0f, 25.0f);
            postCell.postTextView.frame = frame;
                                
            postCell.drawAvatarRight = YES;
            
            if ([self.replyArray count] > index)
            {
                postDict = [self.replyArray objectAtIndex:index];
            }
        }
            break;
        case 1:
        {
            CGRect frame = postCell.postTextView.frame;
            frame.origin = CGPointMake(66.0f, 25.0f);
            postCell.postTextView.frame = frame;
                        
            postCell.drawAvatarRight = NO;

            postDict = self.postDictionary;
        }
            break;
        case 2:
        {
            CGRect frame = postCell.postTextView.frame;
            frame.origin = CGPointMake(5.0f, 25.0f);
            postCell.postTextView.frame = frame;
                        
            postCell.drawAvatarRight = YES;
            
            if ([self.replyToArray count] > index)
            {
                postDict = [self.replyToArray objectAtIndex:index];
            }
        }
            break;
        default:
            break;
    }
    
    CGPoint postCellActivationPoint = [postCell avatarFrame].origin;
    postCellActivationPoint.x = postCellActivationPoint.x + 10.0f;
    postCellActivationPoint.y = postCellActivationPoint.y + 10.0f;
    [postCell setAccessibilityActivationPoint:postCellActivationPoint];
    
    NSDictionary *userDict = [postDict objectForKey:@"user"];
    
    [self.streamTableViewController addSeenId:[postDict objectForKey:@"id"]];
    
//    postCell.nameLabel.text = [NSString stringWithFormat:@"%@", [userDict objectForKey:@"username"]];
//    NSDate *date = [self.iso8601DateFormatter dateFromString:[postDict objectForKey:@"created_at"]];
//    CGFloat secondsSincePost = -[date timeIntervalSinceNow];
//    NSString *timeSincePostString;
//    if (secondsSincePost < 60.0f) {
//        timeSincePostString = @"1m";
//    } else if (secondsSincePost < 3600.0f) {
//        timeSincePostString = [NSString stringWithFormat:@"%dm", (int)secondsSincePost/60];
//    } else if (secondsSincePost < 86400.0f) {
//        timeSincePostString = [NSString stringWithFormat:@"%dh", (int)secondsSincePost/3600];
//    } else {
//        timeSincePostString = [NSString stringWithFormat:@"%dd", (int)secondsSincePost/86400];
//    }
//    postCell.dateLabel.text = timeSincePostString;

    postCell.clientString = [NSString stringWithFormat:@"via %@", [[postDict objectForKey:@"source"] objectForKey:@"name"]];
    
    postCell.nameString = [userDict objectForKey:@"username"];
    postCell.userId         = [userDict objectForKey:@"id"];
    NSDate *date = [self.iso8601DateFormatter dateFromString:[postDict objectForKey:@"created_at"]];
    CGFloat secondsSincePost = -[date timeIntervalSinceNow];
    NSString *timeSincePostString;
    NSMutableString *accessibilityString = [postCell.nameString mutableCopy];
    if (secondsSincePost < 60.0f) {
        timeSincePostString = NSLocalizedString(@"now", nil);
        [accessibilityString appendFormat:NSLocalizedString(@" posted now %@", nil), postCell.clientString];
    } else if (secondsSincePost < 3600.0f) {
        timeSincePostString = [NSString stringWithFormat:@"%dm", (int)secondsSincePost/60];
        [accessibilityString appendFormat:NSLocalizedString(@" posted %d minutes ago %@", nil), (int)secondsSincePost/60, postCell.clientString];
    } else if (secondsSincePost < 86400.0f) {
        timeSincePostString = [NSString stringWithFormat:@"%dh", (int)secondsSincePost/3600];
        [accessibilityString appendFormat:NSLocalizedString(@" posted %d hours ago %@", nil), (int)secondsSincePost/3600, postCell.clientString];
    } else {
        timeSincePostString = [NSString stringWithFormat:@"%dd", (int)secondsSincePost/86400];
        [accessibilityString appendFormat:NSLocalizedString(@" posted %d days ago %@", nil), (int)secondsSincePost/86400, postCell.clientString];
    }
    postCell.dateString = timeSincePostString;
    
    postCell.accessibilityLabel = accessibilityString;

    
    postCell.avatarImage = nil;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![userDefaults boolForKey:kDontLoadImages]) {
        postCell.noImages = NO;

        NSDictionary *userDict = [postDict objectForKey:@"user"];
        NSDictionary *avatarImageDictionary = [userDict objectForKey:@"avatar_image"];
        
        __weak DHStreamDetailTableViewController *weakSelf = self;
        dispatch_queue_t avatarDownloaderQueue = dispatch_queue_create("de.dasdom.avatarDownloader", NULL);
        dispatch_async(avatarDownloaderQueue, ^{
            NSString *avatarUrlString = [avatarImageDictionary objectForKey:@"url"];
            CGFloat width = [[avatarImageDictionary objectForKey:@"width"] floatValue];
            //            dhDebug(@"width: %f", width);
            NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
            NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
            UIImage *avatarImage = [imageCache objectForKey:imageKey];
            if (!avatarImage && width < 2000.0f) {
                avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:56.0f/width];
                               
                if (avatarImage) {
                    [imageCache setObject:avatarImage forKey:imageKey];
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                id asyncCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
                if ([asyncCell isKindOfClass:([DHPostCell class])]) {
                    [asyncCell setAvatarImage:avatarImage];
                }
            });
        });
    } else {
        postCell.noImages = YES;
    }

    
    postCell.clientString = [NSString stringWithFormat:@"via %@", [[postDict objectForKey:@"source"] objectForKey:@"name"]];
    
    NSString *postText = [DHUtils stringOrEmpty:[postDict objectForKey:@"text"]];
    
    NSArray *annotationsArray = [postDict objectForKey:@"annotations"];
    NSDictionary *imageAnnotationDict;
    for (NSDictionary *annotationDict in annotationsArray) {
        if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"] && [[[annotationDict objectForKey:@"value"] objectForKey:@"type"] isEqualToString:@"photo"]) {
            imageAnnotationDict = annotationDict;
        }
    }
    CGFloat widthdiff = 77.0f;
    if (imageAnnotationDict && ![userDefaults boolForKey:kDontLoadImages]) {
        widthdiff = 138.0f;
//        postCell.postImageView.layer.borderWidth = 1.0f;
        NSString *urlKey = @"url";
        NSString *heightKey = @"height";
        NSString *widthKey = @"width";
        
        NSDictionary *valueDict = [imageAnnotationDict objectForKey:@"value"];
        if ([valueDict objectForKey:@"thumbnail_url"]) {
            urlKey = @"thumbnail_url";
            heightKey = @"thumbnail_height";
            widthKey = @"thumbnail_width";
        }
        postCell.postImageURL = [valueDict objectForKey:@"url"];
        CGRect postImageFrame = CGRectMake(postCell.frame.size.width-63.0f, 20.0f, 56.0f, 56.0f);
        CGFloat cellWidth = self.tableView.frame.size.width;
        switch (indexPath.section) {
            case 0:
            {
                postImageFrame = CGRectMake(cellWidth-127.0f, 20.0f, 56.0f, 56.0f);;
            }
                break;
            case 1:
            {
                postImageFrame = CGRectMake(cellWidth-63.0f, 20.0f, 56.0f, 56.0f);
            }
                break;
            case 2:
            {
                postImageFrame = CGRectMake(cellWidth-127.0f, 20.0f, 56.0f, 56.0f);;
            }
                break;
            default:
                break;
        }

        if ([[valueDict objectForKey:widthKey] floatValue] > 0.0f) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                postImageFrame = CGRectMake(postCell.frame.size.width-107.0f, 20.0f, 100.0f, 100.0f);
                switch (indexPath.section) {
                    case 0:
                    {
                        postImageFrame = CGRectMake(cellWidth-171.0f, 20.0f, 100.0f, 100.0f);;
                    }
                        break;
                    case 1:
                    {
                        postImageFrame = CGRectMake(cellWidth-107.0f, 20.0f, 100.0f, 100.0f);
                    }
                        break;
                    case 2:
                    {
                        postImageFrame = CGRectMake(cellWidth-171.0f, 20.0f, 100.0f, 100.0f);;
                    }
                        break;
                    default:
                        break;
                }

                widthdiff = 182.0f;
            }
            postImageFrame.size.height = (postImageFrame.size.width * [[valueDict objectForKey:heightKey] floatValue] / [[valueDict objectForKey:widthKey] floatValue]);
            postCell.postImageFrame = postImageFrame;
        }

        dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("de.dasdom.imageDownloader", NULL);
        dispatch_async(imgDownloaderQueue, ^{
            NSString *avatarUrlString = [valueDict objectForKey:urlKey];
            UIImage *postImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                id asyncCell = [self.tableView cellForRowAtIndexPath:indexPath];
                if ([asyncCell isKindOfClass:([DHPostCell class])]) {
                    [asyncCell setPostImage:postImage];
                }
            });
        });
    } else {
        postCell.postImage = nil;
//        postCell.postImageView.layer.borderWidth = 0.0f;
        postCell.postImageURL = nil;
    }
    CGSize labelSize = [postText sizeWithFont:postCell.postTextView.font constrainedToSize:CGSizeMake(self.view.frame.size.width-widthdiff, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    labelSize.height = labelSize.height+5.0f;
    CGRect postTextFrame = postCell.postTextView.frame;
    postTextFrame.size = labelSize;
    postCell.postTextView.frame = postTextFrame;

//    CGSize labelSize = [postText sizeWithFont:postCell.postTextView.font constrainedToSize:CGSizeMake(self.view.frame.size.width-77.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    labelSize.height = labelSize.height+5.0f;
//    CGRect postTextFrame = postCell.postTextView.frame;
//    postTextFrame.size = labelSize;
//    postCell.postTextView.frame = postTextFrame;
    
    [postCell.postTextView removeAllLinks];
    NSArray *linkArray = [[postDict objectForKey:@"entities"] objectForKey:@"links"];
    for (NSDictionary *linkDict in linkArray) {
//        NSRange linkRange = {[[linkDict objectForKey:@"pos"] integerValue], [[linkDict objectForKey:@"len"] integerValue]};
        [postCell.postTextView addLinkRange:[postText rangeForEntity:linkDict] forLink:[linkDict objectForKey:@"url"]];
    }
    
    [postCell.postTextView removeAllMentions];
    NSArray *mentionArray = [[postDict objectForKey:@"entities"] objectForKey:@"mentions"];
    for (NSDictionary *mentionDict in mentionArray) {
//        NSRange linkRange = {[[mentionDict objectForKey:@"pos"] integerValue], [[mentionDict objectForKey:@"len"] integerValue]};
        [postCell.postTextView addMentionRange:[postText rangeForEntity:mentionDict] forUserId:[mentionDict objectForKey:@"id"]];
    }
    
    [postCell.postTextView removeAllHashTags];
    NSArray *hashTagArray = [[postDict objectForKey:@"entities"] objectForKey:@"hashtags"];
    for (NSDictionary *hashTagDict in hashTagArray) {
//        NSRange hashTagRange = {[[hashTagDict objectForKey:@"pos"] integerValue], [[hashTagDict objectForKey:@"len"] integerValue]};
        [postCell.postTextView addHashTagRange:[postText rangeForEntity:hashTagDict] forName:[hashTagDict objectForKey:@"name"]];
        
    }
    
    postCell.postTextView.isAccessibilityElement = YES;
    postCell.postTextView.text = postText;
    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postTextViewTapped:)];
//    [postCell.postTextView addGestureRecognizer:tapRecognizer];
//    
//    [postCell.postTextView setNeedsDisplay];
    
    postCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIColor *cellBackgroundColor;
    if (self.toHighlightIndexPath && self.toHighlightIndexPath.section == indexPath.section && self.toHighlightIndexPath.row == indexPath.row) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            cellBackgroundColor = kDarkCellBackgroundColorLepliedTo;
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        } else {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        }
//        self.highlightedIndexPath = self.toHeighlightIndexPath;
    } else if (!self.toHighlightIndexPath && [[postDict objectForKey:@"id"] isEqualToString:[self.postDictionary objectForKey:@"reply_to"]]) {
//        dhDebug(@"red indexPath: %@", indexPath);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            cellBackgroundColor = kDarkCellBackgroundColorLepliedTo;
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        } else {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        }
//        self.highlightedIndexPath = indexPath;
    } else {
//        dhDebug(@"white indexPath: %@", indexPath);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            cellBackgroundColor = kDarkCellBackgroundColorDefault;
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        } else {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        }
    }
//    postCell.contentView.backgroundColor = cellBackgroundColor;
    postCell.postColor = cellBackgroundColor;
//    postCell.clientLabel.backgroundColor = cellBackgroundColor;
//    postCell.nameLabel.backgroundColor = cellBackgroundColor;
    postCell.postTextView.backgroundColor = [UIColor clearColor];
//    postCell.dateLabel.backgroundColor = cellBackgroundColor;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        postCell.postTextView.textColor = kDarkTextColor;
//        postCell.textColor = kDarkTextColor;
//        postCell.customSeparatorColor = kDarkSeparatorColor;
        postCell.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        postCell.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        postCell.customSeparatorColor = [DHGlobalObjects sharedGlobalObjects].darkSeparatorColor;
    } else {
        postCell.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        postCell.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        postCell.customSeparatorColor = [DHGlobalObjects sharedGlobalObjects].separatorColor;
    }
    

    if (![postCell.gestureRecognizers count]) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
        panGestureRecognizer.delegate = self;
        [postCell addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHappend:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [postCell addGestureRecognizer:doubleTapRecognizer];
        
//        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHappend:)];
//        [postCell addGestureRecognizer:longPressRecognizer];
        
        UITapGestureRecognizer *postTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postTextViewTapped:)];
        [postTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
//        [postTapRecognizer requireGestureRecognizerToFail:longPressRecognizer];
        [postCell addGestureRecognizer:postTapRecognizer];

//        UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftHappend:)];
//        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//        [postCell addGestureRecognizer:swipeLeftGestureRecognizer];
//        
//        UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
//        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//        [postCell addGestureRecognizer:swipeRightGestureRecognizer];
    }
    
//    postCell.backgroundImageView.alpha = 0.0f;
    [postCell.replyButton addTarget:self action:@selector(replyOnPost:) forControlEvents:UIControlEventTouchUpInside];
    [postCell.repostButton addTarget:self action:@selector(repostPost:) forControlEvents:UIControlEventTouchUpInside];
    [postCell.starButton addTarget:self action:@selector(starPost:) forControlEvents:UIControlEventTouchUpInside];
    [postCell.conversationButton addTarget:self action:@selector(showConversation:) forControlEvents:UIControlEventTouchUpInside];
    postCell.buttonHostView.hidden = YES;

    
    [postCell.postTextView setNeedsDisplay];

    return postCell;
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
//    if (self.controlIndexPath && [indexPath isEqual: self.controlIndexPath]) {
//        return 55.0f;
//    }
    
    NSInteger index;
//    if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row && indexPath.section == self.controlIndexPath.section) {
//        index = indexPath.row-1;
//    } else {
        index = indexPath.row;
//    }

    NSDictionary *postDict;
    switch (indexPath.section) {
        case 0:
//            postText = [DHUtils stringOrEmpty:[[self.replyArray objectAtIndex:index] objectForKey:@"text"]];
            if ([self.replyArray count] <= index) {
                return 0.0f;
            }
            postDict = [self.replyArray objectAtIndex:index];
            break;
        case 1:
//            postText = [DHUtils stringOrEmpty:[self.postDictionary objectForKey:@"text"]];
            postDict = self.postDictionary;
            break;
        case 2:
//            postText = [DHUtils stringOrEmpty:[[self.replyToArray objectAtIndex:index] objectForKey:@"text"]];
            if ([self.replyToArray count] <= index) {
                return 0.0f;
            }
            postDict = [self.replyToArray objectAtIndex:index];
            break;
        default:
            break;
    }
    NSString *postText = [DHUtils stringOrEmpty:[postDict objectForKey:@"text"]];

    NSArray *annotationsArray = [postDict objectForKey:@"annotations"];
    NSDictionary *imageAnnotationDict;
    for (NSDictionary *annotationDict in annotationsArray) {
        if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"] && [[[annotationDict objectForKey:@"value"] objectForKey:@"type"] isEqualToString:@"photo"]) {
            imageAnnotationDict = annotationDict;
        }
    }
    
    CGFloat widthDiff = 77.0f;
    CGFloat minimalHeightForPostImage = 0.0f;
    NSDictionary *annotationDict = [imageAnnotationDict objectForKey:@"value"];
    if (annotationDict) {
        widthDiff = 138.0f;
//        NSString *urlKey = @"url";
        NSString *heightKey = @"height";
        NSString *widthKey = @"width";
        
        if ([annotationDict objectForKey:@"thumbnail_url"]) {
//            urlKey = @"thumbnail_url";
            heightKey = @"thumbnail_height";
            widthKey = @"thumbnail_width";
        }
        
        if ([[annotationDict objectForKey:widthKey] floatValue] > 0.0f) {
            minimalHeightForPostImage = (56.0f * [[annotationDict objectForKey:heightKey] floatValue] / [[annotationDict objectForKey:widthKey] floatValue]) + 25.0f;
        }
    }

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CGSize labelSize = [postText sizeWithFont:[UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]] constrainedToSize:CGSizeMake(self.view.frame.size.width-widthDiff, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(minimalHeightForPostImage, MAX(labelSize.height+36.0f+15.0f, 56.0f+14.0f));
}


//- (void)postTextViewTapped:(UITapGestureRecognizer*)sender {
//    CGPoint point = [sender locationInView:sender.view];
//        
//    NSString *linkString = [(DHPostTextView*)[sender view] linkForPoint:point];
//    dhDebug(@"linkString: %@", linkString);
//    
//    if (linkString) {
//        [self performSegueWithIdentifier:@"ShowWeb" sender:linkString];
//    }
//    
//}

- (IBAction)swipeRightHappend:(UISwipeGestureRecognizer *)sender {
//    if (self.controlIndexPath) {
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:@[self.controlIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//        self.controlIndexPath = nil;
//        [self.tableView endUpdates];
//    }
//    if (self.answerIndexPath) {
//        self.toHighlightIndexPath = self.answerIndexPath;
//        self.answerIndexPath = nil;
//        
//        [self.tableView scrollToRowAtIndexPath:self.toHighlightIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//        
//        NSRange reloadRange = {0, 3};
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:reloadRange] withRowAnimation:UITableViewRowAnimationFade];
//    } else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    [self hightlightReplyPost];
}

- (void)hightlightReplyPost {
//    if (self.controlIndexPath) {
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:@[self.controlIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//        self.controlIndexPath = nil;
//        [self.tableView endUpdates];
//    }
    if (self.answerIndexPath) {
        self.toHighlightIndexPath = self.answerIndexPath;
        self.answerIndexPath = nil;
        
        [self.tableView scrollToRowAtIndexPath:self.toHighlightIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        NSRange reloadRange = {0, 3};
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:reloadRange] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)swipeLeftHappend:(UISwipeGestureRecognizer*)sender {
//    if (self.controlIndexPath) {
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:@[self.controlIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//        self.controlIndexPath = nil;
//        [self.tableView endUpdates];
//    }
    
    [self hightlightQuestionToCell:(UITableViewCell*)sender.view];
    
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender.view];
//    
////    NSInteger index;
////    if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row && indexPath.section == self.controlIndexPath.section) {
////        index = indexPath.row-1;
////    } else {
////        index = indexPath.row;
////    }
//    
//    NSString *replyToId;
//    switch (indexPath.section) {
//        case 0:
//            replyToId = [[self.replyArray objectAtIndex:indexPath.row] objectForKey:@"reply_to"];
//            break;
//        case 1:
//            replyToId = [self.postDictionary objectForKey:@"reply_to"];
//            break;
//        case 2:
//            replyToId = [[self.replyToArray objectAtIndex:indexPath.row] objectForKey:@"reply_to"];
//            break;
//        default:
//            replyToId = nil;
//            break;
//    }    
//    
//    NSIndexPath *replyToIndexPath = nil;
//    for (int i = 0; i < [self.replyArray count]; i++) {
//        NSDictionary *postDict = [self.replyArray objectAtIndex:i];
//        if ([[postDict objectForKey:@"id"] isEqualToString:replyToId]) {
////            NSInteger index;
////            if (self.controlIndexPath && i > self.controlIndexPath.row && 0 == self.controlIndexPath.section) {
////                index = i-1;
////            } else {
////                index = i;
////            }
//            replyToIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//            break;
//        }
//    }
//    if (!replyToIndexPath) {
//        if ([[self.postDictionary objectForKey:@"id"] isEqualToString:replyToId]) {
//            replyToIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
//        }
//    }
//    if (!replyToIndexPath) {
//        for (int i = 0; i < [self.replyToArray count]; i++) {
//            NSDictionary *postDict = [self.replyToArray objectAtIndex:i];
//            if ([[postDict objectForKey:@"id"] isEqualToString:replyToId]) {
////                NSInteger index;
////                if (self.controlIndexPath && i > self.controlIndexPath.row && 2 == self.controlIndexPath.section) {
////                    index = i-1;
////                } else {
////                    index = i;
////                }
//                replyToIndexPath = [NSIndexPath indexPathForRow:i inSection:2];
//                break;
//            }
//        }
//    }
//    self.answerIndexPath = indexPath;
//    self.toHighlightIndexPath = replyToIndexPath;
//    
//    if (!replyToIndexPath) {
//        return;
//    }
//
//    [self.tableView scrollToRowAtIndexPath:replyToIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    
//    NSRange reloadRange = {0, 3};
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:reloadRange] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)hightlightQuestionToCell:(UITableViewCell*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *replyToId;
    switch (indexPath.section) {
        case 0:
            replyToId = [[self.replyArray objectAtIndex:indexPath.row] objectForKey:@"reply_to"];
            break;
        case 1:
            replyToId = [self.postDictionary objectForKey:@"reply_to"];
            break;
        case 2:
            replyToId = [[self.replyToArray objectAtIndex:indexPath.row] objectForKey:@"reply_to"];
            break;
        default:
            replyToId = nil;
            break;
    }
    
    NSIndexPath *replyToIndexPath = nil;
    for (int i = 0; i < [self.replyArray count]; i++) {
        NSDictionary *postDict = [self.replyArray objectAtIndex:i];
        if ([[postDict objectForKey:@"id"] isEqualToString:replyToId]) {
            //            NSInteger index;
            //            if (self.controlIndexPath && i > self.controlIndexPath.row && 0 == self.controlIndexPath.section) {
            //                index = i-1;
            //            } else {
            //                index = i;
            //            }
            replyToIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
    if (!replyToIndexPath) {
        if ([[self.postDictionary objectForKey:@"id"] isEqualToString:replyToId]) {
            replyToIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        }
    }
    if (!replyToIndexPath) {
        for (int i = 0; i < [self.replyToArray count]; i++) {
            NSDictionary *postDict = [self.replyToArray objectAtIndex:i];
            if ([[postDict objectForKey:@"id"] isEqualToString:replyToId]) {
                //                NSInteger index;
                //                if (self.controlIndexPath && i > self.controlIndexPath.row && 2 == self.controlIndexPath.section) {
                //                    index = i-1;
                //                } else {
                //                    index = i;
                //                }
                replyToIndexPath = [NSIndexPath indexPathForRow:i inSection:2];
                break;
            }
        }
    }
    self.answerIndexPath = indexPath;
    self.toHighlightIndexPath = replyToIndexPath;
    
    if (!replyToIndexPath) {
        return;
    }
    
    [self.tableView scrollToRowAtIndexPath:replyToIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

    NSRange reloadRange = {0, 3};
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:reloadRange] withRowAnimation:UITableViewRowAnimationFade];

}

- (void)doubleTapHappend:(UITapGestureRecognizer*)sender {
    CGPoint locationInPostText = [sender locationInView:sender.view];

    if (locationInPostText.x > sender.view.frame.size.width/2.0f) {
        [self hightlightQuestionToCell:(UITableViewCell*)sender.view];
    } else {
        [self hightlightReplyPost];
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"ShowWeb"]) {
//        DHWebViewController *webViewController = segue.destinationViewController;
//        webViewController.linkString = (NSString*)sender;
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    return;
}

- (NSDictionary*)postDictionaryForControlCellIndexPath:(NSIndexPath*)indexPath {
    NSDictionary *postDict;
    switch (indexPath.section) {
        case 0:
            postDict = [self.replyArray objectAtIndex:indexPath.row-1];
            break;
        case 1:
            postDict = self.postDictionary;
            break;
        case 2:
            postDict = [self.replyToArray objectAtIndex:indexPath.row-1];
            break;
        default:
            NSAssert(false, @"unsupported indexPath.section");
            break;
    }
    return postDict;
}

- (void)cancel:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)actionButtonTouched:(UIBarButtonItem*)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposerViewController = [[MFMailComposeViewController alloc] init];
        mailComposerViewController.mailComposeDelegate = self;
        [mailComposerViewController setMessageBody:[self stringFromConversation] isHTML:NO];
        [mailComposerViewController setSubject:[NSString stringWithFormat:@"ADN Conversation for post %@", [self.postDictionary objectForKey:@"id"]]];
        [self presentViewController:mailComposerViewController animated:YES completion:^{}];
    }
}

- (NSString*)stringFromConversation {
    NSMutableString *mutableString = [NSMutableString string];
   
    [mutableString appendString:@"*********************\n"];
    [mutableString appendFormat:@"* ADN Conversation for https://posts.app.net/%@\n", [self.postDictionary objectForKey:@"id"]];
    [mutableString appendString:@"*********************\n\n"];

    for (int i = [self.replyToArray count]-1; i >= 0; i--) {
        [mutableString appendString:@"---\n"];
        NSDictionary *postDict = [self.replyToArray objectAtIndex:i];
        NSDictionary *userDict = [postDict objectForKey:@"user"];
        [mutableString appendFormat:@"%@ (https://alpha.app.net/%@):\n", [userDict objectForKey:@"username"], [userDict objectForKey:@"username"]];
        [mutableString appendFormat:@"%@\n\n%@\n\n", [postDict objectForKey:@"text"], [postDict objectForKey:@"created_at"]];
    }
   
    [mutableString appendString:@"---\n"];
    NSDictionary *userDict = [self.postDictionary objectForKey:@"user"];
    [mutableString appendFormat:@"%@ (https://alpha.app.net/%@):\n", [userDict objectForKey:@"username"], [userDict objectForKey:@"username"]];
    [mutableString appendFormat:@"%@\n\n%@\n\n", [self.postDictionary objectForKey:@"text"], [self.postDictionary objectForKey:@"created_at"]];
   
    for (int i = [self.replyArray count]-1; i >= 0; i--) {
        [mutableString appendString:@"---\n"];
        NSDictionary *postDict = [self.replyArray objectAtIndex:i];
        NSDictionary *userDict = [postDict objectForKey:@"user"];
        [mutableString appendFormat:@"%@ (https://alpha.app.net/%@):\n", [userDict objectForKey:@"username"], [userDict objectForKey:@"username"]];
        [mutableString appendFormat:@"%@\n\n%@\n\n", [postDict objectForKey:@"text"], [postDict objectForKey:@"created_at"]];
    }
        
    return mutableString;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    if (direction == UIAccessibilityScrollDirectionRight) {
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}

@end
