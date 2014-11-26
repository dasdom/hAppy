//
//  MapViewCell.m
//  Appetizr
//
//  Created by dasdom on 07.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MapViewCell.h"

@implementation MapViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mapView = [[MKMapView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_mapView];
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
