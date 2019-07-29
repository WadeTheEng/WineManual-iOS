//
//  WHRegionsViewController.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <PCDefaults/PCDefaults.h>

#import "WHRegionsListViewController.h"
#import "WHRegionViewController.h"
#import "WHRegionViewCell.h"
#import "WHFilterBarView.h"
#import "WHFilterViewController.h"
#import "WHWineryViewCells.h"
#import "WHSearchResultsCell.h"
#import "WHLoadingHUD.h"
#import "WHStateMO.h"
#import "PCDCollectionMergeManagerFixStart.h"

#import "WHRegionMO+Additions.h"
#import "CLLocation+AltDistance.h"

#import "UIColor+WineHoundColors.h"
#import "UIViewController+KeyboardHeight.h"
#import "UIFont+Edmondsans.h"
#import "UIViewController+Appearance.h"

typedef NS_ENUM(NSInteger, WHRegionListFilter) {
    WHRegionListFilterNil,
    WHRegionListFilterAZ,
    WHRegionListFilterLocation,
};

@interface WHRegionsListViewController () <PCDCollectionTableViewManagerDataSource>
{
    CFTimeInterval _lastLocationUpdate;
    
    CLLocation __strong * _filterLocation;
}
@property (nonatomic,strong) PCDCollectionMergeManager * collectionManager;
@property (nonatomic) CFTimeInterval lastReloadTime;
- (void)setRegionFilter:(WHRegionListFilter)filter;
@end

@implementation WHRegionsListViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Regions"];
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setWinehoundTitleView];
    
    if (1 == [self.navigationController.viewControllers count]) {
        [self setBurgerNavBarItem];
    }
    
    CGFloat topEdgeInset = .0;
    topEdgeInset += [[UIApplication sharedApplication] statusBarFrame].size.height;
    topEdgeInset += CGRectGetHeight(self.navigationController.navigationBar.bounds);
    topEdgeInset += CGRectGetHeight(self.filterBarView.bounds);
    [self.tableView setContentInset:UIEdgeInsetsMake(topEdgeInset, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0)];
    [self.tableView setScrollIndicatorInsets:self.tableView.contentInset];
    
    PCDCollectionTableViewManager * tableManager = [[PCDCollectionTableViewManager alloc] initWithDecoratedObject:self];
    [tableManager setTableView:self.tableView];
    [self setTableManager:tableManager];

    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        [[(WHFilterBarView *)self.filterBarView segmentedControl] setSelectedSegmentIndex:0];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self setRegionFilter:WHRegionListFilterAZ];
        [[(WHFilterBarView *)self.filterBarView segmentedControl] setSelectedSegmentIndex:1];
    } else {
        [[(WHFilterBarView *)self.filterBarView segmentedControl] setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
    
    //
    
    NSInteger selectedSegmentIndex = [[(WHFilterBarView *)self.filterBarView segmentedControl] selectedSegmentIndex];
    WHRegionListFilter filter = selectedSegmentIndex==0?WHRegionListFilterLocation:WHRegionListFilterAZ;
    
    _collectionManager = [self collectionManagerWithFilter:filter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.filterBarView setNeedsLayout];
    
    [self.collectionManager.fetchedResultsController setDelegate:(id)self.collectionManager];
    [self.tableManager setCollectionManager:self.collectionManager];
    
    __weak typeof (self) weakSelf = self;
    
    [self.collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
        [weakSelf setDisplayNoResults:noResults];
        [weakSelf.tableView setTableFooterView:nil];
        if (success)
            [weakSelf setLastReloadTime:CACurrentMediaTime()];
    }];
    
    if (CACurrentMediaTime()-self.lastReloadTime > (60*30)) {
        [self.tableManager.collectionManager reload];
    } else {
        [self.tableManager.collectionManager reloadFetchedResultsController];
    }

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.searchResultsTableView deselectRowAtIndexPath:[self.searchResultsTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    /*
     We nil the tableManager to avoid updates to tableView whilst VC is in background.
     Particulary if collection manager is sorting by location.
     
     As this VC is holding reference to a colleciton manager, we repair them on 'viewWillAppear'
     */
    [self.tableManager setCollectionManager:nil];
    [self.collectionManager.fetchedResultsController setDelegate:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"DisplayRegion"]) {
        WHRegionMO * regionObject = (WHRegionMO *)sender;
        WHRegionViewController * regionVC = (WHRegionViewController*)segue.destinationViewController;
        [regionVC setRegionId:regionObject.regionId];
    }
}

#pragma mark

