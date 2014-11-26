//
//  DHUserStreamTableViewController.m
//  Appetizr
//
//  Created by dasdom on 18.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHUserStreamTableViewController.h"
#import "UIImage+NormalizedImage.h"
#import "ImageHelper.h"

#define kScrollViewWidth 200.0f

@interface DHUserStreamTableViewController ()
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *titleScrollView;
@property (nonatomic, strong) NSArray *accountsArray;
@property (nonatomic, strong) NSMutableDictionary *yOffsetDictionary;
@property (nonatomic, strong) NSArray *avatarArray;
@end

@implementation DHUserStreamTableViewController

- (void)awakeFromNib {
    self.urlString = [NSString stringWithFormat:@"%@%@stream/unified", kBaseURL, kPostsSubURL];
    
    self.yOffsetDictionary = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidHappen:) name:kLoginHappendNotification object:nil];
}

- (void)loginDidHappen:(NSNotification*)notification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.accountsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUserArrayKey];
    NSString *currentAccount = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey];
    CGFloat xContentOffset = kScrollViewWidth;
    if ([self.accountsArray count]) {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScrollViewWidth, 40.0f)];
        
        _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScrollViewWidth, 30.0f)];
        CGFloat xPos = 0.0f;
        
        [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:[self.accountsArray lastObject]]];
        xPos += kScrollViewWidth;
    
        for (NSString *accountNameString in self.accountsArray) {
            [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:accountNameString]];
            if ([accountNameString isEqualToString:currentAccount]) {
                xContentOffset = xPos;
            }
            xPos += kScrollViewWidth;
        }
        
    
        [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:[self.accountsArray objectAtIndex:0]]];
        xPos += kScrollViewWidth;
    
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 30.0f, kScrollViewWidth, 10.0f)];
        _pageControl.numberOfPages = [self.accountsArray count];
        _pageControl.pageIndicatorTintColor = [UIColor blackColor];
        _pageControl.alpha = 0.4f;
        [_pageControl addTarget:self action:@selector(pageControlTapped:) forControlEvents:UIControlEventValueChanged];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.isAccessibilityElement = NO;
        _pageControl.currentPage = (int)(xContentOffset/kScrollViewWidth) - 1;
        [titleView addSubview:_pageControl];
    
        _titleScrollView.contentSize = CGSizeMake(xPos, 30.0f);
        _titleScrollView.pagingEnabled = YES;
        _titleScrollView.delegate = self;
        _titleScrollView.showsVerticalScrollIndicator = NO;
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        _titleScrollView.tag = 1001;
        _titleScrollView.contentOffset = CGPointMake(xContentOffset, 0.0f);
        [titleView addSubview:_titleScrollView];
        
//        UITapGestureRecognizer *scrollViewDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
//        scrollViewDoubleTapRecognizer.numberOfTapsRequired = 2;
//        [_titleScrollView addGestureRecognizer:scrollViewDoubleTapRecognizer];
        
        UITapGestureRecognizer *scrollViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
//        [scrollViewTapRecognizer requireGestureRecognizerToFail:scrollViewDoubleTapRecognizer];
        [_titleScrollView addGestureRecognizer:scrollViewTapRecognizer];
        
        _titleScrollView.isAccessibilityElement = YES;
        _titleScrollView.accessibilityLabel = NSLocalizedString(@"scroll to top", nil);
        _titleScrollView.accessibilityTraits = UIAccessibilityTraitButton;
        
//        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 30.0f, kScrollViewWidth, 10.0f)];
//        _pageControl.numberOfPages = [self.accountsArray count];
//        _pageControl.pageIndicatorTintColor = [UIColor blackColor];
//        [_pageControl addTarget:self action:@selector(pageControlTapped:) forControlEvents:UIControlEventValueChanged];
//        _pageControl.userInteractionEnabled = NO;
//        _pageControl.isAccessibilityElement = NO;
//        _pageControl.currentPage = (int)(xContentOffset/kScrollViewWidth) - 1;
//        [titleView addSubview:_pageControl];
        
        self.navigationItem.titleView = titleView;
    } else {
        self.title = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey];
    }
 
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
    [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
    self.menuButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;

}

