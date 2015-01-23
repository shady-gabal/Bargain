//
//  MainTableViewController.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/18/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "MainTableViewController.h"
#import "CouponStore.h"
#import "LocationHandler.h"
#import "CouponDisplayCell.h"
#import "ReadMoreDisplayCell.h"
#import <MONActivityIndicatorView.h>

/* FEATURES:
 1) Displays all coupons near you sorted by distance and popularity pulled from online database
 2) Tells you when you pass by a store if it has a coupon available (push notification). does this maybe once or twice a day so as to not annoy user to turn it off - also make it seem like a 'Hot' and 'popular' coupon. Lastly, don't allow this for cheap coupons
 3) Tracks how many times a user visits a merchant and when his last visit to the merchant was
 4) Allows users to redeem a coupon by clicking 'use'
 5) 
 
 Problems:
 1) Only pulling coupons near someone - send in JSON request lat and long coordinates
 2) Constantly check if coordinates user is at have a merchant near them with a popular coupon
 
 
 Steps:
 1) Add facebook/user identification
 2) Figure out how to generate unique ids 
 
 
 Test Cases:
 1) have location enabled, open app, let app get location, keep app in background while turning off location access, reenter app and see what happens
    if app does not refresh, check [LocationHandler deniedLocationAccess]
    if app does refresh, make sure it refreshes using new location
 */

static float READMORE_HEIGHT = 300.f;
static float FIRST_CELL_PADDING_TOP = 40.f;
static int PADDING_CELL_INCLUSION = 1;
static float PADDING_BETWEEN_SECTIONS = 15.f;

static BOOL FETCH_FROM_SERVER = YES;

static int NUM_COUPONS_TO_LOAD_PER_REQ = 15;
static int NUM_COUPONS_ALREADY_LOADED = 0;


static NSString * SERVER_DOMAIN = @"http://localhost:3000/";


@interface MainTableViewController () <NSURLSessionDataDelegate, MONActivityIndicatorViewDelegate>

@property (nonatomic) NSURLSession * fetchingCouponsSession;

@end

typedef enum : NSUInteger {
    TAG_TYPE_IMAGE_VIEW = 1,
    TAG_TYPE_READ_MORE_VIEW = 2

} COUPON_VIEW_TAG_TYPES;

