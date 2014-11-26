//
//  DHCreatePostViewController.m
//  Appetizr
//
//  Created by dasdom on 16.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHCreateStatusViewController.h"
#import "DHSearchViewController.h"
#import "PRPConnection.h"
#import "PRPAlertView.h"
#import <QuartzCore/QuartzCore.h>
//#import "DHGlobalObjects.h"
#import "Base64.h"
#import "DHActionSheet.h"
#import "SSKeychain.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LinkCreationViewController.h"
#import "PlacesViewController.h"
#import <CoreText/CoreText.h>
#import "DHAppDelegate.h"
#import "ImageHelper.h"
#import "DDHTextView.h"

@interface DHCreateStatusViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet DDHTextView *postTextView;
@property (weak, nonatomic) IBOutlet UITextView *replyToTextView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *postHostView;
@property (weak, nonatomic) IBOutlet UILabel *letterCount;
@property (weak, nonatomic) IBOutlet UILabel *smallLetterCount;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIButton *mentionButton;
@property (weak, nonatomic) IBOutlet UIButton *hashTagButton;
@property (nonatomic, strong) NSArray *followingArray;
@property (nonatomic) NSUInteger startOfMention;
@property (nonatomic) NSUInteger startOfHashtag;
@property (nonatomic) NSUInteger lenthOfMentionSubstring;
@property (weak, nonatomic) IBOutlet UIScrollView *userNamesScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *accountsScrollView;
@property (weak, nonatomic) IBOutlet UINavigationItem *theNavigationItem;
@property (nonatomic) BOOL firstCall;
@property (weak, nonatomic) IBOutlet UIView *annotationHostView;

@property (nonatomic, strong) NSArray *userNameArray;
@property (nonatomic, strong) NSArray *hashtagArray;

@property (nonatomic, strong) NSArray *accountsArray;
@property (nonatomic, strong) NSString *accountNameForPost;

@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UIButton *draftsButton;
@property (nonatomic, strong) NSString *postTextString;

@property (nonatomic, strong) NSArray *draftsArray;

@property (nonatomic, strong) UIImage *postImage;
@property (weak, nonatomic) IBOutlet UIButton *nowPlayingButton;

@property (nonatomic) BOOL broadcastPost;

@property (nonatomic) NSRange startRange;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic, strong) NSArray *linkArray;
@property (nonatomic, strong) UIColor *linkColor;

@property (nonatomic, strong) UIPopoverController *popOverController;
@property (weak, nonatomic) IBOutlet UIImageView *replyToHandle;
@property (weak, nonatomic) IBOutlet UIImageView *replyFromHandle;

@property (nonatomic, assign) CGFloat textViewYOrigin;
@property (nonatomic, assign) NSInteger maxLetters;

@end

@implementation DHCreateStatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateLetterCount];
    
    UISwipeGestureRecognizer *swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownHappend:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.postTextView addGestureRecognizer:swipeDownGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpHappend:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.postTextView addGestureRecognizer:swipeUpGestureRecognizer];
    
    self.postHostView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.postHostView.layer.shadowOffset = CGSizeMake(0.0f, -3.0f);
    self.postHostView.layer.shadowOpacity = 0.8f;
    self.postHostView.layer.shadowRadius = 3.0f;
    
    self.textViewYOrigin = self.postHostView.frame.origin.y;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.textViewYOrigin -= 20.0f;
        
        CGRect replyToTextFrame = self.replyToTextView.frame;
        replyToTextFrame.origin.y -= 20.0f;
        self.replyToTextView.frame = replyToTextFrame;
    }
    
//    self.mentionButton.layer.cornerRadius = 10.0f;
//    self.mentionButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.mentionButton.layer.borderWidth = 1.0f;

    [self.mentionButton addTarget:self action:@selector(mentionButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
//    self.hashTagButton.layer.cornerRadius = 10.0f;
//    self.hashTagButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.hashTagButton.layer.borderWidth = 1.0f;
    
    self.replyToTextView.text = self.replyToText;
//    if (self.replyToText) {
//        self.replyToHandle.hidden = NO;
//    } else {
//        self.replyToHandle.hidden = YES;
//    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        self.letterCount.shadowColor = [kDarkMainColor colorWithAlphaComponent:0.5f];
//        self.replyFromHandle.image = [ImageHelper swipeHandleWithStrokeColor:kDarkTextColor];
//        self.replyToHandle.image = [ImageHelper swipeHandleWithStrokeColor:kDarkTextColor];
        self.letterCount.shadowColor = [[DHGlobalObjects sharedGlobalObjects].darkMainColor colorWithAlphaComponent:0.5f];
        self.replyFromHandle.image = [ImageHelper swipeHandleWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
        self.replyToHandle.image = [ImageHelper swipeHandleWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
        self.postTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.letterCount.shadowColor = [[DHGlobalObjects sharedGlobalObjects].mainColor colorWithAlphaComponent:0.5f];
        self.replyFromHandle.image = [ImageHelper swipeHandleWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].textColor];
        self.replyToHandle.image = [ImageHelper swipeHandleWithStrokeColor:[DHGlobalObjects sharedGlobalObjects].textColor];
        self.postTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    }
//    NSString *urlString = [NSString stringWithFormat:@"%@%@me/following/ids", kBaseURL, kUsersSubURL];
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
//    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@?access_token=%@", urlString, accessToken];
//    dhDebug(@"urlStringWithAccessToken: %@", urlStringWithAccessToken);
//    DHConnection *dhConnection = [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//        NSArray *idArray = [connection arrayFromDownloadedData];
//        
//        dhDebug(@"self.followingArray: %@", self.followingArray);
//    }];
//    [dhConnection start];

//    if ([[UIScreen mainScreen] bounds].size.height > 480) {
//        self.replyFromHandle.hidden = YES;
//    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.postTextView.font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
    
    if ([userDefaults boolForKey:kNormalKeyboard]) {
        self.postTextView.keyboardType = UIKeyboardTypeDefault;
    } else {
        self.postTextView.keyboardType = UIKeyboardTypeTwitter;
    }
    
    [self.postTextView requireGestureRecognizerToFail:swipeDownGestureRecognizer];
    [self.postTextView requireGestureRecognizerToFail:swipeUpGestureRecognizer];
    
    self.postTextView.layoutManager.allowsNonContiguousLayout = NO;
    
    self.startOfMention = 0;
    self.lenthOfMentionSubstring = 0;
    self.startOfHashtag = 0;
    
    self.userNameArray = [[[[DHGlobalObjects sharedGlobalObjects] userNameSet] allObjects] sortedArrayUsingSelector:@selector(compare:)];
    self.hashtagArray = [[[[DHGlobalObjects sharedGlobalObjects] hashtagSet] allObjects] sortedArrayUsingSelector:@selector(compare:)];

    self.firstCall = YES;
    
    if (!self.consigneeArray) {
        self.consigneeArray = [NSArray array];
    }
    
    if ([userDefaults boolForKey:kDarkMode]) {
//        self.postHostView.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.replyToTextView.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.replyToTextView.textColor = kDarkTextColor;
//        self.letterCount.textColor = kDarkCellBackgroundColorDefault;
//        self.letterCount.shadowColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:0.6f];
//        self.postTextView.textColor = kDarkTextColor;
//        self.bottomView.backgroundColor = kDarkMainColor;
//        [self.navigationBar setTintColor:kDarkMainColor];
//        self.linkColor = kDarkLinkColor;
        self.postHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        self.replyToTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        self.replyToTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        self.letterCount.textColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        self.letterCount.shadowColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:0.6f];
        self.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        self.bottomView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
//        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
//        {
//            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
//            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
//        }
//        else
//        {
//            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
//        }
        self.linkColor = [DHGlobalObjects sharedGlobalObjects].darkLinkColor;
    } else {
        self.postHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        self.replyToTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        self.replyToTextView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        self.letterCount.textColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        self.letterCount.shadowColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:0.6f];
        self.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        self.bottomView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
//        if ([self.navigationBar respondsToSelector:@selector(barTintColor)])
//        {
//            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
//            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].textColor];
//        }
//        else
//        {
//            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
//        }
        self.linkColor = [DHGlobalObjects sharedGlobalObjects].linkColor;
    }
    
    MPMediaItem *song = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    if (!song) {
        self.nowPlayingButton.hidden = YES;
    }

    self.linkArray = [NSArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageDidChange:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePost) name:UIApplicationWillTerminateNotification object:nil];
    
