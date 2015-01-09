//
//  CouponStore.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coupon.h"

@interface CouponStore : NSObject

@property (nonatomic) NSArray * allCoupons;

+(instancetype) sharedInstance;
-(Coupon *) createCoupon;
-(Coupon *) createCouponFromTemplate:(NSString *) template withImageName:(NSString *) imageName withDiscountText:(NSString *) discountText withOnObjectText:(NSString *) onObjectText;

-(void) getCouponsFromServer;

@end
