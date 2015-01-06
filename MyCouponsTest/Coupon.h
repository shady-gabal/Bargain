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
@property (nonatomic) NSString * title;

@property (nonatomic) IBOutlet UIImageView * backgroundView;
@property (nonatomic) IBOutlet UILabel * discountLabel;
@property (nonatomic) IBOutlet UILabel * onObjectLabel;
@property (nonatomic) IBOutlet NSString * finePrintString;

@property (nonatomic, assign) BOOL selectedForReadMore;


-(instancetype) init;
-(instancetype) initWithImageNamed:(NSString *) imageName;
-(instancetype) initWithTemplateNum:(int) templateNum;
@end
