//
//  DHProfileTableViewController.m
//  Appetizr
//
//  Created by dasdom on 27.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHProfileTableViewController.h"
#import "DHPostTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "DHCreateStatusViewController.h"
#import "EditProfileViewController.h"
#import "SSKeychain.h"
#import "SlideInView.h"
#import "DHFollowerCollectionViewController.h"
#import "FilesTableViewController.h"
#import "UIImage+NormalizedImage.h"
#import "ImageHelper.h"

@interface DHProfileTableViewController ()
@property (strong, nonatomic) IBOutlet UIView *profileImageHeaderView;
@property (weak, nonatomic) IBOutlet UIView *imageHostView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *profileImageActivityIndicator;
@property (strong, nonatomic) IBOutlet UIScrollView *infoScrollView;
@property (weak, nonatomic) IBOutlet UIView *infoHostView;
@property (weak, nonatomic) IBOutlet UILabel *postsLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followsLabel;
@property (weak, nonatomic) IBOutlet UILabel *followsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *folloedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *followedByNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *starsLabel;
@property (weak, nonatomic) IBOutlet UILabel *starsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectionIndicatorImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet DHPostTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *followsYouImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iFollowImageView;
@property (weak, nonatomic) IBOutlet UIView *headerCoverView;
@property (nonatomic) CGRect avatarFrame;
@property (weak, nonatomic) IBOutlet UIButton *postsButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *followerButton;
@property (weak, nonatomic) IBOutlet UIButton *starredButton;
@property (nonatomic) BOOL idLabelAnimationStopped;
@property (weak, nonatomic) IBOutlet UIButton *interactionsButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesButton;
@property (weak, nonatomic) IBOutlet UIButton *createMessageButton;
@property (nonatomic, strong) UIButton *verifiedButton;
@property (nonatomic, strong) UILabel *sinceLabel;

@property (nonatomic, strong) NSDictionary *userDictionary;

@end

@implementation DHProfileTableViewController
@synthesize imageHostView = _imageHostView;
@synthesize profileImage = _profileImage;
@synthesize profileImageActivityIndicator = _profileImageActivityIndicator;
@synthesize postsLabel = _postsLabel;
@synthesize followsLabel = _followsLabel;
@synthesize folloedByLabel = _folloedByLabel;
@synthesize starsLabel = _starsLabel;
@synthesize idLabel = _idLabel;

- (void)viewDidLoad
{
    self.urlString = [NSString stringWithFormat:@"%@%@%@/posts", kBaseURL, kUsersSubURL, self.userId];

    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChannelsArray:) name:kUpdateChannelsArray object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dissmisData:) name:kUserChangedNotification object:nil];

    UITapGestureRecognizer *profileImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTapped:)];
    [self.profileImage addGestureRecognizer:profileImageTapRecognizer];
    
    self.profileImage.userInteractionEnabled = YES;
    
    self.profileImage.isAccessibilityElement = YES;
    self.profileImage.accessibilityLabel = NSLocalizedString(@"Toggle action", nil);
    self.profileImage.accessibilityHint = NSLocalizedString(@"Toggles between info and action buttons.", nil);
    self.profileImage.accessibilityTraits = UIAccessibilityTraitButton;
    
    UIFont *infoFont = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
    self.postsLabel.font = infoFont;
    self.postsNameLabel.font = infoFont;
    self.followsLabel.font = infoFont;
    self.followsNameLabel.font = infoFont;
    self.folloedByLabel.font = infoFont;
    self.followedByNameLabel.font = infoFont;
    self.starsLabel.font = infoFont;
    self.starsNameLabel.font = infoFont;
    
    self.createMessageButton.titleLabel.font = infoFont;
    self.muteButton.titleLabel.font = infoFont;
    self.followButton.titleLabel.font = infoFont;
    
    self.title = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@%@%@?access_token=%@", kBaseURL, kUsersSubURL, self.userId, accessToken];
    
