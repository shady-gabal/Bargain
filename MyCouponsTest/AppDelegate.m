//
//  AppDelegate.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/18/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTableViewController.h"
#import "CustomFBLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate ()

@property (nonatomic) MainTableViewController * tableController;
@property (nonatomic) CustomFBLoginViewController * fbLoginController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) { //FBSession.activeSession.isOpen
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        

        
        self.tableController = [[MainTableViewController alloc]init];
        self.tableController.loggedIn = YES;
        UITabBarController * tabBarController = [[UITabBarController alloc]init];
        tabBarController.viewControllers = @[self.tableController];
        tabBarController.tabBar.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 320, 70);
        tabBarController.tabBar.backgroundColor = [UIColor blackColor];
        
        self.window.rootViewController = tabBarController;
        NSLog(@"loaded");

    }
        
    // Override point for customization after application launch.
    else{
        self.fbLoginController = [[CustomFBLoginViewController alloc]init];
        self.window.rootViewController = self.fbLoginController;
    }
    
    return YES;
}

-(void) userLoggedIn{
    

    if (!self.tableController){
 
        self.tableController = [[MainTableViewController alloc]init];
        UITabBarController * tabBarController = [[UITabBarController alloc]init];
        tabBarController.viewControllers = @[self.tableController];
        tabBarController.tabBar.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 320, 70);
        tabBarController.tabBar.backgroundColor = [UIColor blackColor];
        
        self.window.rootViewController = tabBarController;
    }
    
    if (self.fbLoginController){
        [self.fbLoginController removeFromParentViewController];
    }
    
    //get current fb user
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *user,
       NSError *error) {
         if (!error) {
             NSString *firstName = user.first_name;
             NSString *lastName = user.last_name;
             NSString *facebookId = user.objectID;
             NSString *email = [user objectForKey:@"email"];
             NSString *imageUrl = [[NSString alloc] initWithFormat: @"http://graph.facebook.com/%@/picture?type=large", facebookId];
             
             NSLog(@"Facebook user %@ %@ has id %@", firstName, lastName, facebookId);
             self.tableController.currentUserFB = user;
         }
     }];
    

}

-(void) userLoggedOut{
    NSLog(@"user logged out");
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            NSLog(@"%@", alertText);
//            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                NSLog(@"%@", alertText);

//                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                NSLog(@"%@", alertText);

//                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//for facebook
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
     }];
    
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.tableController.didShowLocationDeniedPopup = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //log fb activation event
    [FBAppEvents activateApp];
    
    [FBAppCall handleDidBecomeActive];

    
    if (self.tableController && !self.tableController.usingLocation){
        [self.tableController userDeniedLocation];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