- (PCDCollectionManager *)searchCollectionManager
{
    if (_searchCollectionManager == nil) {
        __weak typeof (self) weakSelf = self;

        PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHRegionMO class]];
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            //Dangerous
            WHRegionMO * regionObject = [weakSelf.searchCollectionManager.objects objectAtIndex:index];
            return @{ @"name" : [regionObject name] ?: @"" };
        }];
        _searchCollectionManager = (PCDCollectionManager *)collectionManager;
    }
    return _searchCollectionManager;
}

- (PCDCollectionMergeManager *)collectionManagerWithFilter:(WHRegionListFilter)filter
{
    /*
     TODO - Rewrite filters handling to be shared across Regions/Wineries/Wines/Events
     */
    
    PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHRegionMO class]];
    
    __weak PCDCollectionMergeManager * weakCollectionManager = collectionManager;

    //Country filter
    if (self.countryFilterIndexSet.count > 0) {
        NSMutableArray * filterArray = @[].mutableCopy;
        [self.countryFilterIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [filterArray addObject:@(idx+1)];
        }];
        
        PCDCollectionFilter * collectionFilter = [PCDCollectionFilter new];
        [collectionFilter setPredicate:[NSPredicate predicateWithFormat:@"countryId IN %@",filterArray]];
        if ([self.countryFilterIndexSet containsIndex:0]) {
            NSPredicate * countryPredicate =
            [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"countryId IN %@",filterArray],
                                                                [NSPredicate predicateWithFormat:@"countryId == 0"],
                                                                [NSPredicate predicateWithFormat:@"countryId == nil"]]];
            [collectionFilter setPredicate:countryPredicate];
        }
        [collectionFilter setParameters:@{@"country_id":filterArray}];
        [collectionManager addFilter:collectionFilter];
    }

    //State filter
    if (self.stateFilterIndexSet.count > 0) {
        NSMutableArray * filterArray = @[].mutableCopy;
        NSArray * states = [self.stateFilters objectsAtIndexes:self.stateFilterIndexSet];
        [states enumerateObjectsUsingBlock:^(WHStateMO * state, NSUInteger idx, BOOL *stop) {
            [filterArray addObject:state.primaryKey];
        }];
        
        PCDCollectionFilter * collectionFilter = [PCDCollectionFilter new];
        [collectionFilter setPredicate:[NSPredicate predicateWithFormat:@"stateId IN %@",filterArray]];
        [collectionFilter setParameters:@{@"states":filterArray}];
        
        [collectionManager addFilter:collectionFilter];
    }
    
    if (filter == WHRegionListFilterLocation) {
        CLLocation * location = [self.locationManager.location copy];
        _filterLocation = location;

        PCDCollectionFilter * proximityFilter = [PCDCollectionFilter filterNearLatitude:@(location.coordinate.latitude)
                                                                              longitude:@(location.coordinate.longitude)
                                                                            maxDistance:@(5000)];
        
        [collectionManager addFilter:proximityFilter];
        [collectionManager setComparator:^NSComparisonResult(id<ProximitySortable> obj1, id<ProximitySortable> obj2) {
            NSNumber *obj1Distance = @([obj1.location altDistanceFromLocation:location]);
            NSNumber *obj2Distance = @([obj2.location altDistanceFromLocation:location]);
            return [obj1Distance compare:obj2Distance];
        }];
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            WHRegionMO * regionObject = [weakCollectionManager.objects objectAtIndex:index];
            CLLocationDistance distance = [regionObject.location altDistanceFromLocation:location];
            return @{@"distance": @(distance),@"name":regionObject.name ?: @""};
        }];
    } else {
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            WHRegionMO * regionObject = [weakCollectionManager.objects objectAtIndex:index];
            return @{ @"name" : [regionObject name] ?: @"" };
        }];
    }
    return collectionManager;
}

#pragma mark

