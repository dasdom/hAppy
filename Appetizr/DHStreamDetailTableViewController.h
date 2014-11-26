//
//  DHStreamDetailTableViewController.h
//  Appetizr
//
//  Created by dasdom on 18.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHStreamTableViewController.h"

@interface DHStreamDetailTableViewController : DHStreamTableViewController

@property (nonatomic, strong) NSDictionary *postDictionary;
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) DHStreamTableViewController *streamTableViewController;

@end
