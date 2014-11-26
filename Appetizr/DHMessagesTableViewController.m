//
//  DHMessagesTableViewController.m
//  Appetizr
//
//  Created by dasdom on 16.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHMessagesTableViewController.h"
#import "DHPostCell.h"
#import "DHCreateStatusViewController.h"
#import "DHWebViewController.h"
#import "DHProfileTableViewController.h"
#import "DHHashtagTableViewController.h"
#import "PRPAlertView.h"
#import "SSKeychain.h"
#import "EditColorSchemeViewController.h"
#import "UIColor+StringConversion.h"
#import "DDHTextView.h"

@interface DHMessagesTableViewController ()

@end

@implementation DHMessagesTableViewController

- (void)viewDidLoad
{
    self.urlString = [NSString stringWithFormat:@"%@channels/%@/messages", kBaseURL, self.channelId];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *createMessageBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(createMessage:)];
    self.navigationItem.rightBarButtonItem = createMessageBarButton;
    
    self.title = self.channelName;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
    label.text = self.channelName;
    label.textAlignment = NSTextAlignmentCenter;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        label.textColor = kDarkTextColor;
        label.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
    } else {
        label.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
    }
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
    label.isAccessibilityElement = YES;
    
    self.navigationItem.titleView = label;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isPatter) {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
    
    [self updateSubscribeButton];
}

- (void)updateSubscribeButton {
    UIBarButtonItem *unsubscribeBarButtonItem;
    if ([[DHGlobalObjects sharedGlobalObjects].subscribedChannels containsObject:self.channelId]) {
        unsubscribeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"unsubscribe", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unsubscribe:)];
    } else {
        unsubscribeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"subscribe", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(subscribe:)];
        
    }
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[flexibleSpace, unsubscribeBarButtonItem]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *composeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 60.0f)];
//    composeView.backgroundColor = [UIColor redColor];
//    DDHTextView *textView = [[DDHTextView alloc] initWithFrame:composeView.bounds];
//    textView.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:kFontName] size:[[[NSUserDefaults standardUserDefaults] objectForKey:kFontSize] floatValue]];
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        textView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
//        textView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
//    } else {
//        textView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
//        textView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
//    }
//    [composeView addSubview:textView];
//    return composeView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 60.0f;
//}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DHPostCell *postCell = [DHPostCell cellForTableView:tableView];
    
    NSInteger index;
    if (self.controlIndexPath && indexPath.row > self.controlIndexPath.row) {
        index = indexPath.row-1;
    } else {
        index = indexPath.row;
    }
    NSDictionary *postDict = [self.userStreamArray objectAtIndex:index];
//    dhDebug(@"postDict: %@", postDict);
    
    [self populatePostCell:postCell withDictionary:postDict forIndexPath:indexPath];
    
    NSArray *annotationArray = [postDict objectForKey:@"annotations"];