@implementation MainTableViewController{
    CouponStore * _couponStore;
    
    /* for readmore view */
    BOOL _isReadMoreSelected;
    long _readMoreSectionNum;
    Coupon * _currSelectedCoupon;
    
    /* for location */
    LocationHandler * _locationHandler;
    
    /* colors */
    UIColor * _cellColor;
    UIColor * _tableColor;
    
    BOOL _setup;
    
    NSDictionary * _stringsForTypes;
    
    UIView * _tableLoadingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Coupon"];
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PaddingCell"];
    
    UINib * couponTemplate2Nib = [UINib nibWithNibName:@"CouponTemplate2" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:couponTemplate2Nib forCellReuseIdentifier:@"CouponTemplate2"];
    
    UINib * readMoreViewNib = [UINib nibWithNibName:@"ReadMoreDisplayCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:readMoreViewNib forCellReuseIdentifier:@"ReadMoreDisplayCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



-(id) init{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self){
        //setup location
        _locationHandler = [LocationHandler sharedInstance];
        if (!_locationHandler){
            NSLog(@"Error: You must have location services enabled in order to use this app.");
            //do stuff that prevents user from using app
        }
        else{
            //rest of init code
            _locationHandler.mainViewController = self;
            [_locationHandler startTrackingLocation];
            _fetchingCouponsSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        }
        
        //setup table look
//        UIImageView * backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wood_background.jpg"]];
//        backgroundView.frame = self.tableView.frame;
//        self.tableView.backgroundView = backgroundView;
       
        _cellColor = [UIColor clearColor];
        
        _tableColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_background.jpg"]];
        self.tableView.backgroundColor = _tableColor;

        //create coupon store
        _couponStore = [CouponStore sharedInstance];
        
        _stringsForTypes = @{
                             @"pizza" : @[@"pizza_background.jpg"],
                             @"sushi" : @[@"sushi_background.jpg"]
                             };
        
        //setup readmore values
        _readMoreSectionNum = -1;
        _isReadMoreSelected = NO;
        
    }
    return self;
}

-(void) setup{
    NSLog(@"setup called");
    if (!_setup){
        _setup = YES;
        if (FETCH_FROM_SERVER){
            [self addTableLoadingView];
            [self getCouponsFromServer];
        }
        else{
            for (int i = 0; i < 3; i++){
                [_couponStore createCouponFromTemplate:@"CouponTemplate2" withImageName:@"pizza_background.jpg" withDiscountText:@"$6 OFF" withOnObjectText:@"ONE TOPPING LARGE PIE"];
            }
            for (int i = 0; i < 4; i++){
                [_couponStore createCouponFromTemplate:@"CouponTemplate2" withImageName:@"sushi_background.jpg" withDiscountText:@"$3 OFF" withOnObjectText:@"PLATE OF SUSHI"];
            }
            for (int i = 0; i < 3; i++){
                [_couponStore createCouponFromTemplate:@"CouponTemplate2" withImageName:@"pizza_background.jpg" withDiscountText:@"$6 OFF" withOnObjectText:@"ONE TOPPING LARGE PIE"];
            }
            for (int i = 0; i < 6; i++){
                [_couponStore createCouponFromTemplate:@"CouponTemplate2" withImageName:@"sushi_background.jpg" withDiscountText:@"$3 OFF" withOnObjectText:@"PLATE OF SUSHI"];
            }
        }
        
        [self.tableView reloadData];
    }
}


/*******************************************************************/

#pragma mark - Fetching coupons from server methods

-(void) getCouponsFromServer{
    
    if (!_locationHandler.currentUserLocation){
        NSLog(@"error - current user location not set. cannot get coupons from server");
        return;
    }
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    NSURL * requestURL = [self urlFromString:@"coupons/getCoupons"];
    [request setURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    CGFloat latitude = _locationHandler.currentUserLocation.coordinate.latitude;
    CGFloat longitude = _locationHandler.currentUserLocation.coordinate.longitude;
    
    NSLog(@"trying to make request. %f, %f", latitude, longitude);
    
    NSString * dataToSend = [NSString stringWithFormat:@"latitude=%f&longitude=%f&numResultsRequested=%d&startfrom=%d", latitude, longitude, NUM_COUPONS_TO_LOAD_PER_REQ, NUM_COUPONS_ALREADY_LOADED];
    
    [request setHTTPBody:[dataToSend dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSLog(@"%@", [[request URL]absoluteString]);
    
    [[_fetchingCouponsSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error){
        if (! error){
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
            //if response returned with a status code of success
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 400){
                //convert data received to json
                NSLog(@"Request successful. Data returned:");
                NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                NSLog(@"converting data to json dictionary");
                
                NSError * serializeError = nil;
                NSDictionary * couponData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializeError];
                
                //if data successfully converted to json
                if (!error){
                    //you now have access to coupons
                    NSLog(@"Successfully converted data to json dictionary.");
                    
                    for(id coupon in couponData){
                        NSLog(@"%@", coupon);
                        Coupon * newCoupon = [_couponStore createCouponFromTemplate:@"CouponTemplate2" withImageName:@"pizza_background.jpg" withDiscountText:coupon[@"description"] withOnObjectText:coupon[@"created_at"]];
                        NUM_COUPONS_ALREADY_LOADED++;
                    }
                    //do stuff to turn coupon data into actual coupons in array
                    
                    //then reload the data in the main tableview
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"reloading data");
//                        [NSThread sleepForTimeInterval:10.f];
                        [self removeTableLoadingView];
                        [self.tableView reloadData];
                    });
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
        
        //else error with making request
        else{
            NSLog(@"%@", [error description]);
        }
    }] resume];
}

-(void) removeTableLoadingView{
    NSLog(@"removetableloadingview called");
    if (_tableLoadingView){
        [_tableLoadingView removeFromSuperview];
    }
}

-(void) addTableLoadingView{
    NSLog(@"addtableloadingview called");
    
    _tableLoadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 200)];
    
    MONActivityIndicatorView * activityIndicator = [[MONActivityIndicatorView alloc]init];
    activityIndicator.center = CGPointApplyAffineTransform(_tableLoadingView.center, CGAffineTransformMakeTranslation(0, -20));
