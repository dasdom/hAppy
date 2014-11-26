//
//  ImageHelper.h
//  Appetizr
//
//  Created by dasdom on 18.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject

+ (UIImage*)speechBubbleWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)atSignWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)globeWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)letterWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)pawWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)headWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)swipeHandleWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)searchWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)menueImage;
+ (UIImage*)menueWithStreamColor:(UIColor*)streamColor mentionColor:(UIColor*)mentionColor messagesColor:(UIColor*)messagesColor patterColor:(UIColor*)patterColor;

+ (UIImage*)replyWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)repostWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)conversationWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)trashWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)starWithStrokeColor:(UIColor*)strokeColor filled:(BOOL)filled;
+ (UIImage*)infoWithStrokeColor:(UIColor*)strokeColor;
+ (UIImage*)interactionWithStrokeColor:(UIColor*)strokeColor;

@end
