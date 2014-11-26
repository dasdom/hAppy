//
//  PostDetailsViewController.m
//  Appetizr
//
//  Created by dasdom on 12.02.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PostDetailsViewController.h"
#import "PostDetailsPostCell.h"
#import "PostDetailWebSiteCell.h"
#import "SSKeychain.h"
#import "PRPConnection.h"
#import "PRPAlertView.h"
//#import "DHGlobalObjects.h"
#import "DHAppDelegate.h"
#import "DHFollowerCell.h"
#import "MapViewCell.h"
#import "RawResponseCell.h"
#import "UserSectionHeader.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

enum POST_DETAIL_SECTIONS {
    POST_DETAIL_POST_SECTION = 0,
    POST_DETAIL_MENTIONS_SECTION,
    POST_DETAIL_LINK_SECTION,
    POST_DETAIL_MAP_SECTION,
    POST_DETAIL_STARRED_SECTION,
    POST_DETAIL_REPOSTED_SECTION,
    POST_DETAIL_RAW_SECTION,
    POST_DETAIL_NUM_OF_SECTIONS
    } POST_DETAIL_SECTIONS;

@interface PostDetailsViewController ()

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) NSArray *mentionArray;
@property (nonatomic, strong) NSArray *linkArray;
@property (nonatomic, strong) NSArray *userWhoStarredArray;
@property (nonatomic, strong) NSArray *userWhoRepostedArray;
@property (nonatomic, strong) NSDictionary *locationAnnotationDictionary;

@end

@implementation PostDetailsViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

//- (void)awakeFromNib {
//    NSString *urlString = [NSString stringWithFormat:@"%@%@%@?include_post_annotations=1&include_starred_by=1&include_reposters=1&", kBaseURL, kPostsSubURL, self.postId];
//    
//    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
//    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
//    
//    DHConnection *dhConnection = [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
//        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
//        //        NSLog(@"metaDict: %@", metaDict);
//        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
//            [DHAlertView showWithTitle:@"Error occurred" message:error.localizedDescription buttonTitle:@"OK"];
//            return;
//        }
//    }];
//    [dhConnection start];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageCache = [[NSCache alloc] init];
    
}