;
    activityIndicator.delegate = self;
    [activityIndicator startAnimating];
    [_tableLoadingView addSubview:activityIndicator];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
    label.textColor = [UIColor whiteColor];
    
    label.text = @"Fetching you savings...";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    NSLog(@"%@",[UIFont fontNamesForFamilyName:@"Gotham"]);
    label.font = [UIFont fontWithName:@"Gotham-Light" size:14];
    [_tableLoadingView addSubview:label];
    label.center = CGPointApplyAffineTransform(_tableLoadingView.center, CGAffineTransformMakeTranslation(0, 20));
    _tableLoadingView.backgroundColor = [UIColor clearColor];
    
    _tableLoadingView.center = self.tableView.center;
    [self.tableView addSubview:_tableLoadingView];
    
}

/* FOR LOADING CIRCLES ANIMATION */

-(UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView circleBackgroundColorAtIndex:(NSUInteger)index{
    switch(index){
        case 0:
            return [UIColor greenColor];
            break;
        case 1:
            return [UIColor blueColor];
            break;
        case 2:
            return [UIColor purpleColor];
            break;
        case 3:
            return [UIColor brownColor];
            break;
        case 4:
            return [UIColor redColor];
            break;
        //will need more if adding more circles, less if subtracting circles
        default:
            return [UIColor whiteColor];
            break;
    }
    return nil;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/***********************************************************************/

#pragma mark -  Custom methods for table view UI

- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
    NSLog(@"-------------");
}


-(long) correctCouponIndexForIndexPath:(NSIndexPath *) indexPath{
//    if (indexPath.section > _readMoreSectionNum && _isReadMoreSelected)
//        return indexPath.section - 1 - 1;//-1 for readmore cell, -1 for padding cell on top
//    else
    return indexPath.section - 1; //-1 for top cell padding
}

-(void) removeReadMoreView{
    //first set _isReadMoreSelected to false so that when deleting rows the table cell count is adjusted
    _isReadMoreSelected = NO;
    
    NSIndexPath * path = [NSIndexPath indexPathForRow:1 inSection:_readMoreSectionNum];
//    UITableViewCell * readMoreCell = [self.tableView cellForRowAtIndexPath:path];
//    [[readMoreCell.contentView viewWithTag:TAG_TYPE_READ_MORE_VIEW]removeFromSuperview];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    _currSelectedCoupon.selectedForReadMore = NO;
    _currSelectedCoupon = nil;
    _readMoreSectionNum = -1;
    
}

-(void) insertReadMoreViewForCoupon:(Coupon *) coupon atIndexPath:(NSIndexPath *) indexPath{
    NSLog(@"inserting readmoreview for coupon at index path: %ld", (long)indexPath.section);
    _currSelectedCoupon = coupon;
    _currSelectedCoupon.selectedForReadMore = YES;
    
    _readMoreSectionNum = indexPath.section;
    _isReadMoreSelected = YES;
    NSIndexPath * path = [NSIndexPath indexPathForRow:1 inSection:_readMoreSectionNum];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

/***********************************************************************/

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_isReadMoreSelected && section == _readMoreSectionNum){
        return 2;
    }
    else return 1;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return [[_couponStore allCoupons] count] + PADDING_CELL_INCLUSION; // +1 for top cell padding;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //check if index of cell at this index path is a readmore box
    //if it is, return the standard height of a coupon read more box
    //else return the height of the coupon image view frame
    
    if (indexPath.section == 0 && indexPath.section == 0){
        return FIRST_CELL_PADDING_TOP;
    }
    
    else if (_isReadMoreSelected && indexPath.section == _readMoreSectionNum && indexPath.row == 1){
        return READMORE_HEIGHT;
    }
    else{
        return [CouponDisplayCell heightOfCells];
    }
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    return PADDING_BETWEEN_SECTIONS;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.section == 0){
        return FIRST_CELL_PADDING_TOP;
    }
    
    else if (_isReadMoreSelected && indexPath.section == _readMoreSectionNum && indexPath.row == 1){
        return READMORE_HEIGHT;
    }
    else{
        return [CouponDisplayCell heightOfCells];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return PADDING_BETWEEN_SECTIONS;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == [[_couponStore allCoupons]count] - 1 + PADDING_CELL_INCLUSION && NUM_COUPONS_ALREADY_LOADED != 0){
        NSLog(@"should reload now");
        [self getCouponsFromServer];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 && indexPath.row == 0){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PaddingCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    else if (_isReadMoreSelected && indexPath.section == _readMoreSectionNum){
        ReadMoreDisplayCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ReadMoreDisplayCell" forIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][indexPath.section - PADDING_CELL_INCLUSION];
        
        [self roundCellCorners:cell];
        return cell;

    }
    else{

        long correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];

        CouponDisplayCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CouponTemplate2" forIndexPath:indexPath];
        
        //set data of cell to coupon data
        cell.discountLabel.text = coupon.discountString;
        cell.onObjectLabel.text = coupon.onObjectString;

        //style cell
        [self roundCellCorners:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //add background image to cell
        UIImageView * xibBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:coupon.imageString]];
        xibBackgroundView.alpha = .5f;
        
        cell.backgroundView = xibBackgroundView;
        return cell;
    }
}

