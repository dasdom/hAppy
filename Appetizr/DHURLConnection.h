//
//  DHURLConnection.h
//  Appetizr
//
//  Created by dasdom on 13.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DHURLConnection;

typedef void (^DHURLConnectionProgressBlock)(DHURLConnection *connection);
typedef void (^DHURLConnectionCompletionBlock)(DHURLConnection *connection, NSError *error);

@interface DHURLConnection : NSObject <NSURLConnectionDataDelegate>

//@property (nonatomic, strong) NSData *downloadData;
@property (nonatomic, strong) NSDictionary *responseDictionary;

@end