- (void)viewWillAppear:(BOOL)animated {
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@?include_post_annotations=1&include_starred_by=1&include_reposters=1&", kBaseURL, kPostsSubURL, self.postId];
    
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
    
    __weak PostDetailsViewController *weakSelf = self;
    
    PRPConnection *dhConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
        weakSelf.dataDict = [responseDict objectForKey:@"data"];
        if ([[weakSelf.dataDict objectForKey:@"is_deleted"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
        dhDebug(@"metaDict: %@", metaDict);
        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
        weakSelf.userWhoStarredArray = [weakSelf.dataDict objectForKey:@"starred_by"];
        weakSelf.userWhoRepostedArray = [weakSelf.dataDict objectForKey:@"reposters"];
        
        weakSelf.linkArray = [[weakSelf.dataDict objectForKey:@"entities"] objectForKey:@"links"];
        
        NSArray *annotationsArray = [weakSelf.dataDict objectForKey:@"annotations"];
        NSDictionary *imageAnnotationDict;
        NSString *languageString;
        for (NSDictionary *annotationDict in annotationsArray) {
            if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"] && [[[annotationDict objectForKey:@"value"] objectForKey:@"type"] isEqualToString:@"photo"]) {
                imageAnnotationDict = annotationDict;
            }
            if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.language"]) {
                languageString = [[annotationDict objectForKey:@"value"] objectForKey:@"language"];
            }
            if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.checkin"]) {
                weakSelf.locationAnnotationDictionary = [annotationDict objectForKey:@"value"];
            }
        }

        
        NSArray *mentions = [[weakSelf.dataDict objectForKey:@"entities"] objectForKey:@"mentions"];
        if ([mentions count]) {
            NSMutableString *usersString = [NSMutableString string];
            for (NSDictionary *dict in mentions) {
                [usersString appendFormat:@"%@,", [dict objectForKey:@"id"]];
            }
            NSString *urlString = [NSString stringWithFormat:@"%@users?ids=%@&", kBaseURL, [usersString substringToIndex:[usersString length]-1]];
            NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
            PRPConnection *mentionsConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//            [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection *connection) {} completion:^(DHConnection *connection, NSError *error) {
                NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
                NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
                dhDebug(@"metaDict: %@", metaDict);
                if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                    [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                    return;
                }
                weakSelf.mentionArray = [responseDict objectForKey:@"data"];
                [weakSelf.collectionView reloadData];

            }];
            [mentionsConnection start];
        }
        [weakSelf.collectionView reloadData];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@/stars?", kBaseURL, kPostsSubURL, self.postId];
        NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@access_token=%@", urlString, accessToken];
        PRPConnection *starConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection *connection){} completion:^(DHConnection *connection, NSError *error) {
            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
            //        NSLog(@"responseDict: %@", responseDict);
            NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
            dhDebug(@"metaDict: %@", metaDict);
            if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                return;
            }
            weakSelf.userWhoStarredArray = [responseDict objectForKey:@"data"];
            [weakSelf.collectionView reloadData];
        }];
        [starConnection start];
    }];
    [dhConnection start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.dataDict) {
        return POST_DETAIL_NUM_OF_SECTIONS;
    } else {
        return 0;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    
    switch (section) {
        case POST_DETAIL_POST_SECTION:
            numberOfItems = 1;
            break;
        case POST_DETAIL_MENTIONS_SECTION:
        {
            numberOfItems = [self.mentionArray count];
            break;
        }
        case POST_DETAIL_MAP_SECTION:
        {
            numberOfItems = self.locationAnnotationDictionary ? 1 : 0;
            break;
        }
        case POST_DETAIL_LINK_SECTION:
        {
            numberOfItems = [self.linkArray count];
            break;
        }
        case POST_DETAIL_STARRED_SECTION:
        {
            numberOfItems = [self.userWhoStarredArray count];
            break;
        }
        case POST_DETAIL_REPOSTED_SECTION:
        {
            numberOfItems = [self.userWhoRepostedArray count];
            break;
        }
        case POST_DETAIL_RAW_SECTION:
        {
            numberOfItems = 1;
            break;
        }
        default:
            NSAssert1(false, @"Unsupported section: %d", section);
            break;
    }
    return numberOfItems;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    switch (indexPath.section) {
        case POST_DETAIL_POST_SECTION:
        {
            PostDetailsPostCell *postCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
            NSString *postText = [self.dataDict objectForKey:@"text"];
            
            NSDictionary *userDict = [self.dataDict objectForKey:@"user"];
            postCell.userId  = [userDict objectForKey:@"id"];

            postCell.clientLabel.text = [NSString stringWithFormat:@"via %@", [[self.dataDict objectForKey:@"source"] objectForKey:@"name"]];
            postCell.userNameLabel.text = [userDict objectForKey:@"username"];
            
            NSDate *date = [[[DHGlobalObjects sharedGlobalObjects] iso8601DateFormatter] dateFromString:[self.dataDict objectForKey:@"created_at"]];
            CGFloat secondsSincePost = -[date timeIntervalSinceNow];
            NSString *timeSincePostString;
            NSMutableString *accessibilityString = [postCell.userNameLabel.text mutableCopy];
            if (secondsSincePost < 60.0f) {
                timeSincePostString = NSLocalizedString(@"now", nil);
                [accessibilityString appendFormat:NSLocalizedString(@" posted now %@", nil), postCell.clientLabel.text];
            } else if (secondsSincePost < 3600.0f) {
                timeSincePostString = [NSString stringWithFormat:@"%dm", (int)secondsSincePost/60];
                [accessibilityString appendFormat:NSLocalizedString(@" posted %d minutes ago %@", nil), (int)secondsSincePost/60, postCell.clientLabel.text];
            } else if (secondsSincePost < 86400.0f) {
                timeSincePostString = [NSString stringWithFormat:@"%dh", (int)secondsSincePost/3600];
                [accessibilityString appendFormat:NSLocalizedString(@" posted %d hours ago %@", nil), (int)secondsSincePost/3600, postCell.clientLabel.text];
            } else {
                timeSincePostString = [NSString stringWithFormat:@"%dd", (int)secondsSincePost/86400];
                [accessibilityString appendFormat:NSLocalizedString(@" posted %d days ago %@", nil), (int)secondsSincePost/86400, postCell.clientLabel.text];
            }

            postCell.postDateLabel.text = timeSincePostString;

//            [accessibilityString appendFormat:@" %@", postCell.clientLabel.text];
            postCell.accessibilityLabel = accessibilityString;
            postCell.avatarImageView.image = nil;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            if (![userDefaults boolForKey:kDontLoadImages]) {
                postCell.avatarImageView.backgroundColor = [UIColor clearColor];
                
                NSDictionary *userDict = [self.dataDict objectForKey:@"user"];
                NSDictionary *avatarImageDictionary = [userDict objectForKey:@"avatar_image"];
                dispatch_queue_t avatarDownloaderQueue = dispatch_queue_create("de.dasdom.avatarDownloader", NULL);
                dispatch_async(avatarDownloaderQueue, ^{
                    NSString *avatarUrlString = [avatarImageDictionary objectForKey:@"url"];
                    NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
                    NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
                    UIImage *avatarImage = [imageCache objectForKey:imageKey];
                    if (!avatarImage) {
                        avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
                        if (avatarImage) {
                            [imageCache setObject:avatarImage forKey:imageKey];
                        }
                    }
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        id asyncCell = [self.collectionView cellForItemAtIndexPath:indexPath];
                        if ([asyncCell isKindOfClass:([PostDetailsPostCell class])]) {
                            [[asyncCell avatarImageView] setImage:avatarImage];
                        }
                    });
                });
            } else {
                CGFloat blueFloat = (CGFloat)([postCell.userId integerValue]%100)/100.0f;
                CGFloat greenFloat = (CGFloat)(([postCell.userId integerValue]/100)%100)/100.0f;
                CGFloat redFloat = (CGFloat)(([postCell.userId integerValue]/10000)%100)/100.0f;
                //        dispatch_sync(dispatch_get_main_queue(), ^{
                postCell.avatarImageView.backgroundColor = [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
                //        });
            }

            NSArray *annotationsArray = [self.dataDict objectForKey:@"annotations"];
            NSDictionary *imageAnnotationDict;
            for (NSDictionary *annotationDict in annotationsArray) {
                if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"] && [[[annotationDict objectForKey:@"value"] objectForKey:@"type"] isEqualToString:@"photo"]) {
                    imageAnnotationDict = annotationDict;
                }
            }

            CGFloat widthdiff = 77.0f;
            if (imageAnnotationDict && ![userDefaults boolForKey:kDontLoadImages]) {
                widthdiff = 138.0f;
                postCell.postImage.layer.borderWidth = 1.0f;
                NSString *urlKey = @"url";
                NSString *heightKey = @"height";
                NSString *widthKey = @"width";
                
                NSDictionary *valueDict = [imageAnnotationDict objectForKey:@"value"];
                if ([valueDict objectForKey:@"thumbnail_url"]) {
                    urlKey = @"thumbnail_url";
                    heightKey = @"thumbnail_height";
                    widthKey = @"thumbnail_width";
                }
//                postCell.postImageURL = [valueDict objectForKey:@"url"];
                if ([[valueDict objectForKey:widthKey] floatValue] > 0.0f) {
                    CGRect postImageFrame = postCell.postImage.frame;
                    postImageFrame.size.height = (56.0f * [[valueDict objectForKey:heightKey] floatValue] / [[valueDict objectForKey:widthKey] floatValue]);
                    //            dhDebug(@"postImageFrame: %@", NSStringFromCGRect(postImageFrame));
                    postCell.postImage.frame = postImageFrame;
                }
                dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("de.dasdom.imageDownloader", NULL);
                dispatch_async(imgDownloaderQueue, ^{
                    NSString *avatarUrlString = [valueDict objectForKey:urlKey];
                    UIImage *postImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        id asyncCell = [self.collectionView cellForItemAtIndexPath:indexPath];
                        if ([asyncCell isKindOfClass:([PostDetailsPostCell class])]) {
                            [[asyncCell postImage] setImage:postImage];
                        }
                    });
                });
            } else {
                postCell.postImage.image = nil;
                postCell.postImage.layer.borderWidth = 0.0f;
                postCell.postImage = nil;
            }
            CGSize labelSize = [postText sizeWithFont:postCell.postTextView.font constrainedToSize:CGSizeMake(self.view.frame.size.width-widthdiff, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            labelSize.height = labelSize.height+5.0f;
            CGRect postTextFrame = postCell.postTextView.frame;
            postTextFrame.size = CGSizeMake(self.view.frame.size.width-widthdiff, labelSize.height);
            postCell.postTextView.frame = postTextFrame;
            
            postCell.postTextView.font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
            
            [postCell.postTextView removeAllLinks];
            NSArray *linkArray = [[self.dataDict objectForKey:@"entities"] objectForKey:@"links"];
            for (NSDictionary *linkDict in linkArray) {
                NSRange linkRange = {[[linkDict objectForKey:@"pos"] integerValue], [[linkDict objectForKey:@"len"] integerValue]};
                [postCell.postTextView addLinkRange:linkRange forLink:[linkDict objectForKey:@"url"]];
            }
            
            [postCell.postTextView removeAllMentions];
            NSArray *mentionArray = [[self.dataDict objectForKey:@"entities"] objectForKey:@"mentions"];
//            NSString *myName = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey];
//            BOOL directedToMe = NO;
            for (NSDictionary *mentionDict in mentionArray) {
                NSRange linkRange = {[[mentionDict objectForKey:@"pos"] integerValue], [[mentionDict objectForKey:@"len"] integerValue]};
                [postCell.postTextView addMentionRange:linkRange forUserId:[mentionDict objectForKey:@"id"]];
            }
            
            [postCell.postTextView removeAllHashTags];
            NSArray *hashTagArray = [[self.dataDict objectForKey:@"entities"] objectForKey:@"hashtags"];
            for (NSDictionary *hashTagDict in hashTagArray) {
                NSRange hashTagRange = {[[hashTagDict objectForKey:@"pos"] integerValue], [[hashTagDict objectForKey:@"len"] integerValue]};
                [postCell.postTextView addHashTagRange:hashTagRange forName:[hashTagDict objectForKey:@"name"]];

            }

            postCell.isAccessibilityElement = YES;
            postCell.postTextView.text = postText;

            [postCell.postTextView setNeedsDisplay];
            
            UIColor *cellBackgroundColor;
            if ([userDefaults boolForKey:kDarkMode]) {
//                cellBackgroundColor = kDarkCellBackgroundColorDefault;
                cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
            } else {
                cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
            }
        
            postCell.contentView.backgroundColor = cellBackgroundColor;
            postCell.clientLabel.backgroundColor = cellBackgroundColor;
            postCell.userNameLabel.backgroundColor = cellBackgroundColor;
            postCell.postTextView.backgroundColor = cellBackgroundColor;
            postCell.postDateLabel.backgroundColor = cellBackgroundColor;
            
            if ([userDefaults boolForKey:kDarkMode]) {
//                postCell.postTextView.textColor = kDarkTextColor;
//                postCell.userNameLabel.textColor = kDarkTextColor;
                postCell.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
                postCell.userNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
            } else {
                postCell.postTextView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
                postCell.userNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
            }

            cell = postCell;
            break;
        }
        case POST_DETAIL_MENTIONS_SECTION:
        {
            DHFollowerCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
            NSDictionary *userDict;
            
            userDict = [self.mentionArray objectAtIndex:indexPath.row];
            userCell.nameLabel.text = [NSString stringWithFormat:@"@%@", [userDict objectForKey:@"username"]];
            userCell.avatarImageView.image = nil;
            if ([[userDict objectForKey:@"you_follow"] boolValue]) {
                userCell.iFollowBannerImageView.alpha = 1.0f;
            } else {
                userCell.iFollowBannerImageView.alpha = 0.0f;
            }
            
            dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
            dispatch_async(imgDownloaderQueue, ^{
                NSDictionary *avatartImageDictionary = [userDict objectForKey:@"avatar_image"];
                NSString *avatarUrlString = [avatartImageDictionary objectForKey:@"url"];
                CGFloat avatarWidth = [[avatartImageDictionary objectForKey:@"width"] floatValue];
                NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
                UIImage *avatarImage = [self.imageCache objectForKey:imageKey];
                if (!avatarImage) {
//                    avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
                    avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:100.0f/avatarWidth];

                    if (avatarImage) {
                        [self.imageCache setObject:avatarImage forKey:imageKey];
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    DHFollowerCell *asyncCell = (DHFollowerCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
                    asyncCell.avatarImageView.image = avatarImage;
                    
                });
            });
            
            cell = userCell;
            break;
        }
        case POST_DETAIL_MAP_SECTION:
        {
            MapViewCell *mapViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapViewCell" forIndexPath:indexPath];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[self.locationAnnotationDictionary objectForKey:@"latitude"] floatValue], [[self.locationAnnotationDictionary objectForKey:@"longitude"] floatValue]);
            MKCoordinateSpan span = MKCoordinateSpanMake(0.5, 0.5);
            MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
            [mapViewCell.mapView setRegion:region animated:YES];
                        
            cell = mapViewCell;
            break;
        }
        case POST_DETAIL_LINK_SECTION:
        {
            PostDetailWebSiteCell *webSiteCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WebsiteCell" forIndexPath:indexPath];
            
            NSDictionary *linkDict = [self.linkArray objectAtIndex:indexPath.row];
            NSString *urlString = [linkDict objectForKey:@"url"];
            webSiteCell.urlString = urlString;
            [webSiteCell.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
            
            cell = webSiteCell;
            break;
        }
        case POST_DETAIL_STARRED_SECTION:
        {
            DHFollowerCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
            NSDictionary *userDict;
            
            userDict = [self.userWhoStarredArray objectAtIndex:indexPath.row];
            userCell.nameLabel.text = [NSString stringWithFormat:@"@%@", [userDict objectForKey:@"username"]];
            userCell.avatarImageView.image = nil;
            if ([[userDict objectForKey:@"you_follow"] boolValue]) {
                userCell.iFollowBannerImageView.alpha = 1.0f;
            } else {
                userCell.iFollowBannerImageView.alpha = 0.0f;
            }
            
            dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
            dispatch_async(imgDownloaderQueue, ^{
                NSDictionary *avatartImageDictionary = [userDict objectForKey:@"avatar_image"];
                NSString *avatarUrlString = [avatartImageDictionary objectForKey:@"url"];
                CGFloat avatarWidth = [[avatartImageDictionary objectForKey:@"width"] floatValue];
                NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
                UIImage *avatarImage = [self.imageCache objectForKey:imageKey];
                if (!avatarImage) {
//                    avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
                    avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:100.0f/avatarWidth];

                    if (avatarImage) {
                        [self.imageCache setObject:avatarImage forKey:imageKey];
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    DHFollowerCell *asyncCell = (DHFollowerCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
                    asyncCell.avatarImageView.image = avatarImage;
                    
                });
            });

            cell = userCell;
            break;
        }
        case POST_DETAIL_REPOSTED_SECTION:
        {
            DHFollowerCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
            NSDictionary *userDict;
            
            userDict = [self.userWhoRepostedArray objectAtIndex:indexPath.row];
            userCell.nameLabel.text = [NSString stringWithFormat:@"@%@", [userDict objectForKey:@"username"]];
            userCell.avatarImageView.image = nil;
            if ([[userDict objectForKey:@"you_follow"] boolValue]) {
                userCell.iFollowBannerImageView.alpha = 1.0f;
            } else {
                userCell.iFollowBannerImageView.alpha = 0.0f;
            }
            
            dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
            dispatch_async(imgDownloaderQueue, ^{
                NSDictionary *avatartImageDictionary = [userDict objectForKey:@"avatar_image"];
                NSString *avatarUrlString = [avatartImageDictionary objectForKey:@"url"];
                CGFloat avatarWidth = [[avatartImageDictionary objectForKey:@"width"] floatValue];
                NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
                UIImage *avatarImage = [self.imageCache objectForKey:imageKey];
                if (!avatarImage) {
//                    avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
                    avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:100.0f/avatarWidth];

                    if (avatarImage) {
                        [self.imageCache setObject:avatarImage forKey:imageKey];
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    DHFollowerCell *asyncCell = (DHFollowerCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
                    asyncCell.avatarImageView.image = avatarImage;
                    
                });
            });
            
            cell = userCell;
            break;
        }
        case POST_DETAIL_RAW_SECTION:
        {
            RawResponseCell *rawResponseCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RawCell" forIndexPath:indexPath];
            rawResponseCell.rawResponseTextView.text = [self.dataDict description];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
                rawResponseCell.rawResponseTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
                rawResponseCell.rawResponseTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
            } else {
                rawResponseCell.rawResponseTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
                rawResponseCell.rawResponseTextView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
            }
            cell = rawResponseCell;
            break;
        }
        default:
            NSAssert1(false, @"Unsupported section: %d", indexPath.section);
            break;
    }
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UserSectionHeader *sectionHeader = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UserSectionHeader" forIndexPath:indexPath];
    switch (indexPath.section) {
        case POST_DETAIL_POST_SECTION:
            sectionHeader.titleLabel.text = @"";
            break;
        case POST_DETAIL_MENTIONS_SECTION:
            sectionHeader.titleLabel.text = @"mentions";
            break;
        case POST_DETAIL_LINK_SECTION:
            sectionHeader.titleLabel.text = @"links";
            break;
        case POST_DETAIL_STARRED_SECTION:
            sectionHeader.titleLabel.text = @"starred by";
            break;
        case POST_DETAIL_REPOSTED_SECTION:
            sectionHeader.titleLabel.text = @"reposted by";
            break;
        case POST_DETAIL_RAW_SECTION:
            sectionHeader.titleLabel.text = @"raw API response";
            break;
        default:
            break;
    }
    return sectionHeader;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeZero;
    switch (indexPath.section) {
        case POST_DETAIL_POST_SECTION:
        {
            NSString *postText = [self.dataDict objectForKey:@"text"];
            NSArray *annotationsArray = [self.dataDict objectForKey:@"annotations"];
            NSDictionary *imageAnnotationDict;
            for (NSDictionary *annotationDict in annotationsArray) {
                if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"] && [[[annotationDict objectForKey:@"value"] objectForKey:@"type"] isEqualToString:@"photo"]) {
                    imageAnnotationDict = annotationDict;
                }
            }
            cellSize = CGSizeMake(320.0f, [self heightForPostText:postText withAnnotationDict:imageAnnotationDict]);
            break;
        }
        case POST_DETAIL_MAP_SECTION:
        case POST_DETAIL_LINK_SECTION:
            cellSize = CGSizeMake(self.view.frame.size.width, 160.0f);
            break;
        case POST_DETAIL_MENTIONS_SECTION:
        case POST_DETAIL_STARRED_SECTION:
        case POST_DETAIL_REPOSTED_SECTION:
        {
            cellSize = CGSizeMake(80.0f, 80.0f);
            break;
        }
        case POST_DETAIL_RAW_SECTION:
        {
//            CGSize testSize = [[self.dataDict description] sizeWithFont:[UIFont systemFontOfSize:10.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            cellSize = CGSizeMake(self.view.frame.size.width, 300.0f);
            break;
        }
        default:
            NSAssert1(false, @"Unsupported section %d", indexPath.section);
            break;
    }
    return cellSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeZero;
    switch (section) {
        case POST_DETAIL_MENTIONS_SECTION:
            if ([self.mentionArray count]) {
                headerSize = CGSizeMake(self.view.frame.size.width, 30.0f);
            }
            break;
        case POST_DETAIL_LINK_SECTION:
            if ([self.linkArray count]) {
                headerSize = CGSizeMake(self.view.frame.size.width, 30.0f);
            }
            break;
        case POST_DETAIL_STARRED_SECTION:
            if ([self.userWhoStarredArray count]) {
                headerSize = CGSizeMake(self.view.frame.size.width, 30.0f);
            }
            break;
        case POST_DETAIL_REPOSTED_SECTION:
            if ([self.userWhoRepostedArray count]) {
                headerSize = CGSizeMake(self.view.frame.size.width, 30.0f);
            }
            break;
        case POST_DETAIL_RAW_SECTION:
            headerSize = CGSizeMake(self.view.frame.size.width, 30.0f);
            break;
        default:
            break;
    }
    return headerSize;
}

