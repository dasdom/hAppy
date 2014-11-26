//
//  EditColorSchemeViewController.m
//  Appetizr
//
//  Created by dasdom on 16.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "EditColorSchemeViewController.h"
#import "DHPostTextView.h"
//#import "DHGlobalObjects.h"
#import "UIColor+StringConversion.h"
#import "PRPAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#import "SSKeychain.h"
#import "PRPConnection.h"

@interface EditColorSchemeViewController () <UIScrollViewDelegate, UITextFieldDelegate, SKProductsRequestDelegate>
@property (nonatomic, strong) UIView *hostView;

@property (nonatomic, strong) UIView *normalCellBackgroundView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *postTextLabel;

@property (nonatomic, strong) UIView *separatorView;

@property (nonatomic, strong) UIView *markedCellBackgroundView;
@property (nonatomic, strong) UILabel *userNameLabel2;
@property (nonatomic, strong) UILabel *timeLabel2;
@property (nonatomic, strong) UILabel *postTextLabel2;

@property (nonatomic, strong) UIScrollView *elementSelectionScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UITextField *redTextField;
@property (nonatomic, strong) UITextField *greenTextField;
@property (nonatomic, strong) UITextField *blueTextField;
@property (nonatomic, strong) UISlider *redSlider;
@property (nonatomic, strong) UISlider *blueSlider;
@property (nonatomic, strong) UISlider *greenSlider;

@property (nonatomic) BOOL dontInstallTheme;

@property (nonatomic) BOOL hexValues;

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIActivityIndicatorView *storeInfoLoadingIndicator;
@property (nonatomic, strong) SKProduct *product;
@property (nonatomic, strong) UIButton *restoreButton;
@property (nonatomic, strong) UIButton *buyButton;

@property (nonatomic) BOOL openedFromAnnotation;
@property (nonatomic) BOOL editingDarkTheme;
@end

@implementation EditColorSchemeViewController

