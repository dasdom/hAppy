//
//  ImageHelper.m
//  Appetizr
//
//  Created by dasdom on 18.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "ImageHelper.h"

@implementation ImageHelper

+ (UIImage*)speechBubbleWithStrokeColor:(UIColor*)strokeColor {
 
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// SpeechBubble Drawing
    UIBezierPath* speechBubblePath = [UIBezierPath bezierPath];
    [speechBubblePath moveToPoint: CGPointMake(18.5, 21.5)];
    [speechBubblePath addCurveToPoint: CGPointMake(25.5, 25.5) controlPoint1: CGPointMake(19.74, 21.29) controlPoint2: CGPointMake(25.04, 25.86)];
    [speechBubblePath addCurveToPoint: CGPointMake(23.5, 19.5) controlPoint1: CGPointMake(25.86, 25.22) controlPoint2: CGPointMake(23.2, 19.81)];
    [speechBubblePath addCurveToPoint: CGPointMake(23.13, 7.14) controlPoint1: CGPointMake(26.98, 15.97) controlPoint2: CGPointMake(27.27, 10.37)];
    [speechBubblePath addCurveToPoint: CGPointMake(6.87, 7.14) controlPoint1: CGPointMake(18.64, 3.62) controlPoint2: CGPointMake(11.36, 3.62)];
    [speechBubblePath addCurveToPoint: CGPointMake(6.87, 19.86) controlPoint1: CGPointMake(2.38, 10.65) controlPoint2: CGPointMake(2.38, 16.35)];
    [speechBubblePath addCurveToPoint: CGPointMake(18.5, 21.5) controlPoint1: CGPointMake(10.9, 23.02) controlPoint2: CGPointMake(13.52, 22.33)];
    [speechBubblePath closePath];
    [strokeColor setStroke];
    speechBubblePath.lineWidth = 2;
    [speechBubblePath stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (UIImage*)atSignWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);

    //// Abstracted Attributes
    NSString* textContent = @"@";
    
    //// Text Drawing
    [strokeColor setFill];
    [textContent drawAtPoint:CGPointMake(3.0f, -3.0f) withFont:[UIFont fontWithName: @"Avenir-Black" size: 30]];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)globeWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(4.5, 4.5, 21, 21)];
    [strokeColor setStroke];
    ovalPath.lineWidth = 1.5;
    [ovalPath stroke];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(14.5, 12.31)];
    [bezierPath addCurveToPoint: CGPointMake(15.5, 14.13) controlPoint1: CGPointMake(13.39, 14.99) controlPoint2: CGPointMake(15.5, 14.13)];
    [bezierPath addLineToPoint: CGPointMake(16.5, 15.04)];
    [bezierPath addLineToPoint: CGPointMake(17.5, 16.86)];
    [bezierPath addLineToPoint: CGPointMake(17.5, 18.68)];
    [bezierPath addLineToPoint: CGPointMake(17.5, 20.5)];
    [bezierPath addLineToPoint: CGPointMake(18.5, 20.5)];
    [bezierPath addLineToPoint: CGPointMake(19.5, 20.5)];
    [bezierPath addLineToPoint: CGPointMake(20.5, 18.68)];
    [bezierPath addLineToPoint: CGPointMake(20.5, 17.77)];
    [bezierPath addLineToPoint: CGPointMake(20.5, 16.86)];
    [bezierPath addLineToPoint: CGPointMake(21.5, 15.04)];
    [bezierPath addLineToPoint: CGPointMake(21.5, 13.22)];
    [bezierPath addLineToPoint: CGPointMake(21.5, 12.31)];
    [bezierPath addLineToPoint: CGPointMake(19.5, 10.49)];
    [bezierPath addLineToPoint: CGPointMake(18.5, 10.49)];
    [bezierPath addLineToPoint: CGPointMake(17.5, 10.49)];
    [bezierPath addLineToPoint: CGPointMake(16.5, 10.49)];
    [bezierPath addCurveToPoint: CGPointMake(14.5, 12.31) controlPoint1: CGPointMake(16.5, 10.49) controlPoint2: CGPointMake(15.61, 9.63)];
    [bezierPath closePath];
    [strokeColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(15.5, 6.5)];
    [bezier2Path addLineToPoint: CGPointMake(15.5, 7.5)];
    [bezier2Path addLineToPoint: CGPointMake(16.5, 8.5)];
    [bezier2Path addLineToPoint: CGPointMake(18.5, 7.5)];
    [bezier2Path addLineToPoint: CGPointMake(19.5, 8.5)];
    [bezier2Path addLineToPoint: CGPointMake(22.68, 11.04)];
    [bezier2Path addLineToPoint: CGPointMake(23.5, 13.5)];
    [bezier2Path addLineToPoint: CGPointMake(24.5, 12.5)];
    [bezier2Path addLineToPoint: CGPointMake(24.5, 10.5)];
    [bezier2Path addLineToPoint: CGPointMake(22.5, 8.5)];
    [bezier2Path addLineToPoint: CGPointMake(21.5, 7.5)];
    [bezier2Path addLineToPoint: CGPointMake(19.5, 5.5)];
    [bezier2Path addLineToPoint: CGPointMake(16.5, 4.5)];
    [bezier2Path addLineToPoint: CGPointMake(15.5, 6.5)];
    [bezier2Path closePath];
    [strokeColor setFill];
    [bezier2Path fill];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(7.5, 8.5)];
    [bezier3Path addLineToPoint: CGPointMake(8.5, 7.5)];
    [bezier3Path addLineToPoint: CGPointMake(8.5, 11.5)];
    [bezier3Path addLineToPoint: CGPointMake(7.5, 12.5)];
    [bezier3Path addLineToPoint: CGPointMake(6.5, 16.5)];
    [bezier3Path addLineToPoint: CGPointMake(6.5, 18.5)];
    [bezier3Path addLineToPoint: CGPointMake(7.5, 20.5)];
    [bezier3Path addLineToPoint: CGPointMake(6.5, 20.5)];
    [bezier3Path addLineToPoint: CGPointMake(5.5, 18.5)];
    [bezier3Path addLineToPoint: CGPointMake(5.5, 13.5)];
    [bezier3Path addLineToPoint: CGPointMake(5.5, 10.5)];
    [bezier3Path addLineToPoint: CGPointMake(7.5, 8.5)];
    [bezier3Path closePath];
    [strokeColor setFill];
    [bezier3Path fill];
    [strokeColor setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)letterWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(15, 16)];
    [bezierPath addLineToPoint: CGPointMake(25.88, 7.05)];
    [bezierPath addCurveToPoint: CGPointMake(26.5, 8.5) controlPoint1: CGPointMake(26.26, 7.42) controlPoint2: CGPointMake(26.5, 7.93)];
    [bezierPath addLineToPoint: CGPointMake(26.5, 21.5)];
    [bezierPath addCurveToPoint: CGPointMake(24.5, 23.5) controlPoint1: CGPointMake(26.5, 22.6) controlPoint2: CGPointMake(25.6, 23.5)];
    [bezierPath addLineToPoint: CGPointMake(5.5, 23.5)];
    [bezierPath addCurveToPoint: CGPointMake(3.5, 21.5) controlPoint1: CGPointMake(4.4, 23.5) controlPoint2: CGPointMake(3.5, 22.6)];
    [bezierPath addLineToPoint: CGPointMake(3.5, 8.5)];
    [bezierPath addCurveToPoint: CGPointMake(4.12, 7.05) controlPoint1: CGPointMake(3.5, 7.93) controlPoint2: CGPointMake(3.74, 7.42)];
    [bezierPath addLineToPoint: CGPointMake(15, 16)];
    [bezierPath closePath];
    [strokeColor setStroke];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(4, 7)];
    [bezier2Path addCurveToPoint: CGPointMake(26, 7) controlPoint1: CGPointMake(26, 7) controlPoint2: CGPointMake(26, 7)];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 2;
    [bezier2Path stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)pawWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath moveToPoint: CGPointMake(15, 25)];
    [ovalPath addCurveToPoint: CGPointMake(21, 25) controlPoint1: CGPointMake(16.94, 24.94) controlPoint2: CGPointMake(19.52, 26.2)];
    [ovalPath addCurveToPoint: CGPointMake(20.66, 16.9) controlPoint1: CGPointMake(24.12, 22.46) controlPoint2: CGPointMake(23.78, 19.44)];
    [ovalPath addCurveToPoint: CGPointMake(9.34, 16.9) controlPoint1: CGPointMake(17.53, 14.37) controlPoint2: CGPointMake(12.47, 14.37)];
    [ovalPath addCurveToPoint: CGPointMake(9, 25) controlPoint1: CGPointMake(6.22, 19.44) controlPoint2: CGPointMake(5.88, 22.46)];
    [ovalPath addCurveToPoint: CGPointMake(15, 25) controlPoint1: CGPointMake(10.64, 26.34) controlPoint2: CGPointMake(12.85, 25.07)];
    [ovalPath closePath];
    [strokeColor setFill];
    [ovalPath fill];
    [strokeColor setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(4, 9, 4, 5)];
    [strokeColor setFill];
    [oval2Path fill];
    [strokeColor setStroke];
    oval2Path.lineWidth = 2;
    [oval2Path stroke];
    
    
    //// Oval 3 Drawing
    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(11, 6, 3, 5)];
    [strokeColor setFill];
    [oval3Path fill];
    [strokeColor setStroke];
    oval3Path.lineWidth = 2;
    [oval3Path stroke];
    
    
    //// Oval 4 Drawing
    UIBezierPath* oval4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(17, 6, 3, 5)];
    [strokeColor setFill];
    [oval4Path fill];
    [strokeColor setStroke];
    oval4Path.lineWidth = 2;
    [oval4Path stroke];
    
    
    //// Oval 5 Drawing
    UIBezierPath* oval5Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(22, 9, 4, 5)];
    [strokeColor setFill];
    [oval5Path fill];
    [strokeColor setStroke];
    oval5Path.lineWidth = 2;
    [oval5Path stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)headWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(4.5, 26.5)];
    [bezierPath addLineToPoint: CGPointMake(4.5, 24.13)];
    [bezierPath addLineToPoint: CGPointMake(6.5, 22.5)];
    [bezierPath addLineToPoint: CGPointMake(9.5, 21.5)];
    [bezierPath addLineToPoint: CGPointMake(11.5, 21.5)];
    [bezierPath addLineToPoint: CGPointMake(12.5, 19.5)];
    [bezierPath addLineToPoint: CGPointMake(17.5, 19.5)];
    [bezierPath addLineToPoint: CGPointMake(18.5, 21.5)];
    [bezierPath addLineToPoint: CGPointMake(19.5, 21.5)];
    [bezierPath addLineToPoint: CGPointMake(20.5, 21.5)];
    [bezierPath addLineToPoint: CGPointMake(23.5, 22.5)];
    [bezierPath addLineToPoint: CGPointMake(25.5, 24.5)];
    [bezierPath addLineToPoint: CGPointMake(25.5, 26.5)];
    [bezierPath addLineToPoint: CGPointMake(4.5, 26.5)];
    [bezierPath closePath];
    [strokeColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath moveToPoint: CGPointMake(18.89, 17.45)];
    [ovalPath addCurveToPoint: CGPointMake(18.89, 7.55) controlPoint1: CGPointMake(21.04, 14.72) controlPoint2: CGPointMake(21.04, 10.28)];
    [ovalPath addCurveToPoint: CGPointMake(11.11, 7.55) controlPoint1: CGPointMake(16.74, 4.82) controlPoint2: CGPointMake(13.26, 4.82)];
    [ovalPath addCurveToPoint: CGPointMake(11.11, 17.45) controlPoint1: CGPointMake(8.96, 10.28) controlPoint2: CGPointMake(8.96, 14.72)];
    [ovalPath addCurveToPoint: CGPointMake(18.89, 17.45) controlPoint1: CGPointMake(13.26, 20.18) controlPoint2: CGPointMake(16.74, 20.18)];
    [ovalPath closePath];
    [strokeColor setFill];
    [ovalPath fill];
    [strokeColor setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)swipeHandleWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f, 8.0f), NO, 0.0f);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0, 6.5)];
    [bezierPath addCurveToPoint: CGPointMake(50, 6.5) controlPoint1: CGPointMake(51.02, 6.5) controlPoint2: CGPointMake(50, 6.5)];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(0, 3.5)];
    [bezier2Path addCurveToPoint: CGPointMake(50, 3.5) controlPoint1: CGPointMake(51.02, 3.5) controlPoint2: CGPointMake(50, 3.5)];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(0, 0.5)];
    [bezier3Path addCurveToPoint: CGPointMake(50, 0.5) controlPoint1: CGPointMake(51.02, 0.5) controlPoint2: CGPointMake(50, 0.5)];
    [strokeColor setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)searchWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(5, 5, 13, 13)];
    [strokeColor setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(16.5, 16.5)];
    [bezierPath addCurveToPoint: CGPointMake(24.5, 24.5) controlPoint1: CGPointMake(24.5, 24.5) controlPoint2: CGPointMake(24.5, 24.5)];
    [bezierPath addLineToPoint: CGPointMake(24.5, 24.5)];
    [strokeColor setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
       
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)menueImage {
    UIColor *menuColor = [UIColor whiteColor];
    return [ImageHelper menueWithStreamColor:menuColor mentionColor:menuColor messagesColor:menuColor patterColor:menuColor];
}