//    dhDebug(@"self.userId: %@", self.userId);
//    if ([self.userId isEqualToString:@"me"]) {
//        UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTouched:)];
//        self.navigationItem.leftBarButtonItem = searchBarButton;
//        
//        [self.muteButton setTitle:NSLocalizedString(@"show muted", nil) forState:UIControlStateNormal];
//        [self.followButton setTitle:NSLocalizedString(@"files", nil) forState:UIControlStateNormal];
//    }
    
    self.avatarImageView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.avatarImageView.layer.shadowOpacity = 1.0f;
    self.avatarImageView.layer.shadowRadius = 2.0f;
    self.avatarImageView.layer.cornerRadius = 6.0f;
    self.avatarImageView.clipsToBounds = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![self.userId isEqualToString:@"me"]) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.editButton.title = NSLocalizedString(@"actions", nil);
        self.editButton.accessibilityLabel = NSLocalizedString(@"Actions", nil);
        self.editButton.accessibilityHint = NSLocalizedString(@"Shows additional buttons.", nil);
        self.editButton.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitNotEnabled;
        self.editButton.enabled = NO;
    }
    dhDebug(@"self.userId: %@", self.userId);
    if ([self.userId isEqualToString:@"me"]) {
        UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTouched:)];
        self.navigationItem.leftBarButtonItem = searchBarButton;
        
        [self.muteButton setTitle:NSLocalizedString(@"show muted", nil) forState:UIControlStateNormal];
        [self.followButton setTitle:NSLocalizedString(@"files", nil) forState:UIControlStateNormal];
        [self.createMessageButton setTitle:NSLocalizedString(@"interactions", nil) forState:UIControlStateNormal];
        
        self.editButton.title = NSLocalizedString(@"edit", nil);
        self.editButton.accessibilityLabel = NSLocalizedString(@"Edit", nil);
        self.editButton.accessibilityHint = NSLocalizedString(@"Lets you edit your profile.", nil);
    }
    
