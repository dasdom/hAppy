//
//  DHSearchViewController.m
//  Appetizr
//
//  Created by dasdom on 12.11.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHSearchViewController.h"
#import "DHSearchFieldHostView.h"
#import "PRPConnection.h"
#import "DHSearchResultCell.h"
#import "PRPAlertView.h"
#import "DHCreateStatusViewController.h"
#import "SSKeychain.h"
#import "ImageHelper.h"

@interface DHSearchViewController ()
@property (nonatomic, strong) NSArray *searchResultArray;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentedControl;
@end

@implementation DHSearchViewController

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

//    self.view.backgroundColor = kMainColor;
    
    _imageCache = [[NSCache alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        [self.navigationController.navigationBar setTintColor:kDarkMainColor];
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
        }
        else
        {
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].darkMainColor];
        }
    } else {
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            [self.navigationController.navigationBar setBarTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].textColor];
        }
        else
        {
            [self.navigationController.navigationBar setTintColor:[DHGlobalObjects sharedGlobalObjects].mainColor];
        }
    }
    
    if ([self.presentingViewController isKindOfClass:([DHCreateStatusViewController class])]) {
        self.title = NSLocalizedString(@"search consignee", nil);
    }
    
//    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
    [menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 30.0f);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;
    self.searchSegmentedControl.selectedSegmentIndex = 1;
    if (self.hideSegmentedControl) {
        self.searchSegmentedControl.alpha = 0.0f;
    }
    
    if ([self.navigationController.viewControllers count] < 2) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTouched:)];
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DHSearchFieldHostView *searchFieldHostView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SearchFieldCell" forIndexPath:indexPath];
    self.searchBar = searchFieldHostView.searchBar;
    [self.searchBar becomeFirstResponder];
    return searchFieldHostView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.searchResultArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DHSearchResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        cell.backgroundColor = kDarkMainColor;
        cell.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
    } else {
        cell.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
    }
    NSDictionary *userDict = [self.searchResultArray objectAtIndex:indexPath.row];
    
    cell.userNameLabel.text = [NSString stringWithFormat:@"@%@", [userDict objectForKey:@"username"]];
    
    NSDictionary *descriptionDictionary = [userDict objectForKey:@"description"];
    NSString *postText = [DHUtils stringOrEmpty:[descriptionDictionary objectForKey:@"text"]];
    cell.descriptionLabel.text = postText;
    cell.descriptionLabel.font = kProfileDescriptionFont;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        cell.descriptionLabel.textColor = kDarkTextColor;
        cell.descriptionLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
    } else {
        cell.descriptionLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    cell.descriptionLabel.font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
    
    if ([[userDict objectForKey:@"you_follow"] boolValue]) {
        cell.iFollowBannerImageView.alpha = 1.0f;
    } else {
        cell.iFollowBannerImageView.alpha = 0.0f;
    }
    
    cell.avatarImageView.image = nil;
    dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("imageDownloader", NULL);
    dispatch_async(imgDownloaderQueue, ^{
        NSDictionary *avatartImageDictionary = [userDict objectForKey:@"avatar_image"];
        NSString *avatarUrlString = [avatartImageDictionary objectForKey:@"url"];
        NSString *imageKey = [[avatarUrlString componentsSeparatedByString:@"/"] lastObject];
        UIImage *avatarImage = [self.imageCache objectForKey:imageKey];
        if (!avatarImage) {
            avatarImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
            if (avatarImage) {
                [self.imageCache setObject:avatarImage forKey:imageKey];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            DHSearchResultCell *asyncCell = (DHSearchResultCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            asyncCell.avatarImageView.image = avatarImage;
        });
    });
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if ([searchBar.text isEqualToString:@""]) {
        return;
    }
    
    NSMutableString *mutableUrlString = [NSMutableString stringWithFormat:@"%@%@/search", kBaseURL, kUsersSubURL];
    [mutableUrlString appendFormat:@"?q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
     NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@&access_token=%@", mutableUrlString, accessToken];
    PRPConnection *dhConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithURL:[NSURL URLWithString:urlStringWithAccessToken] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
    
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
        if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
            return;
        }
        
        id resultArray = [responseDict objectForKey:@"data"];
        if (![resultArray isKindOfClass:[NSArray class]]) {
//            NSLog(@"resultArray is not an array");
            return;
        }
        
        self.searchResultArray = resultArray;
        [self.collectionView reloadData];
        dhDebug(@"self.searchResultArray: %@", self.searchResultArray);
    
    }];
    [dhConnection start];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userDict = [self.searchResultArray objectAtIndex:indexPath.row];
    if ([self.presentingViewController isKindOfClass:([DHCreateStatusViewController class])]) {
//        [(DHCreateStatusViewController*)self.presentingViewController setConsigneeString:[userDict objectForKey:@"username"]];
        DHCreateStatusViewController *createStatusViewController = (DHCreateStatusViewController*)self.presentingViewController;
        [createStatusViewController addConsignee:[userDict objectForKey:@"username"]];
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
            [createStatusViewController viewWillAppear:YES];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                [createStatusViewController viewDidAppear:YES];
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"ShowProfile" sender:[userDict objectForKey:@"id"]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        [segue.destinationViewController setValue:sender forKey:@"userId"];
    }
}

- (IBAction)cancelButtonTouched:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)segmentedControlChanged:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)menuButtonTouched:(UIBarButtonItem*)sender {
    [self.searchBar resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuTouchedNotification object:self];
}

@end
