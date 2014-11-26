//
//  DHSplitViewController.m
//  Appetizr
//
//  Created by dasdom on 24.04.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DHSplitViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DHSplitViewController ()
@property (nonatomic, strong) UIImageView *shadowImageView;
@end

@implementation DHSplitViewController

- (id)initWithViewControllers:(NSArray*)viewControllers {
    if ((self = [super init])) {
        if ([viewControllers count] != 2) {
            NSAssert(false, @"Count of viewControllers is not 2.");
        }
        self.viewControllers = viewControllers;
        self.masterWidth = 60.0f;
    }
    return self;
}

- (void)loadView {
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    CGRect masterFrame = CGRectMake(0.0f, 0.0f, 200.0f, frame.size.height);
    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    masterViewController.view.frame = masterFrame;
    masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [masterViewController viewWillAppear:NO];
    [contentView addSubview:masterViewController.view];
    [masterViewController viewDidAppear:NO];
    [self addChildViewController:masterViewController];
    
    CGRect detailFrame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            detailFrame = CGRectMake(200.0f, 0.0f, frame.size.width-200.0f, frame.size.height);
        }
//    } else {
//        detailFrame = CGRectMake(self.masterWidth, 0.0f, frame.size.width, frame.size.height);
    }
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    detailViewController.view.frame = detailFrame;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        detailViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
//    } else {
        detailViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    }
    [detailViewController viewWillAppear:NO];
    [contentView addSubview:detailViewController.view];
    [detailViewController viewDidAppear:NO];
//    detailViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
//    detailViewController.view.layer.shadowOffset = CGSizeMake(-2.0f, 0.0f);
//    detailViewController.view.layer.shadowOpacity = 1.0f;
//    detailViewController.view.layer.shadowRadius = 3.0f;
    [self addChildViewController:detailViewController];
    
    _shadowImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"sideMenuShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0f, 0.0f, 4.0f, 0.0f)]];
    _shadowImageView.frame = CGRectMake(detailFrame.origin.x-8.0f, 0.0f, 8.0f, detailFrame.size.height);
    _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:_shadowImageView];
    
    self.view = contentView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleMenu:) name:kMenuTouchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenu:) name:kHideMenuNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [[self.viewControllers objectAtIndex:0] viewDidLoad];
    [[self.viewControllers objectAtIndex:1] viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//            UIViewController *viewController = [self.viewControllers objectAtIndex:1];
//            CGRect viewFrame = viewController.view.frame;
//            viewFrame.origin.x = 200.0f;
//            viewFrame.size.width = 1024.0f-200.0f;
//            viewController.view.frame = viewFrame;
//        } else {
//            UIViewController *viewController = [self.viewControllers objectAtIndex:1];
//            CGRect viewFrame = viewController.view.frame;
//            viewFrame.origin.x = 0.0f;
//            viewFrame.size.width = 768.0f;
//            viewController.view.frame = viewFrame;
//        }
//    }
    
    [[self.viewControllers objectAtIndex:0] viewWillAppear:animated];
    [[self.viewControllers objectAtIndex:1] viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[self.viewControllers objectAtIndex:0] viewDidAppear:animated];
    [[self.viewControllers objectAtIndex:1] viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[self.viewControllers objectAtIndex:0] viewWillDisappear:animated];
    [[self.viewControllers objectAtIndex:1] viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[self.viewControllers objectAtIndex:0] viewDidDisappear:animated];
    [[self.viewControllers objectAtIndex:1] viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate {
    return [self.viewControllers[1] shouldAutorotate] && [self.viewControllers[0] shouldAutorotate];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            UIViewController *viewController = [self.viewControllers objectAtIndex:1];
            CGRect viewFrame = viewController.view.frame;
            viewFrame.origin.x = 200.0f;
            viewFrame.size.width = 1024.0f-200.0f;
            viewController.view.frame = viewFrame;
            
            CGRect shadowFrame = self.shadowImageView.frame;
            shadowFrame.origin.x = 192.0f;
            self.shadowImageView.frame = shadowFrame;
        } else {
            UIViewController *viewController = [self.viewControllers objectAtIndex:1];
            CGRect viewFrame = viewController.view.frame;
            viewFrame.origin.x = 0.0f;
            viewFrame.size.width = 768.0f;
            viewController.view.frame = viewFrame;
            
            CGRect shadowFrame = self.shadowImageView.frame;
            shadowFrame.origin.x = -8.0f;
            self.shadowImageView.frame = shadowFrame;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleMenu:(NSNotification*)notification {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            return;
        }
    }
    
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    CGRect detailFrame = detailViewController.view.frame;
    if (detailFrame.origin.x < self.masterWidth/2.0f) {
        [self showMenu:nil];
    } else {
        [self hideMenu:nil];
    }
}

- (void)hideMenu:(NSNotification*)notification {
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    CGRect detailFrame = detailViewController.view.frame;
    if (detailFrame.origin.x <= 0)
    {
        return;
    }
    detailFrame.origin.x = 0.0f;
    
    [UIView animateWithDuration:0.2f animations:^{
        detailViewController.view.frame = detailFrame;
        
        CGRect shadowFrame = self.shadowImageView.frame;
        shadowFrame.origin.x = detailFrame.origin.x-8.0f;
        self.shadowImageView.frame = shadowFrame;
    } completion:^(BOOL finished) {
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, NSLocalizedString(@"Menu hidden", nil));
    }];
}

- (void)showMenu:(NSNotification*)notification {
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    CGRect detailFrame = detailViewController.view.frame;
    detailFrame.origin.x = self.masterWidth;
   
    [UIView animateWithDuration:0.2f animations:^{
        detailViewController.view.frame = detailFrame;
        
        CGRect shadowFrame = self.shadowImageView.frame;
        shadowFrame.origin.x = detailFrame.origin.x-8.0f;
        self.shadowImageView.frame = shadowFrame;
    } completion:^(BOOL finished) {
       UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, NSLocalizedString(@"Menu visible", nil));
    }];
}

@end
