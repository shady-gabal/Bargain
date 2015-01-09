//
//  Coupon.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "Coupon.h"

static float COUPON_READ_MORE_HEIGHT = 200.f;
static float COUPON_READ_MORE_WIDTH = 80.f;
static float COUPON_HEIGHT_AS_PERCENTAGE = .20;
static float COUPON_WIDTH_AS_PERCENTAGE = .95f;
static CGFloat DEVICE_WIDTH = 0.f;
static CGFloat DEVICE_HEIGHT = 0.f;

@implementation Coupon

-(instancetype) init{
    return [[Coupon alloc]initWithImageNamed:@"1"];
}


-(instancetype) initWithImageNamed:(NSString *) imageName{
    self = [super init];
    if (self){
        self.couponImage = [UIImage imageNamed:imageName];
        self.couponImageView = [[UIImageView alloc] initWithImage:self.couponImage];
        
        if (DEVICE_WIDTH == 0.f || DEVICE_HEIGHT == 0.f){
            DEVICE_HEIGHT = [[UIScreen mainScreen]bounds].size.height;
            DEVICE_WIDTH = [[UIScreen mainScreen]bounds].size.width;
        }
        
        self.couponImageView.frame = CGRectMake(0,0, DEVICE_WIDTH * COUPON_WIDTH_AS_PERCENTAGE, DEVICE_HEIGHT * COUPON_HEIGHT_AS_PERCENTAGE);
        
        NSLog(@"image height %f, image width %f", self.couponImageView.frame.size.height, self.couponImageView.frame.size.width);
        
        self.couponImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CALayer * l = [self.couponImageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:10.0];
        
        // You can even add a border
//        [l setBorderWidth:1.0];
//        [l setBorderColor:[[UIColor grayColor] CGColor]];

        
        self.couponReadMoreView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner.jpg"]];
        self.couponReadMoreView.frame = CGRectMake(0,0, 300, 300);

    }
    return self;
}

-(instancetype) initWithTemplate:(NSString *) template withImageName:(NSString *)imageName withDiscountText:(NSString *)discountText withOnObjectText:(NSString *)onObjectText{
    self = [super init];
    if (self){
        
        if (DEVICE_WIDTH == 0.f || DEVICE_HEIGHT == 0.f){
            DEVICE_HEIGHT = [[UIScreen mainScreen]bounds].size.height;
            DEVICE_WIDTH = [[UIScreen mainScreen]bounds].size.width;
        }

        /* LOADING XIBVIEW */


        self.templateString = template;
        
        /* SETTING DATA OF COUPON */
        self.discountString = discountText;
        self.onObjectString = onObjectText;

        
        /* COUPON IMAGE VIEW */
        self.couponImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CALayer * l = [self.couponImageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:10.0];
        [l setBorderWidth:1.0];
        [l setBorderColor:[[UIColor grayColor] CGColor]];

        
        /* READMORE VIEW */
//        self.couponReadMoreView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner.jpg"]];
//        self.couponReadMoreView.frame = CGRectMake(0,0, 300, 300);

        
//        CALayer * r = [self.couponReadMoreView layer];
//        [r setMasksToBounds:YES];
//        [r setCornerRadius:15.0];
//        
        /* LOGGING */
        NSLog(@"creating %@", template);


    }
    return self;
}
@end