//
//  DHPostCell.m
//  Appetizr
//
//  Created by dasdom on 14.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHPostCell.h"
#import <QuartzCore/QuartzCore.h>
#import "HappyActionIcons.h"

#define AVATAR_FRAME_LEFT CGRectMake(5.0f, 5.0f, 56.0f, 56.0f)
#define AVATAR_FRAME_RIGHT CGRectMake(self.frame.size.width-61.0f, 5.0f, 56.0f, 56.0f)

#define NAME_POINT_LEFT CGPointMake(66.0f, 2.0f)
#define NAME_POINT_RIGHT CGPointMake(5.0f, 2.0f)

#define DATE_FRAME_LEFT CGRectMake(self.frame.size.width-111.0f, 2.0f, 104.0f, 15.0f)
#define DATE_FRAME_RIGHT CGRectMake(self.frame.size.width-176.0f, 2.0f, 104.0f, 15.0f)

#define CLIENT_POINT_LEFT CGPointMake(66.0f, self.frame.size.height-17.0f)
#define CLIENT_POINT_RIGHT CGPointMake(5.0f, self.frame.size.height-17.0f)

@interface PostContentView : UIView {
    DHPostCell *_postCell;
    BOOL _highlighted;
}
@end

@implementation PostContentView

- (id)initWithFrame:(CGRect)frame cell:(DHPostCell*)cell
{
    if (self = [super initWithFrame:frame])
    {
        _postCell = cell;
        
        self.opaque = YES;
        self.backgroundColor = _postCell.backgroundColor;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (rect.size.height < 1) {
        return;
    }
    
    CGPoint nameStringPoint;
    CGRect dateFrame;
    CGPoint clientStringPoint;
    CGRect avatarFrame;
    if (_postCell.drawAvatarRight) {
        nameStringPoint = NAME_POINT_RIGHT;
        dateFrame = DATE_FRAME_RIGHT;
        clientStringPoint = CLIENT_POINT_RIGHT;
        avatarFrame = AVATAR_FRAME_RIGHT;
    } else {
        nameStringPoint = NAME_POINT_LEFT;
        dateFrame = DATE_FRAME_LEFT;
        clientStringPoint = CLIENT_POINT_LEFT;
        avatarFrame = AVATAR_FRAME_LEFT;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    [_postCell.postColor set];
    CGContextFillRect(context, rect);
    
    if (_postCell.iAmFollowing) {
        [[UIColor colorWithRed:0.79f green:0.5f blue:0.5f alpha:1.0f] set];
//        CGContextFillRect(context, CGRectMake(avatarFrame.origin.x+10.0f, avatarFrame.origin.y+avatarFrame.size.height+2, 28.0f-10.0f, 2.0f));
        CGRect rect = CGRectMake(CGRectGetMidX(avatarFrame)-8.0f, avatarFrame.origin.y+avatarFrame.size.height+2, 6.0f, 6.0f);
        CGContextFillEllipseInRect(context, rect);
    }
    if (_postCell.followsMe) {
        [[UIColor colorWithRed:0.48f green:0.75f blue:0.48f alpha:1.0f] set];
//        CGContextFillRect(context, CGRectMake(avatarFrame.origin.x+28.0f, avatarFrame.origin.y+avatarFrame.size.height+2, 28.0f-10.0f, 2.0f));
        CGRect rect = CGRectMake(CGRectGetMidX(avatarFrame)+2.0f, avatarFrame.origin.y+avatarFrame.size.height+2, 6.0f, 6.0f);
        CGContextFillEllipseInRect(context, rect);
    }
    
    [_postCell.textColor set];
    [_postCell.nameString drawAtPoint:nameStringPoint withFont:[UIFont fontWithName:@"Avenir-Medium" size:14.0f]];
    [_postCell.dateString drawInRect:dateFrame withFont:[UIFont fontWithName:@"Avenir-Medium" size:10.0f] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
    if (!_postCell.noClient) {
        [_postCell.clientString drawAtPoint:clientStringPoint withFont:[UIFont fontWithName:@"Avenir-Medium" size:10.0f]];
    }
    
    if (_postCell.noImages) {
        CGFloat blueFloat = (CGFloat)([_postCell.userId integerValue]%100)/100.0f;
        CGFloat greenFloat = (CGFloat)(([_postCell.userId integerValue]/100)%100)/100.0f;
        CGFloat redFloat = (CGFloat)(([_postCell.userId integerValue]/10000)%100)/100.0f;
        [[UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f] set];
        CGContextFillRect(context, avatarFrame);
        
        if (_postCell.postImageURL) {
            [[UIColor grayColor] set];
            CGContextStrokeRectWithWidth(context, _postCell.postImageFrame, 1.0f);
        }
    } else {
//        CGRect offsetRect = avatarFrame;
//        offsetRect.origin = CGPointZero;
//        
//        UIGraphicsBeginImageContext(offsetRect.size);
//        CGContextRef imgContext = UIGraphicsGetCurrentContext();
//        
//        CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:offsetRect cornerRadius:6.0f].CGPath;
//        CGContextAddPath(imgContext, clippingPath);
//        CGContextClip(imgContext);
//        
//        [_postCell.avatarImage drawInRect:offsetRect];
//        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();

        [_postCell.avatarImage drawInRect:avatarFrame blendMode:kCGBlendModeNormal alpha:1.0f];
        [_postCell.postImage drawInRect:_postCell.postImageFrame blendMode:kCGBlendModeNormal alpha:1.0f];
    }

    if (_postCell.isSelectedCell) {
        [[_postCell.shadowImageView resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)] drawInRect:CGRectMake(0.0f, 0.0f, self.frame.size.width, 10.0f) blendMode:kCGBlendModeNormal alpha:1.0f];
    } else {
        [_postCell.customSeparatorColor set];
        CGContextFillRect(context, CGRectMake(0.0f, 0.0f, rect.size.width, 0.5f));
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted
{
    return _highlighted;
}

@end


@implementation DHPostCell

- (void)awakeFromNib {
    self.userId = @"";
}

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
        self.clipsToBounds = YES;
        
        _actionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 5.0f, 30.0f, 30.0f)];
        _actionImageView.layer.cornerRadius = 3.0f;
        [self.contentView addSubview:_actionImageView];
        
        _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 100.0f, 60.0f)];
        _idLabel.numberOfLines = 0;
        _idLabel.font = [UIFont systemFontOfSize:10.0f];
        _idLabel.alpha = 0.0f;
