//
//  WHListViewController.m
//  WineHound
//
//  Created by Mark Turner on 10/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <PCDefaults/PCDefaults.h>
#import <CoreLocation/CLLocationManager.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>

#import "WHListViewController.h"

#import "WHSearchResultsCell.h"
#import "WHFilterBarView.h"
#import "WHLoadingHUD.h"
#import "WHNoResultsView.h"

#import "UIColor+WineHoundColors.h"
#import "UIViewController+KeyboardHeight.h"
#import "UIActivityIndicatorView+PCDLoading.h"

#import "WHStateMO.h"

@interface WHListViewController () <PCDCollectionTableViewManagerDataSource,WHFilterViewControllerDelegate>
@property (weak, readonly, nonatomic) WHNoResultsView * noResultsView;
@end

@implementation WHListViewController

@synthesize searchResultsTableView = _searchResultsTableView;

@synthesize countryFilterIndexSet = _countryFilterIndexSet;
@synthesize stateFilterIndexSet   = _stateFilterIndexSet;

#pragma mark 
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        [self.filterBarTopContraint setConstant:0.0];
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self _migrateTableViewToChildViewController:self.tableView];
    
    WHSearchBarView * searchBarView = (WHSearchBarView *)self.filterBarView;
    [searchBarView setSearchBarExpanded:NO];
    [searchBarView.searchTextField setBackgroundColor:[UIColor clearColor]];
    [searchBarView.searchTextField setDelegate:self];
    [searchBarView.cancelButton addTarget:self
                                   action:@selector(filterBarCancelButtonTouchedUpInside:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.filterBarView isKindOfClass:[WHFilterBarView class]]) {
        [[(WHFilterBarView *)self.filterBarView filterButton] addTarget:self
                                                                 action:@selector(filterBarFilterButtonTouchedUpInside:)
                                                       forControlEvents:UIControlEventTouchUpInside];
        [[(WHFilterBarView *)self.filterBarView segmentedControl] setSelectedSegmentIndex:0];
        [[(WHFilterBarView *)self.filterBarView segmentedControl] addTarget:self
                                                                     action:@selector(filterSegmentedControlChangedValue:)
                                                           forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.locationManager startUpdatingLocation];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_searchResultsTableView setFrame:(CGRect){
        .0, .0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)
    }];

    CGRect noResultsViewFrame = _noResultsView.frame;
    noResultsViewFrame.origin.y = CGRectGetMaxY(self.view.bounds) - (CGRectGetHeight(noResultsViewFrame) + CGRectGetHeight(self.tabBarController.tabBar.bounds));
    [_noResultsView setFrame:noResultsViewFrame];
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

- (NSArray *)countryFilters
{
    return @[@"Australia",@"New Zealand"];
}

- (NSArray *)stateFilters
{
    if (_stateFilters == nil) {
        NSMutableArray * compoundPredicates = @[].mutableCopy;
        if (self.countryFilterIndexSet.count > 0) {
            if ([self.countryFilterIndexSet containsIndex:0]) {
                [compoundPredicates addObject:[NSPredicate predicateWithFormat:@"countryId == 1"]];
            }
            if ([self.countryFilterIndexSet containsIndex:1]) {
                [compoundPredicates addObject:[NSPredicate predicateWithFormat:@"countryId == 2"]];
            }
        }
        _stateFilterIndexSet = nil;
        _stateFilters = [WHStateMO MR_findAllWithPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:compoundPredicates]];
    }
    return _stateFilters;
}

- (NSMutableIndexSet *)countryFilterIndexSet
{
    if (_countryFilterIndexSet == nil) {
        NSMutableIndexSet * countryFilterIndexSet = [NSMutableIndexSet new];
        //Set default filters
        if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_NZ"]) {
            [countryFilterIndexSet addIndex:1];
        } else {
            //Australia default for all other locales.
            [countryFilterIndexSet addIndex:0];
        }
        _countryFilterIndexSet = countryFilterIndexSet;
    }
    return _countryFilterIndexSet;
}

