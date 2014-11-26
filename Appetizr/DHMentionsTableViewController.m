//
//  DHMentionsTableViewController.m
//  Appetizr
//
//  Created by dasdom on 18.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHMentionsTableViewController.h"
#import "ImageHelper.h"

@implementation DHMentionsTableViewController

- (void)awakeFromNib {
    self.urlString = [NSString stringWithFormat:@"%@%@me/mentions", kBaseURL, kUsersSubURL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [(UITabBarItem*)[self.navigationController.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 40.0f)];
    label.text = NSLocalizedString(@"mentions", nil);
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
    
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
    [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
    self.menuButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;
}

@end