//    CGFloat xPos = 0.0f;
//    CGFloat xContentOffset = 0.0f;
//    self.accountNameForPost = [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey];
//    self.accountsArray = [userDefaults objectForKey:kUserArrayKey];
//    for (NSString *accountName in self.accountsArray) {
//        if ([accountName isEqualToString:self.accountNameForPost]) {
//            xContentOffset = xPos;
//        }
//        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos, 0.0f, self.accountsScrollView.frame.size.width, self.accountsScrollView.frame.size.height)];
//        accountLabel.backgroundColor = [UIColor clearColor];
//        accountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"post as %@", nil), accountName];
//        accountLabel.textAlignment = NSTextAlignmentCenter;
//        if ([userDefaults boolForKey:kDarkMode]) {
//            accountLabel.textColor = kDarkTextColor;
//        } else {
//            accountLabel.textColor = kLightTextColor;
//        }
//        [self.accountsScrollView addSubview:accountLabel];
//        xPos += self.accountsScrollView.frame.size.width;
//    }
//    self.accountsScrollView.contentSize = CGSizeMake(xPos, self.accountsScrollView.frame.size.height);
//    self.accountsScrollView.contentOffset = CGPointMake(xContentOffset, 0.0f);
//    self.accountsScrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    if (self.postTextString) {
//        NSDictionary *attributeDict = @{NSFontAttributeName: self.postTextView.font};
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.postTextString attributes:attributeDict];
//        for (NSDictionary *linkDict in self.linkArray) {
//            [attributedString addAttribute:NSForegroundColorAttributeName value:self.linkColor range:[[linkDict objectForKey:@"range"] rangeValue]];
//        }
//        self.postTextView.attributedText = attributedString;
//        self.postTextView.selectedRange = self.selectedRange;
        self.postTextView.text = self.postTextString;
        return;
    }
    
    NSString *myName = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey];
    
    dhDebug(@"myName: %@", myName);
    dhDebug(@"self.consigneeArray: %@", self.consigneeArray);
    
    NSMutableString *mutableConsigneeString = [[NSMutableString alloc] initWithString:@""];
    if (self.consigneeString) {
        if ([self.consigneeString isEqualToString:myName]) {
            [mutableConsigneeString appendString:@"\n"];
        } else {
            [mutableConsigneeString appendFormat:@"@%@ ", self.consigneeString];
            if ([self.consigneeArray count] && !self.isPrivateMessage) {
                [mutableConsigneeString appendString:@"\n"];
            }
        }
    }
    
    NSString *languageString = [[[UITextInputMode currentInputMode].primaryLanguage componentsSeparatedByString:@"-"] objectAtIndex:0];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
    label.textAlignment = NSTextAlignmentCenter;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        label.textColor = kDarkTextColor;
        label.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
    } else {
        label.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
    }
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
    label.isAccessibilityElement = YES;
    
    self.navigationItem.titleView = label;
    if (self.channelTitle) {
        label.text = [NSString stringWithFormat:@"%@ (%@)", self.channelTitle, languageString];
        self.maxLetters = 2048;
    } else if (self.isPrivateMessage) {
        label.text = @"private message";
        self.maxLetters = 2048;
    } else {
        label.text = [NSString stringWithFormat:NSLocalizedString(@"new post (%@)", nil), languageString];
        self.maxLetters = 256;
    }
    self.theNavigationItem.titleView = label;

    
    for (NSString *consignee in self.consigneeArray) {
        if ([myName isEqualToString:consignee]) {
            continue;
        }
        [mutableConsigneeString appendFormat:@"@%@ ", consignee];
    }
    
    if (self.isPrivateMessage) {
        self.replyToText = [mutableConsigneeString copy];
    } else {
        self.postTextView.text = [mutableConsigneeString copy];
    }
    self.replyToTextView.text = self.replyToText;
    
    if (self.consigneeString && !self.isPrivateMessage) {
        NSRange selectedRange;
        if ([self.consigneeString isEqualToString:myName]) {
            selectedRange = NSMakeRange(0, 0);
        } else {
            selectedRange = NSMakeRange([self.consigneeString length]+2, 0);
        }
        self.postTextView.selectedRange = selectedRange;
    }
    
    CGRect postViewFrame = self.postHostView.frame;
    if (self.replyToText) {
        postViewFrame.origin.y = 44.0f+160.0f;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        postViewFrame.origin.y -= 20.0f;
        postViewFrame.size.height += 20.0f;
    }
    self.postHostView.frame = postViewFrame;
    
    self.draftsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    if (!self.draftsArray) {
        self.draftsArray = [NSArray array];
    }
    if ([self.draftsArray count] < 1) {
        self.draftsButton.hidden = YES;
    } else {
        self.draftsButton.hidden = NO;
    }
    
