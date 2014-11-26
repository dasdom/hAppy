//
//  UIColor+StringConversion.m
//  Appetizr
//
//  Created by dasdom on 30.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "UIColor+StringConversion.h"

@implementation UIColor (StringConversion)

+ (UIColor*)colorWithString:(NSString*)colorString {
    if (!colorString) {
        return nil;
    }
    
//    dhDebug(@"colorString: %@", colorString);
    NSArray *colorCompoments = [colorString componentsSeparatedByString:@","];
    if ([colorCompoments count] < 4) {
        return nil;
    }
    
    CGFloat alphaFloat = [[colorCompoments objectAtIndex:3] floatValue]/100.0f;
    CGFloat blueFloat = [[colorCompoments objectAtIndex:2] floatValue]/100.0f;
    CGFloat greenFloat = [[colorCompoments objectAtIndex:1] floatValue]/100.0f;
    CGFloat redFloat = [[colorCompoments objectAtIndex:0] floatValue]/100.0f;
    
    return [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:alphaFloat];
}

- (NSString*)stringValue {
    CGFloat redColorValue;
    CGFloat greenColorValue;
    CGFloat blueColorValue;
    CGFloat alphaColorValue;
    
    [self getRed:&redColorValue green:&greenColorValue blue:&blueColorValue alpha:&alphaColorValue];
    
    NSString *string = [NSString stringWithFormat:@"%d,%d,%d,%d", (int)(redColorValue*100), (int)(greenColorValue*100), (int)(blueColorValue*100), (int)(alphaColorValue*100)];
    
    return string;
}



@end
