//
//  DHURLConnection.m
//  Appetizr
//
//  Created by dasdom on 13.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHURLConnection.h"

@interface DHURLConnection ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *downloadData;
@end

@implementation DHURLConnection {
    DHURLConnectionProgressBlock progressBlock;
    DHURLConnectionCompletionBlock completionBlock;
}

@synthesize downloadData=_downloadData;

- (id)initWithURL:(NSURL*)url progress:(DHURLConnectionProgressBlock)pBlock completion:(DHURLConnectionCompletionBlock)cBlock {
    if ((self = [super init])) {
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        _connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        
        progressBlock = pBlock;
        completionBlock = cBlock;
    }
    return self;
}


#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    self.downloadData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    [self.downloadData appendData:data];
    
    progressBlock(self);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    
    NSError *jsonError;
    self.responseDictionary = [NSJSONSerialization JSONObjectWithData:self.downloadData options:kNilOptions error:&jsonError];
    
    completionBlock(self, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    
    self.responseDictionary = nil;
    
    completionBlock(self, error);
}


@end
