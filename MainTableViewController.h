//
//  MainTableViewController.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/18/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainTableViewController : UITableViewController <CLLocationManagerDelegate>


@property (nonatomic, assign) BOOL didShowLocationDeniedPopup;
@property (nonatomic, assign) BOOL usingLocation;
-(void) userDeniedLocation;
-(void) setup;
-(void) getCouponsFromServer;

@end
