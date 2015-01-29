//
//  LocationHandler.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 12/27/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MainTableViewController.h"

@interface LocationHandler : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager * locationManager;

@property (nonatomic) CFTimeInterval timeReceivedCurrentLocation;
@property (nonatomic) CFTimeInterval timeReceivedPreviousLocation;

@property (nonatomic) CFTimeInterval currentTimestamp;
@property (nonatomic) CLLocation * currentUserLocation;
@property (nonatomic) CLLocation * previousUserLocation;

@property (nonatomic, weak) MainTableViewController * mainViewController;
@property (nonatomic, assign) BOOL isUserMoving;
@property (nonatomic) NSMutableArray * previousLocations;
@property (nonatomic, assign) BOOL deniedLocationAccess;


+(instancetype) sharedInstance;
-(void) startTrackingLocation;

@end