//    if ([[DBSession sharedSession] isLinked]) {
//        self.takePictureButton.hidden = NO;
//    } else {
//        self.takePictureButton.hidden = YES;
//    }
    
    if (self.postImage) {
        self.pictureImageView.image = self.postImage;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    CGFloat xPos = 0.0f;
    CGFloat xContentOffset = 0.0f;
    self.accountNameForPost = [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey];
    self.accountsArray = [userDefaults objectForKey:kUserArrayKey];
    for (NSString *accountName in self.accountsArray) {
        if ([accountName isEqualToString:self.accountNameForPost]) {
            xContentOffset = xPos;
        }
        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos, 0.0f, self.accountsScrollView.frame.size.width, self.accountsScrollView.frame.size.height)];
        accountLabel.backgroundColor = [UIColor clearColor];
        accountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"post as %@", nil), accountName];
        accountLabel.textAlignment = NSTextAlignmentCenter;
        if ([userDefaults boolForKey:kDarkMode]) {
//            accountLabel.textColor = kDarkTextColor;
            accountLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        } else {
            accountLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        }
        [self.accountsScrollView addSubview:accountLabel];
        xPos += self.accountsScrollView.frame.size.width;
    }
    self.accountsScrollView.contentSize = CGSizeMake(xPos, self.accountsScrollView.frame.size.height);
    self.accountsScrollView.contentOffset = CGPointMake(xContentOffset, 0.0f);
    self.accountsScrollView.delegate = self;
    
    if ([userDefaults boolForKey:kDarkMode]) {
        self.postTextView.inputAccessoryView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
        }
        else
        {
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
        }
    } else {
        self.postTextView.inputAccessoryView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].textColor];
        }
        else
        {
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
        }
    }
    [self.postTextView.inputAccessoryView addSubview:self.userNamesScrollView];
    [self.postTextView.inputAccessoryView addSubview:self.annotationHostView];
    
    UITapGestureRecognizer *tribleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tribleTapHappend:)];
    tribleTapRecognizer.numberOfTapsRequired = 3;
    [self.postTextView.inputAccessoryView addGestureRecognizer:tribleTapRecognizer];
    [self.postTextView requireGestureRecognizerToFail:tribleTapRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateLetterCount];
 
    if (self.isPrivateMessage && !self.consigneeString) {
        if (self.firstCall) {
            self.firstCall = NO;
            [self performSegueWithIdentifier:@"SearchConsignee" sender:self];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    } else {
        CGRect postViewFrame = self.postHostView.frame;
        if (postViewFrame.origin.y > 100.0f) {
            postViewFrame.origin.y = self.textViewYOrigin;
        }
//        [UIView animateWithDuration:0.2f delay:0.0f options:kNilOptions animations:^{
        [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:kNilOptions animations:^{
           self.postHostView.frame = postViewFrame;
        } completion:^(BOOL finished) {
            if (!self.postTextString) {
                [self.postTextView becomeFirstResponder];
            }
        }];
    }

    if (self.quoteString && ![self.quoteString isEqualToString:@""]) {
        NSMutableString *mutableQuoteString = [NSMutableString stringWithString:@""];
        NSInteger startLocation = 0;
        for (NSDictionary *linkDict in self.quoteLinksArray) {
            NSString *subString1 = [self.quoteString substringWithRange:NSMakeRange(startLocation, [[linkDict objectForKey:@"pos"] integerValue]-startLocation)];
//            [mutableQuoteString appendFormat:@"%@[", subString1];
            dhDebug(@"subString1: %@", subString1);
            dhDebug(@"startLocation: %d", startLocation);
            startLocation += subString1.length;
            NSString *subString2 = [self.quoteString substringWithRange:NSMakeRange(startLocation, [[linkDict objectForKey:@"len"] integerValue])];
            dhDebug(@"subString2: %@", subString2);
            startLocation += subString2.length;
            NSRange range;
            range.location = NSNotFound;
            if (startLocation+2 < self.quoteString.length) {
                range = [self.quoteString rangeOfString:@"[" options:kNilOptions range:NSMakeRange(startLocation, 2)];
            }
            if (range.location == NSNotFound) {
                [mutableQuoteString appendFormat:@"%@%@", subString1, subString2];
//                startLocation += subString2.length;
            } else {
                [mutableQuoteString appendFormat:@"%@[%@](%@)", subString1, subString2, [linkDict objectForKey:@"url"]];
                NSRange range = [self.quoteString rangeOfString:@"]" options:kNilOptions range:NSMakeRange(startLocation, self.quoteString.length-startLocation)];
                startLocation = range.location + range.length;
            }
        }
        if (startLocation != 0) {
            NSString *subString3 = [self.quoteString substringWithRange:NSMakeRange(startLocation, self.quoteString.length-startLocation)];
            if (subString3) {
                [mutableQuoteString appendString:subString3];
            }
        }
        
        NSString *quoteString = [mutableQuoteString copy];
        dhDebug(@"quoteString: %@", quoteString);
        if ([quoteString isEqualToString:@""]) {
            quoteString = self.quoteString;
        }
        
        self.postTextView.text = [NSString stringWithFormat:@" >> @%@: %@", self.consigneeString, quoteString];
        NSRange selectedRange = {0, 0};
        self.postTextView.selectedRange = selectedRange;
    }
    
    if (self.draftText) {
        self.postTextView.text = [NSString stringWithFormat:@"%@ ", self.draftText];
        self.postTextView.selectedRange = NSMakeRange([self.draftText length]+1, 0);
        self.draftText = nil;
    }
    
//    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnTap:)]) {
//        [self.navigationController setHidesBarsOnTap:YES];
//        [self.navigationController setHidesBarsWhenKeyboardAppears:YES];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidUnload
{
    [self setPostTextView:nil];
    [self setLetterCount:nil];
    [self setReplyToTextView:nil];
    [self setPostHostView:nil];
    [self setActivityIndicator:nil];
    [self setPostButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)keyboardWillAppear:(NSNotification*)notification {
    CGRect keyboardBounds = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect postViewFrame = self.postHostView.frame;
//    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        postViewFrame.size.height = self.view.frame.size.height - MIN(keyboardBounds.size.height, keyboardBounds.size.width) - self.postTextView.inputAccessoryView.frame.size.height - self.navigationController.navigationBar.frame.size.height + 20.0f;
//    } else {
//        postViewFrame.size.height = self.view.frame.size.height - keyboardBounds.size.width - self.postTextView.inputAccessoryView.frame.size.height - self.navigationController.navigationBar.frame.size.height + 20.0f;
//    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        postViewFrame.origin.y = self.navigationController.navigationBar.frame.size.height;
        postViewFrame.size.height += 20.0f;
    } else {
        postViewFrame.origin.y = self.navigationController.navigationBar.frame.size.height + 20.0f;
    }
    dhDebug(@"self.postTextView.inputAccessoryView.frame: %@", NSStringFromCGRect(self.postTextView.inputAccessoryView.frame));
    self.postHostView.frame = postViewFrame;

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    dhDebug(@"range: %@", NSStringFromRange(range));
    NSMutableArray *mutableLinkArray = [NSMutableArray array];
    for (NSDictionary *linkDict in self.linkArray) {
        NSRange linkRange = [[linkDict objectForKey:@"range"] rangeValue];
        if (linkRange.location > range.location) {
            if ([text length]) {
                linkRange.location = linkRange.location + 1 - range.length;
            } else {
                linkRange.location = linkRange.location - range.length;
            }
            [mutableLinkArray addObject:@{@"linkText": [linkDict objectForKey:@"linkText"], @"url": [linkDict objectForKey:@"url"], @"range": [NSValue valueWithRange:linkRange]}];
        } else {
            [mutableLinkArray addObject:linkDict];
        }
    }
    self.linkArray = [mutableLinkArray copy];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSRange rangeOfLastInsertedCharacter = textView.selectedRange;
    rangeOfLastInsertedCharacter.location = MAX(rangeOfLastInsertedCharacter.location - 1,0);
    rangeOfLastInsertedCharacter.length = 1;
    NSString *lastInsertedSubstring;
    NSString *mentionSubString;
    if (![textView.text isEqualToString:@""]) {
        lastInsertedSubstring = [textView.text substringWithRange:rangeOfLastInsertedCharacter];
        if (self.startOfMention > 0 || self.startOfHashtag > 0) {
            if ([lastInsertedSubstring isEqualToString:@" "] || (self.startOfMention > textView.selectedRange.location || self.startOfHashtag > textView.selectedRange.location)) {
                self.startOfMention = 0;
                self.startOfHashtag = 0;
                self.lenthOfMentionSubstring = 0;
                for (UIView *userNameLabel in self.userNamesScrollView.subviews) {
                    [userNameLabel removeFromSuperview];
                }
                [UIView animateWithDuration:0.25f animations:^{
//                    self.draftsButton.alpha = 1.0f;
                    self.annotationHostView.alpha = 1.0f;
                    self.userNamesScrollView.alpha = 0.0f;
                } completion:^(BOOL finished) {}];

            }
        }
        if (self.startOfMention > 0) {
            self.lenthOfMentionSubstring = textView.selectedRange.location - self.startOfMention;
            NSRange rangeOfMentionSubstring = {self.startOfMention, textView.selectedRange.location - self.startOfMention};
            mentionSubString = [textView.text substringWithRange:rangeOfMentionSubstring];
            dhDebug(@"mentionSubString: %@", mentionSubString);
        
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);

            [self addLabelsForString:mentionSubString fromArray:self.userNameArray preString:@"@"];
        } else if (self.startOfHashtag > 0) {
            self.lenthOfMentionSubstring = textView.selectedRange.location - self.startOfHashtag;
            NSRange rangeOfMentionSubstring = {self.startOfHashtag, textView.selectedRange.location - self.startOfHashtag};
            mentionSubString = [textView.text substringWithRange:rangeOfMentionSubstring];
            dhDebug(@"hashtagSubString: %@", mentionSubString);
            
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);

            [self addLabelsForString:mentionSubString fromArray:self.hashtagArray preString:@"#"];
        } else if ([lastInsertedSubstring isEqualToString:@"@"]) {
            self.startOfMention = textView.selectedRange.location;
            [UIView animateWithDuration:0.25f animations:^{
//                self.draftsButton.alpha = 0.0f;
                self.annotationHostView.alpha = 0.0f;
                self.userNamesScrollView.alpha = 1.0f;
            } completion:^(BOOL finished) {}];
        } else if ([lastInsertedSubstring isEqualToString:@"#"]) {
            self.startOfHashtag = textView.selectedRange.location;
            [UIView animateWithDuration:0.25f animations:^{
//                self.draftsButton.alpha = 0.0f;
                self.annotationHostView.alpha = 0.0f;
                self.userNamesScrollView.alpha = 1.0f;
            } completion:^(BOOL finished) {}];

        }
//            for (UIView *userNameLabel in self.userNamesScrollView.subviews) {
//                [userNameLabel removeFromSuperview];
//            }
//            
//            CGFloat startX = 10.0f;
//            UIFont *userNameFont = [UIFont boldSystemFontOfSize:12.0f];
//            CGSize labelSize = CGSizeMake(0.0f, 0.0f);
//            for (NSString *userName in self.userNameArray) {
//                if ([userName rangeOfString:mentionSubString].location != NSNotFound) {
//                    dhDebug(@"username: %@", userName);
//                    NSString *userNameWithAtSign = [NSString stringWithFormat:@"@%@", userName];
//                    labelSize = [userNameWithAtSign sizeWithFont:userNameFont];
//                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, 0.0f, labelSize.width, 40.0f)];
//                    nameLabel.userInteractionEnabled = YES;
//                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnNameLabelHappend:)];
//                    [nameLabel addGestureRecognizer:tapRecognizer];
//                    nameLabel.font = userNameFont;
//                    nameLabel.text = userNameWithAtSign;
//                    nameLabel.textColor = [UIColor whiteColor];
//                    nameLabel.backgroundColor = [UIColor clearColor];
//                    [self.userNamesScrollView addSubview:nameLabel];
//                    startX = startX + labelSize.width + 5.0f;
//                }
//            }
//            self.userNamesScrollView.contentSize = CGSizeMake(startX + 5.0f, 40.0f);
        
    }
    [self updateLetterCount];
}

