//
//  DHGlobalStreamTableViewController.m
//  Appetizr
//
//  Created by dasdom on 18.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHGlobalStreamTableViewController.h"
#import "SSKeychain.h"
#import "ExploreImagesViewController.h"
#import "SlideInView.h"
#import "ImageHelper.h"

#define kScrollViewWidth 200.0f

@interface DHGlobalStreamTableViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) UISegmentedControl *exploreSegmentedControl;
@property (nonatomic, strong) NSArray *slugArray;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *titleScrollView;

@end

@implementation DHGlobalStreamTableViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.slugArray count]) {
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@stream/explore?include_post_annotations=1&", kBaseURL, kPostsSubURL];
    
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
    
    __weak DHGlobalStreamTableViewController *weakSelf = self;
    PRPConnection *dhConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
        dhDebug(@"responseDict: %@", responseDict);
        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
        dhDebug(@"metaDict: %@", metaDict);
        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
        
        NSMutableArray *mutableSlugArray = [[NSMutableArray alloc] initWithArray:@[@{@"url": [NSString stringWithFormat:@"%@%@stream/global", kBaseURL, kPostsSubURL], @"slug": @"global"}]];
//        weakSelf.slugArray = [responseDict objectForKey:@"data"];
        [mutableSlugArray addObjectsFromArray:[responseDict objectForKey:@"data"]];
        weakSelf.slugArray = [mutableSlugArray copy];
        
//        NSMutableArray *mutableSegmentNameArray = [NSMutableArray array];
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScrollViewWidth, 40.0f)];
        _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScrollViewWidth, 30.0f)];
        CGFloat xPos = 0.0f;
        
        if ([weakSelf.slugArray count]) {
            [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:[[weakSelf.slugArray lastObject] objectForKey:@"slug"]]];
            xPos += kScrollViewWidth;
        }
        
        for (NSDictionary *slugDict in weakSelf.slugArray) {
            [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:[slugDict objectForKey:@"slug"]]];
            xPos += kScrollViewWidth;

        }
        
        if ([weakSelf.slugArray count]) {
            [_titleScrollView addSubview:[self titleLabelWithXPostion:xPos andText:[[weakSelf.slugArray objectAtIndex:0] objectForKey:@"slug"]]];
            xPos += kScrollViewWidth;
        }

        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 30.0f, kScrollViewWidth, 10.0f)];
        _pageControl.numberOfPages = [weakSelf.slugArray count];
        _pageControl.pageIndicatorTintColor = [UIColor blackColor];
        [_pageControl addTarget:self action:@selector(pageControlTapped:) forControlEvents:UIControlEventValueChanged];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.isAccessibilityElement = NO;
        //        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        [titleView addSubview:_pageControl];

        _titleScrollView.contentSize = CGSizeMake(xPos, 30.0f);
        _titleScrollView.pagingEnabled = YES;
        _titleScrollView.delegate = self;
        _titleScrollView.showsVerticalScrollIndicator = NO;
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        _titleScrollView.tag = 1001;
        _titleScrollView.contentOffset = CGPointMake(kScrollViewWidth, 0.0f);
//        _titleScrollView.backgroundColor = [UIColor redColor];
        [titleView addSubview:_titleScrollView];
        
        UITapGestureRecognizer *scrollViewDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        scrollViewDoubleTapRecognizer.numberOfTapsRequired = 2;
        [_titleScrollView addGestureRecognizer:scrollViewDoubleTapRecognizer];
        
        UITapGestureRecognizer *scrollViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
        [scrollViewTapRecognizer requireGestureRecognizerToFail:scrollViewDoubleTapRecognizer];
        [_titleScrollView addGestureRecognizer:scrollViewTapRecognizer];

        self.navigationItem.titleView = titleView;
        
    }];
    [dhConnection start];
    
//    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftHappend:)];
//    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.view addGestureRecognizer:swipeLeftRecognizer];
//    
//    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
//    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:swipeRightRecognizer];
    
    self.urlString = [NSString stringWithFormat:@"%@%@stream/global", kBaseURL, kPostsSubURL];
    
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
    [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
    self.menuButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;

}

- (UILabel*)titleLabelWithXPostion:(CGFloat)xPos andText:(NSString*)textString {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPos, 0.0f, kScrollViewWidth, 30.0f)];
    label.text = textString;
    label.textAlignment = NSTextAlignmentCenter;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        label.textColor = kDarkTextColor;
        label.textColor = [DHGlobalObjects sharedGlobalObjects].darkTintColor;
    } else {
        label.textColor = [DHGlobalObjects sharedGlobalObjects].tintColor;
    }
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0f];
    label.backgroundColor = [UIColor clearColor];
    label.isAccessibilityElement = NO;
    return label;
}