- (UIView*)titleLabelWithXPostion:(CGFloat)xPos andText:(NSString*)textString {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(xPos, 0.0f, kScrollViewWidth, 30.0f)];
    
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[documentsPath objectAtIndex:0] stringByAppendingPathComponent:textString];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:[[UIImage imageWithData:data] resizeImage:CGSizeMake(40.0f, 40.0f)]];
    avatarImageView.layer.cornerRadius = 6.0f;
    avatarImageView.clipsToBounds = YES;
    [titleView addSubview:avatarImageView];
    
    CGRect labelFrame;
    if (data) {
        labelFrame = CGRectMake(30.0f, 0.0f, kScrollViewWidth-30.0f, 30.0f);
    } else {
        labelFrame = CGRectMake(0.0f, 0.0f, kScrollViewWidth, 30.0f);
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
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
    
    [titleView addSubview:label];
    
    CGSize textSize = [textString sizeWithFont:label.font];
    avatarImageView.frame = CGRectMake((kScrollViewWidth-textSize.width-25.0f)/2.0f, 5.0f, 20.0f, 20.0f);
//    avatarImageView.frame = CGRectMake((kScrollViewWidth-30.0f)/2.0f, 5.0f, 30.0f, 30.0f);

    return titleView;
}

- (void)scrollViewTapped:(UITapGestureRecognizer*)sender {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [super scrollViewDidEndDecelerating:scrollView];
    
    if (scrollView.tag != 1001) {
        return;
    }
    [self.yOffsetDictionary setObject:[NSNumber numberWithFloat:self.tableView.contentOffset.y] forKey:[self.accountsArray objectAtIndex:self.pageControl.currentPage]];
    
    NSInteger index = (NSInteger)(scrollView.contentOffset.x/scrollView.frame.size.width) - 1;
    if (index >= self.pageControl.numberOfPages) {
        index = 0;
        self.titleScrollView.contentOffset = CGPointMake(kScrollViewWidth, 0.0f);
    } else if (index < 0) {
        index = self.pageControl.numberOfPages-1;
        self.titleScrollView.contentOffset = CGPointMake(self.pageControl.numberOfPages*kScrollViewWidth, 0.0f);
    }
    self.pageControl.currentPage = index;
    [self changeAccount:index];
    
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    [self.yOffsetDictionary setObject:[NSNumber numberWithFloat:self.tableView.contentOffset.y] forKey:[self.accountsArray objectAtIndex:self.pageControl.currentPage]];

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
    [self changeAccount:self.pageControl.currentPage];
    
    NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"page %d of %d, %@", nil), self.pageControl.currentPage+1, self.pageControl.numberOfPages, [self.accountsArray objectAtIndex:self.pageControl.currentPage]];
    UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, messageString);
    return YES;
}

- (void)changeAccount:(NSInteger)index {
    NSString *userName = [self.accountsArray objectAtIndex:index];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaultsDictionary = [userDefaults objectForKey:userName];
    
    dhDebug(@"userDefaultsDictionary: %@", userDefaultsDictionary);
    
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kIncludeDirecedPosts] boolValue] forKey:kIncludeDirecedPosts];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kDontLoadImages] boolValue] forKey:kDontLoadImages];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kOnlyLoadImagesInWifi] boolValue] forKey:kOnlyLoadImagesInWifi];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kShowRealNames] boolValue] forKey:kShowRealNames];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kDarkMode] boolValue] forKey:kDarkMode];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kStreamMarker] boolValue] forKey:kStreamMarker];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kNormalKeyboard] boolValue] forKey:kNormalKeyboard];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kIgnoreUnreadPatter] boolValue] forKey:kIgnoreUnreadPatter];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kHideSeenThreads] boolValue] forKey:kHideSeenThreads];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kHideClient] boolValue] forKey:kHideClient];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kInlineImages] boolValue] forKey:kInlineImages];
    [userDefaults setObject:[userDefaultsDictionary objectForKey:kFontSize] forKey:kFontSize];
    [userDefaults setObject:[userDefaultsDictionary objectForKey:kFontName] forKey:kFontName];
    //    [userDefaults setObject:[userDefaultsDictionary objectForKey:kAccessTokenDefaultsKey] forKey:kAccessTokenDefaultsKey];
    [userDefaults setObject:userName forKey:kUserNameDefaultKey];
    
    [userDefaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangedNotification object:self];

    self.userStreamArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    
    [self setColors];
    [self.tableView reloadData];
    [self.view setNeedsDisplay];
    
    self.tableView.contentOffset = CGPointMake(0.0f, [[self.yOffsetDictionary objectForKey:userName] floatValue]);
    
    if ([self.userStreamArray count] < 1) {
        [self loadNewPosts:nil];
//        [self refreshTriggered];
    }
}

@end
