//
//  DHGlobalObjects.m
//  Appetizr
//
//  Created by dasdom on 15.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHGlobalObjects.h"
#import "UIColor+StringConversion.h"

@interface DHGlobalObjects ()
//@property (nonatomic, strong) NSDictionary *userImageFileURLDictionary;
@property (nonatomic) NSInteger numberOfConnections;
@end

@implementation DHGlobalObjects

+ (DHGlobalObjects*)sharedGlobalObjects {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (id)init {
    if ((self = [super init])) {
//        _userImageFileURLDictionary = [[NSDictionary alloc] init];
        _numberOfConnections = 0;
        
        self.userNameSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userNameArchivePath]];
        self.hashtagSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[self hashtagArchivePath]];
        self.mutedHashtagSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[self mutedHashtagArchivePath]];
        self.mutedThreadIdSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[self mutedThreadIdArchivePath]];
        self.mutedChannels = [NSKeyedUnarchiver unarchiveObjectWithFile:[self mutedChannelsArchivePath]];
        self.mutedClients = [NSKeyedUnarchiver unarchiveObjectWithFile:[self mutedClientsArchivePath]];
        self.subscribedChannels = [NSKeyedUnarchiver unarchiveObjectWithFile:[self subscribedChannelsArchivePath]];
        self.unreadMentions = [NSKeyedUnarchiver unarchiveObjectWithFile:[self unreadMentionsPath]];
        
        if (!self.userNameSet) {
            self.userNameSet = [NSSet set];
        }
        if (!self.hashtagSet) {
            self.hashtagSet = [NSSet set];
        }
        if (!self.mutedHashtagSet) {
            self.mutedHashtagSet = [NSSet set];
        }
        if (!self.mutedThreadIdSet) {
            self.mutedThreadIdSet = [NSSet set];
        }
        if (!self.mutedChannels) {
            self.mutedChannels = [NSSet set];
        }
        if (!self.mutedClients) {
            self.mutedClients = [NSSet set];
        }
        
        if (!self.subscribedChannels) {
            self.subscribedChannels = [NSSet set];
        }
        if (!self.unreadMentions) {
            self.unreadMentions = [NSSet set];
        }

        _iso8601DateFormatter = [[NSDateFormatter alloc] init];
        _iso8601DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        _iso8601DateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        [self loadCustomColors];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCustomColors) name:kColorChangedNotification object:nil];
    }
    return self;
}

- (void)archiveUserNames {
    [NSKeyedArchiver archiveRootObject:self.userNameSet toFile:[self userNameArchivePath]];
    [NSKeyedArchiver archiveRootObject:self.hashtagSet toFile:[self hashtagArchivePath]];
    [NSKeyedArchiver archiveRootObject:self.mutedHashtagSet toFile:[self mutedHashtagArchivePath]];
    [NSKeyedArchiver archiveRootObject:self.mutedChannels toFile:[self mutedChannelsArchivePath]];
    [NSKeyedArchiver archiveRootObject:self.mutedClients toFile:[self mutedClientsArchivePath]];
    [NSKeyedArchiver archiveRootObject:self.subscribedChannels toFile:[self subscribedChannelsArchivePath]];
    [NSKeyedArchiver archiveRootObject:self.unreadMentions toFile:[self unreadMentionsPath]];
}

- (void)unarchiveUserNames {
    self.userNameSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userNameArchivePath]];
    self.hashtagSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[self hashtagArchivePath]];
    self.mutedChannels = [NSKeyedUnarchiver unarchiveObjectWithFile:[self mutedChannelsArchivePath]];
    self.mutedClients = [NSKeyedUnarchiver unarchiveObjectWithFile:[self mutedClientsArchivePath]];
    self.subscribedChannels = [NSKeyedUnarchiver unarchiveObjectWithFile:[self subscribedChannelsArchivePath]];
    self.unreadMentions = [NSKeyedUnarchiver unarchiveObjectWithFile:[self unreadMentionsPath]];
}

- (void)addConnection {
    self.numberOfConnections = self.numberOfConnections + 1;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)removeConnection {
    self.numberOfConnections = self.numberOfConnections - 1;
    if (self.numberOfConnections < 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)addUnreadMentionWithId:(NSString*)idString {
    NSMutableSet *mutableSet = [self.unreadMentions mutableCopy];
    [mutableSet addObject:idString];
    self.unreadMentions = [mutableSet copy];
}

- (void)removeUnreadMentionWithId:(NSString*)idString {
    NSMutableSet *mutableSet = [self.unreadMentions mutableCopy];
    [mutableSet removeObject:idString];
    self.unreadMentions = [mutableSet copy];
}

- (void)removeAllUnreadMentions {
    self.unreadMentions = [NSSet set];
}

- (NSUInteger)numberOfUnreadMentions {
    return [self.unreadMentions count];
}

- (NSString*)userNameArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userNameSetArchive"];
}

