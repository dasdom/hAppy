//
//  SplitMasterViewController.m
//  Appetizr
//
//  Created by dasdom on 21.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "SplitMasterViewController.h"
#import "DHUserStreamTableViewController.h"
#import "DHMentionsTableViewController.h"
#import "DHGlobalStreamTableViewController.h"
#import "SplitMasterButtonView.h"
#import "ImageHelper.h"
#import "UIImage+NormalizedImage.h"
#import "UIApplication+Storyboard.h"
//#import "DHGlobalObjects.h"

//#define viewWidth 60

//enum BUTTON_TAGS {
//    BUTTON_TAG_UNIVERSAL = 100,
//    BUTTON_TAG_MENTIONS,
//    BUTTON_TAG_GLOBAL,
//    BUTTON_TAG_MESSAGES,
//    BUTTON_TAG_PATTER,
//    BUTTON_TAG_PROFILE,
//    BUTTON_TAG_INTERACTIONS,
//    BUTTON_TAG_HASHTAGSEARCH
//    } BUTTON_TAGS;

@interface SplitMasterViewController ()
//@property (nonatomic, strong) UIButton *universalButton;
//@property (nonatomic, strong) UIButton *mentionsButton;
//@property (nonatomic, strong) UIButton *globalButton;
//@property (nonatomic, strong) UIButton *messagesButton;
//@property (nonatomic, strong) UIButton *patterButton;
//@property (nonatomic, strong) UIButton *profileButton;

@property (nonatomic, strong) SplitMasterButtonView *universalButton;
@property (nonatomic, strong) SplitMasterButtonView *mentionsButton;
@property (nonatomic, strong) SplitMasterButtonView *globalButton;
@property (nonatomic, strong) SplitMasterButtonView *messagesButton;
@property (nonatomic, strong) SplitMasterButtonView *patterButton;

@property (nonatomic, strong) UIView *separatorView;

@property (nonatomic, strong) SplitMasterButtonView *profileButton;
@property (nonatomic, strong) SplitMasterButtonView *interactionsButton;
@property (nonatomic, strong) SplitMasterButtonView *hashTagSearchButton;

//@property (nonatomic, strong) DHUserStreamTableViewController *userStreamTableViewController;
@property (nonatomic, strong) DHMentionsTableViewController *mentionsTableViewController;
@property (nonatomic, strong) DHGlobalStreamTableViewController *globalStreamTableViewController;

@property (nonatomic, strong) UIView *messageIndicatorView;
@property (nonatomic, strong) UIView *patterIndicatorView;
@end

@implementation SplitMasterViewController

- (id)init {
    if ((self = [super init])) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        _userStreamTableViewController = [storyBoard instantiateViewControllerWithIdentifier:@"StreamViewController"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColors) name:kColorChangedNotification object:nil];
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)loadView {
    CGFloat viewWidth = 60;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            viewWidth = 200.0f;
        }
    }
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size = CGSizeMake(viewWidth, frame.size.height-self.navigationController.navigationBar.frame.size.height);
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    CGFloat yPos = 10.0f;
    CGFloat buttonHeight = 40.0f;
    CGFloat buttonGap = 1.0f;
    _universalButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"my stream", nil)];
    _universalButton.tag = BUTTON_TAG_UNIVERSAL;
    _universalButton.isSelected = YES;
    [_universalButton setSelected:YES];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_universalButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_universalButton];
    
    yPos += buttonHeight+buttonGap;
    _mentionsButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"mentions", nil)];
    _mentionsButton.tag = BUTTON_TAG_MENTIONS;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_mentionsButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_mentionsButton];
    
    yPos += buttonHeight+buttonGap;
    _messagesButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"messages", nil)];
    _messagesButton.tag = BUTTON_TAG_MESSAGES;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_messagesButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_messagesButton];
    
    _messageIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yPos, 2.0f, buttonHeight)];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        _messageIndicatorView.backgroundColor = kDarkMarkerColor;
        _messageIndicatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkerColor;
    } else {
        _messageIndicatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markerColor;
    }
    _messageIndicatorView.hidden = YES;
    [contentView addSubview:_messageIndicatorView];

    yPos += buttonHeight+buttonGap;
    _patterButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"patter", nil)];
    _patterButton.tag = BUTTON_TAG_PATTER;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_patterButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_patterButton];
    
    _patterIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yPos, 2.0f, buttonHeight)];
    _patterIndicatorView.hidden = YES;
    [contentView addSubview:_patterIndicatorView];
    
    yPos += buttonHeight+buttonGap+10.0f;
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yPos, viewWidth, 1.0f)];
    [contentView addSubview:_separatorView];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        _patterIndicatorView.backgroundColor = kDarkMarkerColor;