- (void)addLabelsForString:(NSString*)substring fromArray:(NSArray*)theArray preString:(NSString*)preString {    
        for (UIView *userNameLabel in self.userNamesScrollView.subviews) {
            [userNameLabel removeFromSuperview];
        }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat startX = 10.0f;
        UIFont *userNameFont = [UIFont boldSystemFontOfSize:12.0f];
        NSInteger numberOfLabels = 0;
        for (NSString *userName in theArray) {
            if ([userName rangeOfString:substring].location != NSNotFound &&
                [userName rangeOfString:substring].location < 1) {
//                dhDebug(@"username: %@", userName);
                CGSize labelSize = CGSizeMake(0.0f, 0.0f);
                NSString *userNameWithAtSign = [NSString stringWithFormat:@"%@%@", preString, userName];
                labelSize = [userNameWithAtSign sizeWithFont:userNameFont];
                labelSize.width = labelSize.width + 6.0f;
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, 0.0f, labelSize.width, 40.0f)];
                nameLabel.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnNameLabelHappend:)];
                [nameLabel addGestureRecognizer:tapRecognizer];
                nameLabel.font = userNameFont;
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//                    nameLabel.textColor = kDarkTintColor;
                    nameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
                } else {
                    nameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
                }
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.textAlignment = NSTextAlignmentCenter;
                dispatch_async(dispatch_get_main_queue(), ^{
                    nameLabel.text = userNameWithAtSign;
                    [self.userNamesScrollView addSubview:nameLabel];
                });
                
                startX = startX + labelSize.width;
                if (numberOfLabels++ > 6) {
                    break;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userNamesScrollView.contentSize = CGSizeMake(startX + 5.0f, 40.0f);
            self.userNamesScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
        });
    });
}

- (void)updateLetterCount {
//    NSString *postString = self.postTextView.text;
//    NSInteger postLength = [postString length];
    NSInteger postLength = [self numberOfCharacters];
    if (self.startOfMention > 0) {
        self.letterCount.text = @"@";
        self.smallLetterCount.text = @"@";
    } else if (self.startOfHashtag > 0) {
        self.letterCount.text = @"#";
        self.smallLetterCount.text = @"#";
    } else {
        self.letterCount.text = [NSString stringWithFormat:@"%d", self.maxLetters-postLength];
        self.smallLetterCount.text = [NSString stringWithFormat:@"%d", self.maxLetters-postLength];
    }
    if (256-postLength <= 5 && self.isPrivateMessage) {
        self.letterCount.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
        self.smallLetterCount.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    } else if (2048-postLength <= 5) {
        self.letterCount.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
        self.smallLetterCount.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            self.letterCount.textColor = kDarkCellBackgroundColorDefault;
//            self.smallLetterCount.textColor = [kDarkTextColor colorWithAlphaComponent:0.3f];
            self.letterCount.textColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
            self.smallLetterCount.textColor = [[DHGlobalObjects sharedGlobalObjects].darkTextColor colorWithAlphaComponent:0.3f];
        } else {
            self.letterCount.textColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
            self.smallLetterCount.textColor = [[DHGlobalObjects sharedGlobalObjects].textColor colorWithAlphaComponent:0.3f];
        }
    }
    
    self.letterCount.isAccessibilityElement = NO;
    self.smallLetterCount.isAccessibilityElement = NO;
    [self.letterCount setNeedsDisplay];
    [self.smallLetterCount setNeedsDisplay];
    
    __weak DHCreateStatusViewController *weakSelf = self;
    NSString *postString = self.postTextView.text;
    if (postString.length < 60) {
        [weakSelf updateTitleWithLanguageString:nil];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *componentsArray = [postString componentsSeparatedByString:@" "];
            NSMutableString *mutablePostString = [NSMutableString string];
            for (NSString *string in componentsArray) {
                if ([string rangeOfString:@"@"].location != NSNotFound) {
                    continue;
                }
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
                NSUInteger numberOfMatches = [detector numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
                if (numberOfMatches > 0) {
                    continue;
                }
                
                [mutablePostString appendFormat:@"%@ ", string];
            }
            NSString *languageGuessedString = (NSString*)CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)mutablePostString, CFRangeMake(0, mutablePostString.length)));
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateTitleWithLanguageString:languageGuessedString];
            });
        });
    }
}

- (NSInteger)numberOfCharacters {
    NSString *postString = self.postTextView.text;
    NSInteger numberOfLinkText = 0;
    NSArray *componentsArray = [postString componentsSeparatedByString:@"]("];
    if ([componentsArray count] > 1) {
        for (int i = 0; i < [componentsArray count]-1; i++) {
            NSString *secondComponent = [componentsArray objectAtIndex:i+1];
            NSArray *secondComponents = [secondComponent componentsSeparatedByString:@")"];
            if ([secondComponents count] < 2) {
                continue;
            }
            NSString *urlString = [secondComponents objectAtIndex:0];
            
            numberOfLinkText += [urlString length];
        }
    }
    return [postString length] - numberOfLinkText;
}

- (IBAction)sendPost:(UIBarButtonItem*)sender {
    NSString *postString = self.postTextView.text;
    NSString *languageGuessedString;
    
    if (postString.length < 60) {
        languageGuessedString = nil;
    } else {
        NSArray *componentsArray = [postString componentsSeparatedByString:@" "];
        NSMutableString *mutablePostString = [NSMutableString string];
        for (NSString *string in componentsArray) {
            if ([string rangeOfString:@"@"].location != NSNotFound) {
                continue;
            }
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
            NSUInteger numberOfMatches = [detector numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
            if (numberOfMatches > 0) {
                continue;
            }
            
            [mutablePostString appendFormat:@"%@ ", string];
        }
        languageGuessedString = (NSString*)CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)mutablePostString, CFRangeMake(0, mutablePostString.length)));
    }
    dhDebug(@"languageGuessedString: %@", languageGuessedString);
    
    NSString *primaryLanguage;
    if (languageGuessedString) {
        primaryLanguage = languageGuessedString;
    } else {
        primaryLanguage = [UITextInputMode currentInputMode].primaryLanguage;
    }
    NSString *languageString;
    if ([primaryLanguage isEqualToString:@"zh-Hant"]) {
        languageString = @"zh_CN";
    } else if ([primaryLanguage isEqualToString:@"zh-Hans"]) {
        languageString = @"zh_TW";
    } else {
        languageString = [[primaryLanguage componentsSeparatedByString:@"-"] objectAtIndex:0];
    }
    dhDebug(@">>>> set language: %@", languageString);

    if (!postString || [postString isEqualToString:@""]) {
        self.postTextView.text = @"#picture";
    }
//    NSInteger postLength = [postString length];
    NSInteger postLength = [self numberOfCharacters];
    if (postLength > self.maxLetters) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"Post is to long", nil) message:NSLocalizedString(@"The post can maximal be 256 characters.", nil) buttonTitle:@"OK"];
        return;
    }
    self.postButton.enabled = NO;
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
     NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:self.accountNameForPost];
    
