//
//  WHWineriesListViewController.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <PCDefaults/PCDefaults.h>

#import "WHWineriesListViewController.h"
#import "WHWineryViewController.h"
#import "WHWineriesMapViewController.h"
#import "WHWineryViewCells.h"
#import "WHSearchResultsCell.h"
#import "WHFilterBarView.h"
#import "WHLoadingHUD.h"
#import "WHStateMO.h"
#import "PCDCollectionMergeManagerFixStart.h"

#import "WHWineryMO+Additions.h"

#import "UIColor+WineHoundColors.h"
#import "CLLocation+AltDistance.h"

typedef NS_ENUM(NSInteger, WHWineriesListFilter) {
    WHWineriesListFilterNil,
    WHWineriesListFilterAZ,
    WHWineriesListFilterLocation,
};

@interface WHWineriesListViewController () <PCDCollectionTableViewManagerDataSource>
{
    CFTimeInterval _lastLocationUpdate;

    CLLocation __strong * _filterLocation;
}
@property (nonatomic,strong) PCDCollectionMergeManager * collectionManager;
@property (nonatomic) CFTimeInterval lastReloadTime;
- (void)setWineryFilter:(WHWineriesListFilter)filter;
@end

@implementation WHWineriesListViewController

#pragma mark
#pragma mark View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    CGFloat topEdgeInset = .0;
    topEdgeInset += [[UIApplication sharedApplication] statusBarFrame].size.height;
    topEdgeInset += 44.0;//CGRectGetHeight(self.navigationController.navigationBar.bounds);
    topEdgeInset += CGRectGetHeight(self.filterBarView.bounds);
    [self.tableView setContentInset:UIEdgeInsetsMake(topEdgeInset, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0)];
    [self.tableView setScrollIndicatorInsets:self.tableView.contentInset];
    
    [self.tableView registerNib:[WHWineryNormalViewCell nib]  forCellReuseIdentifier:[WHWineryNormalViewCell reuseIdentifier]];
    [self.tableView registerNib:[WHWineryPremiumViewCell nib] forCellReuseIdentifier:[WHWineryPremiumViewCell reuseIdentifier]];
    [self.tableView setDelaysContentTouches:NO];
    [self.tableView setScrollsToTop:YES];

    PCDCollectionTableViewManager * tableManager = [[PCDCollectionTableViewManager alloc] initWithDecoratedObject:self];
    [tableManager setTableView:self.tableView];
    [self setTableManager:tableManager];

    [[(WHFilterBarView *)self.filterBarView segmentedControl] setSelectedSegmentIndex:1];

    NSInteger selectedSegmentIndex = [[(WHFilterBarView *)self.filterBarView segmentedControl] selectedSegmentIndex];
    WHWineriesListFilter filter = selectedSegmentIndex==0?WHWineriesListFilterLocation:WHWineriesListFilterAZ;

    _collectionManager = [self collectionManagerWithFilter:filter];
    [self.tableManager setCollectionManager:self.collectionManager];

    __weak typeof (self) weakSelf = self;

    //Need set network update block since 'tableManager setCollectionManager' resets it.
    [_collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
        [weakSelf setDisplayNoResults:noResults];
        [weakSelf.tableView setTableFooterView:nil];
        if (success)
            [weakSelf setLastReloadTime:CACurrentMediaTime()];
    }];
    
    /*
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        [self setWineryFilter:WHWineriesListFilterLocation];
        [[(WHFilterBarView *)self.filterBarView segmentedControl] setSelectedSegmentIndex:0];
    } else {
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    /*
    [self.collectionManager.fetchedResultsController setDelegate:(id)self.collectionManager];
    
    [self.tableManager setCollectionManager:self.collectionManager];
    
    __weak typeof (self) weakSelf = self;

    [_collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
        [weakSelf setDisplayNoResults:noResults];
        [weakSelf.tableView setTableFooterView:nil];
        if (success)
            [weakSelf setLastReloadTime:CACurrentMediaTime()];
    }];

     */

    if (CACurrentMediaTime()-self.lastReloadTime > (60*30)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableManager.collectionManager reload];
        });
    } else {
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionManager reloadFetchedResultsController];
        });
         */
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

    /*
    [self.tableManager setCollectionManager:nil];
    [self.collectionManager.fetchedResultsController setDelegate:nil];
     */
}

