//
//  DHGlobalObjects.h
//  Appetizr
//
//  Created by dasdom on 15.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHGlobalObjects : NSObject

@property (nonatomic, strong) NSSet *userNameSet;
@property (nonatomic, strong) NSSet *hashtagSet;
@property (nonatomic, strong) NSDateFormatter *iso8601DateFormatter;

@property (nonatomic, strong) NSSet *mutedHashtagSet;
@property (nonatomic, strong) NSSet *mutedThreadIdSet;
@property (nonatomic, strong) NSSet *mutedChannels;
@property (nonatomic, strong) NSSet *mutedClients;

@property (nonatomic, strong) NSSet *subscribedChannels;

@property (nonatomic) NSInteger unreadMessages;
@property (nonatomic) NSInteger unreadPatter;

@property (nonatomic, strong) NSSet *unreadMentions;
@property (nonatomic, assign) NSInteger numberOfUnreadPrivateMessages;
@property (nonatomic, assign) NSInteger numberOfUnreadPatter;

@property (nonatomic, strong) UIColor *mainColor;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *markedCellBackgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) UIColor *mentionColor;
@property (nonatomic, strong) UIColor *hashTagColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *markerColor;
@property (nonatomic, strong) UIColor *separatorColor;

@property (nonatomic, strong) UIColor *darkMainColor;
@property (nonatomic, strong) UIColor *darkCellBackgroundColor;
@property (nonatomic, strong) UIColor *darkMarkedCellBackgroundColor;
@property (nonatomic, strong) UIColor *darkTextColor;
@property (nonatomic, strong) UIColor *darkLinkColor;
@property (nonatomic, strong) UIColor *darkMentionColor;
@property (nonatomic, strong) UIColor *darkHashTagColor;
@property (nonatomic, strong) UIColor *darkTintColor;
@property (nonatomic, strong) UIColor *darkMarkerColor;
@property (nonatomic, strong) UIColor *darkSeparatorColor;

+ (DHGlobalObjects*)sharedGlobalObjects;
- (void)addConnection;
- (void)removeConnection;
- (void)archiveUserNames;
- (void)unarchiveUserNames;
- (void)addUnreadMentionWithId:(NSString*)idString;
- (void)removeUnreadMentionWithId:(NSString*)idString;
- (void)removeAllUnreadMentions;
- (NSUInteger)numberOfUnreadMentions;

@end