//    self.infoHostView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"infoScrollViewBackground"]];
    self.infoHostView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"infoScrollViewBackground2"]];
    
    PRPConnection *dhConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
    
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
        if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
        
        id theDict = [responseDict objectForKey:@"data"];
        if (![theDict isKindOfClass:[NSDictionary class]]) {
//            NSLog(@"theDict is not an array");
            return;
        }
        NSDictionary *userDict = theDict;
        dhDebug(@"userDict: %@", userDict);
        self.userDictionary = theDict;
        self.title = [userDict objectForKey:@"username"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
        label.text = [userDict objectForKey:@"username"];
        label.textAlignment = NSTextAlignmentCenter;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            label.textColor = kDarkTextColor;
            label.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
        } else {
            label.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
        }
        label.font = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
        label.backgroundColor = [UIColor clearColor];
        label.isAccessibilityElement = YES;
        
        self.navigationItem.titleView = label;
        
        self.youFollow = [[userDict objectForKey:@"you_follow"] boolValue];
        if ([self.userId isEqualToString:@"me"]) {
            [self.followButton setTitle:NSLocalizedString(@"files", nil) forState:UIControlStateNormal];
        } else if (self.youFollow) {
            [self.followButton setTitle:NSLocalizedString(@"unfollow", nil) forState:UIControlStateNormal];
        } else {
            [self.followButton setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
        }
        
        self.idLabel.text = [NSString stringWithFormat:@"User Id: %@", [userDict objectForKey:@"id"]];
        CGRect idLabelFrame = self.idLabel.frame;
        idLabelFrame.size.width = [self.idLabel.text sizeWithFont:self.idLabel.font].width+20.0f;
        idLabelFrame.origin.x = -idLabelFrame.size.width;
        self.idLabel.frame = idLabelFrame;
        
        if ([[userDict objectForKey:@"follows_you"] boolValue]) {
            self.followsYouImageView.hidden = NO;
        } else {
            self.followsYouImageView.hidden = YES;
        }
        
        if ([[userDict objectForKey:@"you_follow"] boolValue]) {
            self.iFollowImageView.hidden = NO;
        } else {
            self.iFollowImageView.hidden = YES;
        }
        
        if ([[userDict objectForKey:@"you_muted"] boolValue]) {
            [self.muteButton setTitle:NSLocalizedString(@"unmute", nil) forState:UIControlStateNormal];
            self.youMuted = YES;
        }
        
        NSDictionary *countsDict = [userDict objectForKey:@"counts"];
        dhDebug(@"countsDict: %@", countsDict);
        self.postsLabel.text = [NSString stringWithFormat:@"%@", [countsDict objectForKey:@"posts"]];
        self.postsButton.accessibilityLabel = [NSString stringWithFormat:@"%@ posts", self.postsLabel.text];
        self.followsLabel.text = [NSString stringWithFormat:@"%@", [countsDict objectForKey:@"following"]];
        self.followingButton.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"following %@", nil), self.followsLabel.text];
        self.folloedByLabel.text = [NSString stringWithFormat:@"%@", [countsDict objectForKey:@"followers"]];
        self.followerButton.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%@ follower", nil), self.folloedByLabel.text];
        self.starsLabel.text = [NSString stringWithFormat:@"%@", [countsDict objectForKey:@"stars"]];
        self.starredButton.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%@ starred", nil), self.starsLabel.text];
        
        NSDictionary *descriptionDictionary = [userDict objectForKey:@"description"];
        NSString *postText = [DHUtils stringOrEmpty:[descriptionDictionary objectForKey:@"text"]];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.descriptionTextView.font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
        if ([userDefaults boolForKey:kDarkMode]) {
//            self.descriptionTextView.textColor = kDarkTintColor;
            self.descriptionTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
        } else {
            self.descriptionTextView.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
        }
        CGSize labelSize = [postText sizeWithFont:self.descriptionTextView.font constrainedToSize:CGSizeMake(self.view.frame.size.width-77.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect postTextFrame = self.descriptionTextView.frame;
        postTextFrame.size = labelSize;
        postTextFrame.origin.x = self.view.frame.size.width-labelSize.width;
        self.descriptionTextView.frame = postTextFrame;
        
        [self.descriptionTextView removeAllLinks];
        NSArray *linkArray = [[descriptionDictionary objectForKey:@"entities"] objectForKey:@"links"];
        for (NSDictionary *linkDict in linkArray) {
            NSRange linkRange = {[[linkDict objectForKey:@"pos"] integerValue], [[linkDict objectForKey:@"len"] integerValue]};
            [self.descriptionTextView addLinkRange:linkRange forLink:[linkDict objectForKey:@"url"]];
        }
        
        [self.descriptionTextView removeAllMentions];
        NSArray *mentionArray = [[descriptionDictionary objectForKey:@"entities"] objectForKey:@"mentions"];
        for (NSDictionary *mentionDict in mentionArray) {
            NSRange linkRange = {[[mentionDict objectForKey:@"pos"] integerValue], [[mentionDict objectForKey:@"len"] integerValue]};
            [self.descriptionTextView addMentionRange:linkRange forUserId:[mentionDict objectForKey:@"id"]];
        }
        
        self.descriptionTextView.isAccessibilityElement = YES;
        self.descriptionTextView.text = postText;
        [self.descriptionTextView setNeedsDisplay];
        
        NSDictionary *avatartImageDictionary = [userDict objectForKey:@"cover_image"];
        CGRect profileImageFrame = self.profileImage.frame;
        profileImageFrame.size.height = profileImageFrame.size.width * [[avatartImageDictionary objectForKey:@"height"] floatValue] / [[avatartImageDictionary objectForKey:@"width"] floatValue];
        self.profileImage.frame = profileImageFrame;
        CGFloat coverWidth = [[avatartImageDictionary objectForKey:@"width"] floatValue];
        CGFloat labelHeightAddition = (labelSize.height > 25.0f) ? labelSize.height - 25.0f : 0.0f;
//        if ([self.userId isEqualToString:@"me"]) {
//            profileImageFrame.size.height = profileImageFrame.size.height + 82.0f + labelHeightAddition;
//        } else {
            profileImageFrame.size.height = profileImageFrame.size.height + 55.0f + labelHeightAddition;
            self.messagesButton.hidden = YES;
            self.interactionsButton.hidden = YES;
//        }
        [UIView animateWithDuration:0.25f animations:^{
            self.profileImageHeaderView.frame = profileImageFrame;
        } completion:^(BOOL finished){
//            self.editButton.enabled = YES;
            self.infoScrollView.userInteractionEnabled = YES;
            self.editButton.accessibilityTraits = UIAccessibilityTraitButton;
        }];
        //        }
        
        CGRect avatarImageViewFrame = self.avatarImageView.frame;
        avatarImageViewFrame.origin.y = self.profileImage.frame.size.height - 23.0f;
        self.avatarImageView.frame = avatarImageViewFrame;
        self.avatarFrame = avatarImageViewFrame;
    
        //        self.avatarImageView.layer.affineTransform = CGAffineTransformMakeRotation(-0.05f);
        
        CGRect descriptionTextViewFrame = self.descriptionTextView.frame;
        descriptionTextViewFrame.origin.y = self.profileImage.frame.size.height + 18.0f;
        self.descriptionTextView.frame = descriptionTextViewFrame;
        
        if ([userDict objectForKey:@"verified_domain"]) {
            [self.verifiedButton removeFromSuperview];
//            NSString *verifiedDomain = [NSString stringWithFormat:@"%@ ✓", [userDict objectForKey:@"verified_domain"]];
            NSString *verifiedDomain = [userDict objectForKey:@"verified_domain"];
            _verifiedButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_verifiedButton addTarget:self action:@selector(openSafariWithDomain:) forControlEvents:UIControlEventTouchUpInside];
            _verifiedButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:10.0f];

            CGSize buttonSize = [verifiedDomain sizeWithFont:_verifiedButton.titleLabel.font];
            _verifiedButton.frame
//            self.verifiedLabel
            = CGRectMake(descriptionTextViewFrame.origin.x, self.profileImage.frame.size.height, buttonSize.width, 20.0f);
            
            [_verifiedButton setTitle:verifiedDomain forState:UIControlStateNormal];
            _verifiedButton.backgroundColor = [UIColor clearColor];
            if ([userDefaults boolForKey:kDarkMode]) {
//                self.verifiedLabel.textColor = kDarkTextColor;
                [_verifiedButton setTitleColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor forState:UIControlStateNormal];
            } else {
                [_verifiedButton setTitleColor:[DHGlobalObjects sharedGlobalObjects].textColor forState:UIControlStateNormal];
            }
            _verifiedButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:10.0f];
            [self.imageHostView addSubview:_verifiedButton];
        } else {
            [_verifiedButton removeFromSuperview];
        }
        [self.imageHostView bringSubviewToFront:self.avatarImageView];
        _sinceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageHostView.frame.size.width-120.0f, self.profileImage.frame.size.height, 110.0f, 20.0f)];
        _sinceLabel.textAlignment = NSTextAlignmentRight;
        _sinceLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:10.0f];
        NSDate *createdDate = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:userDict[@"created_at"]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _sinceLabel.text = [dateFormatter stringFromDate:createdDate];
        if ([userDefaults boolForKey:kDarkMode]) {
            _sinceLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        } else {
            _sinceLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        }
        [_imageHostView addSubview:_sinceLabel];
        
        UITapGestureRecognizer *descriptionTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(descriptionTextViewTapped:)];
        [self.descriptionTextView addGestureRecognizer:descriptionTapRecognizer];
        
        //        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:self.profileImageHeaderView.frame];
        //        [self.tableView addSubview:self.profileImageHeaderView];
        self.tableView.tableHeaderView = self.profileImageHeaderView;
        
        CGRect followFrame = self.followsYouImageView.frame;
        followFrame.origin.y = -75.0f;
        self.followsYouImageView.frame = followFrame;
        
        followFrame = self.iFollowImageView.frame;
        followFrame.origin.y = -65.0f;
        self.iFollowImageView.frame = followFrame;
        
        CGFloat viewWidth = self.navigationController.view.frame.size.width;
        if (![userDefaults boolForKey:kDontLoadImages] && !self.profileImage.image) {
            dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
            dispatch_async(imgDownloaderQueue, ^{
//                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[avatartImageDictionary objectForKey:@"url"]]]];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[avatartImageDictionary objectForKey:@"url"]]] scale:viewWidth/coverWidth];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.profileImage.image = image;
                    [self.profileImageActivityIndicator stopAnimating];
                    
                    self.editButton.enabled = YES;
                    
                    [self.tableView bringSubviewToFront:self.profileImageHeaderView];
                    
                    [UIView animateWithDuration:0.6f animations:^{
                        CGRect idLabelFrame = self.idLabel.frame;
                        idLabelFrame.origin.x = (self.profileImageHeaderView.frame.size.width - idLabelFrame.size.width)/2.0f-10.0f;
                        self.idLabel.frame = idLabelFrame;
                        
                        CGRect followFrame = self.followsYouImageView.frame;
                        followFrame.origin.y = 0.0f;
                        self.followsYouImageView.frame = followFrame;
                        
                        followFrame = self.iFollowImageView.frame;
                        followFrame.origin.y = 0.0f;
                        self.iFollowImageView.frame = followFrame;
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:2.0f animations:^{
                            CGRect idLabelFrame = self.idLabel.frame;
                            idLabelFrame.origin.x = (self.profileImageHeaderView.frame.size.width - idLabelFrame.size.width)/2.0f+10.0f;
                            self.idLabel.frame = idLabelFrame;
                        } completion:^(BOOL finished){
                            [UIView animateWithDuration:0.6f animations:^{
                                CGRect idLabelFrame = self.idLabel.frame;
                                idLabelFrame.origin.x = self.profileImageHeaderView.frame.size.width + idLabelFrame.size.width;
                                self.idLabel.frame = idLabelFrame;
                                
                                CGRect followFrame = self.followsYouImageView.frame;
                                followFrame.origin.y = -75.0f;
                                self.followsYouImageView.frame = followFrame;
                                
                                followFrame = self.iFollowImageView.frame;
                                followFrame.origin.y = -65.0f;
                                self.iFollowImageView.frame = followFrame;
                            } completion:^(BOOL finished){
                                self.idLabelAnimationStopped = YES;
                                CGRect idLabelFrame = self.idLabel.frame;
                                idLabelFrame.origin.x = self.profileImageHeaderView.frame.size.width;
                                self.idLabel.frame = idLabelFrame;
                            }];
                        }];
                    }];
                });
            });
            
            NSDictionary *avatarImageDictionary = [userDict objectForKey:@"avatar_image"];
            dispatch_queue_t avatarDownloaderQueue = dispatch_queue_create("avatarDownloaderQueue", NULL);
            dispatch_async(avatarDownloaderQueue, ^{
                NSString *avatarUrlString = [avatarImageDictionary objectForKey:@"url"];
//                CGFloat avatarWidth = [[avatartImageDictionary objectForKey:@"width"] floatValue];
//                UIImage *avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
//                UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:200.0f/avatarWidth];
                UIImage *rawAvatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
                UIImage *avatarImage = [rawAvatarImage resizeImage:CGSizeMake(200.0f, 200.0f)];
                
                if ([self.userId isEqualToString:@"me"]) {
                    NSData *imageData = UIImageJPEGRepresentation(rawAvatarImage, 1.0f);
                    
                    NSFileManager *defaultManager = [NSFileManager defaultManager];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    NSString *imageName = [userDict objectForKey:@"username"];
                    NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
                    
                    BOOL success = [defaultManager createFileAtPath:imagePath contents:imageData attributes:nil];
                    dhDebug(@"success: %@", success ? @"YES" : @"NO");
                }
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.avatarImageView.image = avatarImage;
                    self.avatarImageView.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tapAvatarRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTouched:)];
                    [self.avatarImageView addGestureRecognizer:tapAvatarRecognizer];
                });
            });
        } else {
            [self.profileImageActivityIndicator stopAnimating];
        }
        //        NSDictionary *descriptionDictionary = [userDict objectForKey:@"description"];
        //        NSString *postText = [DHUtils stringOrEmpty:[descriptionDictionary objectForKey:@"text"]];
        //        CGSize labelSize = [postText sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(236.0f, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        //        CGRect postTextFrame = self.descriptionTextView.frame;
        //        postTextFrame.size = labelSize;
        //        self.descriptionTextView.frame = postTextFrame;
        //
        //        [self.descriptionTextView removeAllLinks];
        //        NSArray *linkArray = [[descriptionDictionary objectForKey:@"entities"] objectForKey:@"links"];
        //        for (NSDictionary *linkDict in linkArray) {
        //            NSRange linkRange = {[[linkDict objectForKey:@"pos"] integerValue], [[linkDict objectForKey:@"len"] integerValue]};
        //            [self.descriptionTextView addLinkRange:linkRange forLink:[linkDict objectForKey:@"url"]];
        //        }
        //
        //        [self.descriptionTextView removeAllMentions];
        //        NSArray *mentionArray = [[descriptionDictionary objectForKey:@"entities"] objectForKey:@"mentions"];
        //        for (NSDictionary *mentionDict in mentionArray) {
        //            NSRange linkRange = {[[mentionDict objectForKey:@"pos"] integerValue], [[mentionDict objectForKey:@"len"] integerValue]};
        //            [self.descriptionTextView addMentionRange:linkRange];
        //        }
        //
        //        dhDebug(@"postText: %@", postText);
        //        dhDebug(@"descriptionTextView: %@", self.descriptionTextView);
        //        self.descriptionTextView.text = postText;
        //
        //        [self.descriptionTextView setNeedsDisplay];
    }];
    [dhConnection start];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.infoScrollView.contentSize = CGSizeMake(self.infoScrollView.frame.size.width, self.infoScrollView.frame.size.height);
        self.infoHostView.frame = CGRectMake(0.0f, 0.0f, self.infoScrollView.frame.size.width, self.infoScrollView.frame.size.height);
    } else {
        self.infoScrollView.contentSize = CGSizeMake(self.infoHostView.frame.size.width, self.infoHostView.frame.size.height);
    }
    
    if ([self.userId isEqualToString:@"me"]) {
        [self.followButton setTitle:NSLocalizedString(@"files", nil) forState:UIControlStateNormal];
    } else if (self.youFollow) {
        [self.followButton setTitle:NSLocalizedString(@"unfollow", nil) forState:UIControlStateNormal];
    } else {
        [self.followButton setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
    }

//    NSInteger numberOfNewMessages = 0;
//    for (NSDictionary *channelDict in self.channelsArray) {
//        if ([[channelDict objectForKey:@"has_unread"] boolValue]) {
//            numberOfNewMessages = numberOfNewMessages + 1;
//        }
//    }
//    NSString *messagesString = (numberOfNewMessages == 1) ? @"message" : @"messages";
//    [self.messagesButton setTitle:[NSString stringWithFormat:@"%d new %@", numberOfNewMessages, messagesString] forState:UIControlStateNormal];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.messagesButton.titleLabel.font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
    self.interactionsButton.titleLabel.font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
    
    if ([userDefaults boolForKey:kDarkMode]) {
//        self.imageHostView.backgroundColor = kDarkMainColor;
//        self.descriptionTextView.backgroundColor = kDarkMainColor;
//        self.infoScrollView.backgroundColor = kDarkMainColor;
        self.imageHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        self.descriptionTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        self.infoScrollView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
    } else {
        self.imageHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        self.descriptionTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        self.infoScrollView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
    }
    
    if ([self.navigationController.viewControllers count] < 2 && ![self.userId isEqualToString:@"me"]) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.imageHostView addGestureRecognizer:swipeRightGestureRecognizer];
    
    if ([self.userId isEqualToString:@"me"]) {
        self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
        [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
        self.menuButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 30.0f);
        UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
        self.navigationItem.leftBarButtonItem = menuBarButton;
    }
}

