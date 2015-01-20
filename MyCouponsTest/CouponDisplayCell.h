//
//  CouponDisplayCell.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 1/6/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponDisplayCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel * discountLabel;
@property (nonatomic) IBOutlet UILabel * onObjectLabel;
@property (nonatomic) IBOutlet UIImageView * backgroundView;

+(CGFloat) heightOfCells;

@end
