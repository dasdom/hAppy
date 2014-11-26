//
//  MutedHashtagCell.h
//  Appetizr
//
//  Created by dasdom on 01.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRPSmartTableViewCell.h"

@interface MutedHashtagCell : PRPSmartTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *hashtagLabel;
@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, strong) NSString *threadId;
@property (nonatomic, strong) NSString *clientName;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

@end