- (void)viewDidUnload
{
    [self setProfileImageHeaderView:nil];
    [self setProfileImage:nil];
    [self setImageHostView:nil];
    [self setPostsLabel:nil];
    [self setFollowsLabel:nil];
    [self setFolloedByLabel:nil];
    [self setProfileImageActivityIndicator:nil];
    [self setStarsLabel:nil];
    [self setIdLabel:nil];
    [self setInfoHostView:nil];
    [self setAvatarImageView:nil];
    [self setDescriptionTextView:nil];
    [self setFollowsYouImageView:nil];
    [self setMuteButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 44.0f;
    }
    return 0.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.infoScrollView;
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.idLabelAnimationStopped && scrollView.contentOffset.y < 0) {
        CGRect idLabelFrame = self.idLabel.frame;
        idLabelFrame.origin.x = MAX((self.view.frame.size.width - idLabelFrame.size.width)/2.0f, self.profileImageHeaderView.frame.size.width + 200.0f + scrollView.contentOffset.y*3.0f);
        self.idLabel.frame = idLabelFrame;
    } else {
        [super scrollViewDidScroll:scrollView];
    }
}

- (IBAction)editTouched:(UIBarButtonItem *)sender {
    dhDebug(@"self.userId: %@", self.userId);
    if ([self.userId isEqualToString:@"me"]) {
        EditProfileViewController *editProfileViewController = [[EditProfileViewController alloc] init];
        editProfileViewController.userDictionary = self.userDictionary;
        editProfileViewController.avatarImage = self.avatarImageView.image;
        editProfileViewController.coverImage = self.profileImage.image;
        UINavigationController *editNavigationController = [[UINavigationController alloc] initWithRootViewController:editProfileViewController];
        self.profileImage.image = nil;
        self.avatarImageView.image = nil;
        [self presentViewController:editNavigationController animated:YES completion:^{}];
    } else {
//        if (self.infoScrollView.contentOffset.x > 0.0f) {
//            [self.infoScrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
//            self.editButton.title = NSLocalizedString(@"actions", nil);
//            self.editButton.accessibilityLabel = NSLocalizedString(@"Actions", nil);
//        } else {
//            [self.infoScrollView setContentOffset:CGPointMake(self.infoScrollView.frame.size.width, 0.0f) animated:YES];
//            self.editButton.title = NSLocalizedString(@"info", nil);
//            self.editButton.accessibilityLabel = NSLocalizedString(@"Info", nil);
//        }
//        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
        [self toggleInfoAndAction];
    }
}