- (NSString*)hashtagArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"hashtagSetArchive"];
}

- (NSString*)mutedHashtagArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"mutedHashtagSetArchive"];
}

- (NSString*)mutedThreadIdArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"mutedThreadIdArchive"];
}

- (NSString*)mutedChannelsArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"mutedChannelsArchive"];
}

- (NSString*)mutedClientsArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"mutedClientsArchivePath"];
}

- (NSString*)subscribedChannelsArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"subscribedChannels"];
}

- (NSString*)unreadMentionsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"unreadMentions"];
}


- (UIColor*)mainColor {
    return _mainColor ? _mainColor : kMainColor;
}

- (UIColor*)cellBackgroundColor {
    return _cellBackgroundColor ? _cellBackgroundColor : kLightCellBackgroundColorDefault;
}

- (UIColor*)markedCellBackgroundColor {
    return _markedCellBackgroundColor ? _markedCellBackgroundColor : kLightCellBackgroundColorMarked;
}

- (UIColor*)textColor {
    return _textColor ? _textColor : kLightTextColor;
}

- (UIColor*)linkColor {
    return _linkColor ? _linkColor : kLightLinkColor;
}

- (UIColor*)mentionColor {
    return _mentionColor ? _mentionColor : kLightMentionColor;
}

- (UIColor*)hashTagColor {
    return _hashTagColor ? _hashTagColor : kLightHashTagColor;
}

- (UIColor*)tintColor {
    return _tintColor ? _tintColor : kLightTintColor;
}

- (UIColor*)markerColor {
    return _markerColor ? _markerColor : kLightMarkerColor;
}

- (UIColor*)separatorColor {
    return _separatorColor ? _separatorColor : kLightSeparatorColor;
}

- (UIColor*)darkMainColor {
    return _darkMainColor ? _darkMainColor : kDarkMainColor;
}

- (UIColor*)darkCellBackgroundColor {
    return _darkCellBackgroundColor ? _darkCellBackgroundColor : kDarkCellBackgroundColorDefault;
}

- (UIColor*)darkMarkedCellBackgroundColor {
    return _darkMarkedCellBackgroundColor ? _darkMarkedCellBackgroundColor : kDarkCellBackgroundColorMarked;
}

- (UIColor*)darkTextColor {
    return _darkTextColor ? _darkTextColor : kDarkTextColor;
}

- (UIColor*)darkLinkColor {
    return _darkLinkColor ? _darkLinkColor : kDarkLinkColor;
}

- (UIColor*)darkMentionColor {
    return _darkMentionColor ? _darkMentionColor : kDarkMentionColor;
}

- (UIColor*)darkHashTagColor {
    return _darkHashTagColor ? _darkHashTagColor : kDarkHashTagColor;
}

- (UIColor*)darkTintColor {
    return _darkTintColor ? _darkTintColor : kDarkTintColor;
}

- (UIColor*)darkMarkerColor {
    return _darkMarkerColor ? _darkMarkerColor : kDarkMarkerColor;
}

- (UIColor*)darkSeparatorColor {
    return _darkSeparatorColor ? _darkSeparatorColor : kDarkSeparatorColor;
}


- (void)loadCustomColors {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _mainColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomMainColor]];
    _cellBackgroundColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomCellBackgroundColor]];
    _markedCellBackgroundColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomMarkedCellBackgroundColor]];
    _textColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomTextColor]];
    _linkColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomLinkColor]];
    _mentionColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomMentionColor]];
    _hashTagColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomHashtagColor]];
    _tintColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomTintColor]];
    _markerColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomMarkerColor]];
    _separatorColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomSeparatorColor]];
    
    _darkMainColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkMainColor]];
    _darkCellBackgroundColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkCellBackgroundColor]];
    _darkMarkedCellBackgroundColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkMarkedCellBackgroundColor]];
    _darkTextColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkTextColor]];
    _darkLinkColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkLinkColor]];
    _darkMentionColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkMentionColor]];
    _darkHashTagColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkHashtagColor]];
    _darkTintColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkTintColor]];
    _darkMarkerColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkMarkerColor]];
    _darkSeparatorColor = [UIColor colorWithString:[userDefaults stringForKey:kCustomDarkSeparatorColor]];
}

@end