//    dhDebug(@"annotationArray: %@", annotationArray);
    
    for (NSDictionary* dict in  annotationArray) {
        if ([[dict objectForKey:@"type"] isEqualToString:@"de.dasdom.happy.theme"]) {
            NSDictionary *themeAnnotationDictionary;
            themeAnnotationDictionary = [dict objectForKey:@"value"];
//            dhDebug(@"themeAnnotationDictionary: %@", themeAnnotationDictionary);
            postCell.postColor = [UIColor colorWithString:themeAnnotationDictionary[@"cellBackgroundColor"]];
            postCell.textColor = [UIColor colorWithString:themeAnnotationDictionary[@"textColor"]];
            postCell.postTextView.textColor = [UIColor colorWithString:themeAnnotationDictionary[@"textColor"]];
            postCell.postTextView.linkColor = [UIColor colorWithString:themeAnnotationDictionary[@"linkColor"]];
            postCell.postTextView.mentionColor = [UIColor colorWithString:themeAnnotationDictionary[@"mentionColor"]];
            postCell.postTextView.hashTagColor = [UIColor colorWithString:themeAnnotationDictionary[@"hashTagColor"]];
            postCell.customSeparatorColor = [UIColor colorWithString:themeAnnotationDictionary[@"separatorColor"]];
            [postCell.postTextView setText:postDict[@"text"] withDefaultColors:NO];
            break;
        }
    }
    
    CGFloat cellWidth = postCell.frame.size.width;
    NSDictionary *userDict = [postDict objectForKey:@"user"];
    if ([[userDict objectForKey:@"username"] isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey]]) {
//        CGRect frame = postCell.nameLabel.frame;
//        frame.origin = CGPointMake(10.0f, 7.0f);
//        postCell.nameLabel.frame = frame;
//        
//        frame = postCell.dateLabel.frame;
//        frame.origin = CGPointMake(cellWidth-176.0f, 7.0f);
//        dhDebug(@"frame: %@", NSStringFromCGRect(frame));
//        postCell.dateLabel.frame = frame;
//        
//        frame = postCell.postTextView.frame;
//        frame.origin = CGPointMake(10.0f, 25.0f);
//        postCell.postTextView.frame = frame;
//        
//        frame = postCell.avatarImageView.frame;
//        frame.origin = CGPointMake(cellWidth-66.0f, 7.0f);
//        postCell.avatarImageView.frame = frame;
//        postCell.avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        
//        frame = postCell.postImageView.frame;
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            frame.origin.x = cellWidth-168.0f;
//        } else {
//            frame.origin.x = cellWidth-124.0f;
//        }
//        postCell.postImageView.frame = frame;
//        
//        frame = postCell.clientLabel.frame;
//        frame.origin.x = 10.0f;
//        postCell.clientLabel.frame = frame;
        CGRect frame = postCell.postTextView.frame;
        frame.origin = CGPointMake(5.0f, 25.0f);
        postCell.postTextView.frame = frame;
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kInlineImages]) {
            frame = postCell.postImageFrame;
            frame.origin.x = cellWidth-124.0f;
            postCell.postImageFrame = frame;
        }
        
        postCell.drawAvatarRight = YES;
    } else {
//        CGRect frame = postCell.nameLabel.frame;
//        frame.origin = CGPointMake(74.0f, 7.0f);
//        postCell.nameLabel.frame = frame;
//        
//        frame = postCell.dateLabel.frame;
//        frame.origin = CGPointMake(cellWidth-116.0f, 7.0f);
//        postCell.dateLabel.frame = frame;
//        
//        frame = postCell.postTextView.frame;
//        frame.origin = CGPointMake(74.0f, 25.0f);
//        postCell.postTextView.frame = frame;
//        
//        frame = postCell.avatarImageView.frame;
//        frame.origin = CGPointMake(10.0f, 7.0f);
//        postCell.avatarImageView.frame = frame;
//        postCell.avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//
//        frame = postCell.postImageView.frame;
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            frame.origin.x = cellWidth-107.0f;
//        } else {
//            frame.origin.x = cellWidth-63.0f;
//        }
//        postCell.postImageView.frame = frame;
//        
//        frame = postCell.clientLabel.frame;
//        frame.origin.x = 74.0f;
//        postCell.clientLabel.frame = frame;
        
        CGRect frame = postCell.postTextView.frame;
        frame.origin = CGPointMake(71.0f, 25.0f);
        postCell.postTextView.frame = frame;
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kInlineImages]) {
            frame = postCell.postImageFrame;
            frame.origin.x = cellWidth-63.0f;
            postCell.postImageFrame = frame;
        }
        
        postCell.drawAvatarRight = NO;
    }
    
    if (![postCell.gestureRecognizers count]) {
//        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHappend:)];
//        doubleTapRecognizer.numberOfTapsRequired = 2;
//        [postCell addGestureRecognizer:doubleTapRecognizer];
//        
//        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHappend:)];
//        [postCell addGestureRecognizer:longPressRecognizer];
        
        UITapGestureRecognizer *postTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postTextViewTapped:)];
//        [postTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
//        [postTapRecognizer requireGestureRecognizerToFail:longPressRecognizer];
        [postCell addGestureRecognizer:postTapRecognizer];
        
//        UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftHappend:)];
//        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//        [postCell addGestureRecognizer:swipeLeftGestureRecognizer];
//        
        UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [postCell addGestureRecognizer:swipeRightGestureRecognizer];
        
    }

    [postCell.postTextView setNeedsDisplay];

    return postCell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *postDict = [self.userStreamArray objectAtIndex:indexPath.row];
//    
//    NSDictionary *annotationDictionary = [postDict objectForKey:@"annotations"];
//    dhDebug(@"annotationDictionary: %@", annotationDictionary);
//}