#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"DisplayWinery"]) {
        WHWineryMO * winery = (WHWineryMO *)sender;
        WHWineryViewController * wineryVC = (WHWineryViewController*)segue.destinationViewController;
        [wineryVC setWineryId:winery.wineryId];
    }
}

#pragma mark

- (void)setRegionId:(NSNumber *)regionId
{
    _regionId = regionId;

    /*
    if ([self isViewLoaded]) {
        if (self.filterBarView.segmentedControl.selectedSegmentIndex == 0) {
            [self setWineryFilter:WHWineriesListFilterLocation];
        } else {
            [self setWineryFilter:WHWineriesListFilterAZ];
        }
    }
     */
}

#pragma mark

- (PCDCollectionManager *)searchCollectionManager
{
    if (_searchCollectionManager == nil) {
        __weak typeof (self) weakSelf = self;
        PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHWineryMO class]];
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            //Dangerous
            WHWineryMO * wineryObject = [weakSelf.searchCollectionManager.objects objectAtIndex:index];
            return @{ @"name" : [wineryObject name] ?: @"" };
        }];
        _searchCollectionManager = (PCDCollectionManager *)collectionManager;
    }
    return _searchCollectionManager;
}

- (PCDCollectionMergeManager *)collectionManagerWithFilter:(WHWineriesListFilter)filter
{
    PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHWineryMO class]];
    
    __weak PCDCollectionMergeManager * weakCollectionManager = collectionManager;
    
    //Location filter
    if (filter == WHWineriesListFilterLocation) {
        CLLocation * location = [self.locationManager.location copy];
        PCDCollectionFilter * proximityFilter = [PCDCollectionFilter filterNearLatitude:@(location.coordinate.latitude)
                                                                              longitude:@(location.coordinate.longitude)
                                                                            maxDistance:@(5000)];
        
        [collectionManager setComparator:^NSComparisonResult(id<ProximitySortable> obj1, id<ProximitySortable> obj2) {
            NSNumber *obj1Distance = @([obj1.location altDistanceFromLocation:location]);
            NSNumber *obj2Distance = @([obj2.location altDistanceFromLocation:location]);
            return [obj1Distance compare:obj2Distance];
        }];
        
        _filterLocation = location;
        
        [collectionManager addFilter:proximityFilter];
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            WHWineryMO * wineryObject = [weakCollectionManager.objects objectAtIndex:index];
            CLLocationDistance distance = [wineryObject.location altDistanceFromLocation:location];
            return @{@"distance": @(distance),@"name":wineryObject.name ?: @""};
        }];
    } else {
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            WHWineryMO * wineryObject = [weakCollectionManager.objects objectAtIndex:index];
            return @{ @"name" : [wineryObject name] ?: @"" };
        }];
    }

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
        [collectionFilter setPredicate:[NSPredicate predicateWithFormat:@"ANY %@ CONTAINS stateIds",filterArray]];
        [collectionFilter setParameters:@{@"states":filterArray}];
        [collectionManager addFilter:collectionFilter];
    }
    
    //Region filter
    if (self.regionId != nil) {
        PCDCollectionFilter * regionFilter = [PCDCollectionFilter new];
        [regionFilter setPredicate:[NSPredicate predicateWithFormat:@"ANY regions.regionId == %@",self.regionId]];
        [regionFilter setParameters:@{@"region":self.regionId.stringValue}];
        [collectionManager addFilter:regionFilter];
    }
    
    if (self.fetchWineryType > 0) {
        NSString * typeString = nil;
        switch (self.fetchWineryType) {
            case WHWineryTypeBrewery: typeString = @"Brewery";
                break;
            case WHWineryTypeCidery:  typeString = @"Cidery";
                break;
            case WHWineryTypeWinery:  typeString = @"Winery";
                break;
            default:
                break;
        }

        PCDCollectionFilter * wineriesFilter = [PCDCollectionFilter new];
        [wineriesFilter setPredicate:[NSPredicate predicateWithFormat:@"type == %i",self.fetchWineryType]];
        if (typeString != nil) {
            [wineriesFilter setParameters:@{@"type":typeString}];
        }
        [collectionManager addFilter:wineriesFilter];
        
        if (self.fetchWineryType == WHWineryTypeCidery ||
            self.fetchWineryType == WHWineryTypeBrewery) {
            [collectionManager.fetchedResultsController.fetchRequest setIncludesSubentities:YES];
            [(RKFetchRequestManagedObjectCache *)collectionManager.managedObjectCache setExcludeSubentities:NO];
        }
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
                    [self setWineryFilter:WHWineriesListFilterLocation];
                default:
                    break;
            }
        }
    } else {
        [self setWineryFilter:WHWineriesListFilterAZ];
    }
}

