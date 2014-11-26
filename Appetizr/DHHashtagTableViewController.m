//
//  DHHashtagTableViewController.m
//  Appetizr
//
//  Created by dasdom on 18.11.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHHashtagTableViewController.h"
#import "PRPAlertView.h"
#import "ImageHelper.h"

@interface DHHashtagTableViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentedControl;

@end

@implementation DHHashtagTableViewController

- (void)awakeFromNib {
//    self.urlString = [NSString stringWithFormat:@"%@%@tag/happy", kBaseURL, kPostsSubURL];
    self.urlString = [NSString stringWithFormat:@"%@%@search?%@=%@", kBaseURL, kPostsSubURL, @"query", @"Dassolltenichtszufindensein"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.userStreamArray count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    self.userStreamArray = [NSArray array];
    
    if (self.hashTagString && ![self.hashTagString isEqualToString:@""]) {
//        self.urlString = [NSString stringWithFormat:@"%@%@tag/%@", kBaseURL, kPostsSubURL, self.hashTagString];
        self.urlString = [NSString stringWithFormat:@"%@%@search?%@=%@", kBaseURL, kPostsSubURL, @"hashtags", self.hashTagString];
        self.userStreamArray = [NSArray array];
        [self.tableView reloadData];
        
        self.searchBar.text = self.hashTagString;
    }
    self.searchBar.placeholder = @"@, #, text";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if ([self.userStreamArray count] > 0) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//    }
//    
//    if (self.hashTagString && ![self.hashTagString isEqualToString:@""]) {
//        self.urlString = [NSString stringWithFormat:@"%@%@tag/%@", kBaseURL, kPostsSubURL, self.hashTagString];
//        self.userStreamArray = [NSArray array];
//        [self.tableView reloadData];
//        
//        self.searchBar.text = self.hashTagString;
//    }
    
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.accessibilityLabel = NSLocalizedString(@"menu", nil);
    [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setImage:[ImageHelper menueImage] forState:UIControlStateNormal];
    self.menuButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 30.0f);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;

//    if ([self.navigationController.viewControllers count] < 2) {
//        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
//        self.navigationItem.leftBarButtonItem = cancelBarButton;
//    }
    
    self.searchSegmentedControl.selectedSegmentIndex = 0;
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    NSRange rangeOfSpace = [searchText rangeOfString:@" "];
//    if (rangeOfSpace.location != NSNotFound) {
//        [DHAlertView showWithTitle:NSLocalizedString(@"Not supportet input", nil) message:NSLocalizedString(@"Hashtags can't have spaces.", nil) buttonTitle:@"OK"];
//        self.searchBar.text = [searchText stringByReplacingCharactersInRange:rangeOfSpace withString:@""];
//    }
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if ([searchBar.text isEqualToString:@""]) {
        return;
    }
    
    NSString *searchString;
    NSString *searchParameter;
    if ([searchBar.text rangeOfString:@"#"].location != NSNotFound) {
        searchString = [searchBar.text stringByReplacingOccurrencesOfString:@"#" withString:@""];
        searchParameter = @"hashtags";
    } else if ([searchBar.text rangeOfString:@"@"].location != NSNotFound) {
        searchString = [searchBar.text stringByReplacingOccurrencesOfString:@"@" withString:@""];
        searchParameter = @"mentions";
    } else {
        searchString = [searchBar.text copy];
        searchParameter = @"query";
    }
    self.urlString = [NSString stringWithFormat:@"%@%@search?%@=%@&count=20", kBaseURL, kPostsSubURL, searchParameter, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.userStreamArray = [NSArray array];
    [self.tableView reloadData];
    
    [self updateUserStreamArraySinceId:nil beforeId:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (IBAction)segmentedControlChanged:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *userSearchViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DHSearchViewController"];
    [self.navigationController pushViewController:userSearchViewController animated:NO];
}

- (void)cancel:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