//        _idLabel.backgroundColor = [UIColor yellowColor];
        [self.contentView addSubview:_idLabel];
        
        _buttonHostView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.contentView.frame.size.width, 35.0f)];
//            view.backgroundColor = [UIColor redColor];
            
            _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _replyButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_replyButton setImage:[HappyActionIcons imageOfReplyWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
            [view addSubview:_replyButton];
            
            _repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _repostButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_repostButton setImage:[HappyActionIcons imageOfRepostWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
            [view addSubview:_repostButton];
            
            _conversationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _conversationButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_conversationButton setImage:[HappyActionIcons imageOfConversationWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
            [view addSubview:_conversationButton];
            
            _starButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _starButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_starButton setImage:[HappyActionIcons imageOfFavWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
            [view addSubview:_starButton];
            
            NSDictionary *views = NSDictionaryOfVariableBindings(_replyButton, _repostButton, _conversationButton, _starButton);
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_replyButton(_repostButton,_conversationButton,_starButton)]-[_repostButton]-[_starButton]-[_conversationButton]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_replyButton(_repostButton,_conversationButton,_starButton)]|" options:kNilOptions metrics:nil views:views]];
            
            view.alpha = 0.8f;
            view.hidden = YES;
            
            view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            view.layer.shadowColor = [UIColor blackColor].CGColor;
            view.layer.shadowRadius = 3.0f;
            view.layer.shadowOpacity = 0.8f;
            
            view;
        });
        
        _postContentView = [[PostContentView alloc] initWithFrame:self.contentView.bounds cell:self];
        _postContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _postContentView.contentMode = UIViewContentModeRedraw;
        [self.contentView addSubview:_postContentView];

        [self.contentView addSubview:_buttonHostView];

//        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 56.0f, 56.0f)];
//        _avatarImageView.clipsToBounds = YES;
//        [self.contentView addSubview:_avatarImageView];
//        
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0f, 5.0f, 100.0f, 15.0f)];
//        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
//        [self.contentView addSubview:_nameLabel];
        
//        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(193.0f, 5.0f, 120.0f, 15.0f)];
//        _dateLabel.font = [UIFont boldSystemFontOfSize:12.0f];
//        _dateLabel.textColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
//        [self.contentView addSubview:_dateLabel];
        
        _postTextView = [[DHPostTextView alloc] initWithFrame:CGRectMake(66.0f, 25.0f, 167.0f, 38.0f)];
        [_postContentView addSubview:_postTextView];
        
        UIImage *image = [HappyActionIcons imageOfConversationWithSize:CGSizeMake(15.0f, 15.0f)];
        _conversationImageView = [[UIImageView alloc] initWithImage:image];
        _conversationImageView.hidden = true;
        _conversationImageView.tintColor = [UIColor lightGrayColor];
        [_postContentView addSubview:_conversationImageView];
        
