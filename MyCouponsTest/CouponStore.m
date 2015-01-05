//
//  CouponStore.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "CouponStore.h"

@interface CouponStore ()

@property (nonatomic) NSMutableArray * coupons;

@end

static NSString * SERVER_DOMAIN = @"http://localhost:3000/";


@implementation CouponStore{
    NSURLSession * _session;
}

static CouponStore * sharedStore;

+(instancetype) sharedInstance{
    if (!sharedStore){
        sharedStore = [[CouponStore alloc] initPrivate];
    }
    return sharedStore;
}

-(instancetype) initPrivate{
    self = [super init];
    if (self){
        _coupons = [NSMutableArray array];
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    }
    return self;
}

-(instancetype) init{
    @throw [NSException exceptionWithName:@"Shared Instance Violation" reason:@"Cannot call init on CouponStore - Singleton" userInfo:nil];
    return nil;
}

-(NSArray *) allCoupons{
   // NSArray * ans = [NSArray arrayWithArray:_coupons];
    return self.coupons;
}

-(Coupon *) createCoupon{
    NSArray * imageNames = @[@"coupon2.jpg", @"coupon3.jpg"];
    int randomInt = arc4random() % 2;
    Coupon * newCoupon = [self createCouponWithImageNamed:imageNames[randomInt]];
    return newCoupon;
}

-(Coupon *) createCouponFromTemplateNum:(int) templateNum{
    Coupon * newCoupon = [[Coupon alloc]initWithTemplateNum:1];
    [self.coupons addObject:newCoupon];
    return newCoupon;
}

-(Coupon *) createCouponWithImageNamed:(NSString *) imageName{
    Coupon * newCoupon = [[Coupon alloc] initWithImageNamed:imageName];
    [self.coupons addObject:newCoupon];
    return newCoupon;
}

-(NSURL *) urlFromString:(NSString *) url{
    NSString * requestURL = [SERVER_DOMAIN stringByAppendingString:url];
    NSURL * ans = [NSURL URLWithString:requestURL];
    return ans;
}

-(void) getCouponsFromServer{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    NSURL * requestURL = [self urlFromString:@"coupons/getCoupons"];
    [request setURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString * dataToSend = @"latitude=25&longitude=42&numResultsRequested=20";
    [request setHTTPBody:[dataToSend dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSLog(@"%@", [[request URL]absoluteString]);
    
    [[_session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error){
        if (! error){
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
            //if response returned with a status code of success
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 400){
                //convert data received to json
                NSLog(@"Request successful. Data returned:");
                NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                NSLog(@"converting data to json dictionary");
                
                NSError * serializeError = nil;
                NSDictionary * jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializeError];
                
                //if data successfully converted to json
                if (!error){
                    //you now have access to coupons
                    NSLog(@"Successfully converted data to json dictionary.");
                    NSLog(@"%@", jsonData);
                }
                //else there was an error converting to json
                else{
                    NSLog(@"error converting to json dict - %@", serializeError.description);
                }
            }
            //else response returned with an unsuccessful status code
            else{
                NSLog(@"Response returned with unsuccessful status code.");
            }
        }
        
        else{
            NSLog(@"%@", [error description]);
        }
    }] resume];
}

@end
