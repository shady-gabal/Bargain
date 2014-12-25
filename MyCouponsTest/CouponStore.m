//
//  CouponStore.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "CouponStore.h"

@interface CouponStore ()

@property (nonatomic) NSMutableArray * coupons;

@end


@implementation CouponStore

static CouponStore * sharedStore;

+(instancetype) sharedInstance{
    if (!sharedStore){
        sharedStore = [[CouponStore alloc] initPrivate];
    }
    return sharedStore;
}

-(instancetype) initPrivate{
    self = [super init];
    _coupons = [NSMutableArray array];
    return self;
}

-(instancetype) init{
    @throw [NSException exceptionWithName:@"Shared Instance Violation" reason:@"Cannot call init on CouponStore - Singleton" userInfo:nil];
    return nil;
}

-(NSArray *) allCoupons{
   // NSArray * ans = [NSArray arrayWithArray:_coupons];
    return self.coupons;
}

-(Coupon *) createCoupon{
    NSArray * imageNames = @[@"1.jpg", @"2.jpg", @"3.jpg"];
    int randomInt = arc4random() % 3;
    Coupon * newCoupon = [self createCouponWithImageNamed:imageNames[randomInt]];
    return newCoupon;
}

-(Coupon *) createCouponWithImageNamed:(NSString *) imageName{
    Coupon * newCoupon = [[Coupon alloc] initWithImageNamed:imageName];
    [self.coupons addObject:newCoupon];
    return newCoupon;
}

@end
