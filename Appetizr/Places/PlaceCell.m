//
//  PlaceCell.m
//  Appetizr
//
//  Created by dasdom on 06.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PlaceCell.h"

@implementation PlaceCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, frame.size.width-20.0f, frame.size.height)];
        [self.contentView addSubview:_nameLabel];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
