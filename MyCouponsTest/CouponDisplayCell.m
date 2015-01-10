//
//  CouponDisplayCell.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 1/6/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import "CouponDisplayCell.h"

static float COUPON_HEIGHT_AS_PERCENTAGE = .25f;
static float COUPON_HEIGHT = 0.f;
static float COUPON_WIDTH = 325.f;
static float COUPON_WIDTH_INSET = 5.f;
static float PADDING_BETWEEN_COUPONS = 8.f;
static CGFloat DEVICE_WIDTH = 0.f;
static CGFloat DEVICE_HEIGHT = 0.f;

@implementation CouponDisplayCell{
 
}


- (void)awakeFromNib {
    // Initialization code


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)setFrame:(CGRect)frame {
    frame.size.height = [CouponDisplayCell heightOfCells] - PADDING_BETWEEN_COUPONS;
    frame.origin.x = COUPON_WIDTH_INSET/2.f;
    frame.size.width = (self.superview.frame.size.width - COUPON_WIDTH_INSET);
    [super setFrame:frame];
}

+(CGFloat) heightOfCells{
    
    if (DEVICE_WIDTH == 0.f || DEVICE_HEIGHT == 0.f){
        DEVICE_HEIGHT = [[UIScreen mainScreen]bounds].size.height;
        DEVICE_WIDTH = [[UIScreen mainScreen]bounds].size.width;
    }
    if (COUPON_HEIGHT == 0.f){
        COUPON_HEIGHT = COUPON_HEIGHT_AS_PERCENTAGE * DEVICE_HEIGHT;
    }
    return COUPON_HEIGHT;
}
@end
