//
//  DHFollowerCollectionViewController.m
//  Appetizr
//
//  Created by dasdom on 29.09.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHFollowerCollectionViewController.h"
#import "PRPConnection.h"
#import "DHFollowerCell.h"
#import "DHFollowerScoreView.h"
#import "PRPAlertView.h"
#import "DHAppDelegate.h"
//#import "KeychainItemWrapper.h"
#import "SSKeychain.h"
#import "UIImage+NormalizedImage.h"

@interface DHFollowerCollectionViewController ()
@property (nonatomic, strong) NSArray *followerArray;
//@property (nonatomic, strong) NSMutableArray *iAmFollowingArray;
//@property (nonatomic, strong) NSMutableArray *iAmNotFollowingArray;
//@property (nonatomic, strong) NSMutableDictionary *avatarDict;
@property (nonatomic) CGFloat score;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSString *maxId;
@property (nonatomic, strong) NSString *minId;
@property (nonatomic) BOOL moreToLoad;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIBarButtonItem *moreBarButtonItem;
@property (nonatomic) BOOL showMoreInfo;

@property (nonatomic, strong) NSString *avatarDirectoryPath;
@end

@implementation DHFollowerCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isLoading = NO;
    self.moreToLoad = YES;
    self.showMoreInfo = NO;

    _moreBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"more", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMoreInfo:)];
    self.navigationItem.rightBarButtonItem = _moreBarButtonItem;
    
    self.followerArray = [NSArray array];
    [self updateUserStreamArraySinceId:nil beforeId:nil];
    
//    NSMutableString *mutableUrlString = [self.urlString mutableCopy];
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
//
//    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@?access_token=%@", mutableUrlString, accessToken];
//    
//    _iAmFollowingArray = [NSMutableArray array];
//    _iAmNotFollowingArray = [NSMutableArray array];
//    
//    DHConnection *dhConnection = [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
//        
//        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
//        if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
//            [DHAlertView showWithTitle:@"Error occurred" message:error.localizedDescription buttonTitle:@"OK"];
//            return;
//        }
//    
//        id theArray = [responseDict objectForKey:@"data"];
//        if (![theArray isKindOfClass:[NSArray class]]) {
//            NSLog(@"theArray is not an array");
//            return;
//        }
//
//        self.followerArray = theArray;
//        [self.collectionView reloadData];
////        NSInteger followingOfFollowing = 0;
////        for (NSDictionary *userDict in self.followerArray) {
////            if ([self.title isEqualToString:@"Following"]) {
////                followingOfFollowing = followingOfFollowing + [[[userDict objectForKey:@"counts"] objectForKey:@"following"] integerValue];
////            } else {
////                followingOfFollowing = followingOfFollowing + [[[userDict objectForKey:@"counts"] objectForKey:@"followers"] integerValue];
////            }
////            
////            if ([[userDict objectForKey:@"you_follow"] boolValue]) {
////                [_iAmFollowingArray addObject:userDict];
////            } else {
////                [_iAmNotFollowingArray addObject:userDict];
////            }
////        }
////        if ([self.followerArray count]) {
////            self.score = (float)followingOfFollowing/(float)[self.followerArray count];
////        } else {
////            self.score = 0.0f;
////        }
//    }];
//    [dhConnection start];
    
    _imageCache = [[NSCache alloc] init];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _avatarDirectoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"follower"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:_avatarDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSFileManager defaultManager] removeItemAtPath:_avatarDirectoryPath error:nil];
}

