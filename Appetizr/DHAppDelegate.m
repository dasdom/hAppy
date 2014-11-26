//
//  DHAppDelegate.m
//  Appetizr
//
//  Created by dasdom on 12.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHAppDelegate.h"
#import "PRPAlertView.h"
//#import "DHGlobalObjects.h"
//#import "DHUtils.h"
//#import "DHCreateStatusViewController.h"
#import "DHUserStreamTableViewController.h"
#import "SplitMasterViewController.h"
#import "DHSplitViewController.h"
#import "DHNavigationController.h"
#import "DHURLHelper.h"
#import "StoreObserver.h"
#import "SSKeychain.h"
#import "DHKeys.h"
#import <Crashlytics/Crashlytics.h>

@interface DHAppDelegate ()
@property (nonatomic, strong) NSString *returnURLString;
@property (nonatomic, strong) DHUserStreamTableViewController *userStreamTableViewController;
@property (nonatomic, strong) StoreObserver *observer;
@end

@implementation DHAppDelegate

- (void)costomizeAppearance {
    
    [[UINavigationBar appearance] setTintColor:kDarkMainColor];
    
    [[UITabBar appearance] setTintColor:kDarkMainColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: kDarkMainColor, NSFontAttributeName: [UIFont fontWithName:@"Avenir-Book" size:10.0f]} forState:UIControlStateNormal];
    [[UITabBar appearance] setTintColor: [UIColor yellowColor]];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBarSelectionShadow"]];
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage imageNamed:@"tabBarSelectionShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) resizingMode:UIImageResizingModeStretch]];
    
    [[UIToolbar appearance] setTintColor:kDarkMainColor];
    
    [[UISearchBar appearance] setTintColor:kDarkMainColor];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            [PRPAlertView showWithTitle:NSLocalizedString(@"No Internet", nil) message:NSLocalizedString(@"You don't have connection to the internet.", nil) buttonTitle:@"OK"];
            break;
        }
        case ReachableViaWWAN:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kOnlyLoadImagesInWifi]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDontLoadImages];
            }
            break;
        }
        case ReachableViaWiFi:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kOnlyLoadImagesInWifi]) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDontLoadImages];
            }
            break;
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsChangedNotification object:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
    
    ADNLogin *adn = [ADNLogin sharedInstance];
    adn.delegate = self;
    adn.scopes = @[@"stream", @"write_post", @"follow", @"messages", @"email", @"update_profile", @"files"];
    
