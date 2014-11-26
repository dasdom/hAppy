//
//  DHInteractionPostCell.h
//  Appetizr
//
//  Created by dasdom on 15.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHPostCell.h"

@interface DHInteractionPostCell : DHPostCell

@property (nonatomic, strong) IBOutlet UIScrollView *userScrollView;
@property (nonatomic, strong) IBOutlet UILabel *actionLabel;

@end