- (CGFloat)heightForPostText:(NSString*)postText withAnnotationDict:(NSDictionary*)annotationDict {
    CGFloat widthDiff = 77.0f;
    CGFloat minimalHeightForPostImage = 0.0f;
    if (annotationDict) {
        widthDiff = 138.0f;
//        NSString *urlKey = @"url";
        NSString *heightKey = @"height";
        NSString *widthKey = @"width";
        
        if ([annotationDict objectForKey:@"thumbnail_url"]) {
//            urlKey = @"thumbnail_url";
            heightKey = @"thumbnail_height";
            widthKey = @"thumbnail_width";
        }
        
        if ([[annotationDict objectForKey:widthKey] floatValue] > 0.0f) {
            minimalHeightForPostImage = (56.0f * [[annotationDict objectForKey:heightKey] floatValue] / [[annotationDict objectForKey:widthKey] floatValue]) + 25.0f;
        }
        //        NSLog(@"annotationDict: %@", annotationDict);
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CGSize labelSize = [postText sizeWithFont:[UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]] constrainedToSize:CGSizeMake(self.view.frame.size.width-widthDiff, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(minimalHeightForPostImage, MAX(labelSize.height+36.0f+15.0f, 56.0f+14.0f));
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowWebsite"]) {
        [segue.destinationViewController setValue:[sender valueForKey:@"urlString"] forKey:@"linkString"];
    }
}

@end
