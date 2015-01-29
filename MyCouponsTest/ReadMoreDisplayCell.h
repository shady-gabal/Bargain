//
//  ReadMoreDisplayCell.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 1/6/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coupon.h"
#import "MainTableViewController.h"

@interface ReadMoreDisplayCell : UITableViewCell

@property (nonatomic, weak) Coupon * coupon;
@property (nonatomic, weak) MainTableViewController * mainTableController;

@end
