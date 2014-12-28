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
@property (nonatomic) CLLocation * currentUserLocation;
@property (nonatomic, weak) MainTableViewController * mainViewController;
@property (nonatomic) NSMutableArray * pastLocations;
@property (nonatomic, assign) BOOL deniedLocationAccess;


+(instancetype) sharedInstance;
-(void) startTrackingLocation;

@end
