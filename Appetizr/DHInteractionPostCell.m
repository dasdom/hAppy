     //
//  DHInteractionPostCell.m
//  Appetizr
//
//  Created by dasdom on 15.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHInteractionPostCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation DHInteractionPostCell

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithCellIdentifier:cellID])) {
        _actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, self.frame.size.height-141.0f, 310.0f, 21.0f)];
        _actionLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _actionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
        [self.contentView addSubview:_actionLabel];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, self.frame.size.height-146.0f, 260.0f, 1.0f)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        separatorView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:separatorView];
        
        _userScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5.0f, self.frame.size.height-118.0f, 315.0f, 100.0f)];
        _userScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_userScrollView];
    }
    return self;
}

@end