//        _separatorView.backgroundColor = kDarkSeparatorColor;
        _patterIndicatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkerColor;
        _separatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkSeparatorColor;
    } else {
        _patterIndicatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markerColor;
        _separatorView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].separatorColor;
    }
    
    yPos += buttonGap+_separatorView.frame.size.height+10.0f;
    _profileButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"profile", nil)];
    _profileButton.tag = BUTTON_TAG_PROFILE;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_profileButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_profileButton];
    
    yPos += buttonHeight+buttonGap;
    _interactionsButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"interactions", nil)];
    _interactionsButton.tag = BUTTON_TAG_INTERACTIONS;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_interactionsButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_interactionsButton];
    
    yPos += buttonHeight+buttonGap;
    _globalButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"explore", nil)];
    _globalButton.tag = BUTTON_TAG_GLOBAL;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_globalButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_globalButton];
    
    yPos += buttonHeight+buttonGap;
    _hashTagSearchButton = [[SplitMasterButtonView alloc] initWithFrame:CGRectMake(10.0f, yPos, viewWidth-20.0f, buttonHeight) title:NSLocalizedString(@"hashtag", nil)];
    _hashTagSearchButton.tag = BUTTON_TAG_HASHTAGSEARCH;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTouched:)];
    [_hashTagSearchButton addGestureRecognizer:tapGestureRecognizer];
    [contentView addSubview:_hashTagSearchButton];
    
    self.view = contentView;
    
    ((UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1]).viewControllers = @[self.userStreamTableViewController];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    self.mentionsTableViewController = [storyBoard instantiateViewControllerWithIdentifier:@"MentionsViewController"];
    self.globalStreamTableViewController = [storyBoard instantiateViewControllerWithIdentifier:@"GlobalViewController"];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewWidth, 40.0f)];
//    label.text = NSLocalizedString(@"menu", nil);
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
    self.navigationItem.titleView = label;
    
//    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTouched:)];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.accessibilityLabel = @"settings";
    [settingsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.frame = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.leftBarButtonItem = settingsBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numbersOfUnreadMessagesChanged:) name:kNumberOfUnreadMessagesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColors) name:kChangeColorsNotification object:nil];
}

//- (UIButton*)buttonWithTitle:(NSString*)titleString withFrame:(CGRect)frame andTag:(NSInteger)tag {
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:titleString forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button.frame = frame;
//    [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    button.tag = tag;
//    return button;
//}

