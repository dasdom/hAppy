//
//  DHHashtagTableViewController.h
//  Appetizr
//
//  Created by dasdom on 18.11.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHStreamTableViewController.h"

@interface DHHashtagTableViewController : DHStreamTableViewController <UISearchBarDelegate>

@property (nonatomic, strong) NSString *hashTagString;

@end
