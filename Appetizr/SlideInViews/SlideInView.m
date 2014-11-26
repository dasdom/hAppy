//
//  SlideInView.m
//  SlideInView
//
//  Created by Dominik Hauser on 20.02.13.
//  Copyright (c) 2013 Appseleration. All rights reserved.
//

#import "SlideInView.h"
#import "DHGlobalObjects.h"

@interface SlideInView ()

@property CGFloat adjustY;
@property CGFloat adjustX;
@property CGSize imageSize;
@property (nonatomic, strong) UIImageView *undoIconImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) SlideInCompletionBlock slideInCompletionBlock;

@end

@implementation SlideInView

//+ (id)viewWithImage:(UIImage *)SlideInImage {
//	
//   SlideInView *SlideIn = [[SlideInView alloc] init];
//   SlideIn.imageSize = SlideInImage.size;
//   SlideIn.layer.bounds = CGRectMake(0, 0, SlideIn.imageSize.width,
//                                           SlideIn.imageSize.height);
//   SlideIn.layer.anchorPoint = CGPointMake(0, 0);
//   SlideIn.layer.position = CGPointMake(-SlideIn.imageSize.width, 0);	
//   SlideIn.layer.contents = (id)SlideInImage.CGImage;
//   return SlideIn;
//}
//
//+ (id)viewWithImage:(UIImage *)SlideInImage andText:(NSString*)text {
//	
//    SlideInView *SlideIn = [SlideInView viewWithImage:SlideInImage];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:SlideIn.layer.bounds];
//    label.text = text;
//    label.font = [UIFont boldSystemFontOfSize:15.0f];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = UITextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    [SlideIn addSubview:label];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:SlideIn selector:@selector(removeAsObserver:) name:kObservedKVWillDismiss object:nil];
//    
//    return SlideIn;
//}

+ (id)viewWithView:(UIView*)theView {
    SlideInView *slideInView = [SlideInView viewWithImage:nil text:nil andSize:theView.frame.size];
    [slideInView addSubview:theView];
    return slideInView;
}

+ (id)viewWithImage:(UIImage *)slideInImage text:(NSString *)text andSize:(CGSize)aSize {
//    SlideInView *slideInView = [[SlideInView alloc] initWithSize:aSize];
//    
//    slideInView.backgroundColor = [UIColor colorWithPatternImage:slideInImage];
//    
//    slideInView.messageLabel.text = text;
//    
//    slideInView.slideInCompletionBlock = nil;
//    
//    return slideInView;
    return [SlideInView viewWithImage:slideInImage text:text size:aSize completionBlock:nil];
}

+ (id)viewWithImage:(UIImage *)slideInImage text:(NSString *)text size:(CGSize)aSize completionBlock:(SlideInCompletionBlock)completionBlock {
    SlideInView *slideInView = [[SlideInView alloc] initWithSize:aSize];
    
    if (slideInImage) {
        slideInView.backgroundColor = [UIColor colorWithPatternImage:slideInImage];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        slideInView.backgroundColor = [kDarkMainColor colorWithAlphaComponent:0.9f];
        slideInView.backgroundColor = [[DHGlobalObjects sharedGlobalObjects].darkMainColor colorWithAlphaComponent:0.9f];
    } else {
        slideInView.backgroundColor = [[DHGlobalObjects sharedGlobalObjects].mainColor colorWithAlphaComponent:0.9f];
    }
    
    slideInView.messageLabel.text = text;
    
    slideInView.slideInCompletionBlock = completionBlock;
    
    [[NSNotificationCenter defaultCenter] addObserver:slideInView selector:@selector(removeAsObserver:) name:kObservedKVWillDismiss object:nil];
    
    return slideInView;
}

- (id)initWithSize:(CGSize)aSize {
    if ((self = [super init])) {
        _imageSize = aSize;
        self.frame = CGRectMake(0.0f, 0.0f, aSize.width, aSize.height);
                
        _messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _messageLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:15.0f];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_messageLabel];
        
        _undoIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"systemfeedback_undo_icon"] highlightedImage:[UIImage imageNamed:@"systemfeedback_undo_icon_hover"]];
        CGRect undoIconImageViewFrame = _undoIconImageView.frame;
        undoIconImageViewFrame.origin = CGPointMake(aSize.width-undoIconImageViewFrame.size.width-7.0f, 8.0f);
        _undoIconImageView.frame= undoIconImageViewFrame;
        [self addSubview:_undoIconImageView];

        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        self.layer.shadowOpacity = 0.8f;
        self.layer.shadowRadius = 6.0f;
    }
    return self;
}

