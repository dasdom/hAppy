//
//  DHMessagesTableViewController.h
//  Appetizr
//
//  Created by dasdom on 16.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHStreamTableViewController.h"

@interface DHMessagesTableViewController : DHStreamTableViewController

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic) BOOL isPatter;

@end