- (void)profileImageTapped:(UITapGestureRecognizer*)sender {
    [self toggleInfoAndAction];
}

- (void)toggleInfoAndAction {
    if (self.infoScrollView.contentOffset.x > 0.0f) {
        [self.infoScrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
        self.editButton.title = NSLocalizedString(@"actions", nil);
        self.editButton.accessibilityLabel = NSLocalizedString(@"Actions", nil);
    } else {
        [self.infoScrollView setContentOffset:CGPointMake(self.infoScrollView.frame.size.width, 0.0f) animated:YES];
        self.editButton.title = NSLocalizedString(@"info", nil);
        self.editButton.accessibilityLabel = NSLocalizedString(@"Info", nil);
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (IBAction)selectionButtonTouched:(UIButton *)sender {
    if (sender.tag == 0 || sender.tag == 3) {
        CGRect senderFrame = sender.frame;
        CGRect selectionIndicatorFrame = self.selectionIndicatorImageView.frame;
        selectionIndicatorFrame.origin.x = senderFrame.origin.x;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.selectionIndicatorImageView.frame = selectionIndicatorFrame;
        } completion:^(BOOL finisched){
            self.userStreamArray = [NSArray array];
            switch (sender.tag) {
                case 0:
                    self.urlString = [NSString stringWithFormat:@"%@%@%@/posts", kBaseURL, kUsersSubURL, self.userId];
                    [self updateUserStreamArraySinceId:nil beforeId:nil];
                    break;
                case 3:
                    self.urlString = [NSString stringWithFormat:@"%@%@%@/stars", kBaseURL, kUsersSubURL, self.userId];
                    [self updateUserStreamArraySinceId:nil beforeId:nil];
                    break;
                default:
                    break;
            }
        }];
    }
}

- (IBAction)followButtonTouched:(UIButton *)sender {    
    if ([self.userId isEqualToString:@"me"]) {
        FilesTableViewController *filesTableViewController = [[FilesTableViewController alloc] initWithStyle:UITableViewStylePlain];
        filesTableViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:filesTableViewController animated:YES];
    } else {
        sender.enabled = NO;

        //    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
        NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@/follow?access_token=%@", kBaseURL, kUsersSubURL, self.userId, accessToken];
        
        NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

        if (self.youFollow) {
            [postRequest setHTTPMethod:@"DELETE"];
        } else {
            [postRequest setHTTPMethod:@"POST"];
        }
        
        UIActivityIndicatorView *activitiIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activitiIndicatorView.frame = sender.bounds;
        [sender addSubview:activitiIndicatorView];
        [activitiIndicatorView startAnimating];
        
        PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
    //        NSDictionary *userDict = [connection dictionaryFromDownloadedData];
    //        dhDebug(@"userDict: %@", userDict);
            
            if (self.youFollow) {
                SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully unfollowed", nil) andSize:CGSizeMake(self.view.frame.size.width, 44.0f)];
                [slideInView showWithTimer:3.0f inView:self.tableView from:SlideInViewTop];
                [self.followButton setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
                self.youFollow = NO;
            } else {
                SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully followed", nil) andSize:CGSizeMake(self.view.frame.size.width, 44.0f)];
                [slideInView showWithTimer:3.0f inView:self.tableView from:SlideInViewTop];
                [self.followButton setTitle:NSLocalizedString(@"unfollow", nil) forState:UIControlStateNormal];
                self.youFollow = YES;
            }
            [activitiIndicatorView stopAnimating];
            [activitiIndicatorView removeFromSuperview];
            
            sender.enabled = YES;
        }];
        [dhConnection start];
    }
}