- (void)awakeFromNib {
	
   self.imageSize = self.frame.size;
   self.layer.bounds = CGRectMake(0, 0, self.imageSize.width, 
                                        self.imageSize.height);
   self.layer.anchorPoint = CGPointMake(0, 0);
   self.layer.position = CGPointMake(-self.imageSize.width, 0);
}

- (void)showWithTimer:(CGFloat)timer inView:(UIView *)view from:(SlideInViewSide)side {
	
    self.adjustX = 0;
    self.adjustY = 0;
    CGPoint fromPos;
    switch (side) {              //  align view and set adjustment value
        case SlideInViewTop:
            self.adjustY = self.imageSize.height;
            fromPos = CGPointMake(view.frame.size.width/2-self.imageSize.width/2,
                                  -self.imageSize.height);
            break;
        case SlideInViewBot:
            self.adjustY = -self.imageSize.height;
            fromPos = CGPointMake(view.frame.size.width/2-self.imageSize.width/2,
                                  view.bounds.size.height);
            break;
        case SlideInViewLeft:
            self.adjustX = self.imageSize.width;
            fromPos = CGPointMake(-self.imageSize.width,
                                  view.frame.size.height/2-self.imageSize.height/2);
			break;
        case SlideInViewRight:
            self.adjustX = -self.imageSize.width;
            fromPos = CGPointMake(view.bounds.size.width,
                                  view.frame.size.height/2-self.imageSize.height/2);
            break;
        default:
            return;
	}
        
    CGPoint toPos = fromPos;
    toPos.x += self.adjustX;
    toPos.y	+= self.adjustY;
    
    if ([view isKindOfClass:[UITableView class]]) {
        CGFloat contentOffsetY = [(UITableView*)view contentOffset].y;
        toPos.y += contentOffsetY;
        fromPos.y += contentOffsetY;
        
        [view addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    CGRect frame = self.frame;
    frame.origin = fromPos;
    self.frame = frame;
    
//    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"position"];
//    basic.fromValue = [NSValue valueWithCGPoint:fromPos];
//    basic.toValue = [NSValue valueWithCGPoint:toPos];
//    self.layer.position = toPos;
//    [self.layer addAnimation:basic forKey:@"basic"];		

    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = self.frame;
        frame.origin = toPos;
        self.frame = frame;
    }];
    
    popInTimer = [NSTimer scheduledTimerWithTimeInterval:timer 
                                                  target:self 
                                                selector:@selector(popInFromTimer) 
                                                userInfo:nil 
                                                 repeats:NO];
	
    [view addSubview:self];
}


- (void)popIn {                            // Use explicit animation to slide out image
    [popInTimer invalidate];
    if ([[self superview] isKindOfClass:[UITableView class]]) {
        [[self superview] removeObserver:self forKeyPath:@"contentOffset"];
    }
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = CGRectOffset(self.frame, -self.adjustX, -self.adjustY);
//        self.frame = CGRectOffset(self.frame, -adjustX, self.superview.frame.size.height);
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
		
}

- (void)popInFromTimer {
    if (self.slideInCompletionBlock) {
        self.slideInCompletionBlock();
    }
    [self popIn];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	self.undoIconImageView.highlighted = YES;
//    self.messageLabel.font = TH16_FONT;
//    self.messageLabel.textColor = TH16_COLOR;
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGRect viewFrame = self.frame;
    CGPoint offset = [[change objectForKey:@"new"] CGPointValue];
    viewFrame.origin.y = offset.y;
    self.frame = viewFrame;
}

- (void)removeAsObserver:(NSNotification*)notification {
   	[popInTimer invalidate];
    if (self.slideInCompletionBlock) {
        self.slideInCompletionBlock();
    }
    if ([[self superview] isKindOfClass:[UITableView class]]) {
        [[self superview] removeObserver:self forKeyPath:@"contentOffset"];
    }
    [self removeFromSuperview];
}

@end




