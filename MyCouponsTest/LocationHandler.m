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



-(BOOL) deniedLocationAccess{
    CLAuthorizationStatus auth = [CLLocationManager authorizationStatus];
    if(auth == kCLAuthorizationStatusDenied || auth == kCLAuthorizationStatusRestricted){
        self.deniedLocationAccess = YES;
        return YES;
    }
    else if (auth == kCLAuthorizationStatusNotDetermined){
        return NO;
    }
    else{
        self.deniedLocationAccess = NO;
        self.mainViewController.usingLocation = YES;
        [self.mainViewController setup];
        return NO;
    }
}


-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (self.deniedLocationAccess == YES){
        [self.mainViewController userDeniedLocation];
    }
}

//-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
//    if (self.deniedLocationAccess == YES){
//        [self.mainViewController userDeniedLocation];
//    }
//}

@end
