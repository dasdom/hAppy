//
//  DHURLHelper.m
//  Appetizr
//
//  Created by dasdom on 17.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DHURLHelper.h"

@implementation DHURLHelper

+ (NSDictionary*)parameterDictionaryForQuery:(NSString*)queryString {
    if (!queryString) {
        return nil;
    }
    NSMutableDictionary *mutableParameterDictionary = [NSMutableDictionary dictionary];
    
    NSArray *keyValuePairArray = [queryString componentsSeparatedByString:@"&"];
    for (NSString *keyValuePairString in keyValuePairArray) {
        NSArray *keyValueArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValueArray count] > 1) {
            NSString *keyString = [[keyValueArray objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *valueString = [[keyValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            mutableParameterDictionary[keyString] = valueString;
        }
    }
    
    if ([mutableParameterDictionary count] < 1) {
        return nil;
    }
    
    return [mutableParameterDictionary copy];
}

@end
