//
//  DHControllCell.m
//  Appetizr
//
//  Created by dasdom on 20.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHControllCell.h"

@implementation DHControllCell

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
//        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
//        scrollView.pagingEnabled = YES;
//        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        scrollView.contentSize = CGSizeMake(2.0f*self.frame.size.width, self.frame.size.height);
//        [self.contentView addSubview:scrollView];
        
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyButton.frame = CGRectMake(0.0f, 2.0f, 64.0f, 38.0f);
        [_replyButton  setImage:[UIImage imageNamed:@"replyIcon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_replyButton];
        
        _repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _repostButton.frame = CGRectMake(64.0f, 2.0f, 64.0f, 38.0f);
        [_repostButton  setImage:[UIImage imageNamed:@"repostIcon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_repostButton];
        
        _conversationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _conversationButton.frame = CGRectMake(128.0f, 2.0f, 64.0f, 38.0f);
        [_conversationButton  setImage:[UIImage imageNamed:@"conversationIcon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_conversationButton];
        
        _starButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _starButton.frame = CGRectMake(192.0f, 2.0f, 64.0f, 38.0f);
        [_starButton  setImage:[UIImage imageNamed:@"unstarredIcon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_starButton];
        
        _profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _profileButton.frame = CGRectMake(256.0f, 2.0f, 64.0f, 38.0f);
        [_profileButton  setImage:[UIImage imageNamed:@"infoIcon"] forState:UIControlStateNormal];
        [self.contentView addSubview:_profileButton];
        
        _numberOfRepostsLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 34.0f, 64.0f, 16.0f)];
        _numberOfRepostsLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _numberOfRepostsLabel.textAlignment = NSTextAlignmentCenter;
        _numberOfRepostsLabel.text = @"0";
        _numberOfRepostsLabel.textColor = [UIColor whiteColor];
        _numberOfRepostsLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_numberOfRepostsLabel];
        
        _numberOfRepliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(145.0f, 6.0f, 30.0f, 16.0f)];
        _numberOfRepliesLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _numberOfRepliesLabel.textAlignment = NSTextAlignmentCenter;
        _numberOfRepliesLabel.text = @"0";
        _numberOfRepliesLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
        _numberOfRepliesLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_numberOfRepliesLabel];
        
        _numberOfStarsLabel = [[UILabel alloc] initWithFrame:CGRectMake(195.0f, 34.0f, 64.0f, 16.0f)];
        _numberOfStarsLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _numberOfStarsLabel.textAlignment = NSTextAlignmentCenter;
        _numberOfStarsLabel.text = @"0";
        _numberOfStarsLabel.textColor = [UIColor whiteColor];
        _numberOfStarsLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_numberOfStarsLabel];
        
//        _textField = [[UITextField alloc] initWithFrame:CGRectMake(self.frame.size.width+10.0f, 10.0f, self.frame.size.width-20.0f, 35.0f)];
//        _textField.borderStyle = UITextBorderStyleLine;
//        _textField.returnKeyType = UIReturnKeySend;
//        _textField.font = [UIFont systemFontOfSize:12];
//        [self.contentView addSubview:_textField];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        self.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
        self.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
    } else {
        self.contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
    }
}

@end
