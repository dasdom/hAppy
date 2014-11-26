//
//  MapViewCell.h
//  Appetizr
//
//  Created by dasdom on 07.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