//    NSString *urlString = [NSString stringWithFormat:@"%@posts?access_token=%@", kBaseURL, accessToken];
    NSString *urlString;
    if (self.isPrivateMessage) {
        urlString = [NSString stringWithFormat:@"%@channels/pm/messages", kBaseURL];
    } else if (self.channelId) {
        urlString = [NSString stringWithFormat:@"%@channels/%@/messages", kBaseURL, self.channelId];
    } else if (self.postImage) {
        urlString = [NSString stringWithFormat:@"%@posts?include_post_annotations=1", kBaseURL];
    } else {
        urlString = [NSString stringWithFormat:@"%@posts?include_post_annotations=1", kBaseURL];
    }
    
    NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
    
    NSDictionary *postDict;
    NSString *postText = [self addMarkdownLinksFromText:self.postTextView.text];
    
    if (self.replyToId) {
        postDict = @{@"text" : postText, @"reply_to" : self.replyToId};
    } else if (self.isPrivateMessage) {
        NSMutableArray *mutableConsigneeArray = [NSMutableArray array];
        [mutableConsigneeArray addObject:[NSString stringWithFormat:@"@%@", self.consigneeString]];
        for (NSString *string in self.consigneeArray) {
            [mutableConsigneeArray addObject:[NSString stringWithFormat:@"@%@", string]];
        }
        postDict = @{@"text" : postText, @"destinations" : mutableConsigneeArray};
    } else {
        postDict = @{@"text" : postText};
    }
    
    [self.activityIndicator startAnimating];

    __weak DHCreateStatusViewController *weakSelf = self;
    if (self.postImage) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy_MM_dd'T'HH_mm_ss'Z'";
        
        NSData *imageData;
        if ([self.imageWithHighQuality boolValue]) {
            imageData = UIImageJPEGRepresentation(self.postImage, 1.0f);
        } else {
            imageData = UIImageJPEGRepresentation(self.postImage, 0.3f);
        }
        
        NSString *imageName = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
            
        NSMutableURLRequest *imageUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/files"]];
        [imageUploadRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
        [imageUploadRequest setHTTPMethod:@"POST"];
        NSString *boundary = @"82481319dca6";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [imageUploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
        NSMutableData *postbody = [NSMutableData data];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"content\"; filename=\"%@.jpg\"\r\n", imageName] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:imageData];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:[@"Content-Disposition: form-data; name=\"metadata\"; filename=\"metadata.json\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:[NSJSONSerialization dataWithJSONObject:@{@"type": @"photo"} options:kNilOptions error:nil]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"type\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"de.dasdom.happy.photo" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [imageUploadRequest setHTTPBody:postbody];
        
        PRPConnection *imagePostConnection = [PRPConnection connectionWithRequest:imageUploadRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:imageUploadRequest progress:^(DHConnection *connection) {
//            dhDebug(@"progress");
//        } completion:^(DHConnection *connection, NSError *error) {
            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//            NSLog(@"Image upload responseDict: %@", responseDict);
            if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                weakSelf.postButton.enabled = YES;
                return;
            }
            NSDictionary *imageDataDict = [responseDict objectForKey:@"data"];
            
            NSMutableDictionary *updatedPostDict = [weakSelf postDictFromPostDict:postDict byAddingLanguageString:languageString linkArray:weakSelf.linkArray imageDict:imageDataDict];

            NSData *postData = [NSJSONSerialization dataWithJSONObject:updatedPostDict options:kNilOptions error:nil];
           
            if (self.broadcastPost) {
                NSString *patterURLString = [NSString stringWithFormat:@"%@posts?include_post_annotations=1", kBaseURL];
                
                NSString *imageName = NSLocalizedString(@"<=>", nil);
                NSMutableArray *mutableLinkArray = [weakSelf.linkArray mutableCopy];
                NSRange linkRange = NSMakeRange(postText.length+3+weakSelf.channelTitle.length, imageName.length);
                NSString *linkURLString = [NSString stringWithFormat:@"patter-app.net/room.html?channel=%@", self.channelId];
                NSDictionary *linkDict = @{@"url": linkURLString, @"range": [NSValue valueWithRange:linkRange]};
                [mutableLinkArray addObject:linkDict];
                weakSelf.linkArray = [mutableLinkArray copy];
                NSString *postTextWithImageLink = [NSString stringWithFormat:@"%@\n\n%@ %@", postText, weakSelf.channelTitle, imageName];
                if (postTextWithImageLink.length < 256) {
                    [updatedPostDict setObject:postTextWithImageLink forKey:@"text"];
                    NSMutableDictionary *broadcastChannelDict = [weakSelf postDictFromPostDict:updatedPostDict byAddingLanguageString:languageString linkArray:weakSelf.linkArray imageDict:imageDataDict];
                    
                    NSData *broadcastPostData = [NSJSONSerialization dataWithJSONObject:broadcastChannelDict options:kNilOptions error:nil];
                    [weakSelf postPostToADNWithURLString:patterURLString andData:broadcastPostData dismissViewController:NO];
                }
            }
            
            [weakSelf postPostToADNWithURLString:urlString andData:postData dismissViewController:YES];
            
        }];
        [imagePostConnection start];
        
    } else {
        NSMutableDictionary *updatedPostDict = [weakSelf postDictFromPostDict:postDict byAddingLanguageString:languageString linkArray:weakSelf.linkArray imageDict:nil];
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:updatedPostDict options:kNilOptions error:nil];
        
        if (self.broadcastPost) {
            NSString *patterURLString = [NSString stringWithFormat:@"%@posts?include_post_annotations=1", kBaseURL];
            
            NSString *imageName = NSLocalizedString(@"<=>", nil);
            NSMutableArray *mutableLinkArray = [weakSelf.linkArray mutableCopy];
            NSRange linkRange = NSMakeRange(postText.length+3+weakSelf.channelTitle.length, imageName.length);
            NSString *linkURLString = [NSString stringWithFormat:@"patter-app.net/room.html?channel=%@", self.channelId];
            NSDictionary *linkDict = @{@"url": linkURLString, @"range": [NSValue valueWithRange:linkRange]};
            [mutableLinkArray addObject:linkDict];
            weakSelf.linkArray = [mutableLinkArray copy];
            NSString *postTextWithImageLink = [NSString stringWithFormat:@"%@\n\n%@ %@", postText, weakSelf.channelTitle, imageName];
            if (postTextWithImageLink.length < 256) {
                [updatedPostDict setObject:postTextWithImageLink forKey:@"text"];
                NSMutableDictionary *broadcastChannelDict = [weakSelf postDictFromPostDict:updatedPostDict byAddingLanguageString:languageString linkArray:weakSelf.linkArray imageDict:nil];
                
                NSData *broadcastPostData = [NSJSONSerialization dataWithJSONObject:broadcastChannelDict options:kNilOptions error:nil];
                [weakSelf postPostToADNWithURLString:patterURLString andData:broadcastPostData dismissViewController:NO];
            }
        }
        
        [weakSelf postPostToADNWithURLString:urlString andData:postData dismissViewController:YES];
    }

}

- (NSMutableDictionary*)postDictFromPostDict:(NSDictionary*)postDict byAddingLanguageString:(NSString*)languageString linkArray:(NSArray*)linkArray imageDict:(NSDictionary*)imageDict {
    NSArray *supportedLanguages = @[@"ar",@"az",@"bg",@"bn",@"bs",@"ca",
                                    @"cs",@"cy",@"da",@"de",@"el",@"en",
                                    @"en_GB",@"es",@"es_AR",@"es_MX",@"es_NI",
                                    @"et",@"eu",@"fa",@"fi",@"fr",@"fy_NL",
                                    @"ga",@"gl",@"he",@"hi",@"hr",@"hu",
                                    @"id",@"is",@"it",@"ja",@"ka",@"kk",
                                    @"km",@"kn",@"ko",@"lt",@"lv",@"mk",
                                    @"ml",@"mn",@"nb",@"ne",@"nl",@"nn",
                                    @"no",@"pa",@"pl",@"pt",@"pt_BR",@"ro",
                                    @"ru",@"sk",@"sl",@"sq",@"sr",@"sr_Latn",
                                    @"sv",@"sw",@"ta",@"te",@"th",@"tr",
                                    @"tt",@"uk",@"ur",@"vi",@"zh_CN",@"zh_TW"];
    
    NSMutableArray *mutableAnnotationArray = [NSMutableArray array];
    if (imageDict) {
        NSDictionary *imageAnnotationDict = @{@"file_id" : [imageDict objectForKey:@"id"], @"file_token" : [imageDict objectForKey:@"file_token"], @"format" : @"oembed"};
        
        NSDictionary *annotationValueDict = @{@"+net.app.core.file": imageAnnotationDict};
        NSDictionary *annotationDict = @{@"type": @"net.app.core.oembed", @"value" : annotationValueDict};
        [mutableAnnotationArray addObject:annotationDict];
    }
        
    NSDictionary *languageAnnotationDict = @{@"type": @"net.app.core.language", @"value": @{@"language": languageString}};
    NSMutableDictionary *mutablePostDict = [postDict mutableCopy];
    if ([supportedLanguages containsObject:languageString]) {
        [mutableAnnotationArray addObject:languageAnnotationDict];
    }
    if (self.themeAnnotationDictionary) {
        [mutableAnnotationArray addObject:self.themeAnnotationDictionary];
    }
    if (self.annotationsArray) {
        [mutableAnnotationArray addObjectsFromArray:self.annotationsArray];
    }
    if (self.locationId) {
        NSDictionary *annotationValueDict = @{@"+net.app.core.place": @{@"factual_id": self.locationId}};
        NSDictionary *annotationDict = @{@"type": @"net.app.core.checkin", @"value" : annotationValueDict};
        [mutableAnnotationArray addObject:annotationDict];
    }
    
    [mutablePostDict setObject:mutableAnnotationArray forKey:@"annotations"];
    
    NSString *postText = [postDict objectForKey:@"text"];
    
    if (imageDict) {
        if (postText.length+15 < 256 && !self.channelId && !self.isPrivateMessage) {
            if ([self.linkArray count]) {
                NSString *imageName = NSLocalizedString(@"Image", nil);
                NSMutableArray *mutableLinkArray = [self.linkArray mutableCopy];
                NSRange linkRange = NSMakeRange(postText.length+1, imageName.length);
                NSDictionary *linkDict = @{@"url": @"photos.app.net/{post_id}/1", @"range": [NSValue valueWithRange:linkRange]};
                [mutableLinkArray addObject:linkDict];
                self.linkArray = [mutableLinkArray copy];
                NSString *postTextWithImageLink = [NSString stringWithFormat:@"%@\n%@", postText, imageName];
                [mutablePostDict setObject:postTextWithImageLink forKey:@"text"];
            } else {
                NSString *postTextWithImageLink = [NSString stringWithFormat:@"%@\nphotos.app.net/{post_id}/1", postText];
                [mutablePostDict setObject:postTextWithImageLink forKey:@"text"];
            }
        }
    }
    
    if ([self.linkArray count]) {
        [mutablePostDict setObject:@{@"links": [self entitiesLinkArrayFromLinkArray:self.linkArray], @"parse_links": @YES} forKey:@"entities"];
//    } else if (self.quoteLinksArray) {
//        [mutablePostDict setObject:@{@"links": [self entitiesLinkArrayFromQuoteLinkArray:self.quoteLinksArray withPostText:postText]} forKey:@"entities"];
//    } else {
//        [mutablePostDict setObject:@{@"links": [self entitiesLinkArrayFromLinkArray:self.linkArray]} forKey:@"entities"];
    }

    return mutablePostDict;
}