- (NSMutableIndexSet *)stateFilterIndexSet
{
    if (_stateFilterIndexSet == nil) {
        NSMutableIndexSet * stateFilterIndexSet = [NSMutableIndexSet new];
        _stateFilterIndexSet = stateFilterIndexSet;
    }
    return _stateFilterIndexSet;
}

- (void)updateFilters
{
    NSLog(@"%s - %@ - %@", __func__,self.countryFilterIndexSet,self.stateFilterIndexSet);
}

- (void)updatedLocation:(CLLocationManager *)locationManager
{
    NSLog(@"%s", __func__);
}

#pragma mark

- (void)_migrateTableViewToChildViewController:(UITableView *)tableView
{
    if (tableView == nil) {
        return;
    }
    
    //TableView logic could be in a UITableViewController subclass.
    
    UITableViewController * tvc = [UITableViewController new];
    [tvc setTableView:tableView];
    [tvc setRefreshControl:[UIRefreshControl new]];
    [tvc.refreshControl addTarget:self action:@selector(refreshControlValueDidChange:) forControlEvents:UIControlEventValueChanged];

    ///
    
    [self addChildViewController:tvc];
    [self.view insertSubview:tvc.view belowSubview:self.filterBarView];

    ///
    
    //MT Note - do we want to be responsbible for adding constraints here?
    
    UIView * tv = tvc.view;
    [tableView removeConstraints:tableView.constraints];
    [tv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tv]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(tv)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tv]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(tv)]];
    [tvc didMoveToParentViewController:self];

    _tableViewController = tvc;
}

#pragma mark 

- (void)setSearchResultsTableView:(UITableView *)searchResultsTableView
{
    _searchResultsTableView = searchResultsTableView;
    
    NSString * searchText = [(WHSearchBarView *)self.filterBarView searchTextField].text;
    
    PCDCollectionManager * collectionManager = [self searchCollectionManager];
    [collectionManager setHudClass:[UIActivityIndicatorView class]];
    [collectionManager addFilter:[PCDCollectionFilter filterWithProperty:@"name"
                                                              beginsWith:searchText]];
    
    PCDCollectionTableViewManager * searchTableManager = [[PCDCollectionTableViewManager alloc] initWithDecoratedObject:self];
    [searchTableManager setTableView:searchResultsTableView];
    [searchTableManager setCollectionManager:collectionManager];

    [collectionManager reload];
    
    _searchTableManager = searchTableManager;
}

- (void)setDisplayNoResults:(BOOL)displayNoResults
{
    if (displayNoResults == YES) {
        if (_noResultsView == nil) {
            WHNoResultsView * noResultsView = [WHNoResultsView new];
            [noResultsView.noResultsLabel setText:self.noResultsMessage];
            [self.view insertSubview:noResultsView belowSubview:self.tableView];
            [self.tableView setBackgroundColor:[UIColor clearColor]];
            _noResultsView = noResultsView;
        }
    } else {
        [_noResultsView removeFromSuperview];
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (NSString *)noResultsMessage
{
    return @"Sorry, no results matched your search.\nPlease try again.";
}

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        CLLocationManager * locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [locationManager setDistanceFilter:1000.0];
        [locationManager setDelegate:(id)self];
        _locationManager = locationManager;
    }
    return _locationManager;
}

#pragma mark 
#pragma mark Actions

