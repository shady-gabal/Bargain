//
//  Coupon.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Coupon : UITableViewCell

@property (nonatomic) UIView * couponImageView;
@property (nonatomic) UIView * couponReadMoreView;
@property (nonatomic) UIImage * couponImage;
@property (nonatomic) NSString * templateString;

@property (nonatomic) UIImageView * backgroundView;
@property (nonatomic) NSString * discountString;
@property (nonatomic) NSString * onObjectString;
@property (nonatomic) NSString * finePrintString;
@property (nonatomic) NSString * imageString;

@property (nonatomic, assign) BOOL selectedForReadMore;


-(instancetype) init;
-(instancetype) initWithImageNamed:(NSString *) imageName;
-(instancetype) initWithTemplate:(NSString *) template withImageName:(NSString *) imageName withDiscountText:(NSString *) discountText withOnObjectText:(NSString *) onObjectText;
@end