-(UIView *)roundCellCorners:(UIView *)cell{
    CALayer * l = [cell layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    [l setBorderWidth:1.0];
    [l setBorderColor:[[UIColor grayColor] CGColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"touched coupon at index path: %ld", (long)indexPath.section);
    //
//    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0 && indexPath.section == 0) //if selecting padding cell
        return; //die hacker scum
    
    //if selecting coupon that is not selected
    else if (! _isReadMoreSelected || indexPath.section != _readMoreSectionNum || indexPath.row != 1){
        long correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        
        /* if coupon is already selected, remove it's read more box and update the readmoreindeces array */
        if (coupon.selectedForReadMore){
            NSLog(@"coupon deselected");
            [self removeReadMoreView];
        }
        
        //if the coupon is not already selected, add it's read more box in the next cell and update the readmoreindeces array
        else{
            
            if (_isReadMoreSelected){
                [self removeReadMoreView]; //remove the current readmore view
                
            }
            
            NSLog(@"coupon selected");
            [self insertReadMoreViewForCoupon:coupon atIndexPath:indexPath]; //add new readmore view
        }
        
    }
    
    //selecting readmore
    else{
        
    }
    
}

/***********************************************************************/

#pragma mark - Location

-(BOOL) usingLocation{
    _usingLocation = ![_locationHandler deniedLocationAccess];
    return _usingLocation;
}

-(void) userDeniedLocation{
    NSLog(@"in [tableviewcontroller userDeniedLocation]. _locationHandler.deniedLocationAccess: %d", _locationHandler.deniedLocationAccess);
    if (_locationHandler.deniedLocationAccess && !self.didShowLocationDeniedPopup){
        self.didShowLocationDeniedPopup = YES;
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Cannot use app" message:@"We need your location in order to find the coupons closest to you. Without it, this app will not work." delegate:self cancelButtonTitle:@"Fix" otherButtonTitles:nil];
        [alert show];
    }
}


/***********************************************************************/

#pragma mark - Alerts for Location

-(void) alertWithTitle:(NSString *)title message:(NSString *) message{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