- (void)updateFilters
{
    NSInteger selectedSegmentIndex = [[(WHFilterBarView *)self.filterBarView segmentedControl] selectedSegmentIndex];
    if (selectedSegmentIndex == 0) {
        [self setWineryFilter:WHWineriesListFilterLocation];
    } else {
        [self setWineryFilter:WHWineriesListFilterAZ];
    }
}

#pragma mark

- (void)updatedLocation:(CLLocationManager *)locationManager
{
    CFTimeInterval currentTime = CACurrentMediaTime();
    if (currentTime-_lastLocationUpdate > 30.0) {
        for (WHWineryNormalViewCell * visibleCell in self.tableView.visibleCells) {
            if (visibleCell.winery != nil) {
                [visibleCell setDistance:[self.locationManager.location distanceFromLocation:visibleCell.winery.location]];
            }
        }
        _lastLocationUpdate = currentTime;
    }
    
    NSInteger selectedSegmentIndex = [[(WHFilterBarView *)self.filterBarView segmentedControl] selectedSegmentIndex];
    if (selectedSegmentIndex == 0) {
        CLLocationDistance changeInLocation = [self.locationManager.location distanceFromLocation:_filterLocation];
        if (changeInLocation > 100 || changeInLocation < 0) {
            //Trigger reload
            [self setWineryFilter:WHWineriesListFilterLocation];
        }
    }
}

#pragma mark

- (void)setWineryFilter:(WHWineriesListFilter)filter
{
    if (filter == WHWineriesListFilterLocation) {
        [self.locationManager startUpdatingLocation];
    }
    [self setDisplayNoResults:NO];

    _collectionManager = [self collectionManagerWithFilter:filter];

    [self.tableManager setCollectionManager:self.collectionManager];
    
    __weak typeof (self) weakSelf = self;
    
    //Need set network update block since 'tableManager setCollectionManager' resets it.
    [_collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
        [weakSelf setDisplayNoResults:noResults];
        [weakSelf.tableView setTableFooterView:nil];
        if (success)
            [weakSelf setLastReloadTime:CACurrentMediaTime()];
    }];
    
    [self.tableManager.collectionManager reload];
    
    [self.tableView setContentOffset:CGPointMake(.0, -self.tableView.contentInset.top) animated:NO];
}

#pragma mark WHFilterViewControllerDelegate

- (void)filterViewController:(WHFilterViewController *)vc didSelectFilterItem:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        [[Mixpanel sharedInstance] track:@"Filtered Winery by Country" properties:@{@"country_name": indexPath.row == 0 ?
                                                                                    @"Australia" :
                                                                                    @"New Zealand"}];
    } else if (indexPath.section == 1) {
        WHStateMO * state = self.stateFilters[indexPath.row];
        [[Mixpanel sharedInstance] track:@"Filtered Winery by State" properties:@{@"state_name": state.name}];
    }
    
    [super filterViewController:vc didSelectFilterItem:indexPath];
}

