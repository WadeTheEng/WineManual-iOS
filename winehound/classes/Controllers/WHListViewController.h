//
//  WHListViewController.h
//  WineHound
//
//  Created by Mark Turner on 10/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "WHFilterViewController.h"
#import "WHFilterBarView.h"

@class WHNoResultsView,PCDCollectionTableViewManager,PCDCollectionManager;
@class CLLocationManager;

@interface WHListViewController : UIViewController
<
UITableViewDelegate,
UITextFieldDelegate,
CLLocationManagerDelegate,
WHFilterViewControllerDataSource,
WHFilterViewControllerDelegate>
{
    __weak UITableViewController    * _tableViewController;
    __weak WHFilterViewController   * _filterViewController;
    __weak UITableView              * _searchResultsTableView;
    
    PCDCollectionTableViewManager   * _searchTableManager;
    PCDCollectionManager            * _searchCollectionManager;
}

@property (weak, nonatomic) IBOutlet UITableView     * tableView;
@property (weak, nonatomic) IBOutlet UIView <WHSearchBarViewProtocol> * filterBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterBarTopContraint;

@property (nonatomic) PCDCollectionTableViewManager  * tableManager;
@property (nonatomic) CLLocationManager * locationManager;

@property (nonatomic)        PCDCollectionManager    * searchCollectionManager;
@property (weak, nonatomic)  UITableView             * searchResultsTableView;

@property (nonatomic) BOOL displayNoResults;
@property (nonatomic,readonly) NSString * noResultsMessage;

//Region/Wineries shared filters

@property (nonatomic) NSArray * countryFilters;
@property (nonatomic) NSArray *   stateFilters;

@property (nonatomic,readonly) NSMutableIndexSet * countryFilterIndexSet;
@property (nonatomic,readonly) NSMutableIndexSet *   stateFilterIndexSet;

//

- (void)filterBarCancelButtonTouchedUpInside:(UIButton *)button;
- (void)filterSegmentedControlChangedValue:(UISegmentedControl *)segmentedControl;
- (void)filterBarFilterButtonTouchedUpInside:(UIButton *)button;

- (void)refreshControlValueDidChange:(UIRefreshControl *)refreshControl;

- (void)updateFilters;
- (void)updatedLocation:(CLLocationManager *)locationManager;

@end
