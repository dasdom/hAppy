//
//  UserTableViewController.m
//  Appetizr
//
//  Created by dasdom on 09.02.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "UserTableViewController.h"
#import "AuthenticationViewController.h"

@interface UserTableViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation UserTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _dataSource = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUser:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dataSource = [[NSUserDefaults standardUserDefaults] objectForKey:kUserArrayKey];
    dhDebug(@"self.dataSource: %@", self.dataSource);
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *userName = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = userName;
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey] isEqualToString:userName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *userName = [self.dataSource objectAtIndex:indexPath.row];
//    
//    if ([[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey] isEqualToString:userName]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not possible", nil) message:NSLocalizedString(@"You only can delete accounts which are not logged-in.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [alertView show];
//        return NO;
//    } else {
        return YES;
//    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *userName = [self.dataSource objectAtIndex:indexPath.row];
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey] isEqualToString:userName]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not possible", nil) message:NSLocalizedString(@"You only can delete accounts which are not logged-in.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            return;
        }
        
        NSMutableArray *mutableDataSource = [self.dataSource mutableCopy];
        [mutableDataSource removeObjectAtIndex:indexPath.row];
        self.dataSource = [mutableDataSource copy];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.dataSource forKey:kUserArrayKey];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userName = [self.dataSource objectAtIndex:indexPath.row];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaultsDictionary = [userDefaults objectForKey:userName];
    
    dhDebug(@"userDefaultsDictionary: %@", userDefaultsDictionary);
    
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kIncludeDirecedPosts] boolValue] forKey:kIncludeDirecedPosts];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kDontLoadImages] boolValue] forKey:kDontLoadImages];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kOnlyLoadImagesInWifi] boolValue] forKey:kOnlyLoadImagesInWifi];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kShowRealNames] boolValue] forKey:kShowRealNames];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kDarkMode] boolValue] forKey:kDarkMode];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kStreamMarker] boolValue] forKey:kStreamMarker];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kNormalKeyboard] boolValue] forKey:kNormalKeyboard];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kAboluteTimeStamp] boolValue] forKey:kAboluteTimeStamp];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kIgnoreUnreadPatter] boolValue] forKey:kIgnoreUnreadPatter];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kHideSeenThreads] boolValue] forKey:kHideSeenThreads];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kHideClient] boolValue] forKey:kHideClient];
    [userDefaults setBool:[[userDefaultsDictionary objectForKey:kInlineImages] boolValue] forKey:kInlineImages];
    [userDefaults setObject:[userDefaultsDictionary objectForKey:kFontSize] forKey:kFontSize];
    [userDefaults setObject:[userDefaultsDictionary objectForKey:kFontName] forKey:kFontName];
//    [userDefaults setObject:[userDefaultsDictionary objectForKey:kAccessTokenDefaultsKey] forKey:kAccessTokenDefaultsKey];
    [userDefaults setObject:userName forKey:kUserNameDefaultKey];
    
    [userDefaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addUser:(UIBarButtonItem*)sender {
    AuthenticationViewController *authViewController = [[AuthenticationViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

@end
