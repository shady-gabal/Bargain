//
//  CalculationsMaker.h
//  Bargain
//
//  Created by Shady Gabal on 1/29/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CalculationsMaker : NSObject

+(float) calcDistanceFrom:(CLLocation *) latlng1 to:(CLLocation *) latlng2;
+(float) currentTimestamp;


@end
