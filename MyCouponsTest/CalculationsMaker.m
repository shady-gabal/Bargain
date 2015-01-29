//
//  CalculationsMaker.m
//  Bargain
//
//  Created by Shady Gabal on 1/29/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import "CalculationsMaker.h"

@implementation CalculationsMaker

+(float) calcDistanceFrom:(CLLocation *) latlng1 to:(CLLocation *) latlng2{
    float lat1 = latlng1.coordinate.latitude;
    float lon1 = latlng1.coordinate.longitude;
    
    float lat2 = latlng2.coordinate.latitude;
    float lon2 = latlng2.coordinate.longitude;
    
    
    float distance = 1000.f * (3958.f*3.1415926*sqrt((lat2-lat1)*(lat2-lat1) + cos(lat2/57.29578)*cos(lat1/57.29578)*(lon2-lon1)*(lon2-lon1))/180.f); //in kilometers?
    
    return distance;
}

@end