//    [Crashlytics startWithAPIKey:kCrashlyticsKey];
    
    _observer = [[StoreObserver alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:_observer];
    
    [self costomizeAppearance];
    _avatarCache = [[NSCache alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"wasStartedBefore"]) {
        [userDefaults setBool:YES forKey:@"wasStartedBefore"];
        [userDefaults setObject:@"HelveticaNeue" forKey:kFontName];
        [userDefaults setObject:@"15" forKey:kFontSize];
        [userDefaults setBool:NO forKey:kIncludeDirecedPosts];
        [userDefaults synchronize];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *avatarDirectoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatars"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:avatarDirectoryPath]) {
        [fileManager createDirectoryAtPath:avatarDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    _internetReach = [Reachability reachabilityForInternetConnection];
	[_internetReach startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                
        SplitMasterViewController *splitMasterViewController = [[SplitMasterViewController alloc] init];
        DHNavigationController *splitMasterNavigationController = [[DHNavigationController alloc] initWithRootViewController:splitMasterViewController];
        
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//        DHUserStreamTableViewController *userStreamTableViewController = [storyBoard instantiateViewControllerWithIdentifier:@"StreamViewController"];
        DHNavigationController *userStreamNavigationController = [[DHNavigationController alloc] initWithRootViewController:splitMasterViewController.userStreamTableViewController];

    _userStreamTableViewController = splitMasterViewController.userStreamTableViewController;
    
    if ([application respondsToSelector:@selector(setMinimumBackgroundFetchInterval:)]) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
        splitMasterViewController.detailViewController = userStreamNavigationController;
        DHSplitViewController *splitViewController = [[DHSplitViewController alloc] initWithViewControllers:@[splitMasterNavigationController, userStreamNavigationController]];
        
        self.window.rootViewController = splitViewController;
        [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    NSString *absoluteString = [url absoluteString];
    NSString *queryString = [url query];
    NSDictionary *parameterDictionary = [DHURLHelper parameterDictionaryForQuery:queryString];
    dhDebug(@"parameterDictionary: %@", parameterDictionary);
    
    self.returnURLString = [parameterDictionary objectForKey:@"returnURLScheme"];
    
    DHSplitViewController *splitViewController = (DHSplitViewController*)self.window.rootViewController;
    if ([absoluteString hasPrefix:@"happy://create"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *createPostViewController = [storyBoard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
        [createPostViewController setValue:[parameterDictionary objectForKey:@"text"] forKey:@"draftText"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:createPostViewController];
        [self.window.rootViewController presentViewController:navigationController animated:NO completion:^{}];
    } else if ([absoluteString hasPrefix:@"happy://stream"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 0;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_UNIVERSAL];
    } else if ([absoluteString hasPrefix:@"happy://explore"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 2;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_GLOBAL];
    } else if ([absoluteString hasPrefix:@"happy://mentions"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 1;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_MENTIONS];
    } else if ([absoluteString hasPrefix:@"happy://messages"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 3;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_MESSAGES];
    } else if ([absoluteString hasPrefix:@"happy://post"]) {
        if (parameterDictionary) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *conversationViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
            [conversationViewController setValue:[parameterDictionary objectForKey:@"postId"] forKey:@"postId"];
            
            UINavigationController *conversationNavigationController = [[UINavigationController alloc] initWithRootViewController:conversationViewController];
            
            [self.window.rootViewController presentViewController:conversationNavigationController animated:NO completion:^{}];
        }
    }  else if ([absoluteString hasPrefix:@"happy://profile"]) {
        if (parameterDictionary) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *profileViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHProfileTableViewController"];
            [profileViewController setValue:[parameterDictionary objectForKey:@"userId"] forKey:@"userId"];
            
            UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
            
            [self.window.rootViewController presentViewController:profileNavigationController animated:NO completion:^{}];
        }
    }
    
    return YES;
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSString *absoluteString = [url absoluteString];
    NSString *queryString = [url query];
    NSDictionary *parameterDictionary = [DHURLHelper parameterDictionaryForQuery:queryString];
    dhDebug(@"parameterDictionary: %@", parameterDictionary);
    
    self.returnURLString = [parameterDictionary objectForKey:@"returnURLScheme"];
    
    DHSplitViewController *splitViewController = (DHSplitViewController*)self.window.rootViewController;
    if ([absoluteString hasPrefix:@"happy://create"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *createPostViewController = [storyBoard instantiateViewControllerWithIdentifier:@"CreatePostViewController"];
        [createPostViewController setValue:[parameterDictionary objectForKey:@"text"] forKey:@"draftText"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:createPostViewController];
        [self.window.rootViewController presentViewController:navigationController animated:NO completion:^{}];
    } else if ([absoluteString hasPrefix:@"happy://stream"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 0;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_UNIVERSAL];
    } else if ([absoluteString hasPrefix:@"happy://explore"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 2;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_GLOBAL];
    } else if ([absoluteString hasPrefix:@"happy://mentions"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 1;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_MENTIONS];
    } else if ([absoluteString hasPrefix:@"happy://messages"]) {
        //            UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        //            tabBarController.selectedIndex = 3;
        [[((UINavigationController*)[splitViewController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0] selectButtonWithTag:BUTTON_TAG_MESSAGES];
    } else if ([absoluteString hasPrefix:@"happy://post"]) {
        if (parameterDictionary) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *conversationViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
            [conversationViewController setValue:[parameterDictionary objectForKey:@"postId"] forKey:@"postId"];
            
            UINavigationController *conversationNavigationController = [[UINavigationController alloc] initWithRootViewController:conversationViewController];
            
            [self.window.rootViewController presentViewController:conversationNavigationController animated:NO completion:^{}];
        }
    }  else if ([absoluteString hasPrefix:@"happy://profile"]) {
        if (parameterDictionary) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *profileViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHProfileTableViewController"];
            [profileViewController setValue:[parameterDictionary objectForKey:@"userId"] forKey:@"userId"];
            
            UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
            
            [self.window.rootViewController presentViewController:profileNavigationController animated:NO completion:^{}];
        }
    } else {
        return [[ADNLogin sharedInstance] openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return YES;
}

- (void)adnLoginDidSucceedForUserWithID:(NSString *)userID username:(NSString *)username token:(NSString *)accessToken {
    if (accessToken) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:kAccessTokenDefaultsKey];
        [userDefaults synchronize];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@?access_token=%@", kBaseURL, kUsersSubURL, kMeSubURL, accessToken];
        PRPConnection *dhConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlString] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithURL:[NSURL URLWithString:urlString] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
            //                NSLog(@"connection.responseDictionary: %@", connection.responseDictionary);
            NSError *jsonError;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:connection.downloadData options:kNilOptions error:&jsonError];
            dhDebug(@"responseDict: %@", responseDict);
            NSString *userName = [[responseDict objectForKey:@"data"] objectForKey:@"username"];
            
            [SSKeychain setPassword:accessToken forService:@"de.dasdom.happy" account:userName];
            
            NSArray *userArray = [userDefaults objectForKey:kUserArrayKey];
            
            if ((userArray && [userArray count] < 1) || ![userArray containsObject:userName]) {
                
//                [SSKeychain setPassword:userName forService:@"de.dasdom.happy" account:kUserNameDefaultKey];
//                dispatch_async(dispatch_get_main_queue(), ^{
                [userDefaults setObject:userName forKey:kUserNameDefaultKey];

                NSMutableArray *mutableUserArray;
                if (!userArray || [userArray count] < 1) {
                    mutableUserArray = [NSMutableArray array];
                } else {
                    mutableUserArray = [userArray mutableCopy];
                }
                
                [mutableUserArray addObject:userName];
                [userDefaults setObject:mutableUserArray forKey:kUserArrayKey];
                
//                NSMutableDictionary *userDefaultsDictionaryForCurrentUser = [NSMutableDictionary dictionary];
//                [userDefaultsDictionaryForCurrentUser setObject:@"15.0f" forKey:kFontSize];
//                [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kIncludeDirecedPosts];
//                [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kDontLoadImages];
//                [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kDarkMode];
//                [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:YES] forKey:kStreamMarker];
//                [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kHideSeenThreads];
//                [userDefaultsDictionaryForCurrentUser setObject:@"Avenir-Book" forKey:kFontName];
//                
//                [userDefaults setObject:userDefaultsDictionaryForCurrentUser forKey:userName];
//                
//                [userDefaults setBool:NO forKey:kIncludeDirecedPosts];
//                [userDefaults setBool:NO forKey:kDontLoadImages];
//                [userDefaults setBool:NO forKey:kDarkMode];
//                [userDefaults setBool:YES forKey:kStreamMarker];
//                [userDefaults setBool:NO forKey:kHideSeenThreads];
//                [userDefaults setObject:@"15.0f" forKey:kFontSize];
//                [userDefaults setObject:@"Avenir-Book" forKey:kFontName];
                
                BOOL success = [userDefaults synchronize];
                NSAssert(success, @"something went wrong");
                
//                NSDictionary *userdefaultsDict = [NSUserDefaults standardUserDefaults].dictionaryRepresentation;
//                dhDebug(@"userdefaultsDict: %@", userdefaultsDict);

                dhDebug(@"userdefaults object for key kUserNameDefaultKey: %@", [userDefaults stringForKey:kUserNameDefaultKey]);
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoginHappendNotification object:self];
//                });
            }
        }];
        [dhConnection start];
    }
}

- (void)adnLoginDidFailWithError:(NSError *)error {
    dhDebug(@"falied with error: %@", error);
}

- (void)returnToCaller {
    NSURL *returnURL = [NSURL URLWithString:self.returnURLString];
    if ([[UIApplication sharedApplication] canOpenURL:returnURL]) {
        [[UIApplication sharedApplication] openURL:returnURL];
    }
    
    self.returnURLString = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [_userStreamTableViewController updateMarker];
    [_userStreamTableViewController saveContentOffsetY];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[DHGlobalObjects sharedGlobalObjects] archiveUserNames];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[DHGlobalObjects sharedGlobalObjects] unarchiveUserNames];
    [_userStreamTableViewController changeThemeModeIfNeeded];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [_userStreamTableViewController loadStreamArray];
    [_userStreamTableViewController loadNewPostsWithCompletionHandler:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    dhDebug(@"will terminate");
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [_userStreamTableViewController loadStreamArray];
    [_userStreamTableViewController loadNewPostsWithCompletionHandler:^(BOOL newData) {
        if (newData) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
}

@end