- (void)changeStream:(NSInteger)index {
    [self.tableView setContentOffset:CGPointMake(0.0f, 0.0f)];
    self.userStreamArray = [NSArray array];
    [self.tableView reloadData];
    
    self.urlString = [[self.slugArray objectAtIndex:index] objectForKey:@"url"];
    [self updateUserStreamArraySinceId:nil beforeId:nil];
    
    if ([[[self.slugArray objectAtIndex:self.pageControl.currentPage] objectForKey:@"slug"] isEqualToString: @"photos"] &&
        ![[NSUserDefaults standardUserDefaults] boolForKey:kDontShowPhotosHint]) {
        SlideInView *slideInView = [SlideInView viewWithImage:nil text:NSLocalizedString(@"Try to double tap navigation bar", nil) andSize:CGSizeMake(self.view.frame.size.width, 44.0f)];
        [slideInView showWithTimer:3.0f inView:self.tableView from:SlideInViewTop];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag != 1001) {
        return;
    }
    NSInteger index = (NSInteger)(scrollView.contentOffset.x/scrollView.frame.size.width) - 1;
    if (index >= self.pageControl.numberOfPages) {
        index = 0;
        self.titleScrollView.contentOffset = CGPointMake(kScrollViewWidth, 0.0f);
    } else if (index < 0) {
        index = self.pageControl.numberOfPages-1;
        self.titleScrollView.contentOffset = CGPointMake(self.pageControl.numberOfPages*kScrollViewWidth, 0.0f);
    }
    self.pageControl.currentPage = index;
    [self changeStream:index];

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
    [self changeStream:self.pageControl.currentPage];
    
    NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"page %d of %d, %@", nil), self.pageControl.currentPage+1, self.pageControl.numberOfPages, [[self.slugArray objectAtIndex:self.pageControl.currentPage] objectForKey:@"title"]];
    UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, messageString);
    return YES;
}

//- (void)pageControlTapped:(UIPageControl*)sender {
//    [self changeStream:sender.currentPage];
//    [self.titleScrollView setContentOffset: CGPointMake(sender.currentPage*self.titleScrollView.frame.size.width, 0.0f) animated:YES];
//}

- (void)scrollViewTapped:(UITapGestureRecognizer*)sender {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)sender {
    if ([[[self.slugArray objectAtIndex:self.pageControl.currentPage] objectForKey:@"slug"] isEqualToString: @"photos"] && [self.userStreamArray count] > 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDontShowPhotosHint];
        [[NSUserDefaults standardUserDefaults] synchronize];
        ExploreImagesViewController *exploreImageViewController = [[ExploreImagesViewController alloc] init];
        exploreImageViewController.hidesBottomBarWhenPushed = YES;
        exploreImageViewController.imageStreamArray = self.userStreamArray;
        [self.navigationController pushViewController:exploreImageViewController animated:YES];
    }
}

- (NSArray*)filterLanguagesForArray:(NSArray*)inputArray {
    NSArray *languagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"languagesArray_Global"];
    dhDebug(@"languagesArray: %@", languagesArray);
    if ([languagesArray count] < 1 || [languagesArray containsObject:@"all"]) {
        return inputArray;
    }
    NSMutableArray *mutableUserStreamArray = [NSMutableArray array];
    for (NSDictionary *postDict in inputArray) {
        NSString *postString = postDict[@"text"];
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
        
        if ([languagesArray containsObject:languageGuessedString]) {
            [mutableUserStreamArray addObject:postDict];
        }
    }
    return mutableUserStreamArray;
}

//- (void)swipeRightHappend:(UISwipeGestureRecognizer*)sender {
//    CGFloat offsetX = self.titleScrollView.contentOffset.x-self.titleScrollView.frame.size.width;
//    
//    [UIView animateWithDuration:0.25f animations:^{
//        self.titleScrollView.contentOffset = CGPointMake(offsetX, 0.0f);
//    } completion:^(BOOL finished) {
//        NSInteger index = (NSInteger)(self.titleScrollView.contentOffset.x/self.titleScrollView.frame.size.width) - 1;
//        if (index >= self.pageControl.numberOfPages) {
//            index = 0;
//            self.titleScrollView.contentOffset = CGPointMake(kScrollViewWidth, 0.0f);
//        } else if (index < 0) {
//            index = self.pageControl.numberOfPages-1;
//            self.titleScrollView.contentOffset = CGPointMake(self.pageControl.numberOfPages*kScrollViewWidth, 0.0f);
//        }
//        self.pageControl.currentPage = index;
//        [self changeStream:index];
//    }];
//    
//}
//
//- (void)swipeLeftHappend:(UISwipeGestureRecognizer*)sender {
//    CGFloat offsetX = self.titleScrollView.contentOffset.x+self.titleScrollView.frame.size.width;
//   
//    [UIView animateWithDuration:0.25f animations:^{
//        self.titleScrollView.contentOffset = CGPointMake(offsetX, 0.0f);
//    } completion:^(BOOL finished) {
//        NSInteger index = (NSInteger)(self.titleScrollView.contentOffset.x/self.titleScrollView.frame.size.width) - 1;
//        if (index >= self.pageControl.numberOfPages) {
//            index = 0;
//            self.titleScrollView.contentOffset = CGPointMake(kScrollViewWidth, 0.0f);
//        } else if (index < 0) {
//            index = self.pageControl.numberOfPages-1;
//            self.titleScrollView.contentOffset = CGPointMake(self.pageControl.numberOfPages*kScrollViewWidth, 0.0f);
//        }
//        self.pageControl.currentPage = index;
//        [self changeStream:index];
//    }];
//}

@end
