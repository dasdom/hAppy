//
//  DHFontNamesTableViewController.m
//  Appetizr
//
//  Created by dasdom on 03.11.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHFontNamesTableViewController.h"

@interface DHFontNamesTableViewController ()
@property (nonatomic, strong) NSArray *fontNameArray;
@property (nonatomic, strong) NSString *currentFontName;
@end

@implementation DHFontNamesTableViewController

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

    self.fontNameArray = @[@"AmericanTypewriter", @"ArialMT", @"Avenir-Book", @"Avenir-Medium", @"AvenirNext-Regular", @"Baskerville", @"HelveticaNeue", @"Optima-Regular", @"Papyrus", @"Verdana", @"OpenDyslexic-Regular"];
    self.currentFontName = [[NSUserDefaults standardUserDefaults] objectForKey:kFontName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fontNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FontNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *fontName = [self.fontNameArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:fontName size:self.fontSize];
    cell.textLabel.text = fontName;
    if ([fontName isEqualToString:self.currentFontName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults] setObject:[self.fontNameArray objectAtIndex:indexPath.row] forKey:kFontName];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