#pragma mark UITableViewDataSource

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([tableView isEqual:self.tableView]) {
            return _collectionManager.objects.count;
        } else {
            NSString * searchString = self.filterBarView.searchTextField.text;
            if ([searchString isEqualToString:[NSString string]] || searchString.length == 0) {
                return 0;
            } else {
                return _searchTableManager.collectionManager.objects.count;
            }
        }
    } else {
        // Loading indicator row's section.
        return 1;
    }
}
 */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([tableView isEqual:self.tableView]) {
            WHWineryMO * winery = [self.tableManager.collectionManager.objects objectAtIndex:indexPath.row];
            if (winery.type.intValue == WHWineryTypeBrewery ||
                winery.type.intValue == WHWineryTypeCidery)
            {
                return [WHWineryNormalViewCell cellHeight];
            } else {
                switch (winery.tierValue) {
                    case WHWineryTierBronze:
                    case WHWineryTierSilver:
                        return 155.0;
                        break;
                    case WHWineryTierGold:
                    case WHWineryTierGoldPlus:
                        return [WHWineryPremiumViewCell cellHeight];
                        break;
                    default:
                        return [WHWineryNormalViewCell cellHeight];
                        break;
                }
            }
        } else {
            return [WHSearchResultsCell cellHeight];
        }
    }
    return 44;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView contentCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineryMO * winery = nil;
    if ([tableView isEqual:self.tableView]) {
        winery = [self.tableManager.collectionManager.objects objectAtIndex:indexPath.row];
    } else {
        winery = [_searchTableManager.collectionManager.objects objectAtIndex:indexPath.row];
    }
    
    UITableViewCell * cell = nil;
    if ([tableView isEqual:self.tableView]) {
        WHWineryNormalViewCell *wineryCell = nil;
        if (winery.tierValue > WHWineryTierBronze ||
            (winery.type.intValue == WHWineryTypeBrewery ||
             winery.type.intValue == WHWineryTypeCidery))
        {
            wineryCell = [self.tableView dequeueReusableCellWithIdentifier:[WHWineryNormalViewCell reuseIdentifier]];
        } else {
            wineryCell = [self.tableView dequeueReusableCellWithIdentifier:[WHWineryPremiumViewCell reuseIdentifier]];
        }
        
        [wineryCell setWinery:winery];
        [wineryCell setDistance:[[self.locationManager location] distanceFromLocation:winery.location]];
        [wineryCell setDistanceLabelHidden:([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)];
        
        //SWTableViewCell
        [wineryCell setRightUtilityButtons:nil];
        [wineryCell setDelegate:(id)self];
        [wineryCell setContainingTableView:tableView];

        cell = wineryCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:[WHSearchResultsCell reuseIdentifier]];
        [cell.textLabel setText:winery.name];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineryMO * winery = nil;
    if ([tableView isEqual:self.tableView]) {
        winery = [self.tableManager.collectionManager.objects objectAtIndex:indexPath.row];
    } else {
        winery = [_searchTableManager.collectionManager.objects objectAtIndex:indexPath.row];
    }
    
    if (winery.type.integerValue == WHWineryTypeCidery ||
        winery.type.integerValue == WHWineryTypeBrewery) {
        //push map view controller...
        WHWineriesMapViewController * wineriesMapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WHWineriesMapViewController"];
        [wineriesMapVC setRegionId:self.regionId];
        [wineriesMapVC setDisplayCalloutForWineryId:winery.wineryId];
        [wineriesMapVC setFetchWineryTypes:WHWineryMapTypeWinery|WHWineryMapTypeCidery|WHWineryMapTypeBrewery];
        [wineriesMapVC setTitle:@"Map"];
        [self.navigationController pushViewController:wineriesMapVC animated:YES];
    } else {
        [self performSegueWithIdentifier:@"DisplayWinery" sender:winery];
    }
}

@end