- (IBAction)muteButtonTouched:(UIButton *)sender {
    
    if ([self.userId isEqualToString:@"me"]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        DHFollowerCollectionViewController *followerCollectionViewController = [storyBoard instantiateViewControllerWithIdentifier:@"FollowerViewController"];
        followerCollectionViewController.urlString = [NSMutableString stringWithFormat:@"%@%@%@/muted", kBaseURL, kUsersSubURL, self.userId];
        [self.navigationController pushViewController:followerCollectionViewController animated:YES];
    } else {
        sender.enabled = NO;
        //    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
        NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@/mute?access_token=%@", kBaseURL, kUsersSubURL, self.userId, accessToken];
        
        NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        if (self.youMuted) {
            [postRequest setHTTPMethod:@"DELETE"];
        } else {
            [postRequest setHTTPMethod:@"POST"];
        }
        
        UIActivityIndicatorView *activitiIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activitiIndicatorView.frame = sender.bounds;
        [sender addSubview:activitiIndicatorView];
        [activitiIndicatorView startAnimating];
        
        PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//            NSDictionary *userDict = [connection dictionaryFromDownloadedData];
//            dhDebug(@"userDict: %@", userDict);
            
            if (self.youMuted) {
                SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully unmuted", nil) andSize:CGSizeMake(self.view.frame.size.width, 44.0f)];
                [slideInView showWithTimer:3.0f inView:self.tableView from:SlideInViewTop];
                [self.muteButton setTitle:@"mute" forState:UIControlStateNormal];
                self.youMuted = NO;
            } else {
                SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Successfully muted", nil) andSize:CGSizeMake(self.view.frame.size.width, 44.0f)];
                [slideInView showWithTimer:3.0f inView:self.tableView from:SlideInViewTop];
                [self.muteButton setTitle:@"unmute" forState:UIControlStateNormal];
                self.youMuted = YES;
            }
            [activitiIndicatorView stopAnimating];
            [activitiIndicatorView removeFromSuperview];
            
            sender.enabled = YES;
        }];
        [dhConnection start];
    }
}

