//
//  Coupon.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "Coupon.h"


@implementation Coupon


-(instancetype) init{
    return [[Coupon alloc]initWithImageNamed:@"coupon2"];
}

//
//-(instancetype) initWithImageNamed:(NSString *) imageName{
//    self = [super init];
//    if (self){
//        self.couponImage = [UIImage imageNamed:imageName];
//        self.couponImageView = [[UIImageView alloc] initWithImage:self.couponImage];
//             
//        self.couponImageView.frame = CGRectMake(0,0, DEVICE_WIDTH * COUPON_WIDTH_AS_PERCENTAGE, DEVICE_HEIGHT * COUPON_HEIGHT_AS_PERCENTAGE);
//        
//        NSLog(@"image height %f, image width %f", self.couponImageView.frame.size.height, self.couponImageView.frame.size.width);
//        
//        self.couponImageView.contentMode = UIViewContentModeScaleAspectFit;
//        
//        CALayer * l = [self.couponImageView layer];
//        [l setMasksToBounds:YES];
//        [l setCornerRadius:10.0];
//        
//        // You can even add a border
////        [l setBorderWidth:1.0];
////        [l setBorderColor:[[UIColor grayColor] CGColor]];
//
//        
//        self.couponReadMoreView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner.jpg"]];
//        self.couponReadMoreView.frame = CGRectMake(0,0, 300, 300);
//
//    }
//    return self;
//}


-(instancetype) initWithTemplate:(NSString *) template withImageName:(NSString *)imageName withDiscountText:(NSString *)discountText withOnObjectText:(NSString *)onObjectText{
    self = [super init];
    if (self){

        /* LOADING XIBVIEW */


        self.templateString = template;
        
        /* SETTING DATA OF COUPON */
        self.discountString = discountText;
        self.onObjectString = onObjectText;
        self.imageString = imageName;

//        
        /* LOGGING */
        NSLog(@"creating %@", template);


    }
    return self;
}
@end