//        _postImageView = [[UIImageView alloc] initWithFrame:CGRectMake(257.0f, 20.0f, 56.0f, 56.0f)];
//        _postImageView.clipsToBounds = YES;
//        [self.contentView addSubview:_postImageView];
//        
//        _clientLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0f, 63.0f, 243.0f, 16.0f)];
//        _clientLabel.font = [UIFont boldSystemFontOfSize:10.0f];
//        _clientLabel.textColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
//        _clientLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//        [self.contentView addSubview:_clientLabel];
        
        _shadowImageView = [UIImage imageNamed:@"selectedCellShadow"];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect actionImageViewFrame = self.actionImageView.frame;
    actionImageViewFrame.origin.x = self.contentView.frame.size.width-5.0f-actionImageViewFrame.size.width;
    self.actionImageView.frame = actionImageViewFrame;
    
    CGRect conversationImageFrame = self.conversationImageView.frame;
    conversationImageFrame.origin.x = self.contentView.frame.size.width-20.0f;
    conversationImageFrame.origin.y = self.contentView.frame.size.height-20.0f;
    self.conversationImageView.frame = conversationImageFrame;
    
    CGRect buttonHostViewFrame = self.buttonHostView.frame;
    buttonHostViewFrame.origin.y = self.contentView.frame.size.height+5.0f;
    buttonHostViewFrame.size.width = self.contentView.frame.size.width;
    self.buttonHostView.frame = buttonHostViewFrame;
}

- (void)drawRect:(CGRect)rect {
//    self.avatarImageView.layer.cornerRadius = 3.0f;
//    self.postImageView.layer.cornerRadius = 3.0f;
//    self.postImageView.layer.borderColor = [[UIColor grayColor] CGColor];
//    
    self.backgroundColor = self.postColor;
}

- (void)accessibilityElementDidBecomeFocused {
    self.isFocused = YES;
}

- (void)accessibilityElementDidLoseFocus {
    self.isFocused = NO;
}

//- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    _postContentView.backgroundColor = backgroundColor;
//    [super setBackgroundColor:backgroundColor];
//}

- (void)setAvatarImage:(UIImage *)avatarImage {
    _avatarImage = avatarImage;
    if (self.drawAvatarRight) {
        [self.postContentView setNeedsDisplayInRect:AVATAR_FRAME_RIGHT];
    } else {
        [self.postContentView setNeedsDisplayInRect:AVATAR_FRAME_LEFT];
    }
}

- (void)setPostImage:(UIImage *)postImage {
    _postImage = postImage;
    CGRect postImageFrame = self.postImageFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.drawAvatarRight) {
            postImageFrame.origin.x = self.frame.size.width-168.0f;
        } else {
            postImageFrame.origin.x = self.frame.size.width-107.0f;
        }
    }
    self.postImageFrame = postImageFrame;
    [self.postContentView setNeedsDisplayInRect:self.postImageFrame];
}

- (CGRect)avatarFrame {
    if (self.drawAvatarRight) {
        return AVATAR_FRAME_RIGHT;
    } else {
        return AVATAR_FRAME_LEFT;
    }
}

- (BOOL)toggleActionButtonView {

    BOOL actionsVisible = !self.buttonHostView.hidden;
    [self setActionButtonViewHidden:actionsVisible];
//    if (actionsVisible) {
//        postContentViewFrame.origin.y = 0.0f;
//        alphaOfHostView = 0.0f;
//    } else {
//        postContentViewFrame.origin.y = -40.0f;
//        alphaOfHostView = 1.0f;
//        self.buttonHostView.hidden = NO;
//        
////        NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
////        self.controlIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
//    }
//    
//    [UIView animateWithDuration:0.2f animations:^{
//        self.postContentView.frame = postContentViewFrame;
//    } completion:^(BOOL finished) {
//        
//        BOOL actionsVisible = (postContentViewFrame.origin.y < 0);
//        if (!actionsVisible) {
//            self.buttonHostView.hidden = YES;
//        }
//    }];

    return !actionsVisible;
}

- (void)setActionButtonViewHidden:(BOOL)hidden {
    CGFloat alphaOfHostView = 0.0f;

    CGRect buttonHostViewFrame = self.buttonHostView.frame;
    if (hidden) {
//        postContentViewFrame.origin.y = 0.0f;
        alphaOfHostView = 0.0f;
        buttonHostViewFrame.origin.y = self.contentView.frame.size.height+5.0f;
    } else {
//        postContentViewFrame.origin.y = -40.0f;
        alphaOfHostView = 0.8f;
        self.buttonHostView.hidden = NO;
        self.buttonHostView.backgroundColor = self.backgroundColor;
//        buttonHostViewFrame.origin.y = ceilf((self.contentView.frame.size.height-buttonHostViewFrame.size.height)/2.0f);
        buttonHostViewFrame.origin.y = self.contentView.frame.size.height-buttonHostViewFrame.size.height-3.0f;
        
        if (self.faved) {
            [self.starButton setImage:[HappyActionIcons imageOfFavedWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
        } else {
            [self.starButton setImage:[HappyActionIcons imageOfFavWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
        }

        //        NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
        //        self.controlIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    }
    
    
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.0f options:kNilOptions animations:^{
//        self.postContentView.frame = postContentViewFrame;
//        self.buttonHostView.alpha = alphaOfHostView;
        self.buttonHostView.frame = buttonHostViewFrame;
    } completion:^(BOOL finished) {
        if (hidden) {
            self.buttonHostView.hidden = YES;
        }
    }];

}

@end