+ (UIImage*)menueWithStreamColor:(UIColor*)streamColor mentionColor:(UIColor*)mentionColor messagesColor:(UIColor*)messagesColor patterColor:(UIColor*)patterColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// streams Drawing
    UIBezierPath* streamsPath = [UIBezierPath bezierPath];
    [streamsPath moveToPoint: CGPointMake(2, 7.5)];
    [streamsPath addCurveToPoint: CGPointMake(28, 7.5) controlPoint1: CGPointMake(28, 7.5) controlPoint2: CGPointMake(28, 7.5)];
    streamsPath.miterLimit = 11;
    
    [streamColor setStroke];
    streamsPath.lineWidth = 3;
    [streamsPath stroke];
    
    
    //// mentions Drawing
    UIBezierPath* mentionsPath = [UIBezierPath bezierPath];
    [mentionsPath moveToPoint: CGPointMake(2, 12.5)];
    [mentionsPath addCurveToPoint: CGPointMake(28, 12.5) controlPoint1: CGPointMake(28, 12.5) controlPoint2: CGPointMake(28, 12.5)];
    mentionsPath.miterLimit = 11;
    
    [mentionColor setStroke];
    mentionsPath.lineWidth = 3;
    [mentionsPath stroke];
    
    
    //// messages Drawing
    UIBezierPath* messagesPath = [UIBezierPath bezierPath];
    [messagesPath moveToPoint: CGPointMake(2, 17.5)];
    [messagesPath addCurveToPoint: CGPointMake(28, 17.5) controlPoint1: CGPointMake(28, 17.5) controlPoint2: CGPointMake(28, 17.5)];
    messagesPath.miterLimit = 11;
    
    [messagesColor setStroke];
    messagesPath.lineWidth = 3;
    [messagesPath stroke];
    
    
    //// patter Drawing
    UIBezierPath* patterPath = [UIBezierPath bezierPath];
    [patterPath moveToPoint: CGPointMake(2, 22.5)];
    [patterPath addCurveToPoint: CGPointMake(28, 22.5) controlPoint1: CGPointMake(28, 22.5) controlPoint2: CGPointMake(28, 22.5)];
    patterPath.miterLimit = 11;
    
    [patterColor setStroke];
    patterPath.lineWidth = 3;
    [patterPath stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)replyWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 38.0f), NO, 0.0f);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(17.5, 15)];
    [bezierPath addLineToPoint: CGPointMake(29.5, 7.5)];
    [bezierPath addLineToPoint: CGPointMake(27.5, 12.5)];
    [bezierPath addLineToPoint: CGPointMake(31.5, 12.5)];
    [bezierPath addCurveToPoint: CGPointMake(36.5, 12.5) controlPoint1: CGPointMake(31.5, 12.5) controlPoint2: CGPointMake(34.24, 12.49)];
    [bezierPath addCurveToPoint: CGPointMake(41.5, 13.5) controlPoint1: CGPointMake(38.76, 12.51) controlPoint2: CGPointMake(41.5, 13.5)];
    [bezierPath addLineToPoint: CGPointMake(44.5, 16.5)];
    [bezierPath addLineToPoint: CGPointMake(45.5, 19.5)];
    [bezierPath addLineToPoint: CGPointMake(45.5, 24.5)];
    [bezierPath addLineToPoint: CGPointMake(42.5, 20.5)];
    [bezierPath addCurveToPoint: CGPointMake(36.5, 17.5) controlPoint1: CGPointMake(42.5, 20.5) controlPoint2: CGPointMake(38.4, 17.53)];
    [bezierPath addCurveToPoint: CGPointMake(31.5, 17.5) controlPoint1: CGPointMake(34.6, 17.47) controlPoint2: CGPointMake(31.5, 17.5)];
    [bezierPath addLineToPoint: CGPointMake(27.5, 17.5)];
    [bezierPath addLineToPoint: CGPointMake(29.5, 22.5)];
    [bezierPath addLineToPoint: CGPointMake(17.5, 15)];
    [bezierPath closePath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [strokeColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)repostWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 38.0f), NO, 0.0f);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(22.09, 10.89)];
    [bezierPath addLineToPoint: CGPointMake(29.43, 6.06)];
    [bezierPath addLineToPoint: CGPointMake(28.71, 8.94)];
    [bezierPath addLineToPoint: CGPointMake(32.16, 8.94)];
    [bezierPath addCurveToPoint: CGPointMake(36.47, 8.94) controlPoint1: CGPointMake(32.16, 8.94) controlPoint2: CGPointMake(34.52, 8.93)];
    [bezierPath addCurveToPoint: CGPointMake(40.78, 10.5) controlPoint1: CGPointMake(38.42, 8.96) controlPoint2: CGPointMake(40.78, 10.5)];
    [bezierPath addLineToPoint: CGPointMake(43.36, 12.83)];
    [bezierPath addLineToPoint: CGPointMake(43.5, 14.5)];
    [bezierPath addLineToPoint: CGPointMake(43.5, 17.5)];
    [bezierPath addCurveToPoint: CGPointMake(41.47, 14.91) controlPoint1: CGPointMake(43.5, 17.5) controlPoint2: CGPointMake(42.65, 15.52)];
    [bezierPath addCurveToPoint: CGPointMake(36.47, 12.83) controlPoint1: CGPointMake(40.43, 14.36) controlPoint2: CGPointMake(37.24, 12.85)];
    [bezierPath addCurveToPoint: CGPointMake(32.16, 12.83) controlPoint1: CGPointMake(34.82, 12.81) controlPoint2: CGPointMake(32.16, 12.83)];
    [bezierPath addLineToPoint: CGPointMake(28.71, 12.83)];
    [bezierPath addLineToPoint: CGPointMake(29.43, 15.72)];
    [bezierPath addLineToPoint: CGPointMake(22.09, 10.89)];
    [bezierPath closePath];
    bezierPath.lineJoinStyle = kCGLineJoinBevel;
    
    [strokeColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(43.5, 20.67)];
    [bezier2Path addLineToPoint: CGPointMake(36.16, 25.5)];
    [bezier2Path addLineToPoint: CGPointMake(36.88, 22.61)];
    [bezier2Path addLineToPoint: CGPointMake(33.43, 22.61)];
    [bezier2Path addCurveToPoint: CGPointMake(29.12, 22.61) controlPoint1: CGPointMake(33.43, 22.61) controlPoint2: CGPointMake(31.07, 22.62)];
    [bezier2Path addCurveToPoint: CGPointMake(24.81, 21.06) controlPoint1: CGPointMake(27.17, 22.6) controlPoint2: CGPointMake(24.81, 21.06)];
    [bezier2Path addLineToPoint: CGPointMake(22.22, 18.72)];
    [bezier2Path addLineToPoint: CGPointMake(22.09, 17.06)];
    [bezier2Path addLineToPoint: CGPointMake(22.09, 14.06)];
    [bezier2Path addCurveToPoint: CGPointMake(24.11, 16.65) controlPoint1: CGPointMake(22.09, 14.06) controlPoint2: CGPointMake(22.94, 16.04)];
    [bezier2Path addCurveToPoint: CGPointMake(29.12, 18.72) controlPoint1: CGPointMake(25.16, 17.19) controlPoint2: CGPointMake(28.35, 18.71)];
    [bezier2Path addCurveToPoint: CGPointMake(33.43, 18.72) controlPoint1: CGPointMake(30.76, 18.75) controlPoint2: CGPointMake(33.43, 18.72)];
    [bezier2Path addLineToPoint: CGPointMake(36.88, 18.72)];
    [bezier2Path addLineToPoint: CGPointMake(36.16, 15.83)];
    [bezier2Path addLineToPoint: CGPointMake(43.5, 20.67)];
    [bezier2Path closePath];
    bezier2Path.lineJoinStyle = kCGLineJoinBevel;

    [bezier2Path fill];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)conversationWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 38.0f), NO, 0.0f);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath moveToPoint: CGPointMake(42, 19.26)];
    [ovalPath addCurveToPoint: CGPointMake(48.07, 22) controlPoint1: CGPointMake(43.12, 18.91) controlPoint2: CGPointMake(48.07, 22)];
    [ovalPath addCurveToPoint: CGPointMake(45.76, 17.62) controlPoint1: CGPointMake(48.07, 22) controlPoint2: CGPointMake(45.43, 17.82)];
    [ovalPath addCurveToPoint: CGPointMake(44.69, 9.34) controlPoint1: CGPointMake(49.74, 15.16) controlPoint2: CGPointMake(49.38, 11.6)];
    [ovalPath addCurveToPoint: CGPointMake(26.31, 9.34) controlPoint1: CGPointMake(39.62, 6.89) controlPoint2: CGPointMake(31.38, 6.89)];
    [ovalPath addCurveToPoint: CGPointMake(26.31, 18.2) controlPoint1: CGPointMake(21.23, 11.79) controlPoint2: CGPointMake(21.23, 15.76)];
    [ovalPath addCurveToPoint: CGPointMake(42, 19.26) controlPoint1: CGPointMake(30.85, 20.4) controlPoint2: CGPointMake(37.5, 20.65)];
    [ovalPath closePath];
    ovalPath.lineJoinStyle = kCGLineJoinBevel;
    
    [strokeColor setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPath];
    [oval2Path moveToPoint: CGPointMake(24, 17.26)];
    [oval2Path addCurveToPoint: CGPointMake(17.93, 20) controlPoint1: CGPointMake(22.88, 16.91) controlPoint2: CGPointMake(17.93, 20)];
    [oval2Path addCurveToPoint: CGPointMake(20.24, 15.62) controlPoint1: CGPointMake(17.93, 20) controlPoint2: CGPointMake(20.57, 15.82)];
    [oval2Path addCurveToPoint: CGPointMake(21.31, 7.34) controlPoint1: CGPointMake(16.26, 13.16) controlPoint2: CGPointMake(16.62, 9.6)];
    [oval2Path addCurveToPoint: CGPointMake(39.69, 7.34) controlPoint1: CGPointMake(26.38, 4.89) controlPoint2: CGPointMake(34.62, 4.89)];
    [oval2Path addCurveToPoint: CGPointMake(39.69, 16.2) controlPoint1: CGPointMake(44.77, 9.79) controlPoint2: CGPointMake(44.77, 13.76)];
    [oval2Path addCurveToPoint: CGPointMake(24, 17.26) controlPoint1: CGPointMake(35.15, 18.4) controlPoint2: CGPointMake(28.5, 18.65)];
    [oval2Path closePath];
    oval2Path.lineJoinStyle = kCGLineJoinBevel;
    
    [strokeColor setFill];
    [oval2Path fill];
    [strokeColor setStroke];
    oval2Path.lineWidth = 1;
    [oval2Path stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)trashWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 38.0f), NO, 0.0f);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(23, 11.5)];
    [bezierPath addLineToPoint: CGPointMake(24.8, 28.5)];
    [bezierPath addLineToPoint: CGPointMake(39.2, 28.5)];
    [bezierPath addLineToPoint: CGPointMake(41, 11.5)];
    [bezierPath addLineToPoint: CGPointMake(37.5, 11.5)];
    [bezierPath addLineToPoint: CGPointMake(36.6, 24.92)];
    [bezierPath addLineToPoint: CGPointMake(33.8, 24.92)];
    [bezierPath addLineToPoint: CGPointMake(33.8, 11.5)];
    [bezierPath addLineToPoint: CGPointMake(30.2, 11.5)];
    [bezierPath addLineToPoint: CGPointMake(30.2, 24.92)];
    [bezierPath addLineToPoint: CGPointMake(27.4, 24.92)];
    [bezierPath addLineToPoint: CGPointMake(26.5, 11.5)];
    [bezierPath addLineToPoint: CGPointMake(23, 11.5)];
    [bezierPath closePath];
    [strokeColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Polygon Drawing
    UIBezierPath* polygonPath = [UIBezierPath bezierPath];
    [polygonPath moveToPoint: CGPointMake(32, 5)];
    [polygonPath addLineToPoint: CGPointMake(40.96, 6.77)];
    [polygonPath addLineToPoint: CGPointMake(40.97, 8.93)];
    [polygonPath addLineToPoint: CGPointMake(23.03, 8.93)];
    [polygonPath addLineToPoint: CGPointMake(23.04, 6.77)];
    [polygonPath addLineToPoint: CGPointMake(32, 5)];
    [polygonPath closePath];
    [strokeColor setFill];
    [polygonPath fill];
    [strokeColor setStroke];
    polygonPath.lineWidth = 1;
    [polygonPath stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)starWithStrokeColor:(UIColor*)strokeColor filled:(BOOL)filled {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 38.0f), NO, 0.0f);
    
    //// Star Drawing
    UIBezierPath* starPath = [UIBezierPath bezierPath];
    [starPath moveToPoint: CGPointMake(34, 5.5)];
    [starPath addLineToPoint: CGPointMake(36.82, 12.94)];
    [starPath addLineToPoint: CGPointMake(45.41, 13.1)];
    [starPath addLineToPoint: CGPointMake(38.57, 17.86)];
    [starPath addLineToPoint: CGPointMake(41.05, 25.4)];
    [starPath addLineToPoint: CGPointMake(34, 20.9)];
    [starPath addLineToPoint: CGPointMake(26.95, 25.4)];
    [starPath addLineToPoint: CGPointMake(29.43, 17.86)];
    [starPath addLineToPoint: CGPointMake(22.59, 13.1)];
    [starPath addLineToPoint: CGPointMake(31.18, 12.94)];
    [starPath closePath];
    [strokeColor setStroke];
    if (filled) {
        [strokeColor setFill];
    }
    starPath.lineWidth = 1.5;
    [starPath stroke];

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)infoWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 38.0f), NO, 0.0f);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(31.32, 10.32)];
    [bezierPath addCurveToPoint: CGPointMake(31.32, 12.68) controlPoint1: CGPointMake(30.67, 10.97) controlPoint2: CGPointMake(30.67, 12.03)];
    [bezierPath addCurveToPoint: CGPointMake(33.68, 12.68) controlPoint1: CGPointMake(31.97, 13.33) controlPoint2: CGPointMake(33.03, 13.33)];
    [bezierPath addCurveToPoint: CGPointMake(33.68, 10.32) controlPoint1: CGPointMake(34.33, 12.03) controlPoint2: CGPointMake(34.33, 10.97)];
    [bezierPath addCurveToPoint: CGPointMake(31.32, 10.32) controlPoint1: CGPointMake(33.03, 9.67) controlPoint2: CGPointMake(31.97, 9.67)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(34.17, 14.83)];
    [bezierPath addLineToPoint: CGPointMake(30.83, 14.83)];
    [bezierPath addLineToPoint: CGPointMake(30.83, 22.33)];
    [bezierPath addLineToPoint: CGPointMake(34.17, 22.33)];
    [bezierPath addLineToPoint: CGPointMake(34.17, 14.83)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(39.57, 9.43)];
    [bezierPath addCurveToPoint: CGPointMake(39.57, 23.57) controlPoint1: CGPointMake(43.48, 13.33) controlPoint2: CGPointMake(43.48, 19.67)];
    [bezierPath addCurveToPoint: CGPointMake(25.43, 23.57) controlPoint1: CGPointMake(35.67, 27.48) controlPoint2: CGPointMake(29.33, 27.48)];
    [bezierPath addCurveToPoint: CGPointMake(25.43, 9.43) controlPoint1: CGPointMake(21.52, 19.67) controlPoint2: CGPointMake(21.52, 13.33)];
    [bezierPath addCurveToPoint: CGPointMake(39.57, 9.43) controlPoint1: CGPointMake(29.33, 5.52) controlPoint2: CGPointMake(35.67, 5.52)];
    [bezierPath closePath];
    [strokeColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)interactionWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(4.5, 17)];
    [bezier2Path addLineToPoint: CGPointMake(26.5, 17)];
    [bezier2Path addLineToPoint: CGPointMake(20, 21.5)];
    [bezier2Path addLineToPoint: CGPointMake(20, 17)];
    [bezier2Path addLineToPoint: CGPointMake(20, 17)];
    bezier2Path.lineJoinStyle = kCGLineJoinRound;
    
    [strokeColor setFill];
    [bezier2Path fill];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1.5;
    [bezier2Path stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(26.5, 13)];
    [bezierPath addLineToPoint: CGPointMake(4.5, 13)];
    [bezierPath addLineToPoint: CGPointMake(11, 8.5)];
    [bezierPath addLineToPoint: CGPointMake(11, 13)];
    [bezierPath addLineToPoint: CGPointMake(11, 13)];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [strokeColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1.5;
    [bezierPath stroke];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)templateWithStrokeColor:(UIColor*)strokeColor {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, 0.0f);
    
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
