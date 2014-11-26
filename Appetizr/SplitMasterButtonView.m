//
//  SplitMasterButtonView.m
//  Appetizr
//
//  Created by dasdom on 18.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "SplitMasterButtonView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SplitMasterButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleString {
    if ((self = [super initWithFrame:frame])) {
//        _backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tabBarSelectionShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) resizingMode:UIImageResizingModeStretch]];
        _backgroundImageView = [[UIImageView alloc] init];

        _backgroundImageView.frame = self.bounds;
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backgroundImageView];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 30.0f, 30.0f)];
        [self addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 0.0f, 150.0f, frame.size.height)];
        _titleLabel.text = titleString;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            _titleLabel.textColor = kDarkTextColor;
            _titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        } else {
            _titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        }
        _titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = titleString;
        
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setSelected:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *theTouch = [[event touchesForView:self] anyObject];
    CGPoint location = [theTouch locationInView:self];
    if (!CGRectContainsPoint(self.frame, location) && !self.isSelected) {
        _backgroundImageView.image = nil;
    }
}

- (void)setSelected:(BOOL)isSelected {
    self.isSelected = isSelected;
    if (isSelected) {
//        _backgroundImageView.image = [[UIImage imageNamed:@"tabBarSelectionShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) resizingMode:UIImageResizingModeStretch];
        UIImage *backgroundImage = [[UIImage imageNamed:@"tabBarSelectionShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) resizingMode:UIImageResizingModeStretch];
        if ([backgroundImage respondsToSelector:@selector(imageWithRenderingMode:)]) {
            _backgroundImageView.image = [[[UIImage imageNamed:@"tabBarSelectionShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) resizingMode:UIImageResizingModeStretch] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _backgroundImageView.tintColor = _titleLabel.textColor;
        } else {
            _backgroundImageView.image = backgroundImage;
        }
    } else {
        _backgroundImageView.image = nil;
    }
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
