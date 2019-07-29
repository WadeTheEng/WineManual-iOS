//
//  WHWineRangesViewController.m
//  WineHound
//
//  Created by Mark Turner on 07/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>

#import "WHWineRangesViewController.h"
#import "WHWineryMO+Mapping.h"
#import "WHWineRangeMO+Mapping.h"
#import "WHWineViewController.h"

#import "WHLoadingHUD.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@interface WHWineRangesViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray * _wineryRangesArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) WHWineryMO * winery;
@end

@implementation WHWineRangesViewController
@synthesize winery = _winery;

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];

    [self setWinery:[self winery]];
    [self reload];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark

- (void)reload
{
    NSAssert(_wineryId != nil, @"Error - No winery ID provided");
    
    [PCDHUD show];
    
    __weak typeof (self) weakSelf = self;
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"winery"
                                                            object:@{@"wineryId": _wineryId}
                                                        parameters:nil
                                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                               [WHLoadingHUD dismiss];
                                                               [weakSelf setWinery:[weakSelf winery]];
                                                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                               [PCDHUD showError:error];
                                                           }];
}

- (void)setWinery:(WHWineryMO *)winery
{
    _winery = winery;
    _wineryRangesArray = nil;
    
    [self.tableView reloadData];
}

- (WHWineryMO *)winery
{
    if (_winery == nil && _wineryId != nil) {
        WHWineryMO * winery = [WHWineryMO MR_findFirstByAttribute:@"wineryId" withValue:_wineryId];
        _winery = winery;
    }
    return _winery;
}

#pragma mark
#pragma mark

- (NSArray *)rangesArray
{
    if (_wineryRangesArray == nil) {
        _wineryRangesArray = [self.winery.ranges sortedArrayUsingDescriptors:[WHWineRangeMO sortDescriptors]];
    }
    return _wineryRangesArray;
}

#pragma mark
#pragma mark

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * sectionHeaderLabel = [UILabel new];
    [sectionHeaderLabel setFont:[UIFont edmondsansMediumOfSize:20.0]];
    [sectionHeaderLabel setTextColor:[UIColor wh_burgundy]];
    [sectionHeaderLabel setText:@"Our Wine Ranges"];
    [sectionHeaderLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    UIView * headerView = [UIView new];
    [headerView addSubview:sectionHeaderLabel];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView attribute:NSLayoutAttributeLeft
                                                          multiplier:1.0
                                                            constant:10.0]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rangesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineRangeMO * wineRange = [self.rangesArray objectAtIndex:indexPath.row];
    UIImageView * accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"winery_standard_accesory"]];
    UITableViewCell * cell = [UITableViewCell new];
    [cell setAccessoryView:accessoryImageView];
    [cell.textLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [cell.textLabel setTextColor:[UIColor wh_grey]];
    [cell.textLabel setText:wineRange.name];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * wineStoryboard = [UIStoryboard storyboardWithName:@"Wine" bundle:[NSBundle mainBundle]];
    WHWineViewController * wineViewController = [wineStoryboard instantiateInitialViewController];

    WHWineRangeMO * wineRange = [self.rangesArray objectAtIndex:indexPath.row];
    [wineViewController setWineryId:self.winery.wineryId];
    [wineViewController setRangeId:wineRange.rangeId];
    
    [self.navigationController pushViewController:wineViewController animated:YES];
}

@end