- (void)postPostToADNWithURLString:(NSString*)urlString andData:(NSData*)postData dismissViewController:(BOOL)dismissViewController {
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:self.accountNameForPost];

    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
    [postRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
    [postRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [postRequest setHTTPBody:postData];

    __weak DHCreateStatusViewController *weakSelf = self;
    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:postRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
        [weakSelf.activityIndicator stopAnimating];
        
        dhDebug(@"error: %@", error);
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
        dhDebug(@"responseDict: %@", responseDict);
        if (error) {
//            [DHAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            weakSelf.postButton.enabled = YES;
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
        if ([[metaDict objectForKey:@"code"] integerValue] != 200) {
//            [DHAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:[metaDict objectForKey:@"error_message"] buttonTitle:@"OK"];
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            weakSelf.postButton.enabled = YES;
            return;
        }
        if (dismissViewController) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                if ([weakSelf appDelegate].returnURLString) {
                    [[weakSelf appDelegate] returnToCaller];
                }
            }];
        }
    }];
    [dhConnection start];
}

- (NSArray*)entitiesLinkArrayFromLinkArray:(NSArray*)linkArray {
    NSMutableArray *mutableLinkArray = [NSMutableArray array];
    for (NSDictionary *linkDict in self.linkArray) {
        NSRange linkRange = [[linkDict objectForKey:@"range"] rangeValue];
        [mutableLinkArray addObject:@{@"url": [linkDict objectForKey:@"url"], @"pos": [NSString stringWithFormat:@"%d", linkRange.location], @"len": [NSString stringWithFormat:@"%d", linkRange.length]}];
    }
    return mutableLinkArray;
}

- (NSArray*)entitiesLinkArrayFromQuoteLinkArray:(NSArray*)linkArray withPostText:(NSString*)postText {
    NSMutableArray *mutableLinkArray = [NSMutableArray array];
    for (NSDictionary *linkDict in linkArray) {
        NSMutableDictionary *mutableLinkDict = [linkDict mutableCopy];
        NSInteger changedPos = [[mutableLinkDict objectForKey:@"pos"] integerValue];
        changedPos += postText.length - self.quoteString.length;
        [mutableLinkDict setObject:[NSString stringWithFormat:@"%d", changedPos] forKey:@"pos"];
        [mutableLinkArray addObject:mutableLinkDict];
    }
    return mutableLinkArray;
}

- (NSString*)addMarkdownLinksFromText:(NSString*)text {
    NSMutableArray *mutableLinkArray = [self.linkArray mutableCopy];
    NSArray *componentsArray = [text componentsSeparatedByString:@"]("];
    NSMutableString *postString = [NSMutableString string];
    NSString *previousLinkString;
    NSMutableString *lastString = [NSMutableString string];
    if ([componentsArray count] > 1) {
        for (int i = 0; i < [componentsArray count]-1; i++) {
            NSString *firstComponent = [componentsArray objectAtIndex:i];
            NSArray *firstComponents = [firstComponent componentsSeparatedByString:@"["];
            if ([firstComponents count] < 2) {
                [postString appendString:firstComponent];
                continue;
            }
            NSString *linkString = [firstComponents objectAtIndex:1];
            
            NSString *secondComponent = [componentsArray objectAtIndex:i+1];
            NSArray *secondComponents = [secondComponent componentsSeparatedByString:@")"];
            if ([secondComponents count] < 2) {
                continue;
            }
            NSString *urlString = [secondComponents objectAtIndex:0];
            
            if (previousLinkString) {
                NSString *stringToRemove = [NSString stringWithFormat:@"%@)", previousLinkString];
                NSString *stringToAppend = [[firstComponents objectAtIndex:0] stringByReplacingOccurrencesOfString:stringToRemove withString:@""];
                [postString appendString:stringToAppend];
            } else {
                [postString appendString:[firstComponents objectAtIndex:0]];
            }
            previousLinkString = nil;
            
            NSRange range = {[postString length], [linkString length]};

            [mutableLinkArray addObject:@{@"linkText": linkString, @"url": [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"range": [NSValue valueWithRange:range]}];
            
            [postString appendString:[firstComponents objectAtIndex:1]];
            
            lastString = [NSMutableString string];
            for (int i = 1; i < [secondComponents count]; i++) {
                [lastString appendString:[secondComponents objectAtIndex:i]];
                [lastString appendString:@")"];
            }
            [lastString deleteCharactersInRange:NSMakeRange(lastString.length-1, 1)];
            
            previousLinkString = [urlString copy];
        }
    }
    if (lastString) {
        [postString appendString:lastString];
    }
    
    if ([postString isEqualToString:@""]) {
        postString = [text copy];
    }
    self.linkArray = [mutableLinkArray copy];
    dhDebug(@"self.linkArray: %@", self.linkArray);
    return postString;
}

- (void)swipeDownHappend:(UISwipeGestureRecognizer*)sender {

    CGRect postViewFrame = self.postHostView.frame;
    if ((postViewFrame.origin.y < 100.0f && self.replyToText) || self.isPrivateMessage) {
        postViewFrame.origin.y = self.textViewYOrigin+120.0f;
    } else {
        postViewFrame.origin.y = self.textViewYOrigin;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.postHostView.frame = postViewFrame;
    } completion:^(BOOL finished) {
    
    }];
}

- (void)swipeUpHappend:(UISwipeGestureRecognizer*)sender {

    CGRect postViewFrame = self.postHostView.frame;
    if (postViewFrame.origin.y > 100.0f) {
        postViewFrame.origin.y = self.textViewYOrigin;
    } else {
        postViewFrame.origin.y = 0.0f;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.postHostView.frame = postViewFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)tribleTapHappend:(UITapGestureRecognizer*)sender {
//    if (sender.state == UIGestureRecognizerStateBegan) {
        [self sendPost:nil];
//    }
}

- (void)mentionButtonTouched:(UIButton*)sender {
    dhDebug(@"userNameArray: %@", self.userNameArray);
}

- (IBAction)cancelPost:(UIBarButtonItem *)sender {
    if ([self.postTextView.text isEqualToString:@""] || self.isPrivateMessage) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self appDelegate].returnURLString) {
                [[self appDelegate] returnToCaller];
            }
        }];
        return;
    }
    [PRPAlertView showWithTitle:NSLocalizedString(@"Save draft", nil) message:NSLocalizedString(@"Do you want to save the post as a draft?", nil) cancelTitle:NSLocalizedString(@"Discard", nil) cancelBlock:^{
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self appDelegate].returnURLString) {
                [[self appDelegate] returnToCaller];
            }
        }];
    } otherTitle:NSLocalizedString(@"Save", nil) otherBlock:^{
//        NSMutableArray *mutableDraftsArray = [self.draftsArray mutableCopy];
//        NSMutableDictionary *draftDict = [NSMutableDictionary dictionary];
//        if (self.replyToId) {
//            [draftDict setObject:self.replyToId forKey:@"replyToId"];
//        }
//        if (self.postTextView.text) {
//            [draftDict setObject:self.postTextView.text forKey:@"postText"];
//        }
//        if (self.postImage) {
//            NSData *imageData = UIImageJPEGRepresentation(self.postImage, 1.0f);
//
//            NSFileManager *defaultManager = [NSFileManager defaultManager];
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"yyyy_MM_dd'T'HH_mm_ss'Z'";
//            NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [dateFormatter stringFromDate:[NSDate date]]];
//            NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
//
//            BOOL success = [defaultManager createFileAtPath:imagePath contents:imageData attributes:nil];
//            NSLog(@"success: %@", success ? @"YES" : @"NO");
//            
//            [draftDict setObject:imagePath forKey:@"imagePath"];
//        }
//        [draftDict setObject:[NSDate date] forKey:@"draftDate"];
//        [mutableDraftsArray addObject:draftDict];
//        self.draftsArray = [mutableDraftsArray copy];
//        [NSKeyedArchiver archiveRootObject:self.draftsArray toFile:[self archivePath]];
//        [self dismissViewControllerAnimated:YES completion:^{
//            if ([self appDelegate].returnURLString) {
//                [[self appDelegate] returnToCaller];
//            }
//        }];
        [self savePost];
    }];
}

