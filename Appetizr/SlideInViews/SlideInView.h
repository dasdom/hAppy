//
//  SlideInView.h
//  SlideInView
//
//  Created by Dominik Hauser on 20.02.13.
//  Copyright (c) 2013 Appseleration. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kObservedKVWillDismiss @"kObservedKVWillDismiss"

typedef enum {	
	SlideInViewTop,
	SlideInViewBot, 
	SlideInViewLeft, 
	SlideInViewRight, 
} SlideInViewSide;

@interface SlideInView : UIView {
	
	NSTimer *popInTimer;

}

typedef void (^SlideInCompletionBlock)(void);

//+ (id)viewWithImage:(UIImage *)SlideInImage;
//+ (id)viewWithImage:(UIImage *)SlideInImage andText:(NSString*)text;
+ (id)viewWithView:(UIView*)theView;
+ (id)viewWithImage:(UIImage *)slideInImage text:(NSString *)text andSize:(CGSize)aSize;
+ (id)viewWithImage:(UIImage *)slideInImage text:(NSString *)text size:(CGSize)aSize completionBlock:(SlideInCompletionBlock)completionBlock;

- (void)showWithTimer:(CGFloat)timer inView:(UIView *)view from:(SlideInViewSide)side;
- (void)popIn;

@end