- (void)updateUserStreamArraySinceId:(NSString*)sinceId beforeId:(NSString*)beforeId {
    if (self.isLoading || !self.moreToLoad) {
        return;
    }
    
    if ([(DHAppDelegate*)[[UIApplication sharedApplication] delegate] internetReach].currentReachabilityStatus == NotReachable) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"No Internet", nil) message:NSLocalizedString(@"You don't have connection to the internet.", nil) buttonTitle:@"OK"];
        return;
    }
    NSMutableString *mutableUrlString = [self.urlString mutableCopy];
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
     NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSMutableString *urlStringWithAccessToken = [NSMutableString stringWithFormat:@"%@?access_token=%@", mutableUrlString, accessToken];
    
    if (sinceId) {
        [urlStringWithAccessToken appendFormat:@"&since_id=%@&", sinceId];
    }
    if (beforeId) {
        [urlStringWithAccessToken appendFormat:@"&before_id=%@&", beforeId];
    }
        
    self.isLoading = YES;
    PRPConnection *dhConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
        self.isLoading = NO;

        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
        NSDictionary *metaDataDict = [responseDict objectForKey:@"meta"];
        if (error || [[metaDataDict objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
//        NSLog(@"metaDataDict: %@", metaDataDict);
        self.maxId = [metaDataDict objectForKey:@"max_id"];
        self.minId = [metaDataDict objectForKey:@"min_id"];
        if (![[metaDataDict objectForKey:@"more"] boolValue]) {
            self.moreToLoad = NO;
            [self calculateScore];
        }
        
        id theArray = [responseDict objectForKey:@"data"];
        if (![theArray isKindOfClass:[NSArray class]]) {
            dhDebug(@"theArray is not an array");
            return;
        }
        
        NSMutableArray *mutableFollowerArray = [self.followerArray mutableCopy];
        [mutableFollowerArray addObjectsFromArray:theArray];
        self.followerArray = [mutableFollowerArray copy];
        
        [self.collectionView reloadData];
    }];
    [dhConnection start];

}

- (void)calculateScore {
    NSInteger followingOfFollowing = 0;
    for (NSDictionary *userDict in self.followerArray) {
        if ([self.title isEqualToString:@"Following"]) {
            followingOfFollowing = followingOfFollowing + [[[userDict objectForKey:@"counts"] objectForKey:@"following"] integerValue];
        } else {
            followingOfFollowing = followingOfFollowing + [[[userDict objectForKey:@"counts"] objectForKey:@"followers"] integerValue];
        }
        
    }
    if ([self.followerArray count]) {
        self.score = (float)followingOfFollowing/(float)[self.followerArray count];
    } else {
        self.score = 0.0f;
    }

//    NSString *followingScore;
//    if ([self.title isEqualToString:@"Following"]) {
//        followingScore = [NSString stringWithFormat:NSLocalizedString(@"The people %@ is following are following in average %.1f people.", nil), self.nameString, self.score];
//    } else {
//        followingScore = [NSString stringWithFormat:NSLocalizedString(@"The people following %@ are followed in average by %.1f people.", nil), self.nameString, self.score];
//    }
//
//    [DHAlertView showWithTitle:NSLocalizedString(@"Score", nil) message:followingScore buttonTitle:NSLocalizedString(@"OK", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItem = 0;

    numberOfItem = [self.followerArray count];
    return numberOfItem;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DHFollowerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FollowingCell" forIndexPath:indexPath];
    NSDictionary *userDict;

    userDict = [self.followerArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"@%@", [userDict objectForKey:@"username"]];
    cell.avatarImageView.image = nil;
//    cell.nameString = [NSString stringWithFormat:@"@%@", [userDict objectForKey:@"username"]];
//    cell.avatarImage = nil;
//    
//    cell.moreInfoHostView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 26.0f, 106.0f, 60.0f)];
//    [cell addSubview:cell.moreInfoHostView];
//    
//    cell.moreInfoHostView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 26.0f, 106.0f, 60.0f)];
//    UILabel *moreInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 96.0f, 60.0f)];
//    [moreInfoLabel setTextColor:[UIColor whiteColor]];
//    [moreInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [moreInfoLabel setNumberOfLines:3];
//    [cell.moreInfoHostView addSubview:moreInfoLabel];
//    
//    NSDictionary *countsDict = [userDict objectForKey:@"counts"];
//    moreInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"posts: %@\nfollowing: %@\nfollower: %@", nil), [countsDict objectForKey:@"posts"], [countsDict objectForKey:@"following"], [countsDict objectForKey:@"followers"]];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDarkMode]) {
//        moreInfoLabel.backgroundColor = kDarkMainColor;
//        cell.moreInfoHostView.backgroundColor = kDarkMainColor;
//    } else {
//        moreInfoLabel.backgroundColor = kMainColor;
//        cell.moreInfoHostView.backgroundColor = kMainColor;
//    }
    
    NSDictionary *countsDict = [userDict objectForKey:@"counts"];
    cell.moreInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"posts: %@\nfollowing: %@\nfollower: %@", nil), [countsDict objectForKey:@"posts"], [countsDict objectForKey:@"following"], [countsDict objectForKey:@"followers"]];

    
    if (self.showMoreInfo) {
        cell.moreInfoHostView.hidden = NO;
    } else {
        cell.moreInfoHostView.hidden = YES;
    }
    
    if ([[userDict objectForKey:@"you_follow"] boolValue] && [self.showIFollowBanner boolValue]) {
        cell.iFollowBannerImageView.alpha = 1.0f;
    } else {
        cell.iFollowBannerImageView.alpha = 0.0f;
    }
    if ([[userDict objectForKey:@"follows_you"] boolValue] && [self.showFollowsMeBanner boolValue]) {
        cell.followsMeBannerImageView.alpha = 1.0f;
    } else {
        cell.followsMeBannerImageView.alpha = 0.0f;
    }