- (void)savePost {
    NSMutableArray *mutableDraftsArray = [self.draftsArray mutableCopy];
    NSMutableDictionary *draftDict = [NSMutableDictionary dictionary];
    if (self.replyToId) {
        [draftDict setObject:self.replyToId forKey:@"replyToId"];
    }
    if (self.postTextView.text) {
        [draftDict setObject:self.postTextView.text forKey:@"postText"];
    }
    if (self.postImage) {
        NSData *imageData = UIImageJPEGRepresentation(self.postImage, 1.0f);
        
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy_MM_dd'T'HH_mm_ss'Z'";
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [dateFormatter stringFromDate:[NSDate date]]];
        NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        
        BOOL success = [defaultManager createFileAtPath:imagePath contents:imageData attributes:nil];
        dhDebug(@"success: %@", success ? @"YES" : @"NO");
        
        [draftDict setObject:imagePath forKey:@"imagePath"];
    }
    [draftDict setObject:[NSDate date] forKey:@"draftDate"];
    [mutableDraftsArray addObject:draftDict];
    self.draftsArray = [mutableDraftsArray copy];
    [NSKeyedArchiver archiveRootObject:self.draftsArray toFile:[self archivePath]];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self appDelegate].returnURLString) {
            [[self appDelegate] returnToCaller];
        }
    }];
}

- (void)tapOnNameLabelHappend:(UITapGestureRecognizer*)sender {
    UILabel *nameLabel = (UILabel*)sender.view;
    UILabel *secondNameLabel = [[UILabel alloc] initWithFrame:[self.view convertRect:nameLabel.frame fromView:self.userNamesScrollView]];

    secondNameLabel.font = nameLabel.font;
    secondNameLabel.text = nameLabel.text;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        secondNameLabel.textColor = kDarkTextColor;
        secondNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
    } else {
        secondNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    secondNameLabel.backgroundColor = nameLabel.backgroundColor;
    secondNameLabel.textAlignment = nameLabel.textAlignment;
    [self.view addSubview:secondNameLabel];
    
    CGRect secondNameLabelFrame = secondNameLabel.frame;
    secondNameLabelFrame.origin.y = secondNameLabelFrame.origin.y - 100.0f;
    [UIView animateWithDuration:0.3f animations:^{
        secondNameLabel.frame = secondNameLabelFrame;
        secondNameLabel.alpha = 0.0f;
        self.postTextView.alpha = 0.5f;
    } completion:^(BOOL finished) {
        NSRange replacementRange = {MAX(self.startOfMention, self.startOfHashtag), self.lenthOfMentionSubstring};
        NSRange rangeOfFirstCharacter = {0 , 1};
        NSString *replacementString = [NSString stringWithFormat:@"%@ ", [nameLabel.text stringByReplacingCharactersInRange:rangeOfFirstCharacter withString:@""]];
        self.postTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.postTextView.text = [self.postTextView.text stringByReplacingCharactersInRange:replacementRange withString:replacementString];
        self.startOfMention = 0;
        self.startOfHashtag = 0;
        self.lenthOfMentionSubstring = 0;
        self.postTextView.selectedRange = NSMakeRange(replacementRange.location+replacementString.length, 0);
        
        for (UIView *userNameLabel in self.userNamesScrollView.subviews) {
            [userNameLabel removeFromSuperview];
        }
        
        [self updateLetterCount];

        [UIView animateWithDuration:0.2f animations:^{
            self.postTextView.alpha = 1.0f;
            self.annotationHostView.alpha = 1.0f;
            self.userNamesScrollView.alpha = 0.0f;
            self.postTextView.autocorrectionType = UITextAutocorrectionTypeDefault;
        } completion:^(BOOL finished) {}];
    }];
}

- (void)addConsignee:(NSString*)name {
    if (!self.consigneeString || [self.consigneeString isEqualToString:@""]) {
        self.consigneeString = name;
    } else {
        NSMutableArray *mutableConsigneeArray = [self.consigneeArray mutableCopy];
        [mutableConsigneeArray addObject:name];
        self.consigneeArray = [mutableConsigneeArray copy];
    }
}

- (IBAction)addButtonTouched:(UIButton *)sender {
    DHActionSheet *actionSheet;
    if (self.channelId) {
        actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"add", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"last photo", nil), NSLocalizedString(@"camera photo", nil), NSLocalizedString(@"gallery photo", nil), NSLocalizedString(@"link", nil), NSLocalizedString(@"place", nil), self.broadcastPost?NSLocalizedString(@"post to patter", nil):NSLocalizedString(@"also post to stream", nil), nil];
    } else {
        MPMediaItem *song = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
        if (!song || [self.postTextView.text rangeOfString:@"nowplaying"].location != NSNotFound || self.isPrivateMessage) {
            actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"chose item type to add", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"last photo", nil), NSLocalizedString(@"camera photo", nil), NSLocalizedString(@"gallery photo", nil), NSLocalizedString(@"link", nil), NSLocalizedString(@"place", nil), nil];
        } else {
            actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"chose item type to add", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"last photo", nil), NSLocalizedString(@"camera photo", nil), NSLocalizedString(@"gallery photo", nil), NSLocalizedString(@"link", nil), NSLocalizedString(@"place", nil), NSLocalizedString(@"now playing", nil), nil];
        }
    }
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
}


//- (IBAction)pictureButtonTouched:(id)sender {
//    if (self.isPrivateMessage) {
//        [self performSegueWithIdentifier:@"SearchConsignee" sender:self];
//    } else {
//        DHActionSheet *actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"chose image source", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"camera", nil), NSLocalizedString(@"gallery", nil), NSLocalizedString(@"last photo", nil), nil];
//        actionSheet.tag = 102;
//        [actionSheet showInView:self.view];
//    }
//}

