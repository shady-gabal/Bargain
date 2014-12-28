//
//  LocationHandler.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 12/27/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "LocationHandler.h"


@implementation LocationHandler

static CGFloat DISTANCE_FILTER = 100.f;
static LocationHandler * locationHandler = nil;

+(instancetype) sharedInstance{
    if (locationHandler)
        return locationHandler;
    else{
        locationHandler = [[LocationHandler alloc] init];
        return locationHandler;
    }
}

-(instancetype) init{
    self = [super init];
    if (self){
        if([CLLocationManager locationServicesEnabled]){
            _locationManager = [[CLLocationManager alloc]init];
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_locationManager requestAlwaysAuthorization];
            }
            CLAuthorizationStatus auth = [CLLocationManager authorizationStatus];
            if(auth == kCLAuthorizationStatusDenied || auth == kCLAuthorizationStatusRestricted || auth == kCLAuthorizationStatusNotDetermined){
                NSLog(@"not allowed to use location");
            }
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = DISTANCE_FILTER;
        }
        else self = nil;
    }
    return self;
}

-(void) startTrackingLocation{
    [_locationManager startUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@", locations);
    self.currentUserLocation = [locations lastObject];
}




@end
