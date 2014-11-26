//
//  DHProfileTableViewController.h
//  Appetizr
//
//  Created by dasdom on 27.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHStreamTableViewController.h"

@interface DHProfileTableViewController : DHStreamTableViewController

@property (nonatomic, strong) NSString *userId;
@property (nonatomic) BOOL youFollow;
@property (nonatomic) BOOL youMuted;
@property (nonatomic, strong) NSArray *channelsArray;

@end
