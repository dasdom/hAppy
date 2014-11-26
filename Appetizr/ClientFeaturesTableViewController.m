//
//  ClientFeaturesTableViewController.m
//  Appetizr
//
//  Created by dasdom on 21.04.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "ClientFeaturesTableViewController.h"
#import "PRPConnection.h"
#import "ClientsTableViewController.h"
#import "PRPAlertView.h"

@interface ClientFeaturesTableViewController ()
@property (nonatomic, strong) NSArray *clientFeatureArray;
@property (nonatomic, strong) NSArray *featureNames;
@property (nonatomic, strong) NSDictionary *featureNamesDict;

@property (nonatomic, strong) NSMutableSet *mutableFeatureSet;

@property (nonatomic, strong) NSArray *filteredClientFeatureArray;
@end

@implementation ClientFeaturesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController setToolbarHidden:NO];
    
    NSString *urlString = [NSString stringWithFormat:@"http://adncc.nigma.de/hAppy.php"];
//    NSString *urlString = [NSString stringWithFormat:@"http://adn-client-comparison.nigma.de/pull.php"];

    
    NSMutableURLRequest *filesRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [filesRequest setHTTPMethod:@"GET"];
    [filesRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    __weak ClientFeaturesTableViewController *weakSelf = self;
    PRPConnection *filesConnection = [PRPConnection connectionWithRequest:filesRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:filesRequest progress:^(DHConnection *connection){} completion:^(DHConnection *connection, NSError *error) {
    
        NSArray *array = [connection arrayFromDownloadedData];
        
        dhDebug(@"downloadData: %@", [[NSString alloc] initWithData:connection.downloadData encoding:NSUTF8StringEncoding]);
        dhDebug(@"*****************************************************");
//        NSMutableArray *mutableArray = [NSMutableArray array];
//        for (NSDictionary *clientDict in array) {
//            if ([[clientDict objectForKey:@"platform"] rangeOfString:@"iPhone"].location != NSNotFound) {
//                [mutableArray addObject:clientDict];
//            }
//        }
        weakSelf.clientFeatureArray = [array copy];
        
        NSMutableSet *featureNamesSet = [NSMutableSet set];
        for (NSDictionary *featuresDictionary in weakSelf.clientFeatureArray) {
            [featureNamesSet addObjectsFromArray:[featuresDictionary allKeys]];
        }
        [featureNamesSet removeObject:@"name"];
        self.featureNames = [[featureNamesSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
        
//        self.featureNames = @[@"known_active_development", @"multiple_accounts", @"global_stream", @"unified_stream", @"filter_stream_by_language", @"private_messages", @"public_patter_rooms", @"private_patter_rooms", @"browse_patter_rooms", @"open_patter_room_by_url", @"show_mentions_to_people_i_dont_follow", @"show_starred_posts", @"interactions_view", @"push_notifications", @"drafts", @"outbox", @"username_completion", @"hashtag_completion", @"user_search", @"hashtag_search", @"save_hashtag_search", @"keyword_search", @"search_own_stream", @"block_user", @"report_post", @"hard_mute_user", @"soft_mute_user", @"mute_hashtag", @"mute_thread", @"mute_keyword", @"mute_client", @"hide_posts_seen_in_conversations", @"edit_profile", @"accessible", @"language_annotations", @"light_theme", @"dark_theme", @"stream_marker_support", @"inline_media", @"inline_media_in_private_messages", @"creation_of_inline_links", @"file_api_integration", @"picture_services_integration", @"video_services_integration", @"read_later_services_integration", @"post_current_location", @"places_api", @"now_playing", @"url_shortening", @"full_screen_mode", @"open_links_from_stream_view", @"save_conversations", @"configurable_fonts", @"twitter_crossposting", @"facebook_crossposting", @"buffer_integration", @"show_twitter_timeline", @"display_multiple_streams_at_once", @"landscape_view_of_streams", @"landscape_compose", @"text_expander_support", @"1password_integration", @"url_schemes"];
        
        NSString *urlString = [NSString stringWithFormat:@"http://adncc.nigma.de/hAppy-dictionary.php"];
                
        NSMutableURLRequest *filesRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [filesRequest setHTTPMethod:@"GET"];
        [filesRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        
        PRPConnection *dictConnection = [PRPConnection connectionWithRequest:filesRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:filesRequest progress:^(DHConnection *connection){} completion:^(DHConnection *connection, NSError *error) {
        
            dhDebug(@"downloadData: %@", [[NSString alloc] initWithData:connection.downloadData encoding:NSUTF8StringEncoding]);

            NSDictionary *rawDict = [connection dictionaryFromDownloadedData];
            NSMutableDictionary *mutableFeatureNamesDictionary = [NSMutableDictionary dictionary];
            for (NSString *keyString in [rawDict allKeys]) {
                [mutableFeatureNamesDictionary setObject:keyString forKey:[rawDict objectForKey:keyString]];
            }
            self.featureNamesDict = [mutableFeatureNamesDictionary copy];
            
            [weakSelf.tableView reloadData];
        }];
        [dictConnection start];
        
    }];
    [filesConnection start];
    
    self.mutableFeatureSet = [NSMutableSet set];
    
    self.title = NSLocalizedString(@"features", nil);
    
    [PRPAlertView showWithTitle:NSLocalizedString(@"Features", nil) message:NSLocalizedString(@"Select the features you would like to see in the client of your dreams and let me show you the clients with these features.", nil) buttonTitle:@"OK"];

}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    [DHAlertView showWithTitle:NSLocalizedString(@"Features", nil) message:NSLocalizedString(@"Select the features you would like to see in the client of your dreams and let me show you the clients with these features.", nil) buttonTitle:@"OK"];
//}

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
    return [self.featureNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *featureKey = [self.featureNames objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.featureNamesDict objectForKey:featureKey];
    if ([self.mutableFeatureSet containsObject:featureKey]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *featureKey = [self.featureNames objectAtIndex:indexPath.row];
    if ([self.mutableFeatureSet containsObject:featureKey]) {
        [self.mutableFeatureSet removeObject:featureKey];
    } else {
        [self.mutableFeatureSet addObject:featureKey];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSMutableArray *mutableClientArray = [self.clientFeatureArray mutableCopy];
    for (NSString *keyString in [self.mutableFeatureSet allObjects]) {
        for (NSDictionary *clientDict in self.clientFeatureArray) {
//            if ([[clientDict objectForKey:keyString] rangeOfString:@"NO"].location != NSNotFound) {
//                [mutableClientArray removeObject:clientDict];
//            }
            if (![[[clientDict objectForKey:keyString] capitalizedString] boolValue]) {
                [mutableClientArray removeObject:clientDict];
            }
        }
    }
    self.filteredClientFeatureArray = [mutableClientArray copy];
    
    dhDebug(@"self.filteredClientFeatureArray.count: %d", self.filteredClientFeatureArray.count);
    
    NSString *buttonTitle = [NSString stringWithFormat:@"show the %d clients", [self.filteredClientFeatureArray count]];
    UIBarButtonItem *showClientsBarButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(showClients:)];
    
    UIBarButtonItem *spaceBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[spaceBarButton, showClientsBarButton];
}

- (void)showClients:(UIBarButtonItem*)sender {
    ClientsTableViewController *clientsTableViewController = [[ClientsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    clientsTableViewController.clientsArray = self.filteredClientFeatureArray;
    [self.navigationController pushViewController:clientsTableViewController animated:YES];
}

@end