- (id)init
{
    if ((self = [super init]))
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)loadView {
    CGRect frame = CGRectMake(0.0f, 0.0f, 320.0f, 460.0f);
    frame.size.height = frame.size.height - 44.0f;
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    contentView.backgroundColor = [UIColor whiteColor];
    
    if (!_cellBackgroundColor) {
        _cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
    }
    if (!_markedCellBackgroundColor) {
        _markedCellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
    }
    if (!_mainColor) {
        _mainColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
    }
    if (!_textColor) {
        _textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    if (!_hashTagColor) {
        _hashTagColor = [DHGlobalObjects sharedGlobalObjects].hashTagColor;
    }
    if (!_mentionColor) {
        _mentionColor = [DHGlobalObjects sharedGlobalObjects].mentionColor;
    }
    if (!_linkColor) {
        _linkColor = [DHGlobalObjects sharedGlobalObjects].linkColor;
    }
    if (!_tintColor) {
        _tintColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
    }
    if (!_markerColor) {
        _markerColor = [DHGlobalObjects sharedGlobalObjects].markerColor;
    }
    if (!_separatorColor) {
        _separatorColor = [DHGlobalObjects sharedGlobalObjects].separatorColor;
    }
    
    _hostView = [[UIView alloc] initWithFrame:contentView.bounds];
    _hostView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [contentView addSubview:_hostView];
    
    _normalCellBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), 100.0f)];
    _normalCellBackgroundView.backgroundColor = _cellBackgroundColor;
    [_hostView addSubview:_normalCellBackgroundView];
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 56.0f, 56.0f)];
    avatarImageView.image = [UIImage imageNamed:@"Icon-60"];
    [_normalCellBackgroundView addSubview:avatarImageView];
    
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0f, 5.0f, 100.0f, 15.0f)];
    _userNameLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
    _userNameLabel.backgroundColor = [UIColor clearColor];
    _userNameLabel.text = @"happy";
    [_normalCellBackgroundView addSubview:_userNameLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-111.0f, 5.0f, 104.0f, 15.0f)];
    _timeLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:10.0f];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.text = @"1m";
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [_normalCellBackgroundView addSubview:_timeLabel];
    
    _postTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0f, 20.0f, 236.0f, 70.0f)];
    _postTextLabel.numberOfLines = 0;
    _postTextLabel.backgroundColor = [UIColor clearColor];
    [_normalCellBackgroundView addSubview:_postTextLabel];
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_normalCellBackgroundView.frame), CGRectGetWidth(frame), 1.0f)];
    _separatorView.backgroundColor = self.separatorColor;
    [_hostView addSubview:_separatorView];
    
    _markedCellBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_normalCellBackgroundView.frame)+1.0f, CGRectGetWidth(frame), 100.0f)];
    _markedCellBackgroundView.backgroundColor = _markedCellBackgroundColor;
    [_hostView addSubview:_markedCellBackgroundView];
    
    avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 56.0f, 56.0f)];
    avatarImageView.image = [UIImage imageNamed:@"Icon-60"];
    [_markedCellBackgroundView addSubview:avatarImageView];
    
    _userNameLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(66.0f, 5.0f, 100.0f, 15.0f)];
    _userNameLabel2.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
    _userNameLabel2.backgroundColor = [UIColor clearColor];
    _userNameLabel2.text = @"happy";
    [_markedCellBackgroundView addSubview:_userNameLabel2];
    
    _timeLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-111.0f, 5.0f, 104.0f, 15.0f)];
    _timeLabel2.font = [UIFont fontWithName:@"Avenir-Medium" size:10.0f];
    _timeLabel2.backgroundColor = [UIColor clearColor];
    _timeLabel2.text = @"1m";
    _timeLabel2.textAlignment = NSTextAlignmentRight;
    [_markedCellBackgroundView addSubview:_timeLabel2];
    
    _postTextLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(66.0f, 20.0f, 236.0f, 55.0f)];
    _postTextLabel2.numberOfLines = 0;
    _postTextLabel2.backgroundColor = [UIColor clearColor];
    [_markedCellBackgroundView addSubview:_postTextLabel2];

    CGFloat scrollViewYPosition = CGRectGetMaxY(_markedCellBackgroundView.frame);
    CGFloat scrollViewWidth = frame.size.width;
    _elementSelectionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, scrollViewYPosition, scrollViewWidth, 30.0f)];
    _elementSelectionScrollView.pagingEnabled = YES;
    _elementSelectionScrollView.delegate = self;
    NSArray *elementsArray = @[NSLocalizedString(@"cell background", nil), NSLocalizedString(@"marked cell background", nil), NSLocalizedString(@"text", nil), NSLocalizedString(@"hashtags", nil), NSLocalizedString(@"mentions", nil), NSLocalizedString(@"links", nil), NSLocalizedString(@"main color", nil), NSLocalizedString(@"new message marker", nil), NSLocalizedString(@"title", nil), NSLocalizedString(@"separator", nil)];
    CGFloat xPosition = 0.0f;
    for (NSString *elementName in elementsArray) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPosition+5.0f, 5.0f, scrollViewWidth-10.0f, 20.0f)];
        label.text = elementName;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        [_elementSelectionScrollView addSubview:label];
        xPosition += scrollViewWidth;
    }
    _elementSelectionScrollView.contentSize = CGSizeMake(xPosition, 30.0f);
    _elementSelectionScrollView.showsHorizontalScrollIndicator = NO;
    [_hostView addSubview:_elementSelectionScrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(_elementSelectionScrollView.frame), scrollViewWidth, 10.0f)];
    _pageControl.numberOfPages = [elementsArray count];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    _pageControl.userInteractionEnabled = NO;
    [_hostView addSubview:_pageControl];
    
    dhDebug(@"cellBackgroundColor: %@", self.cellBackgroundColor);

    CGFloat redColorValue;
    CGFloat blueColorValue;
    CGFloat greenColorValue;
    CGFloat alphaColorValue;
    [_cellBackgroundColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
    _elementSelectionScrollView.backgroundColor = _cellBackgroundColor;
    
    scrollViewWidth = frame.size.width-20;
    CGFloat textFieldYPosition = scrollViewYPosition+50.0f;
    _redTextField = [[UITextField alloc] initWithFrame:CGRectMake(scrollViewWidth-50.0f, textFieldYPosition, 60.0f, 30.0f)];
    _redTextField.text = [NSString stringWithFormat:@"%d", (int)(redColorValue*100)];
    _redTextField.borderStyle = UITextBorderStyleBezel;
    _redTextField.textAlignment = NSTextAlignmentCenter;
    _redTextField.delegate = self;
    _redTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _redTextField.returnKeyType = UIReturnKeyNext;
    [_hostView addSubview:_redTextField];
    
    CGFloat sliderYPosition = scrollViewYPosition+50.0f;
    _redSlider = [[UISlider alloc] initWithFrame:CGRectMake(10.0f, sliderYPosition, scrollViewWidth-70.0f, 30.0f)];
    _redSlider.thumbTintColor = [UIColor redColor];
    _redSlider.minimumTrackTintColor = [UIColor redColor];
    _redSlider.value = redColorValue;
    [_redSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_hostView addSubview:_redSlider];
    
    textFieldYPosition = textFieldYPosition+35.0f;
    _greenTextField = [[UITextField alloc] initWithFrame:CGRectMake(scrollViewWidth-50.0f, textFieldYPosition, 60.0f, 30.0f)];
    _greenTextField.text = [NSString stringWithFormat:@"%d", (int)(greenColorValue*100)];
    _greenTextField.borderStyle = UITextBorderStyleBezel;
    _greenTextField.textAlignment = NSTextAlignmentCenter;
    _greenTextField.delegate = self;
    _greenTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _greenTextField.returnKeyType = UIReturnKeyNext;
    [_hostView addSubview:_greenTextField];
    
    sliderYPosition = sliderYPosition+35.0f;
    _greenSlider = [[UISlider alloc] initWithFrame:CGRectMake(10.0f, sliderYPosition, scrollViewWidth-70.0f, 30.0f)];
    _greenSlider.thumbTintColor = [UIColor greenColor];
    _greenSlider.minimumTrackTintColor = [UIColor greenColor];
    _greenSlider.value = greenColorValue;
    [_greenSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_hostView addSubview:_greenSlider];
    
    textFieldYPosition = textFieldYPosition+35.0f;
    _blueTextField = [[UITextField alloc] initWithFrame:CGRectMake(scrollViewWidth-50.0f, textFieldYPosition, 60.0f, 30.0f)];
    _blueTextField.text = [NSString stringWithFormat:@"%d", (int)(blueColorValue*100)];
    _blueTextField.borderStyle = UITextBorderStyleBezel;
    _blueTextField.textAlignment = NSTextAlignmentCenter;
    _blueTextField.delegate = self;
    _blueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _blueTextField.returnKeyType = UIReturnKeyDone;
    [_hostView addSubview:_blueTextField];
    
    sliderYPosition = sliderYPosition+35.0f;
    _blueSlider = [[UISlider alloc] initWithFrame:CGRectMake(10.0f, sliderYPosition, scrollViewWidth-70.0f, 30.0f)];
    _blueSlider.thumbTintColor = [UIColor blueColor];
    _blueSlider.minimumTrackTintColor = [UIColor blueColor];
    _blueSlider.value = blueColorValue;
    [_blueSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_hostView addSubview:_blueSlider];
    
    sliderYPosition = sliderYPosition+40.0f;
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    shareButton.frame = CGRectMake(10.0f, sliderYPosition, scrollViewWidth, 40.0f);
    [shareButton setTitle:NSLocalizedString(@"share", nil) forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareColorTheme:) forControlEvents:UIControlEventTouchUpInside];
    [_hostView addSubview:shareButton];
    
    self.view = contentView;
    
