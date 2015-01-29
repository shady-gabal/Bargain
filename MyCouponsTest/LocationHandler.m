//
//  LocationHandler.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 12/27/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "LocationHandler.h"
#import "RequestMaker.h"
#import "CalculationsMaker.h"

@interface LocationHandler ()


@end


@implementation LocationHandler{
    RequestMaker * _requestMaker;
}

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
            self.currentUserLocation = nil;
            
            _requestMaker = [RequestMaker sharedInstance];
            _previousLocations = [NSMutableArray array];

        }
        else self = nil;
    }
    return self;
}

-(void) startTrackingLocation{
    [_locationManager startUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"num locations: %d", [locations count]);
//    NSLog(@"%@", locations);
    [_previousLocations addObject:[locations lastObject]];
    self.previousUserLocation = self.currentUserLocation;
    self.currentUserLocation = [locations lastObject];

    if (!self.previousUserLocation){
        self.timeReceivedCurrentLocation = self.currentTimestamp;
        [self.mainViewController setup];
    }
    else{
        self.timeReceivedPreviousLocation = self.timeReceivedCurrentLocation;
        self.timeReceivedCurrentLocation = self.currentTimestamp;
        [self isUserMoving];
        NSLog(@"%@", self.previousUserLocation);
    }
    
}

-(BOOL) isUserMoving{
    float dist = [CalculationsMaker calcDistanceFrom:self.previousUserLocation to:self.currentUserLocation];
    NSLog(@"time received current location: %f, previous: %f", self.timeReceivedCurrentLocation, self.timeReceivedPreviousLocation);
    
    NSLog(@"distance from last position: %f", dist);
    float timeDiffInSec = self.timeReceivedCurrentLocation - self.timeReceivedPreviousLocation;
    
    float speed = dist/timeDiffInSec; 
    return NO;
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
//        [self.mainViewController setup];
        return NO;
    }
}


-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (self.deniedLocationAccess == YES){
        [self.mainViewController userDeniedLocation];
    }
}





-(CFTimeInterval) currentTimestamp{
    return CACurrentMediaTime();
}

+(CFTimeInterval) currentTimestamp{
    return CACurrentMediaTime();
}

//-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
//    if (self.deniedLocationAccess == YES){
//        [self.mainViewController userDeniedLocation];
//    }
//}

@end
