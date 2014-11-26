//
//  PlacesViewController.m
//  Appetizr
//
//  Created by dasdom on 06.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#define kPlaceCellIdentifer @"kPlaceCellIdentifer"
#define kMapCellIdentifier @"kMapCellIdentifier"

#import "PlacesViewController.h"
#import "DHCreateStatusViewController.h"
#import "PlaceCell.h"
#import "PRPConnection.h"
#import "SSKeychain.h"
#import <CoreLocation/CoreLocation.h>
#import "MapViewCell.h"
#import "PlaceAnnotation.h"

@interface PlacesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *placeArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation PlacesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    CGRect frame = self.navigationController.view.frame;
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height-20.0f;
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:contentView.bounds collectionViewLayout:collectionViewFlowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[PlaceCell class] forCellWithReuseIdentifier:kPlaceCellIdentifer];
    [_collectionView registerClass:[MapViewCell class] forCellWithReuseIdentifier:kMapCellIdentifier];
    [contentView addSubview:_collectionView];
    
    _placeArray = [NSArray array];
    
    self.title = NSLocalizedString(@"places", nil);
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return [self.placeArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MapViewCell *mapViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:kMapCellIdentifier forIndexPath:indexPath];

        MKCoordinateSpan span = MKCoordinateSpanMake(0.001, 0.001);
        MKCoordinateRegion region = MKCoordinateRegionMake(self.coordinate, span);
        [mapViewCell.mapView setRegion:region animated:YES];
        mapViewCell.mapView.showsUserLocation = YES;
        
        for (NSDictionary *placeDictionary in self.placeArray) {
            PlaceAnnotation *placeAnnotation = [[PlaceAnnotation alloc] init];
            placeAnnotation.coordinate = CLLocationCoordinate2DMake([[placeDictionary objectForKey:@"latitude"] floatValue], [[placeDictionary objectForKey:@"longitude"] floatValue]);
            placeAnnotation.placeTitle = [placeDictionary objectForKey:@"name"];
            placeAnnotation.placeSubtitle = [placeDictionary objectForKey:@"address"];
//            MKPinAnnotationView *pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:placeAnnotation reuseIdentifier:@"PinIdentifier"];
            [mapViewCell.mapView addAnnotation:placeAnnotation];
        }

        return mapViewCell;
    } else {
        PlaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPlaceCellIdentifer forIndexPath:indexPath];
        NSDictionary *placeDictionary = [self.placeArray objectAtIndex:indexPath.row];
//        cell.nameLabel.text = [NSString stringWithFormat:@"%@, %@", [placeDictionary objectForKey:@"name"], [placeDictionary objectForKey:@"address"]];
        cell.nameLabel.text = [placeDictionary objectForKey:@"name"];
        return cell;
    }
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    NSDictionary *placeDictionary = [self.placeArray objectAtIndex:indexPath.row];
    dhDebug(@"dictionary: %@", placeDictionary);
    
    self.createStatusViewController.locationId = [placeDictionary objectForKey:@"factual_id"];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - collection view flow layout delecate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width, 200.0f);
    }
    return CGSizeMake(self.view.frame.size.width, 40.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

#pragma mark - logaction manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    dhDebug(@"long: %f, lat: %f", location.coordinate.longitude, location.coordinate.latitude);
    self.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    
    [manager stopUpdatingLocation];
    
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];

    NSString *urlString = [NSString stringWithFormat:@"%@places/search?latitude=%.6f&longitude=%.6f&access_token=%@", kBaseURL, location.coordinate.latitude, location.coordinate.longitude, accessToken];
    
    NSMutableURLRequest *placesRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [placesRequest setHTTPMethod:@"GET"];
    [placesRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    PRPConnection *placesConnection = [PRPConnection connectionWithRequest:placesRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:placesRequest progress:^(DHConnection *connection){} completion:^(DHConnection *connection, NSError *error) {
    
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
        dhDebug(@"responseDict: %@", responseDict);
        
        self.placeArray = [responseDict objectForKey:@"data"];
        
        [self.collectionView reloadData];
    }];
    [placesConnection start];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    dhDebug(@"error: %@", error);
}

- (void)cancel:(UIBarButtonItem*)sender {
    self.createStatusViewController.locationId = nil;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
