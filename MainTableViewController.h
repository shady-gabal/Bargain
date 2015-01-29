//
//  MainTableViewController.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/18/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Coupon.h"

@interface MainTableViewController : UITableViewController <CLLocationManagerDelegate>


@property (nonatomic, assign) BOOL didShowLocationDeniedPopup;
@property (nonatomic, assign) BOOL usingLocation;
@property (nonatomic, assign) BOOL loggedIn;
@property (nonatomic, assign) int numCouponsAlreadyLoaded;
@property (nonatomic, assign) NSDictionary<FBGraphUser> * currentUserFB;
@property (nonatomic, assign) NSDictionary * currentUserDB;
-(void) userDeniedLocation;
-(void) setup;
-(void) getCouponsFromServer;
-(BOOL) redeemCoupon:(Coupon *) coupon;

@end
