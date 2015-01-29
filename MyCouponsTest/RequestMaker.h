//
//  RequestMaker.h
//  Bargain
//
//  Created by Shady Gabal on 1/27/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestMaker : NSObject

+(instancetype) sharedInstance;

-(void) makeRequestTo:(NSString *) url withSession:(NSURLSession *) session withData:(NSString *) dataToSend withCompletionHandler:(void(^)(NSDictionary *, NSHTTPURLResponse *, NSError *)) block;

@end
