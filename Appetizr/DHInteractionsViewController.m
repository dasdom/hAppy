//
//  DHInteractionsViewController.m
//  Appetizr
//
//  Created by dasdom on 15.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHInteractionsViewController.h"
//#import "DHPostCell.h"
#import "DHInteractionPostCell.h"
#import "DHStartedFollowingCell.h"
#import "DHAppDelegate.h"
#import "DHProfileTableViewController.h"
#import "ImageHelper.h"
#import "UIImage+NormalizedImage.h"

@interface DHInteractionsViewController ()

@end

@implementation DHInteractionsViewController

- (void)viewDidLoad
{
    self.urlString = [NSString stringWithFormat:@"%@%@/me/interactions", kBaseURL, kUsersSubURL];

    [super viewDidLoad];

    self.title = NSLocalizedString(@"interactions", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController.viewControllers count] < 2) {
        self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
        [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
        self.menuButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
        UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
        self.navigationItem.leftBarButtonItem = menuBarButton;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSString *actionString = [[self.userStreamArray objectAtIndex:indexPath.row] objectForKey:@"action"];
    
    NSMutableString *mutalbeAccessibilityLabel = [NSMutableString string];
    if (![actionString isEqualToString:@"follow"]) {
        DHInteractionPostCell *interactionPostCell = [DHInteractionPostCell cellForTableView:tableView];
        for (UIView *scrollViewSubview in interactionPostCell.userScrollView.subviews) {
            if ([scrollViewSubview isKindOfClass:([UIImageView class])] ||
                [scrollViewSubview isKindOfClass:([UILabel class])] ||
                scrollViewSubview.tag == 111) {
                [scrollViewSubview removeFromSuperview];
            }
        }
        NSDictionary *postDict = [[[self.userStreamArray objectAtIndex:indexPath.row] objectForKey:@"objects"] objectAtIndex:0];

        [self populatePostCell:interactionPostCell withDictionary:postDict forIndexPath:indexPath];
        
        interactionPostCell.clientString = nil;
//        interactionPostCell.postTextView.isAccessibilityElement = NO;
        
//        NSString *accessibilityString = [NSString stringWithFormat:@"Your post %@", [postDict objectForKey:@"text"]];
        interactionPostCell.accessibilityLabel = [NSString stringWithFormat:@"Your post %@", [postDict objectForKey:@"text"]];
        
        [interactionPostCell.postTextView setNeedsDisplay];
        
        if ([actionString isEqualToString:@"reply"]) {
            interactionPostCell.actionLabel.text = NSLocalizedString(@"... was replyed to by ...", nil);
            [mutalbeAccessibilityLabel appendString:NSLocalizedString(@"was replyed to by ", nil)];
        } else if ([actionString isEqualToString:@"repost"]) {
            interactionPostCell.actionLabel.text = NSLocalizedString(@"... was reposted by ...", nil);
            [mutalbeAccessibilityLabel appendString:NSLocalizedString(@"was reposted by ", nil)];
        } else if ([actionString isEqualToString:@"star"]) {
            interactionPostCell.actionLabel.text = NSLocalizedString(@"... was starred by ...", nil);
            [mutalbeAccessibilityLabel appendString:NSLocalizedString(@"was starred by ", nil)];
        }
        interactionPostCell.actionLabel.isAccessibilityElement = YES;
        
//        NSArray *userArray = [[self.userStreamArray objectAtIndex:indexPath.row] objectForKey:@"users"];
//        
//        __block CGFloat xPosForUserAvatar = 0.0f;
//        for (NSDictionary *userDict in userArray) {
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            if (![userDefaults boolForKey:kDontLoadImages]) {
//                
//                NSDictionary *avatarImageDictionary = [userDict objectForKey:@"avatar_image"];
//                dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
//                dispatch_async(imgDownloaderQueue, ^{
//                    NSString *avatarUrlString = [avatarImageDictionary objectForKey:@"url"];
//                    NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
//                    NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
//                    UIImage *avatarImage = [imageCache objectForKey:imageKey];
//                    if (!avatarImage) {
//                        avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
//                        if (avatarImage) {
//                            [imageCache setObject:avatarImage forKey:imageKey];
//                        }
//                    }
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        id asyncCell = [self.tableView cellForRowAtIndexPath:indexPath];
//                        if ([asyncCell isKindOfClass:([DHInteractionPostCell class])]) {
//                            UIImageView *imageView = [[UIImageView alloc] initWithImage:avatarImage];
//                            imageView.frame = CGRectMake(xPosForUserAvatar, 0.0f, 50.0f, 50.0f);
//                            [[asyncCell valueForKey:@"userScrollView"] addSubview:imageView];
//                            xPosForUserAvatar = xPosForUserAvatar+50.0f;
//                        }
//                    });
//                });
//            } else {
//                CGFloat blueFloat = (CGFloat)([interactionPostCell.userId integerValue]%100)/100.0f;
//                CGFloat greenFloat = (CGFloat)(([interactionPostCell.userId integerValue]/100)%100)/100.0f;
//                CGFloat redFloat = (CGFloat)(([interactionPostCell.userId integerValue]/10000)%100)/100.0f;
//                interactionPostCell.avatarImageView.backgroundColor = [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
//            }
// 
//        }
//        interactionPostCell.userScrollView.contentSize = CGSizeMake(xPosForUserAvatar, 50.0f);
        
        cell = interactionPostCell;
    } else {
        DHStartedFollowingCell *interactionPostCell = [tableView dequeueReusableCellWithIdentifier:@"StartedFollowingCell"];
        for (UIView *scrollViewSubview in interactionPostCell.userScrollView.subviews) {
            if ([scrollViewSubview isKindOfClass:([UIImageView class])] ||
                [scrollViewSubview isKindOfClass:([UILabel class])] ||
                scrollViewSubview.tag == 111) {
                [scrollViewSubview removeFromSuperview];
            }
        }
        interactionPostCell.actionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"started following you", nil)];
        [mutalbeAccessibilityLabel appendString:[NSString stringWithFormat:NSLocalizedString(@"The following users started following you: ", nil)]];
        
        cell = interactionPostCell;
    }
    
    NSArray *userArray = [[self.userStreamArray objectAtIndex:indexPath.row] objectForKey:@"users"];
    
    __block CGFloat xPosForUserAvatar = 0.0f;
//    for (NSDictionary *userDict in userArray) {
    for (int i = 0; i < [userArray count]; i++) {
        NSDictionary *userDict = [userArray objectAtIndex:i];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (![userDefaults boolForKey:kDontLoadImages]) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPosForUserAvatar, 0.0f, 100.0f, 100.0f)];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            [[cell valueForKey:@"userScrollView"] addSubview:imageView];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTouched:)];
            [imageView addGestureRecognizer:tapGestureRecognizer];
            
            UIView *userNameHostView = [[UIView alloc] initWithFrame:CGRectMake(xPosForUserAvatar, 80.0f, 100.0f, 20.0f)];
            userNameHostView.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f];
            userNameHostView.tag = 111;
            [[cell valueForKey:@"userScrollView"] addSubview:userNameHostView];
            
            UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 90.0f, 20.0f)];
            userNameLabel.text = [userDict objectForKey:@"username"];
            [mutalbeAccessibilityLabel appendFormat:@"%@ ", [userDict objectForKey:@"username"]];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//                userNameLabel.textColor = kDarkTextColor;
                userNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
            } else {
                userNameLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
            }
            userNameLabel.backgroundColor = [UIColor clearColor];
            userNameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            [userNameHostView addSubview:userNameLabel];
            
            xPosForUserAvatar = xPosForUserAvatar+100.0f;

            NSDictionary *avatarImageDictionary = [userDict objectForKey:@"avatar_image"];
            dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
            dispatch_async(imgDownloaderQueue, ^{
                NSString *avatarUrlString = [avatarImageDictionary objectForKey:@"url"];
//                CGFloat avatarWidth = [[avatarImageDictionary objectForKey:@"width"] floatValue];
                NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
                NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
                UIImage *avatarImage = [imageCache objectForKey:imageKey];
                if (!avatarImage) {
//                    avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
//                    avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:100.0f/avatarWidth];
//                    UIImage *dummyImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:100.0f/avatarWidth];
                    UIImage *dummyImage = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]] resizeImage:CGSizeMake(200.0f, 200.0f)];
                    avatarImage = [UIImage imageWithData:UIImageJPEGRepresentation(dummyImage, 0.2f)];
                    if (avatarImage) {
                        [imageCache setObject:avatarImage forKey:imageKey];
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
//                    id asyncCell = [self.tableView cellForRowAtIndexPath:indexPath];
//                    if ([asyncCell isKindOfClass:([DHInteractionPostCell class])]) {
//                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPosForUserAvatar, 0.0f, 100.0f, 100.0f)];
                        imageView.image = avatarImage;
//                        [[asyncCell valueForKey:@"userScrollView"] addSubview:imageView];
//                        xPosForUserAvatar = xPosForUserAvatar+100.0f;
//                    }
                });
            });
        } else {
            CGFloat blueFloat = (CGFloat)([[cell valueForKey:@"userId"] integerValue]%100)/100.0f;
            CGFloat greenFloat = (CGFloat)(([[cell valueForKey:@"userId"] integerValue]/100)%100)/100.0f;
            CGFloat redFloat = (CGFloat)(([[cell valueForKey:@"userId"] integerValue]/10000)%100)/100.0f;
            [[cell valueForKey:@"avatarImageView"] setBackgroundColor: [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f]];
        }
        
    }
    [[cell valueForKey:@"userScrollView"] setContentSize:CGSizeMake([userArray count]*100.0f, 100.0f)];
   
    [[cell valueForKey:@"actionLabel"] setValue:mutalbeAccessibilityLabel forKey:@"accessibilityLabel"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UIColor *cellBackgroundColor;
//    if (indexPath.row % 2 == 0) {
//        if ([userDefaults boolForKey:kDarkMode]) {
//            cellBackgroundColor = kDarkCellBackgroundColorMarked;
//        } else {
//            cellBackgroundColor = kLightCellBackgroundColorMarked;
//        }
//    } else {
        if ([userDefaults boolForKey:kDarkMode]) {
//            cellBackgroundColor = kDarkCellBackgroundColorDefault;
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        } else {
            cellBackgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        }
//    }
    
//    [[cell valueForKey:@"contentView"] setBackgroundColor:cellBackgroundColor];
//    [[cell valueForKey:@"userScrollView"] setBackgroundColor:cellBackgroundColor];
    
    [[cell valueForKey:@"actionLabel"] setBackgroundColor:cellBackgroundColor];
    if ([userDefaults boolForKey:kDarkMode]) {
//        [[cell valueForKey:@"actionLabel"] setTextColor:kDarkTextColor];
        [[cell valueForKey:@"actionLabel"] setTextColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
    } else {
        [[cell valueForKey:@"actionLabel"] setTextColor:[DHGlobalObjects sharedGlobalObjects].textColor];
    }
//
//    if (![actionString isEqualToString:@"follow"]) {
//        [[cell valueForKey:@"clientLabel"] setBackgroundColor:cellBackgroundColor];
//        [[cell valueForKey:@"nameLabel"] setBackgroundColor:cellBackgroundColor];
//        [[cell valueForKey:@"dateLabel"] setBackgroundColor:cellBackgroundColor];
//        [[cell valueForKey:@"postTextView"] setBackgroundColor:cellBackgroundColor];
//        if ([userDefaults boolForKey:kDarkMode]) {
//            [[cell valueForKey:@"nameLabel"] setTextColor:kDarkTextColor];
//            [[cell valueForKey:@"postTextView"] setTextColor:kDarkTextColor];
//        } else {
//            [[cell valueForKey:@"nameLabel"] setTextColor:kLightTextColor];
//            [[cell valueForKey:@"postTextView"] setTextColor:kLightTextColor];
//        }
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *actionString = [[self.userStreamArray objectAtIndex:indexPath.row] objectForKey:@"action"];
    
    if (![actionString isEqualToString:@"follow"]) {
//        if ([actionString isEqualToString:@"reply"]) {
//            return 0.0f;
//        }
        NSDictionary *postDict = [[[self.userStreamArray objectAtIndex:indexPath.row] objectForKey:@"objects"] objectAtIndex:0];
        CGFloat heightForText = [self heightForPostDict:postDict withAnnotationDict:nil isRepost:YES];
        return heightForText+150.0f;
    } else {
        return 150.0f;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    return;
}

- (void)avatarImageTouched:(UITapGestureRecognizer*)sender {
    CGPoint buttonOrigin = [self.tableView convertPoint:sender.view.frame.origin fromView:sender.view.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOrigin];
    
    NSArray *userArray = [[self.userStreamArray objectAtIndex:indexPath.row] objectForKey:@"users"];
    NSDictionary *userDict = [userArray objectAtIndex:sender.view.tag];
    dhDebug(@"userId: %@", [userDict objectForKey:@"id"]);
    [self performSegueWithIdentifier:@"ShowProfile" sender:[userDict objectForKey:@"id"]];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        DHProfileTableViewController *profileTableViewController = segue.destinationViewController;
        profileTableViewController.userId = (NSString*)sender;
        profileTableViewController.hidesBottomBarWhenPushed = YES;
    }
}

@end