//    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"reset", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetColors:)];
//    self.navigationItem.rightBarButtonItem = resetButton;
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"install", nil) style:UIBarButtonItemStyleDone target:self action:@selector(pop:)];
//    self.navigationItem.backBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13.0f], NSFontAttributeName, [DHGlobalObjects sharedGlobalObjects].textColor, NSForegroundColorAttributeName, nil];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"I am an #ADN client. I was made by @dasdom. You can finde me here https://directory.app.net/app/125/happy/" attributes:attributesDict];
//    
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[DHGlobalObjects sharedGlobalObjects].hashTagColor range:NSMakeRange(8, 4)];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[DHGlobalObjects sharedGlobalObjects].mentionColor range:NSMakeRange(35, 7)];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[DHGlobalObjects sharedGlobalObjects].linkColor range:NSMakeRange(66, 40)];
//
//    self.postTextLabel.attributedText = attributedString;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchasedHappend:) name:kPurchasedProductNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchasedFailed:) name:kPurchasFailedNotification object:nil];
    
//    if ([self.navigationController.viewControllers count] < 2) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.rightBarButtonItem = cancelBarButton;
//    }
    UIBarButtonItem *installBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"install", nil) style:UIBarButtonItemStylePlain target:self action:@selector(install:)];
    self.navigationItem.leftBarButtonItem = installBarButton;
    
    [self setColors];
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    dhDebug(@"bundleIdentifier: %@", bundleIdentifier);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"COLOR_EDITOR"]
        || [bundleIdentifier isEqualToString:@"de.dasdom.hAppyBeta"]
        ) {
        if (!self.openedFromAnnotation) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Dark or Light", nil) message:NSLocalizedString(@"Which color theme would you like to customize?", nil) cancelTitle:NSLocalizedString(@"Dark", nil) cancelBlock:^{
                [self initializeColorsForDarkTheme:YES];
                [self setColors];
                self.editingDarkTheme = YES;
            } otherTitle:NSLocalizedString(@"Light", nil) otherBlock:^{
                [self initializeColorsForDarkTheme:NO];
                [self setColors];
                self.editingDarkTheme = NO;
            }];
        }
        return;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    
    _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85f];
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_coverView];
    
    _storeInfoLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _storeInfoLoadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _storeInfoLoadingIndicator.center = self.view.center;
    _storeInfoLoadingIndicator.hidesWhenStopped = YES;
    [_storeInfoLoadingIndicator startAnimating];
    [self.view addSubview:_storeInfoLoadingIndicator];
    
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductData];
    } else {
        [PRPAlertView showWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"In App Purchase are not possible. Do you have them disabled?", nil) buttonTitle:@"OK"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.dontInstallTheme) {
        return;
    }
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"COLOR_EDITOR"] && ![bundleIdentifier isEqualToString:@"de.dasdom.hAppyBeta"]) {
        return;
    }
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    if (self.editingDarkTheme) {
        [userdefaults setObject:[self.cellBackgroundColor stringValue] forKey:kCustomDarkCellBackgroundColor];
        [userdefaults setObject:[self.markedCellBackgroundColor stringValue] forKey:kCustomDarkMarkedCellBackgroundColor];
        [userdefaults setObject:[self.mainColor stringValue] forKey:kCustomDarkMainColor];
        [userdefaults setObject:[self.textColor stringValue] forKey:kCustomDarkTextColor];
        [userdefaults setObject:[self.mentionColor stringValue] forKey:kCustomDarkMentionColor];
        [userdefaults setObject:[self.linkColor stringValue] forKey:kCustomDarkLinkColor];
        [userdefaults setObject:[self.hashTagColor stringValue] forKey:kCustomDarkHashtagColor];
        [userdefaults setObject:[self.tintColor stringValue] forKey:kCustomDarkTintColor];
        [userdefaults setObject:[self.markerColor stringValue] forKey:kCustomDarkMarkerColor];
        [userdefaults setObject:[self.separatorColor stringValue] forKey:kCustomDarkSeparatorColor];
        [userdefaults setBool:YES forKey:kDarkMode];
    } else {
        [userdefaults setObject:[self.cellBackgroundColor stringValue] forKey:kCustomCellBackgroundColor];
        [userdefaults setObject:[self.markedCellBackgroundColor stringValue] forKey:kCustomMarkedCellBackgroundColor];
        [userdefaults setObject:[self.mainColor stringValue] forKey:kCustomMainColor];
        [userdefaults setObject:[self.textColor stringValue] forKey:kCustomTextColor];
        [userdefaults setObject:[self.mentionColor stringValue] forKey:kCustomMentionColor];
        [userdefaults setObject:[self.linkColor stringValue] forKey:kCustomLinkColor];
        [userdefaults setObject:[self.hashTagColor stringValue] forKey:kCustomHashtagColor];
        [userdefaults setObject:[self.tintColor stringValue] forKey:kCustomTintColor];
        [userdefaults setObject:[self.markerColor stringValue] forKey:kCustomMarkerColor];
        [userdefaults setObject:[self.separatorColor stringValue] forKey:kCustomSeparatorColor];
        [userdefaults setBool:NO forKey:kDarkMode];
    }
    [userdefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kColorChangedNotification object:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeColorsForDarkTheme:(BOOL)forDarkTheme {
    if (forDarkTheme) {
//        if (!_cellBackgroundColor) {
            _cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
//        }
//        if (!_markedCellBackgroundColor) {
            _markedCellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
//        }
//        if (!_mainColor) {
            _mainColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
//        }
//        if (!_textColor) {
            _textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
//        }
//        if (!_hashTagColor) {
            _hashTagColor = [DHGlobalObjects sharedGlobalObjects].darkHashTagColor;
//        }
//        if (!_mentionColor) {
            _mentionColor = [DHGlobalObjects sharedGlobalObjects].darkMentionColor;
//        }
//        if (!_linkColor) {
            _linkColor = [DHGlobalObjects sharedGlobalObjects].darkLinkColor;
//        }
//        if (!_tintColor) {
            _tintColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
//        }
//        if (!_markerColor) {
            _markerColor = [DHGlobalObjects sharedGlobalObjects].darkMarkerColor;
//        }
//        if (!_separatorColor) {
            _separatorColor = [DHGlobalObjects sharedGlobalObjects].darkSeparatorColor;
//        }
    } else {
//        if (!_cellBackgroundColor) {
            _cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
//        }
//        if (!_markedCellBackgroundColor) {
            _markedCellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
//        }
//        if (!_mainColor) {
            _mainColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
//        }
//        if (!_textColor) {
            _textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
//        }
//        if (!_hashTagColor) {
            _hashTagColor = [DHGlobalObjects sharedGlobalObjects].hashTagColor;
//        }
//        if (!_mentionColor) {
            _mentionColor = [DHGlobalObjects sharedGlobalObjects].mentionColor;
//        }
//        if (!_linkColor) {
            _linkColor = [DHGlobalObjects sharedGlobalObjects].linkColor;
//        }
//        if (!_tintColor) {
            _tintColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
//        }
//        if (!_markerColor) {
            _markerColor = [DHGlobalObjects sharedGlobalObjects].markerColor;
//        }
//        if (!_separatorColor) {
            _separatorColor = [DHGlobalObjects sharedGlobalObjects].separatorColor;
//        }
    }
}

- (void)setColorsFromAnnotationDictionary:(NSDictionary*)annotationDictionary {
    self.cellBackgroundColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"cellBackgroundColor"]];
    self.hashTagColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"hashTagColor"]];
    self.linkColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"linkColor"]];
    self.mainColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"mainColor"]];
    self.markedCellBackgroundColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"markedCellBackgroundColor"]];
    self.markerColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"markerColor"]];
    self.mentionColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"mentionColor"]];
    self.textColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"textColor"]];
    self.tintColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"tintColor"]];
    self.separatorColor = [UIColor colorWithString:[annotationDictionary objectForKey:@"separatorColor"]];

    self.openedFromAnnotation = YES;
    dhDebug(@"cellBackgroundColor: %@", self.cellBackgroundColor);
}

