//
//  DHSplitViewController.h
//  Appetizr
//
//  Created by dasdom on 24.04.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHSplitViewController : UIViewController

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic) NSInteger masterWidth;

- (id)initWithViewControllers:(NSArray*)viewControllers;

@end