- (void)postCellTapped:(DHPostCell*)postCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];

    NSDictionary *postDict = [self.userStreamArray objectAtIndex:indexPath.row];

    NSArray *annotationArray = [postDict objectForKey:@"annotations"];
    dhDebug(@"annotationDictionary: %@", annotationArray);

    NSDictionary *themeAnnotationDictionary;
    for (NSDictionary* dict in  annotationArray) {
        if ([[dict objectForKey:@"type"] isEqualToString:@"de.dasdom.happy.theme"]) {
            themeAnnotationDictionary = [dict objectForKey:@"value"];
            
            EditColorSchemeViewController *editColorSchemeViewControllor = [[EditColorSchemeViewController alloc] init];
            [editColorSchemeViewControllor setColorsFromAnnotationDictionary:themeAnnotationDictionary];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editColorSchemeViewControllor];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            [self presentViewController:navigationController animated:YES completion:^{
            
            }];
        }
    }

}

- (void)createMessage:(UIBarButtonItem*)sender {
    [self performSegueWithIdentifier:@"CreateMessageInChannel" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
    static BOOL alreadyUpdatedMarker = NO;
    
    if (scrollView.contentOffset.y < 5.0f && [self.userStreamArray count] > 0 && !alreadyUpdatedMarker) {
        [self updateMarker];
        alreadyUpdatedMarker = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    dhDebug(@"segue.identifier: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"CreateMessageInChannel"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ((UIViewController*)(segue.destinationViewController)).modalPresentationStyle = UIModalPresentationFormSheet;
            ((UIViewController*)(segue.destinationViewController)).view.accessibilityViewIsModal = YES;
        }
        DHCreateStatusViewController *createStatusViewController = (DHCreateStatusViewController*)((UINavigationController*)segue.destinationViewController).topViewController;

        [createStatusViewController setChannelId:self.channelId];
        [createStatusViewController setChannelTitle:[self.title stringByReplacingOccurrencesOfString:@" (via patter)" withString:@""]];
    } else if ([segue.identifier isEqualToString:@"ShowWeb"]) {
        DHWebViewController *webViewController = segue.destinationViewController;
        webViewController.linkString = (NSString*)sender;
    } else if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        DHProfileTableViewController *profileTableViewController = segue.destinationViewController;
        profileTableViewController.userId = (NSString*)sender;
        profileTableViewController.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"ShowHashTag"]) {
        DHHashtagTableViewController *hashTagTableViewController = segue.destinationViewController;
        hashTagTableViewController.hashTagString = (NSString*)sender;
        hashTagTableViewController.hidesBottomBarWhenPushed = YES;
    }
}

- (void)unsubscribe:(UIBarButtonItem*)sender {
    [PRPAlertView showWithTitle:NSLocalizedString(@"Unsubscribe?", nil) message:NSLocalizedString(@"Do you really want to unsubscribe from this channel.", nil) cancelTitle:NSLocalizedString(@"cancel", nil) cancelBlock:^{} otherTitle:NSLocalizedString(@"yes", nil) otherBlock:^{
        
        NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@channels/%@/subscribe?", kBaseURL, self.channelId];
        
        NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
        
        NSMutableURLRequest *channelRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
        [channelRequest setHTTPMethod:@"DELETE"];
        [channelRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

        PRPConnection *dhConnection = [PRPConnection connectionWithRequest:channelRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:channelRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
            dhDebug(@"responseDict: %@", responseDict);
            NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
            if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                return;
            } else {
                NSMutableSet *mutableSubscribedChannelsSet = [[DHGlobalObjects sharedGlobalObjects].subscribedChannels mutableCopy];
                [mutableSubscribedChannelsSet removeObject:self.channelId];
                [DHGlobalObjects sharedGlobalObjects].subscribedChannels = [mutableSubscribedChannelsSet copy];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [dhConnection start];
    }];
}

- (void)subscribe:(UIBarButtonItem*)sender {
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@channels/%@/subscribe?", kBaseURL, self.channelId];
    
    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
    
    NSMutableURLRequest *channelRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
    [channelRequest setHTTPMethod:@"POST"];
    [channelRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:channelRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:channelRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
        dhDebug(@"responseDict: %@", responseDict);
        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        } else {
            NSMutableSet *mutableSubscribedChannelsSet = [[DHGlobalObjects sharedGlobalObjects].subscribedChannels mutableCopy];
            [mutableSubscribedChannelsSet addObject:self.channelId];
            [DHGlobalObjects sharedGlobalObjects].subscribedChannels = [mutableSubscribedChannelsSet copy];
            [self updateSubscribeButton];
        }
    }];
    [dhConnection start];
}

- (void)swipeRightHappend:(UISwipeGestureRecognizer*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    if (direction == UIAccessibilityScrollDirectionRight) {
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}


@end
