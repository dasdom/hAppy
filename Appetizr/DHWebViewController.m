//
//  DHWebViewController.m
//  Appetizr
//
//  Created by dasdom on 26.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHWebViewController.h"
#import "PRPAlertView.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/Twitter.h>
#import "DHOpenWebsiteActivity.h"
#import "SlideInView.h"

@interface DHWebViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadActivityIndicator;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@end

@implementation DHWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.linkString]];
    [self.webView loadRequest: urlRequest];
    
    self.title = self.linkString;
    
    self.backButton.accessibilityLabel = @"Back";
    self.backButton.accessibilityHint = @"Loads the previous website.";
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        self.webView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        self.toolBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
    } else {
        self.webView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        self.toolBar.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
    }

    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:swipeRightGestureRecognizer];
    
    self.webView.scrollView.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadActivityIndicator stopAnimating];
    
    self.title = self.webView.request.URL.absoluteString;
    if ([webView canGoBack]) {
        self.backButton.enabled = YES;
    } else {
        self.backButton.enabled = NO;
    }
}

- (IBAction)backButtonTouched:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (IBAction)actionButtonTouched:(UIBarButtonItem *)sender {
    NSString *link = self.webView.request.URL.absoluteString;
    NSArray *dataToShare = @[link];

    DHOpenWebsiteActivity *safariActivity = [[DHOpenWebsiteActivity alloc] init];
 
    NSMutableArray *activityArray = [NSMutableArray arrayWithObject:safariActivity];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:[activityArray copy]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        activityViewController.popoverPresentationController.sourceView = postCell.postTextView;
//        CGRect sourceRect = CGRectMake(locationInPostText.x, locationInPostText.y, 10, 10);
        activityViewController.popoverPresentationController.barButtonItem = sender;
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
        [self presentViewController:activityViewController animated:YES completion:^{}];
    } else {
        [self presentViewController:activityViewController animated:YES completion:^{}];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < -60.0f) {
        [self swipeRightHappend:nil];
    }
}

- (void)swipeRightHappend:(UISwipeGestureRecognizer*)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