- (IBAction)messageButtonTouched:(UIButton*)sender {
    if ([self.userId isEqualToString:@"me"]) {
        [self performSegueWithIdentifier:@"ShowInteractions" sender:self];
    } else {
        [self performSegueWithIdentifier:@"MentionUser" sender:self];
    }
}

- (void)openSafariWithDomain:(UIButton*)sender {
    NSURL  *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", _userDictionary[@"verified_domain"]]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)avatarTouched: (UITapGestureRecognizer*)sender {
    CGRect myNewAvatarFrame;
    CGFloat myNewAlpha;
//    CGFloat myNewAngle;
    if (self.headerCoverView.alpha < 0.1f) {
        myNewAvatarFrame = CGRectMake(60.0f, 20.0f, 200.0f, 200.0f);
        myNewAlpha = 0.7f;
//        myNewAngle = 0.0f;
    } else {
        myNewAvatarFrame = self.avatarFrame;
        myNewAlpha = 0.0f;
//        myNewAngle = -0.05f;
    }
    [UIView animateWithDuration:0.3f animations:^{
//        self.avatarImageView.layer.affineTransform = CGAffineTransformMakeRotation(myNewAngle);
        self.avatarImageView.frame = myNewAvatarFrame;
        self.headerCoverView.alpha = myNewAlpha;
    } completion:^(BOOL finished){
        
    }];
}

