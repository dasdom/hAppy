//
//  LanguagesTableViewController.m
//  Appetizr
//
//  Created by dasdom on 13.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "LanguagesTableViewController.h"

@interface LanguagesTableViewController ()
@property (nonatomic, strong) NSArray *mainLanguages;
@property (nonatomic, strong) NSArray *otherLanguagesArray;
@property (nonatomic, strong) NSMutableSet *mutableLanguagesSet;
@property (nonatomic, strong) UISegmentedControl *globalSegmentedControl;
@property (nonatomic, assign) NSInteger previouslySelectedIndex;
@end

@implementation LanguagesTableViewController

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
    
    self.mainLanguages = @[@"de",@"en",@"es",@"fr",@"it"];
    self.otherLanguagesArray = @[@"ar",@"az",@"bg",@"bn",@"bs",@"ca",
                                    @"cs",@"cy",@"da",@"el",
                                    @"et",@"eu",@"fa",@"fi",
                                    @"ga",@"gl",@"he",@"hi",@"hr",@"hu",
                                    @"id",@"is",@"ja",@"ka",@"kk",
                                    @"km",@"kn",@"ko",@"lt",@"lv",@"mk",
                                    @"ml",@"mn",@"nb",@"ne",@"nl",@"nn",
                                    @"no",@"pa",@"pl",@"pt",@"ro",
                                    @"ru",@"sk",@"sl",@"sq",@"sr",
                                    @"sv",@"sw",@"ta",@"te",@"th",@"tr",
                                    @"tt",@"uk",@"ur",@"vi",@"zh_CN",@"zh_TW"];
    
//    self.title = NSLocalizedString(@"language filter", nil);
    
    _globalSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Stream", @"Global"]];
    _globalSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_globalSegmentedControl addTarget:self action:@selector(segementedControlChanged:) forControlEvents:UIControlEventValueChanged];
    _globalSegmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = _globalSegmentedControl;

    [self configureLanguagesSet];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    _globalSegmentedControl.selectedSegmentIndex = 0;
//}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveArrayWithIndex:_globalSegmentedControl.selectedSegmentIndex];
}

- (void)saveArrayWithIndex:(NSInteger)index {
    NSArray *languageArray;
    if ([self.mutableLanguagesSet count] > 0) {
        languageArray = [self.mutableLanguagesSet allObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangedNotification object:self];
    } else {
        languageArray = @[@"all"];
    }
    dhDebug(@"languageArray: %@", languageArray);
    NSString *arrayQualifierString;
    if (index == 0) {
        arrayQualifierString = @"Stream";
    } else {
        arrayQualifierString = @"Global";
    }
    NSString *languagesKeyString = [NSString stringWithFormat:@"languagesArray_%@", arrayQualifierString];
    [[NSUserDefaults standardUserDefaults] setObject:languageArray forKey:languagesKeyString];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 1;
            break;
        case 1:
            numberOfRows = 1;
            break;
        case 2:
            numberOfRows = [self.mainLanguages count];
            break;
        case 3:
            numberOfRows = [self.otherLanguagesArray count];
            break;
        default:
            numberOfRows = 0;
            break;
    }
    return numberOfRows;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"w/o", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"main languages", nil);
    } else if (section == 3) {
        return NSLocalizedString(@"other languages", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"all", nil);
            if ([self.mutableLanguagesSet count] == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
//            [self setupColorForCell:cell];
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"without language annotation", nil);
            if ([self.mutableLanguagesSet containsObject:@"w/o"]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 2:
        {
            NSString *languageShortString = [self.mainLanguages objectAtIndex:indexPath.row];
            cell.textLabel.text = NSLocalizedString(languageShortString, nil);
            if ([self.mutableLanguagesSet containsObject:languageShortString]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
        case 3:
        {
            NSString *languageShortString = [self.otherLanguagesArray objectAtIndex:indexPath.row];
            cell.textLabel.text = NSLocalizedString(languageShortString, nil);
            if ([self.mutableLanguagesSet containsObject:languageShortString]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

//- (void)setupColorForCell:(UITableViewCell*)cell {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        cell.accessoryView.backgroundColor = kDarkCellBackgroundColorDefault;
//        cell.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//        cell.textLabel.textColor = kDarkTextColor;
//        cell.textLabel.backgroundColor = kDarkCellBackgroundColorDefault;
//        cell.detailTextLabel.textColor = kDarkTextColor;
//        cell.detailTextLabel.backgroundColor = kDarkCellBackgroundColorDefault;
//    } else {
//        cell.accessoryView.backgroundColor = kLightCellBackgroundColorDefault;
//        cell.contentView.backgroundColor = kLightCellBackgroundColorDefault;
//        cell.backgroundColor = kLightCellBackgroundColorDefault;
//        cell.textLabel.textColor = kLightTextColor;
//        cell.textLabel.backgroundColor = kLightCellBackgroundColorDefault;
//        cell.detailTextLabel.textColor = kLightTextColor;
//        cell.detailTextLabel.backgroundColor = kLightCellBackgroundColorDefault;
//    }
//}

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
    if (indexPath.section == 0) {
        self.mutableLanguagesSet = [NSMutableSet set];
    } else if (indexPath.section == 1) {
        NSString *languageShortString = @"w/o";
        if ([self.mutableLanguagesSet containsObject:languageShortString]) {
            [self.mutableLanguagesSet removeObject:languageShortString];
        } else {
            [self.mutableLanguagesSet addObject:languageShortString];
        }
    } else if (indexPath.section == 2) {
        NSString *languageShortString = [self.mainLanguages objectAtIndex:indexPath.row];
        if ([self.mutableLanguagesSet containsObject:languageShortString]) {
            [self.mutableLanguagesSet removeObject:languageShortString];
        } else {
            [self.mutableLanguagesSet addObject:languageShortString];
        }
    }  else if (indexPath.section == 3) {
        NSString *languageShortString = [self.otherLanguagesArray objectAtIndex:indexPath.row];
        if ([self.mutableLanguagesSet containsObject:languageShortString]) {
            [self.mutableLanguagesSet removeObject:languageShortString];
        } else {
            [self.mutableLanguagesSet addObject:languageShortString];
        }
    }
    [self.tableView reloadData];
}

- (void)configureLanguagesSet {
    NSString *arrayQualifierString;
    if (_globalSegmentedControl.selectedSegmentIndex == 0) {
        arrayQualifierString = @"Stream";
    } else {
        arrayQualifierString = @"Global";
    }
    NSString *languagesKeyString = [NSString stringWithFormat:@"languagesArray_%@", arrayQualifierString];
    NSArray *storedLanguagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:languagesKeyString];
    if ([storedLanguagesArray containsObject:@"all"]) {
        self.mutableLanguagesSet = [NSMutableSet set];
    } else {
        self.mutableLanguagesSet = [NSMutableSet setWithArray:storedLanguagesArray];
    }
    [self.tableView reloadData];
}

- (void)segementedControlChanged:(UISegmentedControl*)sender {
    [self saveArrayWithIndex:_previouslySelectedIndex];
    _previouslySelectedIndex = _globalSegmentedControl.selectedSegmentIndex;
    [self configureLanguagesSet];
}

@end