//    if ([self.avatarDict objectForKey:avatarUrl]) {
//        cell.avatarImageView.image = [self.avatarDict objectForKey:avatarUrl];
//    } else {
        dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
        dispatch_async(imgDownloaderQueue, ^{
            NSDictionary *avatartImageDictionary = [userDict objectForKey:@"avatar_image"];
            NSString *avatarUrlString = [avatartImageDictionary objectForKey:@"url"];
            CGFloat width = [[avatartImageDictionary objectForKey:@"width"] floatValue];
            dhDebug(@"width: %f", width);
            if (width < 2000.0f) {
                NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
//                UIImage *avatarImage = [self.imageCache objectForKey:imageKey];
                
                NSString *avatarPath = [self.avatarDirectoryPath stringByAppendingPathComponent:imageKey];
                UIImage *avatarImage = [UIImage imageWithContentsOfFile:avatarPath];
                if (!avatarImage) {
                    UIImage *dummyImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
                    avatarImage = [dummyImage resizeImage:CGSizeMake(212.0f, 212.0f)];
                    if (avatarImage) {
//                        [self.imageCache setObject:avatarImage forKey:imageKey];
                        NSData *imageData = UIImagePNGRepresentation(avatarImage);
                        [[NSFileManager defaultManager] createFileAtPath:avatarPath contents:imageData attributes:nil];
                    }
                }
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    DHFollowerCell *asyncCell = (DHFollowerCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
                    asyncCell.avatarImageView.image = avatarImage;
//                    asyncCell.avatarImage = avatarImage;
                });
            }
        });
//    }
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView;
    if ([kind isEqualToString:NSStringFromClass([DHFollowerScoreView class])]) {
        DHFollowerScoreView *followerScoreView = (DHFollowerScoreView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        NSString *followingScore;
        if (self.moreToLoad) {
            followingScore = @"";
        } else {
            if ([self.title isEqualToString:@"Following"]) {
                followingScore = [NSString stringWithFormat:NSLocalizedString(@"The people %@ is following are following in average %.1f people.", nil), self.nameString, self.score];
            } else {
                followingScore = [NSString stringWithFormat:NSLocalizedString(@"The people following %@ are followed in average by %.1f people.", nil), self.nameString, self.score];
            }
        }
        followerScoreView.scoreLabel.text = followingScore;
        reusableView = followerScoreView;
    }
    return reusableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - 100.0f) {
        [self updateUserStreamArraySinceId:nil beforeId:self.minId];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userDict = [self.followerArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowProfile" sender:[userDict objectForKey:@"id"]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(175.0f, 175.0f);
    } else {
        return CGSizeMake(106.0f, 106.0f);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        [segue.destinationViewController setValue:sender forKey:@"userId"];
    }
}

- (void)toggleMoreInfo:(id)sender {
    self.showMoreInfo = !self.showMoreInfo;
    if (self.showMoreInfo) {
        [self.moreBarButtonItem setTitle:NSLocalizedString(@"less", nil)];
    } else {
        [self.moreBarButtonItem setTitle:NSLocalizedString(@"more", nil)];
    }
    [self.collectionView reloadData];
}

@end