- (void)filterBarFilterButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    [[(WHSearchBarView *)self.filterBarView searchTextField] resignFirstResponder];

    if (_filterViewController != nil) {
        [self _hideFilterVC:_filterViewController];
    } else {
        [self setDisplayNoResults:NO];
        
        WHFilterViewController * filterViewController = [WHFilterViewController new];
        [filterViewController setDelegate:self];
        [filterViewController setDataSource:self];
        [filterViewController.view setFrame:(CGRect){.0,
            -CGRectGetHeight(self.view.frame),
            CGRectGetWidth(self.view.frame),
            .0}];
        
        [filterViewController willMoveToParentViewController:self];
        [self.view insertSubview:filterViewController.view belowSubview:self.filterBarView];
        [self addChildViewController:filterViewController];
        [filterViewController didMoveToParentViewController:self];
        
        _filterViewController = filterViewController;
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [filterViewController.view setFrame:(CGRect){
                                 0.0,CGRectGetMaxY(self.filterBarView.frame),
                                 CGRectGetWidth(self.view.frame),
                                 CGRectGetHeight(self.view.frame) - (CGRectGetMaxY(self.filterBarView.frame) + CGRectGetHeight(self.tabBarController.tabBar.bounds))}];
                         } completion:nil];
    }
}

- (void)filterBarCancelButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    [(WHSearchBarView*)self.filterBarView cancel];
}

- (void)filterSegmentedControlChangedValue:(UISegmentedControl *)segmentedControl
{
    NSLog(@"%s", __func__);
}

- (void)_searchTableTapGesture:(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"%s", __func__);
    [(WHSearchBarView*)self.filterBarView cancel];
}

- (void)refreshControlValueDidChange:(UIRefreshControl *)refreshControl
{
    NSLog(@"%s", __func__);

    [self.tableManager.collectionManager reload];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

#pragma mark
#pragma mark WHFilterViewControllerDelegate

- (BOOL)filterViewController:(WHFilterViewController *)vc filterItemSelected:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self.countryFilterIndexSet containsIndex:indexPath.row];
    } else {
        return [self.stateFilterIndexSet containsIndex:indexPath.row];
    }
    return NO;
}

- (void)filterViewController:(WHFilterViewController *)vc didSelectFilterItem:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self.countryFilterIndexSet containsIndex:indexPath.row]) {
            [self.countryFilterIndexSet removeIndex:indexPath.row];
        } else {
            [self.countryFilterIndexSet addIndex:indexPath.row];
        }
        _stateFilters = nil;
    } else {
        if ([self.stateFilterIndexSet containsIndex:indexPath.row]) {
            [self.stateFilterIndexSet removeIndex:indexPath.row];
        } else {
            [self.stateFilterIndexSet addIndex:indexPath.row];
        }
    }

    BOOL filtersSelected = (self.countryFilterIndexSet.count > 0) || (self.stateFilterIndexSet.count > 0);
    [[(WHFilterBarView *)self.filterBarView filterButton] setSelected:filtersSelected];
}

- (void)filterViewController:(WHFilterViewController *)vc didTapHideButton:(UIButton *)hideButton
{
    [self _hideFilterVC:vc];
}

- (void)_hideFilterVC:(UIViewController *)vc
{
    [self updateFilters];

    [vc willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [vc.view setFrame:(CGRect){.0,
                             -CGRectGetHeight(self.view.frame),
                             CGRectGetWidth(self.view.frame),
                             CGRectGetHeight(self.view.frame)}];
                     } completion:^(BOOL finished) {
                         [vc.view removeFromSuperview];
                         [vc removeFromParentViewController];
                     }];
}

#pragma mark WHFilterViewControllerDataSource

- (NSInteger)filterViewControllerNumberOfFilterSections:(WHFilterViewController *)vc
{
    if (self.countryFilterIndexSet.count > 0) {
        return 2;
    }
    return 1;
}

- (NSString *)filterViewController:(WHFilterViewController *)vc titleForFilterSection:(NSInteger)section
{
    return [@[@"Countries",@"State"] objectAtIndex:section];
}

- (NSString *)filterViewController:(WHFilterViewController *)vc detailForFilterSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        return [[[self.stateFilters objectsAtIndexes:self.stateFilterIndexSet] valueForKey:@"name"] componentsJoinedByString:@", "];
    }
}