- (void)setColors {
    self.normalCellBackgroundView.backgroundColor = self.cellBackgroundColor;
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13.0f], NSFontAttributeName, self.textColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"I am an #ADN client. I was made by @dasdom. You can find me here https://directory.app.net/app/125/happy/" attributes:attributesDict];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.hashTagColor range:NSMakeRange(8, 4)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.mentionColor range:NSMakeRange(35, 7)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.linkColor range:NSMakeRange(65, 40)];
    
    self.postTextLabel.attributedText = attributedString;
    
    self.userNameLabel.textColor = self.textColor;
    self.timeLabel.textColor = self.textColor;
    
    self.separatorView.backgroundColor = self.separatorColor;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey];
    
    self.markedCellBackgroundView.backgroundColor = self.markedCellBackgroundColor;
    
    attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13.0f], NSFontAttributeName, self.textColor, NSForegroundColorAttributeName, nil];
    attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@ isn't it awesome to have an #ADN client like hAppy [directory.app.net]?", userName] attributes:attributesDict];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.mentionColor range:NSMakeRange(0, userName.length+1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.hashTagColor range:NSMakeRange(30+userName.length, 4)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.linkColor range:NSMakeRange(47+userName.length, 5)];
    
    self.postTextLabel2.attributedText = attributedString;
    
    self.userNameLabel2.textColor = self.textColor;
    self.timeLabel2.textColor = self.textColor;
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
    {
        self.navigationController.navigationBar.barTintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    else
    {
        self.navigationController.navigationBar.tintColor = self.mainColor;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 40.0f)];
    label.text = NSLocalizedString(@"colors", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = self.tintColor;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
    label.backgroundColor = [UIColor clearColor];
    label.isAccessibilityElement = NO;
    
    self.navigationItem.titleView = label;
    
    [self.navigationController.navigationBar setNeedsDisplay];
    [self.view setNeedsDisplay];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat redColorValue;
    CGFloat blueColorValue;
    CGFloat greenColorValue;
    CGFloat alphaColorValue;
    
    NSInteger index = [self indexOfElement];
    self.pageControl.currentPage = index;
    
    switch (index) {
        case 0:
            [self.cellBackgroundColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.cellBackgroundColor;
            break;
        case 1:
            [self.markedCellBackgroundColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.markedCellBackgroundColor;
            break;
        case 2:
            [self.textColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.textColor;
            break;
        case 3:
            [self.hashTagColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.hashTagColor;
            break;
        case 4:
            [self.mentionColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.mentionColor;
            break;
        case 5:
            [self.linkColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.linkColor;
            break;
        case 6:
            [self.mainColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.mainColor;
            break;
        case 7:
            [self.markerColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.markerColor;
            break;
        case 8:
            [self.tintColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.tintColor;
            break;
        case 9:
            [self.separatorColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.separatorView.backgroundColor = self.separatorColor;
            break;
        default:
            [self.cellBackgroundColor getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
            self.elementSelectionScrollView.backgroundColor = self.cellBackgroundColor;
            break;
    }
    
    [self.redSlider setValue:redColorValue animated:YES];
    [self.greenSlider setValue:greenColorValue animated:YES];
    [self.blueSlider setValue:blueColorValue animated:YES];
    [self sliderChanged:nil];
}

- (NSInteger)indexOfElement {
    return (NSInteger)(self.elementSelectionScrollView.contentOffset.x/self.elementSelectionScrollView.frame.size.width);
}

- (void)sliderChanged:(UISlider*)sender {
    UIColor *elementColor = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:1.0f];
    self.elementSelectionScrollView.backgroundColor = elementColor;
    if (self.hexValues) {
        self.redTextField.text = [NSString stringWithFormat:@"0x%x", (int)(self.redSlider.value*255)];
        self.greenTextField.text = [NSString stringWithFormat:@"0x%x", (int)(self.greenSlider.value*255)];
        self.blueTextField.text = [NSString stringWithFormat:@"0x%x", (int)(self.blueSlider.value*255)];
    } else {
        self.redTextField.text = [NSString stringWithFormat:@"%d", (int)(self.redSlider.value*100)];
        self.greenTextField.text = [NSString stringWithFormat:@"%d", (int)(self.greenSlider.value*100)];
        self.blueTextField.text = [NSString stringWithFormat:@"%d", (int)(self.blueSlider.value*100)];
    }
    switch ([self indexOfElement]) {
        case 0:
            self.cellBackgroundColor = elementColor;
            break;
        case 1:
            self.markedCellBackgroundColor = elementColor;
            break;
        case 2:
            self.textColor = elementColor;
            break;
        case 3:
            self.hashTagColor = elementColor;
            break;
        case 4:
            self.mentionColor = elementColor;
            break;
        case 5:
            self.linkColor = elementColor;
            break;
        case 6:
            self.mainColor = elementColor;
            break;
        case 7:
            self.markerColor = elementColor;
            break;
        case 8:
            self.tintColor = elementColor;
            break;
        case 9:
            self.separatorColor = elementColor;
            break;
        default:
            break;
    }
    [self setColors];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.text = @"";
    CGRect hostViewFrame = self.hostView.frame;
    hostViewFrame.origin.y = -200.0f;
    [UIView animateWithDuration:0.25f animations:^{
        self.hostView.frame = hostViewFrame;
    } completion:^(BOOL finished) {}];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.redTextField) {
        NSScanner *scanner = [NSScanner scannerWithString:self.redTextField.text];
        unsigned int redvalue;
        if ([self.redTextField.text rangeOfString:@"0x"].location != NSNotFound && [scanner scanHexInt:&redvalue]) {
            self.redSlider.value = (float)redvalue/255.0f;
            self.hexValues = YES;
        } else {
            self.redSlider.value = [self.redTextField.text integerValue]/100.0f;
            self.hexValues = NO;
        }
        [self.greenTextField becomeFirstResponder];
    } else if (textField == self.greenTextField) {
        NSScanner *scanner = [NSScanner scannerWithString:self.greenTextField.text];
        unsigned int greenValue;
        if ([self.greenTextField.text rangeOfString:@"0x"].location != NSNotFound && [scanner scanHexInt:&greenValue]) {
            self.greenSlider.value = (float)greenValue/255.0f;
            self.hexValues = YES;
        } else {
            self.greenSlider.value = [self.greenTextField.text integerValue]/100.0f;
            self.hexValues = NO;
        }
        [self.blueTextField becomeFirstResponder];
    } else {
        NSScanner *scanner = [NSScanner scannerWithString:self.blueTextField.text];
        unsigned int blueValue;
        if ([self.blueTextField.text rangeOfString:@"0x"].location != NSNotFound && [scanner scanHexInt:&blueValue]) {
            self.blueSlider.value = (float)blueValue/255.0f;
            self.hexValues = YES;
        } else {
            self.blueSlider.value = [self.blueTextField.text integerValue]/100.0f;
            self.hexValues = NO;
        }
        [self.blueTextField resignFirstResponder];
        CGRect hostViewFrame = self.hostView.frame;
        hostViewFrame.origin.y = 0.0f;
        [UIView animateWithDuration:0.25f animations:^{
            self.hostView.frame = hostViewFrame;
        } completion:^(BOOL finished) {
        }];
    }
    [self sliderChanged:nil];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.redTextField) {
        NSScanner *scanner = [NSScanner scannerWithString:self.redTextField.text];
        unsigned int redvalue;
        if ([self.redTextField.text rangeOfString:@"0x"].location != NSNotFound && [scanner scanHexInt:&redvalue]) {
            self.redSlider.value = (float)redvalue/255.0f;
            self.hexValues = YES;
        } else {
            self.redSlider.value = [self.redTextField.text integerValue]/100.0f;
            self.hexValues = NO;
        }
    } else if (textField == self.greenTextField) {
        NSScanner *scanner = [NSScanner scannerWithString:self.greenTextField.text];
        unsigned int greenValue;
        if ([self.greenTextField.text rangeOfString:@"0x"].location != NSNotFound && [scanner scanHexInt:&greenValue]) {
            self.greenSlider.value = (float)greenValue/255.0f;
            self.hexValues = YES;
        } else {
            self.greenSlider.value = [self.greenTextField.text integerValue]/100.0f;
            self.hexValues = NO;
        }
    } else {
        NSScanner *scanner = [NSScanner scannerWithString:self.blueTextField.text];
        unsigned int blueValue;
        if ([self.blueTextField.text rangeOfString:@"0x"].location != NSNotFound && [scanner scanHexInt:&blueValue]) {
            self.blueSlider.value = (float)blueValue/255.0f;
            self.hexValues = YES;
        } else {
            self.blueSlider.value = [self.blueTextField.text integerValue]/100.0f;
            self.hexValues = NO;
        }
    }
    [self sliderChanged:nil];
}

- (void)resetColors:(UIBarButtonItem*)sender {
    [PRPAlertView showWithTitle:NSLocalizedString(@"confirm reset", nil) message:NSLocalizedString(@"Do you really want to reset the custom colors to the preinstalles light color theme?", nil) cancelTitle:NSLocalizedString(@"cancel", nil) cancelBlock:^{} otherTitle:NSLocalizedString(@"reset", nil) otherBlock:^{
        self.cellBackgroundColor = kLightCellBackgroundColorDefault;
        self.markedCellBackgroundColor = kLightCellBackgroundColorMarked;
        self.textColor = kLightTextColor;
        self.hashTagColor = kLightHashTagColor;
        self.mentionColor = kLightMentionColor;
        self.linkColor = kLightLinkColor;
        self.mainColor = kMainColor;
        self.markerColor = kLightMarkerColor;
        self.tintColor = kLightTintColor;
        self.separatorColor = kLightSeparatorColor;
        
        [self setColors];
    }];
    
}

- (void)shareColorTheme:(UIButton*)sender {
    [PRPAlertView showWithTitle:NSLocalizedString(@"Share Color Theme", nil) message:NSLocalizedString(@"Do you want to share your custom color theme in the hAppy color theme patter room (id: 19518)?", nil) cancelTitle:NSLocalizedString(@"cancel", nil) cancelBlock:^{} otherTitle:NSLocalizedString(@"share", nil) otherBlock:^{
        
        CGSize viewSize = self.navigationController.view.bounds.size;
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, 0);
        [self.navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
                
        CGRect cropFrame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([UIScreen mainScreen].scale == 2.0) {
                cropFrame = CGRectMake(220.0f, 0.0f, 640.0f, 2*244.0f);
            } else {
                cropFrame = CGRectMake(110.0f, 0.0f, 320.0f, 244.0f);
            }
        } else {
            if ([UIScreen mainScreen].scale == 2.0) {
                cropFrame = CGRectMake(0.0f, 40.0f, 640.0f, 2*244.0f);
            } else {
                cropFrame = CGRectMake(0.0f, 20.0f, 320.0f, 244.0f);
            }
        }
        CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], cropFrame);
        UIImage *cropedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *createPostViewController = [storyBoard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
        [createPostViewController setValue:cropedImage forKey:@"postImage"];
        [createPostViewController setValue:@"19518" forKey:@"channelId"];
        [createPostViewController setValue:@YES forKey:@"imageWithHighQuality"];
        NSDictionary *annotationValueDict = @{@"cellBackgroundColor": [_cellBackgroundColor stringValue],
                                              @"markedCellBackgroundColor": [_markedCellBackgroundColor stringValue],
                                              @"textColor": [_textColor stringValue],
                                              @"hashTagColor": [_hashTagColor stringValue],
                                              @"mentionColor": [_mentionColor stringValue],
                                              @"linkColor": [_linkColor stringValue],
                                              @"mainColor": [_mainColor stringValue],
                                              @"markerColor": [_markerColor stringValue],
                                              @"tintColor": [_tintColor stringValue],
                                              @"separatorColor": [_separatorColor stringValue]
                                              };
        NSDictionary *annotationDict = @{@"type": @"de.dasdom.happy.theme", @"value" : annotationValueDict};
        [createPostViewController setValue:annotationDict forKey:@"themeAnnotationDictionary"];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            createPostViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:createPostViewController];
        [self presentViewController:navigationController animated:YES completion:^{
            if (![[DHGlobalObjects sharedGlobalObjects].subscribedChannels containsObject:@"19518"]) {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Subscribe", nil) message:NSLocalizedString(@"You are going to share your theme in the hAppy Color patter room. Do you want to subscribe to that channel?", nil) cancelTitle:NSLocalizedString(@"cancel", nil) cancelBlock:^{
                } otherTitle:NSLocalizedString(@"OK", nil) otherBlock:^{
                    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
                    
                    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@channels/%@/subscribe?", kBaseURL, @"19518"];
                    
                    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
                    
                    NSMutableURLRequest *channelRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
                    [channelRequest setHTTPMethod:@"POST"];
                    [channelRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
                    
                    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:channelRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//                    [DHConnection connectionWithRequest:channelRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
                        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
                        dhDebug(@"responseDict: %@", responseDict);
                        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
                        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                            return;
                        } else {
                            NSMutableSet *mutableSubscribedChannelsSet = [[DHGlobalObjects sharedGlobalObjects].subscribedChannels mutableCopy];
                            [mutableSubscribedChannelsSet addObject:@"19518"];
                            [DHGlobalObjects sharedGlobalObjects].subscribedChannels = [mutableSubscribedChannelsSet copy];
                        }
                    }];
                    [dhConnection start];
                }];
            }
        }];
    }];
}

- (void)cancel:(UIBarButtonItem*)sender {
    self.dontInstallTheme = YES;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)install:(UIBarButtonItem*)sender {
    if (self.openedFromAnnotation) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"Dark or Light", nil) message:NSLocalizedString(@"Which color theme would you like to customize?", nil) cancelTitle:NSLocalizedString(@"Dark", nil) cancelBlock:^{
            self.editingDarkTheme = YES;
            [self dismissViewControllerAnimated:YES completion:^{}];
        } otherTitle:NSLocalizedString(@"Light", nil) otherBlock:^{
            self.editingDarkTheme = NO;
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)requestProductData {
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                 [NSSet setWithObject: @"COLOR_EDITOR"]];
    request.delegate = self;
    [request start];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self.storeInfoLoadingIndicator stopAnimating];
    