- (void)actionSheet:(DHActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
//            DHActionSheet *photosActionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"chose image source", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"camera", nil), NSLocalizedString(@"gallery", nil), NSLocalizedString(@"last photo", nil), nil];
//            photosActionSheet.tag = 102;
//            [photosActionSheet showInView:self.view];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                // Within the group enumeration block, filter to enumerate just photos.
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                // Chooses the photo at the last index
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                    
                    // The end of the enumeration is signaled by asset == nil.
                    if (alAsset) {
                        ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                        UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                        
                        self.pictureImageView.image = latestPhoto;
                        self.postImage = latestPhoto;
                        
                        [self.postTextView becomeFirstResponder];
                    }
                }];
            } failureBlock: ^(NSError *error) {
                // Typically you should handle an error more gracefully than this.
                dhDebug(@"No groups");
            }];
        } else if (buttonIndex == 1) {
            self.postTextString = self.postTextView.text;
            [self.postTextView resignFirstResponder];
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        } else if (buttonIndex == 2) {
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePickerController.delegate = self;
                self.popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
                [self.popOverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                self.postTextString = self.postTextView.text;
                [self.postTextView resignFirstResponder];
                
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePickerController animated:YES completion:^{}];
            }
        } else if (buttonIndex == 3) {
            self.postTextString = self.postTextView.text;
            self.selectedRange = self.postTextView.selectedRange;
            LinkCreationViewController *linkCreationViewController = [[LinkCreationViewController alloc] init];
            linkCreationViewController.createStatusViewController = self;
            linkCreationViewController.linkText = [self.postTextString substringWithRange:self.selectedRange];
            UINavigationController *linkCreationNavigationController = [[UINavigationController alloc] initWithRootViewController:linkCreationViewController];
            linkCreationNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:linkCreationNavigationController animated:YES completion:^{}];
        } else if (buttonIndex == 4) {
            if ([CLLocationManager locationServicesEnabled]) {
                self.postTextString = self.postTextView.text;
                PlacesViewController *placesViewController = [[PlacesViewController alloc] init];
                placesViewController.createStatusViewController = self;
                UINavigationController *placesNavigationController = [[UINavigationController alloc] initWithRootViewController:placesViewController];
                [self presentViewController:placesNavigationController animated:YES completion:^{}];
            } else {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Please Allow Location Service", nil) message:NSLocalizedString(@"To add a place to a post you have to allow hAppy to access the location of your device.", nil) buttonTitle:NSLocalizedString(@"OK", nil)];
            }
        }
        if (self.channelId || self.isPrivateMessage) {
            if (buttonIndex == 5) {
//                [self performSegueWithIdentifier:@"SearchConsignee" sender:self];
                self.broadcastPost = !self.broadcastPost;
                if (self.broadcastPost) {
                    self.postButton.title = NSLocalizedString(@"broadcast", nil);
                } else {
                    self.postButton.title = NSLocalizedString(@"send", nil);
                }
            }
        } else {
            if (buttonIndex == 5) {
                MPMediaItem *song = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
                if (song) {
                    [self includeNowPlaying];
                }
            }
        }
    } else if (actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            self.postTextString = self.postTextView.text;
            [self.postTextView resignFirstResponder];
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        } else if (buttonIndex == 1) {
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePickerController.delegate = self;
                self.popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
                [self.popOverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                self.postTextString = self.postTextView.text;
                [self.postTextView resignFirstResponder];
                
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePickerController animated:YES completion:^{
                    dhDebug(@"did present image picker");
                }];
            }
        } else if (buttonIndex == 2) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                // Within the group enumeration block, filter to enumerate just photos.
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                // Chooses the photo at the last index
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                    
                    // The end of the enumeration is signaled by asset == nil.
                    if (alAsset) {
                        ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                        UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                        
                        self.pictureImageView.image = latestPhoto;
                        self.postImage = latestPhoto;
                        
                        [self.postTextView becomeFirstResponder];
                    }
                }];
            } failureBlock: ^(NSError *error) {
                // Typically you should handle an error more gracefully than this.
                dhDebug(@"No groups");
            }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowImagePicker"]) {
        self.postTextString = self.postTextView.text;
        [self.postTextView resignFirstResponder];
        [segue.destinationViewController setDelegate:self];
        if ([sender isEqualToString:@"camera"]) {
            [segue.destinationViewController setSourceType:UIImagePickerControllerSourceTypeCamera];
        } else {
            [segue.destinationViewController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    if ([segue.identifier isEqualToString:@"SearchConsignee"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ((UIViewController*)segue.destinationViewController).modalPresentationStyle = UIModalPresentationFormSheet;
            ((UIViewController*)segue.destinationViewController).view.accessibilityViewIsModal = YES;
        }
        ((DHSearchViewController*)((UINavigationController*)segue.destinationViewController).visibleViewController).hideSegmentedControl = YES;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        [self.popOverController dismissPopoverAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    dhDebug(@"info: %@", info);
    self.pictureImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.postImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self.postTextView becomeFirstResponder];
//    [self uploadImage:[info objectForKey:UIImagePickerControllerOriginalImage]];

//    [self.activityIndicator startAnimating];
}

- (void)uploadImage:(UIImage*)image {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy_MM_dd'T'HH_mm_ss'Z'";

    NSData *jpgImageData = UIImageJPEGRepresentation(image, 0.1f);
    UIImage *pngImage = [UIImage imageWithData:jpgImageData];
    NSData *imageData = UIImagePNGRepresentation(pngImage);

    
//    NSFileManager *defaultManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"imageToUpload.jpg"];
//    BOOL success = [defaultManager createFileAtPath:imagePath contents:imageData attributes:nil];
//    dhDebug(@"success: %@", success ? @"YES" : @"NO");
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [dateFormatter stringFromDate:[NSDate date]]];
//    [[self restClient] uploadFile:[imageName stringByReplacingOccurrencesOfString:@" " withString:@"_"] toPath:@"/"
//                    withParentRev:nil fromPath:imagePath];
    
    NSMutableURLRequest *imageUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/files"]];
    [imageUploadRequest setHTTPMethod:@"POST"];
    NSString *boundary = @"82481319dca6";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [imageUploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"content\"; filename=\"%@.jpg\"\r\n", imageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:imageData]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Disposition: form-data; name=\"metadata\"; filename=\"metadata.json\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSJSONSerialization dataWithJSONObject:@{@"type": @"photo"} options:kNilOptions error:nil]];

    [imageUploadRequest setHTTPBody:postbody];

    
    
}

- (void)includeNowPlaying {
    MPMediaItem *song = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    NSString *title   = [song valueForProperty:MPMediaItemPropertyTitle];
//    NSString * album   = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *artist  = [song valueForProperty:MPMediaItemPropertyArtist];
    UIImage *artwork = [[song valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(200.0f, 200.0f)];
    
    if ([self.postTextView.text isEqualToString:@""]) {
        self.postTextView.text = [self.postTextView.text stringByAppendingFormat:@"#nowplaying %@ - %@", title, artist];
    } else {
        self.postTextView.text = [self.postTextView.text stringByAppendingFormat:@"\n#nowplaying %@ - %@", title, artist];
    }
    if (artwork) {
        self.pictureImageView.image = artwork;
        self.postImage = artwork;

    }
    
    [self updateLetterCount];
}

- (void)languageDidChange:(NSNotificationCenter*)notification {
//    NSString *languageString = [[[UITextInputMode currentInputMode].primaryLanguage componentsSeparatedByString:@"-"] objectAtIndex:0];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
//    label.textAlignment = NSTextAlignmentCenter;
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        label.textColor = kDarkTextColor;
//    } else {
//        label.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
//    }
//    label.font = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
//    label.adjustsFontSizeToFitWidth = YES;
//    label.backgroundColor = [UIColor clearColor];
//    label.isAccessibilityElement = YES;
//    
//    self.navigationItem.titleView = label;
//    if (self.channelTitle) {
//        label.text = [NSString stringWithFormat:@"%@ (%@)", self.channelTitle, languageString];
//    } else {
//        label.text = [NSString stringWithFormat:NSLocalizedString(@"new post (%@)", nil), languageString];
//    }
//    self.theNavigationItem.titleView = label;
    
    [self updateTitleWithLanguageString:nil];
}

- (void)updateTitleWithLanguageString:(NSString*)languageString {
    if (!languageString) {
        languageString = [[[UITextInputMode currentInputMode].primaryLanguage componentsSeparatedByString:@"-"] objectAtIndex:0];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
    label.textAlignment = NSTextAlignmentCenter;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        label.textColor = kDarkTextColor;
        label.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
    } else {
        label.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
    }
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
    label.isAccessibilityElement = YES;
    
    self.navigationItem.titleView = label;
    if (self.channelTitle) {
        if (languageString) {
            label.text = [NSString stringWithFormat:@"%@ (%@)", self.channelTitle, languageString];
        } else {
            label.text = [NSString stringWithFormat:@"%@", self.channelTitle];
        }
    } else {
        if (languageString) {
            label.text = [NSString stringWithFormat:NSLocalizedString(@"new post (%@)", nil), languageString];
        } else {
            label.text = NSLocalizedString(@"new post", nil);
        }
    }
    self.theNavigationItem.titleView = label;
}

- (NSString*)archivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PostDrafts"];
}

- (void)addLink:(NSDictionary*)linkDictionary {
    NSRange selectedRange = self.postTextView.selectedRange;
    NSString *subStringToRange = [self.postTextView.text substringToIndex:selectedRange.location];
    NSString *subStringFromRange = [self.postTextView.text substringFromIndex:selectedRange.location+selectedRange.length];
    NSString *linkText = [linkDictionary objectForKey:@"linkText"];
    NSString *urlString = [linkDictionary objectForKey:@"url"];
    self.postTextString = [NSString stringWithFormat:@"%@[%@](%@) %@", subStringToRange, linkText, urlString, subStringFromRange];
    self.postTextView.text = self.postTextString;
    
    NSRange updatedSelectedRange = {selectedRange.location + [linkText length] + [urlString length] + 5, 0};
    self.selectedRange = updatedSelectedRange;
    self.postTextView.selectedRange = self.selectedRange;
    
//
//    NSRange rangeOfLink = {selectedRange.location, [linkText length]};
//    NSMutableArray *mutableLinkArray = [self.linkArray mutableCopy];
//    [mutableLinkArray addObject:@{@"linkText": [linkDictionary objectForKey:@"linkText"], @"url": [[linkDictionary objectForKey:@"url"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"range": [NSValue valueWithRange:rangeOfLink]}];
//    self.linkArray = [mutableLinkArray copy];
//    
//    NSRange updatedSelectedRange = {rangeOfLink.location + rangeOfLink.length + 1, 0};
//    self.selectedRange = updatedSelectedRange;
//   
//    if (self.postTextString && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
//        NSDictionary *attributeDict = @{NSFontAttributeName: self.postTextView.font};
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.postTextString attributes:attributeDict];
//        for (NSDictionary *linkDict in self.linkArray) {
//            [attributedString addAttribute:NSForegroundColorAttributeName value:self.linkColor range:[[linkDict objectForKey:@"range"] rangeValue]];
//        }
//        self.postTextView.attributedText = attributedString;
//        self.postTextView.selectedRange = self.selectedRange;
//    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)(scrollView.contentOffset.x/scrollView.frame.size.width);

    dhDebug(@"accountName: %@", [self.accountsArray objectAtIndex:index]);
    self.accountNameForPost = [self.accountsArray objectAtIndex:index];
}

- (DHAppDelegate*)appDelegate {
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate isKindOfClass:[DHAppDelegate class]]) {
        DHAppDelegate *appDelegate = (DHAppDelegate*)delegate;
        return appDelegate;
    }
    
    return nil;
}

@end
