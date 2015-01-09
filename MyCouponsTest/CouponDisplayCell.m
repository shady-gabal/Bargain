//
//  CouponDisplayCell.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 1/6/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import "CouponDisplayCell.h"
#import "CouponCellSizes.h"

@implementation CouponDisplayCell{
    BOOL loadedFrame;
    float finalYPosition;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)setFrame:(CGRect)frame {
//  frame.origin.y += PADDING_BETWEEN_COUPONS;
    frame.size.height = COUPON_HEIGHT - PADDING_BETWEEN_COUPONS;
    [super setFrame:frame];
}

@end
