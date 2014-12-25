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
    TAG_TYPE_READ_MORE_VIEW,
    TAG_TYPE_IMAGE_VIEW
} COUPON_VIEW_TAG_TYPES;

@implementation MainTableViewController{
    CouponStore * _couponStore;
    
    NSMutableArray * _readMoreIndeces;
    
    
}


-(id) init{
    self = [super init];
    if (self){
        _couponStore = [CouponStore sharedInstance];
        for (int i = 0; i < 6; i++){
            Coupon * createdCoupon = [_couponStore createCoupon];
            NSLog(@"%@", createdCoupon);
        }
        _readMoreIndeces = [NSMutableArray array];
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

-(int) getReadMoreCount{
    return [_readMoreIndeces count];
}

-(int) correctCouponIndexForIndexPath:(NSIndexPath *) indexPath{
    int currAns = indexPath.row;
    for (int i = 0; i < _readMoreIndeces.count; i++){
        NSNumber * curr = _readMoreIndeces[i];
        if(curr.intValue <= indexPath.row){
            currAns--;
        }
        else{
            break;
        }
    }
    return currAns;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[_couponStore allCoupons] count] + [_readMoreIndeces count];
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //check if index of cell at this index path is a readmore box
    //if it is, return the standard height of a coupon read more box
    //else return the height of the coupon image view frame
    
    int correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
    Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
    
    if ([self isReadMoreIndex:indexPath]){
        return coupon.couponReadMoreView.frame.size.height;
    }
    else{

        return coupon.couponImageView.frame.size.height;
    }
}

-(BOOL) isReadMoreIndex:(NSIndexPath *)indexPath{
    NSLog(@"readmoreindeces count: %d", [_readMoreIndeces count]);
    for (int i = 0; i < [_readMoreIndeces count]; i++){
        NSNumber * curr = (NSNumber *)_readMoreIndeces[i];
        NSLog(@"curr.intvalue : %d", curr.intValue);
        NSLog(@"indexpath.row : %d", indexPath.row);
        if (curr.intValue == indexPath.row){
            NSLog(@"returning yes");
            return YES;
        }
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Coupon" forIndexPath:indexPath];

    NSLog(@"%@", [cell viewWithTag:TAG_TYPE_READ_MORE_VIEW]);
    
    int correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];

    if ([self isReadMoreIndex:indexPath]){
        Coupon * coupon = [_couponStore allCoupons][indexPath.row - 1];
        [cell.contentView addSubview:coupon.couponReadMoreView];
        coupon.couponReadMoreView.tag = TAG_TYPE_READ_MORE_VIEW;
        
        NSLog(@"IS ROW INDEX");
    }
    else{
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        [cell.contentView addSubview:coupon.couponImageView];
        coupon.couponImageView.tag = TAG_TYPE_IMAGE_VIEW;
        //****** add uitableviewcell extension to enable a coupon property
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (! [self isReadMoreIndex:indexPath]){
        int correctCouponIndex = [self correctCouponIndexForIndexPath:indexPath];
        Coupon * coupon = [_couponStore allCoupons][correctCouponIndex];
        
        //if coupon is already selected, remove it's read more box and update the readmoreindeces array
        if (coupon.selected){
            coupon.selected = NO;
            for (int i = 0; i < [_readMoreIndeces count]; i++){
                NSNumber * readMoreIndex = _readMoreIndeces[i];
                if(readMoreIndex.intValue == indexPath.row + 1){
                    [_readMoreIndeces removeObjectAtIndex:i];
                    break;
                }
            }

            NSIndexPath * path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
            UITableViewCell * readMoreCell = [tableView cellForRowAtIndexPath:path];
            [[readMoreCell.contentView viewWithTag:TAG_TYPE_READ_MORE_VIEW]removeFromSuperview];
            [tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];

        }
        
        //if the coupon is not already selected, add it's read more box in the next cell and update the readmoreindeces array
        else{
            coupon.selected = YES;
            NSNumber * readMoreIndex = [NSNumber numberWithInt:indexPath.row + 1];
            [_readMoreIndeces addObject:readMoreIndex];
            NSIndexPath * path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
            [tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
            
    //        [tableView insertSubview:coupon.couponReadMoreView atIndex:indexPath];
    //        [tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
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