- (void)filterSegmentedControlChangedValue:(UISegmentedControl *)segmentedControl
{
    NSLog(@"%s", __func__);
    if (segmentedControl.selectedSegmentIndex == 0) {
        if (NO == [CLLocationManager locationServicesEnabled]) {
            [segmentedControl setSelectedSegmentIndex:1];
            [[[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                        message:@"To re-enable, please enable Location Services in the settings."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        } else {
            CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
            switch (authStatus) {
                case kCLAuthorizationStatusRestricted:
                case  kCLAuthorizationStatusDenied: {
                    [segmentedControl setSelectedSegmentIndex:1];
                    [[[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                message:@"To re-enable, please go to Settings and turn on Location Service for Winehound."
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                    break;
                case kCLAuthorizationStatusAuthorized:
                    [self setRegionFilter:WHRegionListFilterLocation];
                default:
                    break;
            }
        }
    } else {
        [self setRegionFilter:WHRegionListFilterAZ];
    }
}

- (void)updateFilters
{
    NSInteger selectedSegmentIndex = [[(WHFilterBarView *)self.filterBarView segmentedControl] selectedSegmentIndex];
    if (selectedSegmentIndex == 0) {
        [self setRegionFilter:WHRegionListFilterLocation];
    } else {
        [self setRegionFilter:WHRegionListFilterAZ];
    }
}

#pragma mark

- (void)updatedLocation:(CLLocationManager *)locationManager
{
    CFTimeInterval currentTime = CACurrentMediaTime();
    if (currentTime-_lastLocationUpdate > 5.0) {
        for (WHRegionViewCell * visibleCell in self.tableView.visibleCells) {
            if (visibleCell.region != nil) {
                [visibleCell setDistance:[self.locationManager.location distanceFromLocation:visibleCell.region.location]];
            }
        }
        _lastLocationUpdate = currentTime;
    }
    
    NSInteger selectedSegmentIndex = [[(WHFilterBarView *)self.filterBarView segmentedControl] selectedSegmentIndex];
    if (selectedSegmentIndex == 0) {
        CLLocationDistance changeInLocation = [self.locationManager.location distanceFromLocation:_filterLocation];
        if (changeInLocation > 100 || changeInLocation < 0) {
            //Trigger reload
            [self setRegionFilter:WHRegionListFilterLocation];
        }
    }
}

#pragma mark

- (void)setRegionFilter:(WHRegionListFilter)filter
{
    if (filter == WHRegionListFilterLocation) {
        [self.locationManager startUpdatingLocation];
    }
    [self setDisplayNoResults:NO];
    
    _collectionManager = [self collectionManagerWithFilter:filter];
    
    [self.tableManager setCollectionManager:self.collectionManager];

    __weak typeof (self) weakSelf = self;
    
    [self.collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
        [weakSelf setDisplayNoResults:noResults];
        [weakSelf.tableView setTableFooterView:nil];
        if (success)
            [weakSelf setLastReloadTime:CACurrentMediaTime()];
    }];
    
    [self.tableManager.collectionManager reload];
    
    [self.tableView setContentOffset:CGPointMake(.0, -self.tableView.contentInset.top) animated:NO];
}

#pragma mark
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [WHRegionViewCell cellHeight];
    } else {
        return [WHSearchResultsCell cellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView contentCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = nil;
    if ([tableView isEqual:self.tableView]) {
        WHRegionViewCell * regionViewCell = (WHRegionViewCell*)[tableView dequeueReusableCellWithIdentifier:[WHRegionViewCell reuseIdentifier]];
        
        WHRegionMO * region = [self.tableManager.collectionManager.objects objectAtIndex:indexPath.row];
        [regionViewCell setRegion:region];
        [regionViewCell setDistance:[[self.locationManager location] distanceFromLocation:region.location]];
        [regionViewCell setDistanceLabelHidden:([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)];

        cell = regionViewCell;
    } else {
        WHRegionMO * region = [self.searchCollectionManager.objects objectAtIndex:indexPath.row];
        UITableViewCell * searchCell = [tableView dequeueReusableCellWithIdentifier:[WHSearchResultsCell reuseIdentifier]];
        [searchCell.textLabel setText:region.name];
        cell = searchCell;
    }
    return cell;
}

#pragma mark

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHRegionMO * region = nil;
    if ([tableView isEqual:self.tableView]) {
        region = [self.tableManager.collectionManager.objects objectAtIndex:indexPath.row];
    } else {
        region = [self.searchCollectionManager.objects objectAtIndex:indexPath.row];
    }
    [self performSegueWithIdentifier:@"DisplayRegion" sender:region];
}


#pragma mark
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    UISegmentedControl * segmentedControl = [(WHFilterBarView *)self.filterBarView segmentedControl];
    if (status == kCLAuthorizationStatusAuthorized) {
        if (segmentedControl.selectedSegmentIndex != 0) {
            [segmentedControl setSelectedSegmentIndex:0];
            [self setRegionFilter:WHRegionListFilterLocation];
        }
    } else if (status == kCLAuthorizationStatusDenied) {
        //user denied access to location, so we display A-Z results.
        [segmentedControl setSelectedSegmentIndex:1];
        [self setRegionFilter:WHRegionListFilterAZ];
    }
}

@end
