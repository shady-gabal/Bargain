//
//  ReadMoreDisplayCell.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 1/6/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import "ReadMoreDisplayCell.h"

@implementation ReadMoreDisplayCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)redeemCoupon:(id) sender{
    NSLog(@"redeem coupon called for coupon: %@", [self.coupon description]);
    [self.mainTableController redeemCoupon:self.coupon];
}

//- (void)setFrame:(CGRect)frame {
//    //    frame.origin.y += 4;
//    frame.size.height -= 2 * 2;
//    [super setFrame:frame];
//}


@end
