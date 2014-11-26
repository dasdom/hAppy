//
//  MutedHashtagCell.m
//  Appetizr
//
//  Created by dasdom on 01.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MutedHashtagCell.h"
#import "DHGlobalObjects.h"

@implementation MutedHashtagCell

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
        _hashtagLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 4.0f, 252.0f, 21.0f)];
        _hashtagLabel.textColor = [UIColor grayColor];
        _hashtagLabel.backgroundColor = [UIColor clearColor];
        _hashtagLabel.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:kFontName] size:[[[NSUserDefaults standardUserDefaults] objectForKey:kFontSize] floatValue]];
        [self.contentView addSubview:_hashtagLabel];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(self.frame.size.width-44.0f, 1.0f, 44.0f, 30.0f);
        [_deleteButton setTitle:@"x" forState:UIControlStateNormal];
        _deleteButton.titleLabel.textColor = [UIColor redColor];
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _deleteButton.accessibilityLabel = @"Remove";
        _deleteButton.accessibilityHint = @"Remove the hashtag from the list of muted hashtags.";
        [self.contentView addSubview:_deleteButton];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
            self.backgroundColor = [[DHGlobalObjects sharedGlobalObjects] darkCellBackgroundColor];
        } else {
            self.backgroundColor = [[DHGlobalObjects sharedGlobalObjects] cellBackgroundColor];
        }
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    [[UIColor darkGrayColor] set];
//    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, rect.size.width, 1.0f));
//
//}

@end
