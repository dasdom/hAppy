//
//  SplitMasterButtonView.h
//  Appetizr
//
//  Created by dasdom on 18.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitMasterButtonView : UIView

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic) BOOL isSelected;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleString;
- (void)setSelected:(BOOL)isSelected;

@end
