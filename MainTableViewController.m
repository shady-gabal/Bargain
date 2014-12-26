//
//  MainTableViewController.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/18/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "MainTableViewController.h"
#import "CouponStore.h"



@interface MainTableViewController ()

@end

typedef enum : NSUInteger {
    TAG_TYPE_IMAGE_VIEW = 1,
    TAG_TYPE_READ_MORE_VIEW = 2

} COUPON_VIEW_TAG_TYPES;

@implementation MainTableViewController{
    CouponStore * _couponStore;
    
    BOOL isReadMoreSelected;
    int readMoreIndex;
    Coupon * _currSelectedCoupon;
    
    
}


-(id) init{
    self = [super init];
    if (self){
        _couponStore = [CouponStore sharedInstance];
        for (int i = 0; i < 6; i++){
            Coupon * createdCoupon = [_couponStore createCoupon];
            NSLog(@"%@", createdCoupon);
        }
        readMoreIndex = -1;
        isReadMoreSelected = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Coupon"];
    self.tableView.separatorColor = [UIColor clearColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(int) correctCouponIndexForIndexPath:(NSIndexPath *) indexPath{
    if (indexPath.row > readMoreIndex && isReadMoreSelected)
        return indexPath.row - 1;
    else return indexPath.row;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isReadMoreSelected)
        return [[_couponStore allCoupons] count] + 1;
    else return [[_couponStore allCoupons] count];
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //check if index of cell at this index path is a readmore box
    //if it is, return the standard height of a coupon read more box
    //else return the height of the coupon image view frame
    
    if (indexPath.row == readMoreIndex && isReadMoreSelected){
        Coupon * coupon = [_couponStore allCoupons][indexPath.row - 1];
        return coupon.couponReadMoreView.frame.size.height;
    }
    else{
        int correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        return coupon.couponImageView.frame.size.height;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get cell to reuse
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Coupon" forIndexPath:indexPath];


    /* if the path of the cell that is to be displayed is a readmore view */
    if (indexPath.row == readMoreIndex && isReadMoreSelected){
        /* get correct coupon */
        Coupon * coupon = [_couponStore allCoupons][indexPath.row - 1];
        /* clean cell before using */
        [[cell.contentView viewWithTag:TAG_TYPE_IMAGE_VIEW]removeFromSuperview];
        /* add readmore view */
        [cell.contentView addSubview:coupon.couponReadMoreView];
        coupon.couponReadMoreView.tag = TAG_TYPE_READ_MORE_VIEW;
        }
    
    /* else you're displaying a coupon */
    else{
        /* get correct index of the coupon in the couponstore array */
        int correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        /* clean cell before using */
        [[cell.contentView viewWithTag:TAG_TYPE_READ_MORE_VIEW]removeFromSuperview];
        /* add coupon imageview */
        coupon.couponImageView.tag = TAG_TYPE_IMAGE_VIEW;
        [cell.contentView addSubview:coupon.couponImageView];
        //****** add uitableviewcell extension to enable a coupon property (?)
    }
    return cell;
}


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

-(void) removeReadMoreView{
    //first set isreadmoreselected to false so that when changing rows the table cell count is adjusted
    isReadMoreSelected = NO;

    NSIndexPath * path = [NSIndexPath indexPathForRow:readMoreIndex inSection:0];
    UITableViewCell * readMoreCell = [self.tableView cellForRowAtIndexPath:path];
    [[readMoreCell.contentView viewWithTag:TAG_TYPE_READ_MORE_VIEW]removeFromSuperview];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
    _currSelectedCoupon.selected = NO;
    _currSelectedCoupon = nil;
    readMoreIndex = -1;
    
}

-(void) insertReadMoreViewForCoupon:(Coupon *) coupon atIndexPath:(NSIndexPath *) indexPath{
    NSLog(@"inserting readmoreview for coupon at index path: %d", indexPath.row);
    _currSelectedCoupon = coupon;
    _currSelectedCoupon.selected = YES;
    
    readMoreIndex = indexPath.row + 1;
    isReadMoreSelected = YES;
    NSIndexPath * path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"touched coupon at index path: %d", indexPath.row);
    if (indexPath.row != readMoreIndex || ! isReadMoreSelected){
        int correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        
        /* if coupon is already selected, remove it's read more box and update the readmoreindeces array */
        if (coupon.selected){
            NSLog(@"coupon deselected");
            [self removeReadMoreView];
        }
        
        //if the coupon is not already selected, add it's read more box in the next cell and update the readmoreindeces array
        else{
            
            if (isReadMoreSelected){
                if (readMoreIndex < indexPath.row)
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self removeReadMoreView];

            }
            
            NSLog(@"coupon selected");
            [self insertReadMoreViewForCoupon:coupon atIndexPath:indexPath];
        }
    }

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