//- (UIView*)buttonViewWithTitle:(NSString*)titleString frame:(CGRect)frame andTag:(NSInteger)tag {
//    UIView *buttonView = [[UIView alloc] initWithFrame:frame];
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, frame.size.width-30.0f, frame.size.height)];
//    titleLabel.text = titleString;
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
//    titleLabel.textAlignment = NSTextAlignmentLeft;
//    titleLabel.backgroundColor = [UIColor clearColor];
//    [buttonView addSubview:titleLabel];
//    
//    return buttonView;
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setColors];
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setColors {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        self.view.backgroundColor = kDarkCellBackgroundColorDefault;
//        [self.navigationController.navigationBar setTintColor:kDarkMainColor];
//        self.messageIndicatorView.backgroundColor = kDarkMarkerColor;
//        self.patterIndicatorView.backgroundColor = kDarkMarkerColor;
//        
//        self.universalButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.mentionsButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.globalButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.messagesButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.patterButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.profileButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.interactionsButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.hashTagSearchButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.universalButton.iconImageView.image = [ImageHelper speechBubbleWithStrokeColor:kDarkTextColor];
//        self.mentionsButton.iconImageView.image = [ImageHelper atSignWithStrokeColor:kDarkTextColor];
//        self.globalButton.iconImageView.image = [ImageHelper globeWithStrokeColor:kDarkTextColor];
//        self.messagesButton.iconImageView.image = [ImageHelper letterWithStrokeColor:kDarkTextColor];
//        self.patterButton.iconImageView.image = [ImageHelper pawWithStrokeColor:kDarkTextColor];
//        self.separatorView.backgroundColor = kDarkSeparatorColor;
//        self.profileButton.iconImageView.image = [ImageHelper headWithStrokeColor:kDarkTextColor];
//        self.interactionsButton.iconImageView.image = [ImageHelper interactionWithStrokeColor:kDarkTextColor];
//        self.hashTagSearchButton.iconImageView.image = [ImageHelper searchWithStrokeColor:kDarkTextColor];
//        self.universalButton.titleLabel.textColor = kDarkTextColor;
//        self.mentionsButton.titleLabel.textColor = kDarkTextColor;
//        self.globalButton.titleLabel.textColor = kDarkTextColor;
//        self.messagesButton.titleLabel.textColor = kDarkTextColor;
//        self.patterButton.titleLabel.textColor = kDarkTextColor;
//        self.profileButton.titleLabel.textColor = kDarkTextColor;
//        self.interactionsButton.titleLabel.textColor = kDarkTextColor;
//        self.hashTagSearchButton.titleLabel.textColor = kDarkTextColor;
        DHGlobalObjects *globalObject = [DHGlobalObjects sharedGlobalObjects];
        self.view.backgroundColor = globalObject.darkCellBackgroundColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            self.navigationController.navigationBar.barTintColor = globalObject.darkMainColor;
            self.navigationController.navigationBar.tintColor = globalObject.darkTextColor;
        }
        else
        {
            self.navigationController.navigationBar.tintColor = globalObject.darkMainColor;
        }
        self.messageIndicatorView.backgroundColor = globalObject.darkMarkerColor;
        self.patterIndicatorView.backgroundColor = globalObject.darkMarkerColor;
        self.separatorView.backgroundColor = globalObject.darkSeparatorColor;
        
        self.universalButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.mentionsButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.globalButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.messagesButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.patterButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.profileButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.interactionsButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.hashTagSearchButton.backgroundColor = globalObject.darkCellBackgroundColor;
        self.universalButton.iconImageView.image = [ImageHelper speechBubbleWithStrokeColor:globalObject.darkTextColor];
        self.mentionsButton.iconImageView.image = [ImageHelper atSignWithStrokeColor:globalObject.darkTextColor];
        self.globalButton.iconImageView.image = [ImageHelper globeWithStrokeColor:globalObject.darkTextColor];
        self.messagesButton.iconImageView.image = [ImageHelper letterWithStrokeColor:globalObject.darkTextColor];
        self.patterButton.iconImageView.image = [ImageHelper pawWithStrokeColor:globalObject.darkTextColor];
        self.separatorView.backgroundColor = globalObject.darkSeparatorColor;
        self.profileButton.iconImageView.image = [ImageHelper headWithStrokeColor:globalObject.darkTextColor];
        self.interactionsButton.iconImageView.image = [ImageHelper interactionWithStrokeColor:globalObject.darkTextColor];
        self.hashTagSearchButton.iconImageView.image = [ImageHelper searchWithStrokeColor:globalObject.darkTextColor];
        self.universalButton.titleLabel.textColor = globalObject.darkTextColor;
        self.mentionsButton.titleLabel.textColor = globalObject.darkTextColor;
        self.globalButton.titleLabel.textColor = globalObject.darkTextColor;
        self.messagesButton.titleLabel.textColor = globalObject.darkTextColor;
        self.patterButton.titleLabel.textColor = globalObject.darkTextColor;
        self.profileButton.titleLabel.textColor = globalObject.darkTextColor;
        self.interactionsButton.titleLabel.textColor = globalObject.darkTextColor;
        self.hashTagSearchButton.titleLabel.textColor = globalObject.darkTextColor;
    } else {
        DHGlobalObjects *globalObject = [DHGlobalObjects sharedGlobalObjects];
        self.view.backgroundColor = globalObject.cellBackgroundColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            self.navigationController.navigationBar.barTintColor = globalObject.mainColor;
            self.navigationController.navigationBar.tintColor = globalObject.textColor;
        }
        else
        {
            self.navigationController.navigationBar.tintColor = globalObject.mainColor;
        }
        self.messageIndicatorView.backgroundColor = globalObject.markerColor;
        self.patterIndicatorView.backgroundColor = globalObject.markerColor;
        self.separatorView.backgroundColor = globalObject.separatorColor;
        
        self.universalButton.backgroundColor = globalObject.cellBackgroundColor;
        self.mentionsButton.backgroundColor = globalObject.cellBackgroundColor;
        self.globalButton.backgroundColor = globalObject.cellBackgroundColor;
        self.messagesButton.backgroundColor = globalObject.cellBackgroundColor;
        self.patterButton.backgroundColor = globalObject.cellBackgroundColor;
        self.profileButton.backgroundColor = globalObject.cellBackgroundColor;
        self.interactionsButton.backgroundColor = globalObject.cellBackgroundColor;
        self.hashTagSearchButton.backgroundColor = globalObject.cellBackgroundColor;
        self.universalButton.iconImageView.image = [ImageHelper speechBubbleWithStrokeColor:globalObject.textColor];
        self.mentionsButton.iconImageView.image = [ImageHelper atSignWithStrokeColor:globalObject.textColor];
        self.globalButton.iconImageView.image = [ImageHelper globeWithStrokeColor:globalObject.textColor];
        self.messagesButton.iconImageView.image = [ImageHelper letterWithStrokeColor:globalObject.textColor];
        self.patterButton.iconImageView.image = [ImageHelper pawWithStrokeColor:globalObject.textColor];
        self.separatorView.backgroundColor = globalObject.separatorColor;
        self.profileButton.iconImageView.image = [ImageHelper headWithStrokeColor:globalObject.textColor];
        self.interactionsButton.iconImageView.image = [ImageHelper interactionWithStrokeColor:globalObject.textColor];
        self.hashTagSearchButton.iconImageView.image = [ImageHelper searchWithStrokeColor:globalObject.textColor];
        self.universalButton.titleLabel.textColor = globalObject.textColor;
        self.mentionsButton.titleLabel.textColor = globalObject.textColor;
        self.globalButton.titleLabel.textColor = globalObject.textColor;
        self.messagesButton.titleLabel.textColor = globalObject.textColor;
        self.patterButton.titleLabel.textColor = globalObject.textColor;
        self.profileButton.titleLabel.textColor = globalObject.textColor;
        self.interactionsButton.titleLabel.textColor = globalObject.textColor;
        self.hashTagSearchButton.titleLabel.textColor = globalObject.textColor;
    }
    
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[documentsPath objectAtIndex:0] stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        self.profileButton.iconImageView.image = [[UIImage imageWithData:data] resizeImage:CGSizeMake(60.0f, 60.0f)];
        self.profileButton.iconImageView.layer.cornerRadius = 6.0f;
        self.profileButton.iconImageView.clipsToBounds = YES;
    }
    
    [self.view setNeedsDisplay];
}

