//
//  DHUserPostsTableViewController.h
//  Appetizr
//
//  Created by dasdom on 14.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRPConnection.h"
#import "PRPAlertView.h"

@class DHPostCell;

@interface DHStreamTableViewController : UITableViewController

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSArray *userStreamArray;
@property (nonatomic, strong) NSIndexPath *controlIndexPath;

@property (nonatomic, strong) UIButton *menuButton;

- (void)loadNewPostsWithCompletionHandler:(void(^)(BOOL newData))completionHandler;
- (void)updateUserStreamArraySinceId:(NSString*)sinceId beforeId:(NSString*)beforeId;
- (void)populatePostCell:(DHPostCell*)postCell withDictionary:(NSDictionary*)postDict forIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)heightForPostDict:(NSDictionary*)postDict withAnnotationDict:(NSDictionary*)annotationDict isRepost:(BOOL)isRepost;
- (void)updateMarker;
- (void)addSeenId:(NSString*)idString;
- (void)dissmisData:(NSNotification*)note;
- (void)setColors;
- (NSString*)archivePath;
- (void)loadNewPosts:(UIRefreshControl*)sender;
//- (void)refreshTriggered;
- (void)saveContentOffsetY;
- (void)loadStreamArray;
- (void)changeThemeModeIfNeeded;
- (void)postCellTapped:(DHPostCell*)postCell;

@end