- (void)updateChannelsArray:(NSNotification*)note {
    self.channelsArray = [note.userInfo objectForKey:@"channelsArray"];
   
    NSInteger numberOfNewMessages = 0;
    for (NSDictionary *channelDict in self.channelsArray) {
        if ([[channelDict objectForKey:@"has_unread"] boolValue]) {
            numberOfNewMessages = numberOfNewMessages + 1;
        }
    }
    NSString *messagesString = (numberOfNewMessages == 1) ? NSLocalizedString(@"message", nil) : NSLocalizedString(@"messages", nil);
    [self.messagesButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d new %@", nil), numberOfNewMessages, messagesString] forState:UIControlStateNormal];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFollowing"]) {
        [segue.destinationViewController setValue:[NSMutableString stringWithFormat:@"%@%@%@/following", kBaseURL, kUsersSubURL, self.userId] forKey:@"urlString"];
        [segue.destinationViewController setValue:@"Following" forKey:@"title"];
        [segue.destinationViewController setValue:self.title forKey:@"nameString"];
        if ([self.userId isEqualToString:@"me"]) {
            [segue.destinationViewController setValue:@NO forKey:@"showIFollowBanner"];
        } else {
            [segue.destinationViewController setValue:@YES forKey:@"showIFollowBanner"];
        }
        [segue.destinationViewController setValue:@YES forKey:@"showFollowsMeBanner"];
    } else if ([segue.identifier isEqualToString:@"showFollower"]) {
        [segue.destinationViewController setValue:[NSMutableString stringWithFormat:@"%@%@%@/followers", kBaseURL, kUsersSubURL, self.userId] forKey:@"urlString"];
        [segue.destinationViewController setValue:@"Follower" forKey:@"title"];
        [segue.destinationViewController setValue:self.title forKey:@"nameString"];
        if ([self.userId isEqualToString:@"me"]) {
            [segue.destinationViewController setValue:@NO forKey:@"showFollowsMeBanner"];
        } else {
            [segue.destinationViewController setValue:@YES forKey:@"showFollowsMeBanner"];
        }
        [segue.destinationViewController setValue:@YES forKey:@"showIFollowBanner"];
    } else if ([segue.identifier isEqualToString:@"MentionUser"]) {
        DHCreateStatusViewController *creationViewController = ((UINavigationController*)segue.destinationViewController).viewControllers[0];
        [creationViewController setValue:self.title forKey:@"consigneeString"];
        [creationViewController setIsPrivateMessage:YES];
    } else if ([segue.identifier isEqualToString:@"ShowInbox"]) {
        [segue.destinationViewController setChannelsArray:self.channelsArray];
    } else {
        [super prepareForSegue:segue sender:sender];
    }

}

- (void)searchButtonTouched:(UIBarButtonItem*)sender {
    [self performSegueWithIdentifier:@"SearchForUsers" sender:self];
}

- (void)descriptionTextViewTapped:(UITapGestureRecognizer*)sender {
    CGPoint locationInPostText = [sender locationInView:self.descriptionTextView];
    
    NSString *linkString = [self.descriptionTextView linkForPoint:locationInPostText];

    if (linkString) {
        [self performSegueWithIdentifier:@"ShowWeb" sender:linkString];
    }
}

- (void)dissmisData:(NSNotification*)notification {
    [super dissmisData:notification];
    self.profileImage.image = nil;
    self.avatarImageView.image = nil;
}

- (void)cancel:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