- (void)resetSelectionState {
    [self.universalButton setSelected:NO];
    [self.mentionsButton setSelected:NO];
    [self.globalButton setSelected:NO];
    [self.messagesButton setSelected:NO];
    [self.patterButton setSelected:NO];
    [self.profileButton setSelected:NO];
    [self.interactionsButton setSelected:NO];
    [self.hashTagSearchButton setSelected:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            CGFloat updatedWitdh = 180.0f;
            CGRect buttonFrame = self.universalButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.universalButton.frame = buttonFrame;
            
            buttonFrame = self.mentionsButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.mentionsButton.frame = buttonFrame;
            
            buttonFrame = self.globalButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.globalButton.frame = buttonFrame;
            
            buttonFrame = self.messagesButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.messagesButton.frame = buttonFrame;
            
            buttonFrame = self.patterButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.patterButton.frame = buttonFrame;
            
            buttonFrame = self.profileButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.profileButton.frame = buttonFrame;
            
            buttonFrame = self.interactionsButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.interactionsButton.frame = buttonFrame;
            
            buttonFrame = self.hashTagSearchButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.hashTagSearchButton.frame = buttonFrame;
        } else {
            CGFloat updatedWitdh = 40.0f;
            CGRect buttonFrame = self.universalButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.universalButton.frame = buttonFrame;
            
            buttonFrame = self.mentionsButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.mentionsButton.frame = buttonFrame;
            
            buttonFrame = self.globalButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.globalButton.frame = buttonFrame;
            
            buttonFrame = self.messagesButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.messagesButton.frame = buttonFrame;
            
            buttonFrame = self.patterButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.patterButton.frame = buttonFrame;
            
            buttonFrame = self.profileButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.profileButton.frame = buttonFrame;
            
            buttonFrame = self.interactionsButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.interactionsButton.frame = buttonFrame;
            
            buttonFrame = self.hashTagSearchButton.frame;
            buttonFrame.size.width = updatedWitdh;
            self.hashTagSearchButton.frame = buttonFrame;
        }
    }
}

