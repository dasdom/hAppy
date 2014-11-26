//
//  PlaceAnnotation.h
//  Appetizr
//
//  Created by dasdom on 09.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *placeTitle;
@property (nonatomic, strong) NSString *placeSubtitle;

@end