//    NSArray *myProducts = response.products;
//    dhDebug(@"myProducts: %@", myProducts);
    
    self.product = [response.products lastObject];
    dhDebug(@"product.localizedTitle %@", self.product.localizedTitle);
    dhDebug(@"product.localizedDescription %@", self.product.localizedDescription);
    dhDebug(@"product.price %@", self.product.price);
    dhDebug(@"product.priceLocale %@", self.product.priceLocale);

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, self.view.frame.size.width-20.0f, 30.0f)];
    titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0f];
    titleLabel.text = self.product.localizedTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.coverView addSubview:titleLabel];
    
    CGSize descriptionSize = [self.product.localizedDescription sizeWithFont:[UIFont fontWithName:@"Avenir-Medium" size:15.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width-20.0f, MAXFLOAT)];
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(titleLabel.frame)+10.0f, self.view.frame.size.width-20.0f, descriptionSize.height)];
    descriptionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:15.0f];
    descriptionLabel.text = self.product.localizedDescription;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.coverView addSubview:descriptionLabel];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:self.product.price];
    
    CGFloat buttonGap = 10.0f;
    CGFloat buttonWidth = (self.view.frame.size.width-3*buttonGap)/2.0f;
    _restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _restoreButton.frame = CGRectMake(buttonGap, CGRectGetMaxY(descriptionLabel.frame)+20.0f, buttonWidth, 40.0f);
    _restoreButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_restoreButton addTarget:self action:@selector(restoreButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_restoreButton setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
    _restoreButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _restoreButton.layer.borderWidth = 1.0f;
    _restoreButton.layer.cornerRadius = 3.0f;
    [self.coverView addSubview:_restoreButton];
    
    _buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _buyButton.frame = CGRectMake(CGRectGetMaxX(_restoreButton.frame)+10.0f, CGRectGetMaxY(descriptionLabel.frame)+20.0f, buttonWidth, 40.0f);
    _buyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_buyButton addTarget:self action:@selector(buyButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_buyButton setTitle:formattedPrice forState:UIControlStateNormal];
    _buyButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _buyButton.layer.borderWidth = 1.0f;
    _buyButton.layer.cornerRadius = 3.0f;
    [self.coverView addSubview:_buyButton];
    
    UIButton *getItFreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getItFreeButton.frame = CGRectMake(CGRectGetMinX(_restoreButton.frame), CGRectGetMaxY(_buyButton.frame)+20.0f, 2*buttonWidth+buttonGap, 40.0f);
    getItFreeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [getItFreeButton addTarget:self action:@selector(getItFree:) forControlEvents:UIControlEventTouchUpInside];
    [getItFreeButton setTitle:NSLocalizedString(@"Get If For Free", nil) forState:UIControlStateNormal];
    getItFreeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    getItFreeButton.layer.borderWidth = 1.0f;
    getItFreeButton.layer.cornerRadius = 3.0f;
    [self.coverView addSubview:getItFreeButton];
    
    // Populate your UI from the products list.
    // Save a reference to the products list.
}

- (void)buyButtonTouched:(UIButton*)sender {
    self.buyButton.hidden = YES;
    self.restoreButton.hidden = YES;
    [self.storeInfoLoadingIndicator startAnimating];
    
    if (self.product) {
        SKProduct *selectedProduct = self.product;
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)purchasedHappend:(NSNotification*)notification {
    self.buyButton = nil;
    self.restoreButton = nil;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"COLOR_EDITOR"]) {
        [self.coverView removeFromSuperview];
    }
}

- (void)purchasedFailed:(NSNotification*)notification {
    self.buyButton.hidden = NO;
    self.restoreButton.hidden = NO;
    [self.storeInfoLoadingIndicator stopAnimating];
}

- (void)restoreButtonTouched:(UIButton*)sender {
    self.buyButton.hidden = YES;
    self.restoreButton.hidden = YES;
    [self.storeInfoLoadingIndicator startAnimating];

    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)pop:(UIBarButtonItem*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getItFree:(UIButton*)sender
{
    self.buyButton = nil;
    self.restoreButton = nil;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"COLOR_EDITOR"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.coverView removeFromSuperview];
}

@end
