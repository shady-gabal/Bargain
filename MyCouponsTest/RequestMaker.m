//
//  RequestMaker.m
//  Bargain
//
//  Created by Shady Gabal on 1/27/15.
//  Copyright (c) 2015 Shady Gabal. All rights reserved.
//

#import "RequestMaker.h"


@interface RequestMaker ()

@end

@implementation RequestMaker

static NSString * SERVER_DOMAIN = @"https://evening-escarpment-6500.herokuapp.com";
static RequestMaker * requestMaker = nil;


+(instancetype) sharedInstance{
    if (requestMaker)
        return requestMaker;
    else{
        requestMaker = [[RequestMaker alloc] init];
        return requestMaker;
    }
}

-(instancetype) init{
    self = [super init];
    if (self){
    
    
    }
    return self;
}


-(void) makeRequestTo:(NSString *) url withSession:(NSURLSession *) session withData:(NSString *) dataToSend withCompletionHandler:(void(^)(NSDictionary *, NSHTTPURLResponse *, NSError *)) block{
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    NSURL * requestURL = [self urlFromString:url];
    [request setURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPBody:[dataToSend dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSLog(@"%@", [[request URL]absoluteString]);
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error){
        if (! error){
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
            //if response returned with a status code of success
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 400){
                //convert data received to json
                NSLog(@"Request to %@ successful. Data returned.", url);
                //                NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                NSLog(@"converting data to json dictionary");
                
                NSError * serializeError = nil;
                NSDictionary * returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializeError];
                
                //if data successfully converted to json
                if (!serializeError){
                    //you now have access to coupons
                    NSLog(@"Successfully converted response data to json dictionary after making request to: %@.", url);
                    block(returnedData, httpResponse, error);
                }
                //else there was an error converting to json
                else{
                    NSLog(@"error converting to json dict making request to: %@ - %@", url, serializeError.description);
                    block(returnedData, httpResponse, serializeError);
                }
            }
            
            
            //else response returned with an unsuccessful status code
            else{
                block(nil, httpResponse, error);
                NSLog(@"Response returned with unsuccessful status code after making request to: %@ .", url );
            }
        }
        
        //else error with making request
        else{
            block(nil, nil, error);
            NSLog(@"Error while making request to: %@ - %@", url, [error description]);
        }
    }] resume];
    
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSURLCredential * credentials = [NSURLCredential credentialWithUser:@"shady" password:@"123" persistence:NSURLCredentialPersistenceForSession];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credentials);
}

-(NSURL *) urlFromString:(NSString *) url{
    NSString * requestURL = [SERVER_DOMAIN stringByAppendingString:url];
    NSURL * ans = [NSURL URLWithString:requestURL];
    return ans;
}


@end