//- (void)buttonTouched:(UIButton*)sender {
- (void)buttonTouched:(UITapGestureRecognizer*)sender {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        sender.backgroundColor = kDarkCellBackgroundColorLepliedTo;
//    } else {
//        sender.backgroundColor = kLightCellBackgroundColorLepliedTo;
//    }

    SplitMasterButtonView *theView = (SplitMasterButtonView*)sender.view;
    [theView setSelected:YES];
    
    [self selectButtonWithTag:theView.tag];
//    UIViewController *previousViewController = [((UINavigationController*)self.detailViewController).viewControllers lastObject];
//    [previousViewController viewWillDisappear:NO];
//    
//    UIViewController *rootViewController;
//    switch (theView.tag) {
//        case BUTTON_TAG_UNIVERSAL: {
//            rootViewController = self.userStreamTableViewController;
//            break;
//        }
//        case BUTTON_TAG_MENTIONS: {
//            rootViewController = self.mentionsTableViewController;
//            break;
//        }
//        case BUTTON_TAG_GLOBAL: {
//            rootViewController = self.globalStreamTableViewController;
//            break;
//        }
//        case BUTTON_TAG_MESSAGES: {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ChannelsViewController"];
//            break;
//        }
//        case BUTTON_TAG_PATTER: {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ChannelsViewController"];
//            [rootViewController setValue:@1 forKey:@"startPageNumber"];
//            break;
//        }
//        case BUTTON_TAG_PROFILE: {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHProfileTableViewController"];
//            break;
//        }
//        case BUTTON_TAG_INTERACTIONS: {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHInteractionsViewController"];
//            break;
//        }
//        case BUTTON_TAG_HASHTAGSEARCH: {
//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHHashtagTableViewController"];
//            break;
//        }
//            
//        default:
//            break;
//    }
//    [rootViewController viewWillAppear:NO];
//    
////    ((UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1]).viewControllers = @[rootViewController];
//    ((UINavigationController*)self.detailViewController).viewControllers = @[rootViewController];
//    
//    [previousViewController viewDidDisappear:NO];
//    [rootViewController viewDidAppear:NO];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuTouchedNotification object:nil];
}