- (NSInteger)filterViewController:(WHFilterViewController *)vc numerOfItemsForFilterSection:(NSInteger)section
{
    if (section == 0) {
        return [self.countryFilters count];
    } else {
        return [self.stateFilters count];
    }
}

- (NSString *)filterViewController:(WHFilterViewController *)vc filterItemTitleForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.countryFilters[indexPath.row];
    } else {
        return [self.stateFilters[indexPath.row] valueForKey:@"name"];
    }
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIActivityIndicatorView setCurrentActivityIndicatorView:[(WHSearchBarView*)self.filterBarView activityIndicatorView]];
    [(WHSearchBarView*)self.filterBarView setSearchBarExpanded:YES];
    
    //TODO - issue where by textFieldDidBeginEditing delegate is getting called with view dissapears.
    
    [self.searchResultsTableView removeFromSuperview];
    
    //
    
    UITableView * searchResultsTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
    [searchResultsTableView setContentInset:(UIEdgeInsets){
        .top    = CGRectGetMaxY(self.filterBarView.frame),
        .bottom = [self visibleKeyboardHeight]
    }];
    [searchResultsTableView setScrollIndicatorInsets:searchResultsTableView.contentInset];
    [searchResultsTableView setContentOffset:(CGPoint){.y = -searchResultsTableView.contentInset.top}];
    [searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [searchResultsTableView registerClass:[WHSearchResultsCell class] forCellReuseIdentifier:[WHSearchResultsCell reuseIdentifier]];
    
    UITapGestureRecognizer * searchTableTapGesture = [UITapGestureRecognizer new];
    [searchTableTapGesture addTarget:self action:@selector(_searchTableTapGesture:)];
    [searchTableTapGesture setDelaysTouchesBegan:YES];
    [searchTableTapGesture setDelegate:(id)self];
    
    [searchResultsTableView addGestureRecognizer:searchTableTapGesture];
    
    [self.view insertSubview:searchResultsTableView belowSubview:self.filterBarView];
    [self setSearchResultsTableView:searchResultsTableView];
    
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        [searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
    } completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIActivityIndicatorView setCurrentActivityIndicatorView:nil];
    [(WHSearchBarView*)self.filterBarView setSearchBarExpanded:NO];
    [self.searchResultsTableView removeFromSuperview];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = NO;
    NSString * searchString = nil;

    if([string isEqualToString:@"\n"]) {
        searchString = textField.text;
    } else {
        searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        shouldChange = YES;
    }
    
    PCDCollectionFilter * filter = [PCDCollectionFilter new];
    if (searchString.length) {
        [filter setPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",searchString]];
        [filter setParameters:@{@"name": searchString}];
    }
    [_searchTableManager.collectionManager reloadWithFilter:filter];
    
    return shouldChange;
}

#pragma mark
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    if ([touch.view.superview isKindOfClass:[UITableView class]]) {
        return YES;
    }
    return NO;
}

#pragma mark
#pragma mark Keyboard Notifications

- (void)_keyboardWillShowNotification:(NSNotification *)notification
{
    NSTimeInterval animationDuration    = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    UIEdgeInsets searchTableViewCI = self.searchResultsTableView.contentInset;
    searchTableViewCI.bottom = keyboardSize.height;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.searchResultsTableView setContentInset:searchTableViewCI];
                         [self.searchResultsTableView setScrollIndicatorInsets:searchTableViewCI];
                     } completion:nil];
}

- (void)_keyboardWillHideNotification:(NSNotification *)notification
{
    NSTimeInterval animationDuration    = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    UIEdgeInsets searchTableViewCI = self.searchResultsTableView.contentInset;
    searchTableViewCI.bottom = 0.0;

    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.searchResultsTableView setContentInset:searchTableViewCI];
                         [self.searchResultsTableView setScrollIndicatorInsets:searchTableViewCI];
                     } completion:nil];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    [self updatedLocation:manager];
}


@end
