//
//  DHURLHelper.h
//  Appetizr
//
//  Created by dasdom on 17.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHURLHelper : NSObject

+ (NSDictionary*)parameterDictionaryForQuery:(NSString*)queryString;

@end