- (void)selectButtonWithTag:(NSInteger)buttonTag {
    [self resetSelectionState];
    
//    UIViewController *previousViewController = [((UINavigationController*)self.detailViewController).viewControllers lastObject];
//    [previousViewController viewWillDisappear:NO];
    
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:([SplitMasterButtonView class])]) {
            if (view.tag == buttonTag) {
                [(SplitMasterButtonView*)view setSelected:YES];
            }
        }
    }
    
    UIViewController *rootViewController;
    switch (buttonTag) {
        case BUTTON_TAG_UNIVERSAL: {
            rootViewController = self.userStreamTableViewController;
            break;
        }
        case BUTTON_TAG_MENTIONS: {
            rootViewController = self.mentionsTableViewController;
            break;
        }
        case BUTTON_TAG_GLOBAL: {
            rootViewController = self.globalStreamTableViewController;
            break;
        }
        case BUTTON_TAG_MESSAGES: {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ChannelsViewController"];
            break;
        }
        case BUTTON_TAG_PATTER: {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ChannelsViewController"];
            [rootViewController setValue:@1 forKey:@"startPageNumber"];
            break;
        }
        case BUTTON_TAG_PROFILE: {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHProfileTableViewController"];
            break;
        }
        case BUTTON_TAG_INTERACTIONS: {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHInteractionsViewController"];
            break;
        }
        case BUTTON_TAG_HASHTAGSEARCH: {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHHashtagTableViewController"];
            break;
        }
            
        default:
            break;
    }
//    [rootViewController viewWillAppear:NO];
    
    //    ((UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1]).viewControllers = @[rootViewController];
    ((UINavigationController*)self.detailViewController).viewControllers = @[rootViewController];
    
//    [previousViewController viewDidDisappear:NO];
//    [rootViewController viewDidAppear:NO];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideMenuNotification object:nil];
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

- (void)numbersOfUnreadMessagesChanged:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger unreadMessages = [[userInfo objectForKey:@"unreadMessages"] integerValue];
    NSString *unreadMessagesString = [NSString stringWithFormat:NSLocalizedString(@"messages(%d)", nil), unreadMessages];
//    [self.messagesButton setTitle:unreadMassagesString forState:UIControlStateNormal];
    self.messagesButton.titleLabel.text = unreadMessagesString;
    self.messagesButton.accessibilityLabel = unreadMessagesString;

    if (unreadMessages > 0) {
        self.messageIndicatorView.hidden = NO;
    } else {
        self.messageIndicatorView.hidden = YES;
    }
    
    NSInteger unreadPatter = [[userInfo objectForKey:@"unreadPatter"] integerValue];
    NSString *unreadPatterString = [NSString stringWithFormat:NSLocalizedString(@"patter(%d)", nil), unreadPatter];
//    [self.patterButton setTitle:unreadPatterString forState:UIControlStateNormal];
    self.patterButton.titleLabel.text = unreadPatterString;
    self.patterButton.accessibilityLabel = unreadPatterString;
 
    if (unreadPatter > 0) {
        self.patterIndicatorView.hidden = NO;
    } else {
        self.patterIndicatorView.hidden = YES;
    }
}

- (void)settingsButtonTouched:(UIBarButtonItem*)sender {
    UIStoryboard *storyboard = [UIApplication settingsStoryboard];
    UINavigationController *settingsNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsNavigationController"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        settingsNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:settingsNavigationController animated:YES completion:^{
        
    }];
    
}

@end
