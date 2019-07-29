//
//  WHEventsCalendarViewController.m
//  WineHound
//
//  Created by Mark Turner on 22/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <PCDefaults/PCDefaults.h>
#import <CoreLocation/CoreLocation.h>
#import <V8HorizontalPickerView/V8HorizontalPickerView.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>

#import "WHEventsCalendarViewController.h"
#import "WHEventViewController.h"
#import "WHEventMO+Mapping.h"
#import "WHStateMO.h"
#import "WHEventListCellView.h"
#import "WHFilterViewController.h"
#import "WHEventCalendarViewCell.h"
#import "WHLoadingHUD.h"
#import "PCDCollectionMergeManagerFixStart.h"

#import "NSPredicate+Date.h"
#import "NSCalendar+WineHound.h"
#import "UIRefreshControl+PCDLoading.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "UIViewController+Appearance.h"
#import "CLLocation+AltDistance.h"

@interface WHCalendarViewController () <UICollectionViewDataSource>
- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath;
- (WHEventCalendarViewCell *)cellForItemAtDate:(NSDate *)date;
@end

@interface WHEventsCalendarViewController () <PCDCollectionTableViewManagerDataSource>
{
    __weak IBOutlet UIView  *_collectionViewFooterView;
    
    __weak WHFilterViewController * _filterViewController;

    CLLocationCoordinate2D _previousUsedLocation;
    
    CGFloat _datePickerHeight;
}
@property (nonatomic,strong) PCDCollectionTableViewManager * eventsTableViewManager;
@property (nonatomic,strong) CLLocationManager * locationManager;
@property (nonatomic,weak)   UIRefreshControl  * refreshControl;
@property (nonatomic,strong) NSMutableIndexSet * stateFilterIndexSet;

@property (nonatomic) NSArray * stateFilters;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;

@end

@implementation WHEventsCalendarViewController
@synthesize calendar = _calendar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Events"];
    
    if (self.displayTradeEvents == NO) {
        [self setBurgerNavBarItem];
    }
    
    UIButton * stateFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stateFilterButton addTarget:self action:@selector(_stateFilterButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [stateFilterButton setImage:[UIImage imageNamed:@"event_filter_icon"] forState:UIControlStateNormal];
    [stateFilterButton setImage:[UIImage imageNamed:@"event_filter_selected_icon"] forState:UIControlStateHighlighted];
    [stateFilterButton setImage:[UIImage imageNamed:@"event_filter_selected_icon"] forState:UIControlStateSelected];
    [stateFilterButton setFrame:CGRectMake(.0, .0, 20.0, 44.0)];

    UIBarButtonItem * stateFilterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:stateFilterButton];
    [self.navigationItem setRightBarButtonItem:stateFilterButtonItem];
    
    // Migrate TableView to child view controller
    
    UITableViewController * tvc = [UITableViewController new];
    [tvc setTableView:self.eventsTableView];
    [tvc setRefreshControl:[UIRefreshControl new]];
    [tvc.refreshControl addTarget:self action:@selector(refreshControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [self addChildViewController:tvc];
    [tvc didMoveToParentViewController:self];
    
    [self.eventsTableView setContentInset:(UIEdgeInsets){.bottom = CGRectGetHeight(self.tabBarController.tabBar.bounds)}];
    [self.eventsTableView setScrollIndicatorInsets:self.eventsTableView.contentInset];
    [self.eventsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.eventsTableView registerNib:[WHEventListCellView nib] forCellReuseIdentifier:[WHEventListCellView reuseIdentifier]];
    
    [self setRefreshControl:tvc.refreshControl];
    [UIRefreshControl setCurrentRefreshControl:self.refreshControl];
    
    PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHEventMO class]];
    PCDCollectionTableViewManager * tableManager = [[PCDCollectionTableViewManager alloc] initWithDecoratedObject:self];
    [tableManager setTableView:self.eventsTableView];
    [tableManager setCollectionManager:collectionManager];
    [tableManager.noItemsLabel setText:@"No events found."];
    [tableManager.noItemsLabel setFont:[UIFont edmondsansRegularOfSize:15.0]];
    [tableManager.noItemsLabel setTextColor:[UIColor wh_grey]];
    
    /*
     Removes events older than current date:
     Since RKPaginator doesn't remove orphaned objects, this is no good.
    [collectionManager setConfigurePaginatorBlock:^(RKPaginator * paginator) {
        [paginator setFetchRequestBlocks:@[^NSFetchRequest *(NSURL *URL) {
            RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/events.json"];
            NSDictionary *argsDict = nil;
            if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[WHEventMO entityName]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"startDate < %@",[NSDate date]]];
                [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]]];
                return fetchRequest;
            }
            return nil;
        }]];
    }];
    */
    
    [self setEventsTableViewManager:tableManager];
    
    //
    
    UISwipeGestureRecognizer * swipeGesture = nil;
    
    swipeGesture = [UISwipeGestureRecognizer new];
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [swipeGesture addTarget:self action:@selector(_swipeGesture:)];
    [self.view addGestureRecognizer:swipeGesture];
    
    swipeGesture = [UISwipeGestureRecognizer new];
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [swipeGesture addTarget:self action:@selector(_swipeGesture:)];
    [self.view addGestureRecognizer:swipeGesture];
    
    //initial state
    [_collectionViewFooterView setAlpha:0.0];
    [self.view setNeedsLayout]; //shouldn't be nessasary.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [UIRefreshControl setCurrentRefreshControl:self.refreshControl];

    [self.locationManager startUpdatingLocation];
    
    if (self.monthHorizontalPickerView.currentSelectedIndex == -1) {
        /*
        [self updateDatePickerConstraintAnimated:NO];
         */
                
        //This will trigger a reload.
        [self.monthHorizontalPickerView scrollToElement:0 animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.eventsTableView deselectRowAtIndexPath:[self.eventsTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    [UIRefreshControl setCurrentRefreshControl:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.eventsTableViewManager.noItemsLabel setFrame:(CGRect){
        80.0,
        (CGRectGetHeight(self.eventsTableView.frame) - (self.eventsTableView.contentInset.top + self.eventsTableView.contentInset.bottom)) * 0.5,
        CGRectGetWidth(self.eventsTableView.frame) - 160.0,
        35.0
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return self.displayTradeEvents;
}

#pragma mark 

- (BOOL)cellIndicatorVisibleForDate:(NSDate *)date
{
    /*
     This will be called the for each day of the month when the month changes. 
     Performance hit isn't noticable, but could be improved.
     */
     
    NSDateComponents *components = [self.calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate * beginningOfDay = [self.calendar dateFromComponents:components];
    NSDate * endOfDay       = [beginningOfDay dateByAddingTimeInterval:86400];

    NSManagedObjectContext * context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"(startDate < %@) && (finishDate > %@)",endOfDay,beginningOfDay];

    NSPredicate * currentPredicate = [self.eventsTableViewManager.collectionManager.fetchedResultsController.fetchRequest predicate];
    
    NSPredicate * newPedicate = todayPredicate;
    if (currentPredicate) {
        newPedicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[currentPredicate,todayPredicate]];
    }
    
    NSFetchRequest * todaysEventsRequest = [NSFetchRequest new];
    [todaysEventsRequest setPredicate:newPedicate];
    [todaysEventsRequest setEntity:[NSEntityDescription entityForName:[WHEventMO entityName] inManagedObjectContext:context]];
    [todaysEventsRequest setFetchLimit:1];
    
    NSUInteger todayCount = [context countForFetchRequest:todaysEventsRequest error:nil];
    
    return todayCount > 0;
}

- (void)updateDatePickerConstraintForMonth:(NSInteger)month animated:(BOOL)animated
{
    CGFloat newHeight = .0;
    if (month > 0) {
        NSDateComponents *offset = [NSDateComponents new];
        [offset setMonth:(month-1)+self.monthOffset];

        NSDate * firstOfMonth = [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
        NSRange rangeOfWeeks  = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];
        
        UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout*)self.datePickerCollectionView.collectionViewLayout;
        newHeight = flowLayout.headerReferenceSize.height+(flowLayout.itemSize.height*rangeOfWeeks.length)+(flowLayout.minimumLineSpacing*rangeOfWeeks.length);
        newHeight += 10.0;//Padding
    }
    
    if (month == 0 || _datePickerHeight != newHeight) {
        _datePickerHeight = newHeight;

        UIEdgeInsets tvEdgeInsets = self.eventsTableView.contentInset;
        tvEdgeInsets.top = newHeight;
        
        void(^animationBlock)() = ^{
            [self.eventsTableView setContentInset:tvEdgeInsets];
            [self.eventsTableView setScrollIndicatorInsets:tvEdgeInsets];

            [self.collectionViewTopSpaceConstraint setConstant:month == 0 ? 200 : 0.0];
            [self.collectionViewHeightConstraint setConstant:newHeight];
            
            [_collectionViewFooterView setAlpha:(month > 0 ? 1.0f : 0.0f)];
            
            [_eventsTableView          layoutIfNeeded];
            [_collectionViewFooterView layoutIfNeeded];
        };
        
        if (animated == YES) {
            [UIView animateWithDuration:0.45
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                             animations:animationBlock
                             completion:nil];
        } else {
            [UIView setAnimationsEnabled:NO];
            animationBlock();
            [UIView setAnimationsEnabled:YES];
        }
    }
}

#pragma mark
#pragma mark actions

- (void)refreshControlValueDidChange:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
    [self.eventsTableViewManager.collectionManager reload];
}

- (void)_swipeGesture:(UISwipeGestureRecognizer *)swipeGesture
{
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        if ((self.currentMonth-self.monthOffset) > -1) {
            self.currentMonth --;
        }
    } else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        if ((self.currentMonth-self.monthOffset) < 12) {
            self.currentMonth ++;
        }
    }
    [self.monthHorizontalPickerView scrollToElement:self.currentMonth-(self.monthOffset-1) animated:YES];
}

- (void)_stateFilterButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    if (_filterViewController != nil) {
        //Trigger reload
        [self setCurrentMonth:self.currentMonth];
        
        [self _hideFilterVC:_filterViewController];
    } else {
        WHFilterViewController * filterViewController = [WHFilterViewController new];
        [filterViewController setDelegate:(id)self];
        [filterViewController setDataSource:(id)self];
        [filterViewController.view setFrame:(CGRect){.0,
            -CGRectGetHeight(self.view.frame),
            CGRectGetWidth(self.view.frame),
            .0}];
        
        [filterViewController willMoveToParentViewController:self];
        [self.view addSubview:filterViewController.view];
        [self addChildViewController:filterViewController];
        [filterViewController didMoveToParentViewController:self];
        
        _filterViewController = filterViewController;
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [filterViewController.view setFrame:(CGRect){
                                 0.0,
                                 self.monthHorizontalPickerView.frame.origin.y,
                                 CGRectGetWidth(self.view.frame),
                                 CGRectGetHeight(self.view.frame) - (self.monthHorizontalPickerView.frame.origin.y + CGRectGetHeight(self.tabBarController.tabBar.bounds))}];
                         } completion:nil];
    }
}

#pragma mark
#pragma mark WHFilterViewControllerDelegate

- (BOOL)filterViewController:(WHFilterViewController *)vc filterItemSelected:(NSIndexPath *)indexPath;
{
    return [self.stateFilterIndexSet containsIndex:indexPath.row];
}

- (void)filterViewController:(WHFilterViewController *)vc didSelectFilterItem:(NSIndexPath *)indexPath;
{
    if ([self.stateFilterIndexSet containsIndex:indexPath.row]) {
        [self.stateFilterIndexSet removeIndex:indexPath.row];
    } else {
        [self.stateFilterIndexSet addIndex:indexPath.row];
    }
    
    if ([self.navigationItem.rightBarButtonItem.customView isKindOfClass:[UIButton class]]) {
        UIButton * filterButton = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
        [filterButton setSelected:(self.stateFilterIndexSet.count > 0)];
    }
}

- (void)filterViewController:(WHFilterViewController *)vc didTapHideButton:(UIButton *)hideButton
{
    [self _hideFilterVC:vc];
    [self setCurrentMonth:self.currentMonth];
}

- (void)_hideFilterVC:(UIViewController *)vc
{
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

- (NSString *)filterViewController:(WHFilterViewController *)vc titleForFilterSection:(NSInteger)section
{
    return @"State";
}

- (NSString *)filterViewController:(WHFilterViewController *)vc detailForFilterSection:(NSInteger)section
{
    return [[[self.stateFilters objectsAtIndexes:self.stateFilterIndexSet] valueForKey:@"name"] componentsJoinedByString:@", "];
}

- (NSInteger)filterViewController:(WHFilterViewController *)vc numerOfItemsForFilterSection:(NSInteger)section
{
    return [self.stateFilters count];
}

- (NSString *)filterViewController:(WHFilterViewController *)vc filterItemTitleForIndexPath:(NSIndexPath *)indexPath
{
    return [self.stateFilters[indexPath.row] valueForKey:@"name"];
}

#pragma mark - Accessors

- (NSCalendar *)calendar
{
    if (_calendar == nil) {
        _calendar = [NSCalendar wh_sharedCalendar];
    }
    return _calendar;
}

- (NSMutableIndexSet *)stateFilterIndexSet
{
    if (_stateFilterIndexSet == nil) {
        NSMutableIndexSet * stateFilterIndexSet = [NSMutableIndexSet new];
        _stateFilterIndexSet = stateFilterIndexSet;
    }
    return _stateFilterIndexSet;
}

#pragma mark

#warning TODO - Subclass PCDCollectionTableViewManager & move all below logic:

- (NSArray *)stateFilters
{
    if (_stateFilters == nil) {
        _stateFilterIndexSet = nil;
        _stateFilters = [WHStateMO MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"countryId == 1"]];
    }
    return _stateFilters;
}

- (PCDCollectionFilter *)stateFilter
{
    NSMutableArray * filterArray = @[].mutableCopy;
    
    NSArray * states = [self.stateFilters objectsAtIndexes:self.stateFilterIndexSet];
    [states enumerateObjectsUsingBlock:^(WHStateMO * state, NSUInteger idx, BOOL *stop) {
        [filterArray addObject:state.primaryKey];
    }];
    
    PCDCollectionFilter * stateFilter = [PCDCollectionFilter new];
    [stateFilter setPredicate:[NSPredicate predicateWithFormat:@"ANY %@ CONTAINS stateIds",filterArray]];
    [stateFilter setParameters:@{@"states":filterArray}];
    
    return stateFilter;
}

- (PCDCollectionFilter *)tradeEventFilter
{
    PCDCollectionFilter * tradeEventsFilter = [PCDCollectionFilter new];
    if (self.displayTradeEvents == YES) {
        [tradeEventsFilter setPredicate:[NSPredicate predicateWithFormat:@"tradeEvent == YES"]];
        [tradeEventsFilter setParameters:@{@"trade_event":@(YES)}];
    } else {
        [tradeEventsFilter setPredicate:[NSPredicate predicateWithFormat:@"tradeEvent == NO OR tradeEvent == nil"]];
        [tradeEventsFilter setParameters:@{@"trade_event":@(NO)}];
    }
    return tradeEventsFilter;
}

- (PCDCollectionFilter *)noChildEventsFilter
{
    PCDCollectionFilter * noChildEventsFilter = [PCDCollectionFilter new];
    [noChildEventsFilter setPredicate:[NSPredicate predicateWithFormat:@"parentEventId == nil"]];
    [noChildEventsFilter setParameters:@{@"sub_events":@(NO)}];
    return noChildEventsFilter;
}

- (PCDCollectionFilter *)belongToRegionOrFeatured
{
    NSPredicate * predicate =
    [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"regions.@count > 0"],
                                                        [NSPredicate predicateWithFormat:@"featured == 1"]
                                                        ]];
    
    PCDCollectionFilter * belongToRegionOrFeatured = [PCDCollectionFilter new];
    [belongToRegionOrFeatured setPredicate:predicate];
    [belongToRegionOrFeatured setParameters:@{@"belongs_to_region":@(YES)}];
    return belongToRegionOrFeatured;
}

- (PCDCollectionFilter *)lessThanSevenDaysFilter
{
    NSPredicate * sevenDaysPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:
                                        @[[NSPredicate predicateWithFormat:@"eventLength == nil"],
                                          [NSPredicate predicateWithFormat:@"eventLength <= 7"]]];
    
    PCDCollectionFilter * lessThanSevenDaysFilter = [PCDCollectionFilter new];
    [lessThanSevenDaysFilter setPredicate:sevenDaysPredicate];
    [lessThanSevenDaysFilter setParameters:@{@"short_events":@(YES)}];
    return lessThanSevenDaysFilter;
}

#pragma mark 

- (void)setSelectedDate:(NSDate *)newSelectedDate
{
    if (newSelectedDate != nil) {
        NSDateComponents *components = [self.calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:newSelectedDate];
        PCDCollectionFilter * dayFilter = [PCDCollectionFilter new];
        [dayFilter setPredicate:[NSPredicate predicateForDate:[self.calendar dateFromComponents:components]]];
        [dayFilter setParameters:@{@"day":@(components.day),@"month":@(components.month),@"year":@(components.year)}];
        
        [self.eventsTableViewManager.collectionManager clearFilters];
        [self.eventsTableViewManager.collectionManager setComparator:nil];
        [self.eventsTableViewManager.collectionManager addFilter:dayFilter];

        if (self.stateFilterIndexSet.count > 0) {
            [self.eventsTableViewManager.collectionManager addFilter:self.stateFilter];
        }
        [self.eventsTableViewManager.collectionManager addFilter:self.tradeEventFilter];
        [self.eventsTableViewManager.collectionManager addFilter:self.noChildEventsFilter];
        [self.eventsTableViewManager.collectionManager addFilter:self.belongToRegionOrFeatured];
        [self.eventsTableViewManager.collectionManager addFilter:self.lessThanSevenDaysFilter];
        [self.eventsTableViewManager.collectionManager reload];
    } else {
        [self setCurrentMonth:self.currentMonth];
    }
    [super setSelectedDate:newSelectedDate];
}

- (void)setCurrentMonth:(NSInteger)currentMonth
{
    [super setCurrentMonth:currentMonth];
    
    _selectedDate = nil;
    
    PCDCollectionMergeManager * collectionManager = (PCDCollectionMergeManager *)self.eventsTableViewManager.collectionManager;
    [collectionManager clearFilters];
    
    __weak typeof (self) weakSelf = self;
    
    if (currentMonth-self.monthOffset < 0) {
        if (self.locationManager.location == nil) {
            [self.eventsTableViewManager.noItemsLabel setText:@"Locating..."];
        } else {
            [self.eventsTableViewManager.noItemsLabel setText:@"No events found nearby."];
        }
        CLLocation * location = [self.locationManager location];
        _previousUsedLocation = location.coordinate;
        
        PCDCollectionFilter *filter = [PCDCollectionFilter filterNearLatitude:@(location.coordinate.latitude)
                                                                    longitude:@(location.coordinate.longitude)];
        [collectionManager addFilter:filter];
        [collectionManager setComparator:^NSComparisonResult(id<ProximitySortable> obj1, id<ProximitySortable> obj2) {
            
            NSComparisonResult startDateCompare = [[(WHEventMO *)obj1 startDate] compare:[(WHEventMO *)obj2 startDate]];
            if (startDateCompare) {
                return startDateCompare;
            }
            
            NSNumber *obj1Distance = @([obj1.location altDistanceFromLocation:location]);
            NSNumber *obj2Distance = @([obj2.location altDistanceFromLocation:location]);
            
            NSComparisonResult distanceCompare  = [obj1Distance compare:obj2Distance];
            if (distanceCompare) {
                return distanceCompare;
            }
            
            return NSOrderedSame;
        }];
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            WHEventMO * event = [weakSelf.eventsTableViewManager.collectionManager.objects objectAtIndex:index];
            CLLocation * eventLocation = [[CLLocation alloc] initWithLatitude:event.latitude.doubleValue longitude:event.longitude.doubleValue];
            CLLocationDistance distance = [eventLocation altDistanceFromLocation:location];
            return @{@"distance": @(distance),@"name":event.name ?: @""};
        }];
    } else {
        [self.eventsTableViewManager.noItemsLabel setText:@"No events found."];

        NSDateComponents *components = [self.calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth) fromDate:self.firstOfMonth];
        PCDCollectionFilter * monthFilter = [PCDCollectionFilter new];
        [monthFilter setPredicate:[NSPredicate predicateForStartDate:self.firstOfMonth endDate:self.lastOfMonth]];
        [monthFilter setParameters:@{@"month":@(components.month),@"year":@(components.year)}];
        [collectionManager addFilter:monthFilter];
        [collectionManager setComparator:nil];
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            WHEventMO * event = [weakSelf.eventsTableViewManager.collectionManager.objects objectAtIndex:index];
            return @{ @"name": [event name] ?: @"" };
        }];
    }
    
    if (self.stateFilterIndexSet.count > 0) {
        [self.eventsTableViewManager.collectionManager addFilter:self.stateFilter];
    }
    
    NSDate * dateToday = [NSDate date];
    PCDCollectionFilter * outOfDateFilter = [PCDCollectionFilter new];
    [outOfDateFilter setPredicate:[NSPredicate predicateWithFormat:@"(startDate > %@) OR (finishDate > %@)",dateToday,dateToday]];
    
    [self.eventsTableViewManager.collectionManager addFilter:outOfDateFilter];
    [self.eventsTableViewManager.collectionManager addFilter:self.tradeEventFilter];
    [self.eventsTableViewManager.collectionManager addFilter:self.noChildEventsFilter];
    [self.eventsTableViewManager.collectionManager addFilter:self.belongToRegionOrFeatured];
    [self.eventsTableViewManager.collectionManager addFilter:self.lessThanSevenDaysFilter];
    [self.eventsTableViewManager.collectionManager reload];
    [self.eventsTableView setContentOffset:(CGPoint){.0,-self.eventsTableView.contentInset.top}];
    
    [super updateMonth];
}

#pragma mark

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
#pragma mark PCDCollectionTableViewManagerDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHEventMO * event = [self.eventsTableViewManager.collectionManager.objects objectAtIndex:indexPath.row];
    if (event.featured.boolValue == YES && event.photographs.count > 0) {
        return 155.0;
    } else if (event.regions.count > 0) {
        return 80.0;
    }
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView contentCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO - investigate issue with TableViewManager
    if (self.eventsTableViewManager.collectionManager.objects.count <= 0) {
        return [UITableViewCell new];
    }
    
    WHEventListCellView * eventCell = [tableView dequeueReusableCellWithIdentifier:[WHEventListCellView reuseIdentifier]];
    [eventCell setEvent:[self.eventsTableViewManager.collectionManager.objects objectAtIndex:indexPath.row]];
    [eventCell setTopSeperatorHidden:((indexPath.row==0) && ((self.currentMonth-self.monthOffset) < 0))];

    //SWTableViewCell
    [eventCell setRightUtilityButtons:nil];
    [eventCell setDelegate:(id)self];
    [eventCell setContainingTableView:tableView];

    return eventCell;
}

- (UIView *)tableViewPageLoadingView:(UITableView *)tableView
{
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHEventMO * event = [self.eventsTableViewManager.collectionManager.objects objectAtIndex:indexPath.row];
    
    if (event != nil) {
        [[Mixpanel sharedInstance] track:@"View Event from Calendar"
                              properties:@{@"event_id"   :event.eventId ?: @"",
                                           @"event_name" :event.name    ?: @""}];
    }
    
    UIStoryboard * eventStoryboard = [UIStoryboard storyboardWithName:@"Event" bundle:[NSBundle mainBundle]];
    WHEventViewController * eventViewController = [eventStoryboard instantiateInitialViewController];
    [eventViewController setEventId:event.eventId];

    [WHLoadingHUD dismiss];

    [self.navigationController pushViewController:eventViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL scrollingNessasary = (scrollView.contentSize.height > scrollView.frame.size.height);
    if (scrollingNessasary && scrollView.contentOffset.y > -scrollView.contentInset.top) {
        CGFloat newSpaceValue = scrollView.contentOffset.y + scrollView.contentInset.top;
        newSpaceValue = newSpaceValue < _datePickerHeight ? newSpaceValue : _datePickerHeight;
        [self.collectionViewTopSpaceConstraint setConstant:-MAX(0, newSpaceValue)];
    } else if (self.collectionViewTopSpaceConstraint.constant != 0) {
        [self.collectionViewTopSpaceConstraint setConstant:0];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat newOffY = (targetContentOffset->y + scrollView.contentInset.top);
    if (newOffY <= _datePickerHeight) {
        if (newOffY > (_datePickerHeight*0.5)) {
            targetContentOffset->y = 0.0;
        } else {
            targetContentOffset->y = -scrollView.contentInset.top;
        }
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    if (self.currentMonth-self.monthOffset < 0) {
        CLLocation * currentFilterLocation = [[CLLocation alloc] initWithLatitude:_previousUsedLocation.latitude
                                                                        longitude:_previousUsedLocation.longitude];
        CLLocationDistance distance = [manager.location distanceFromLocation:currentFilterLocation];
        if (distance > 500 && (self.currentMonth-self.monthOffset) < 0) {
            //If 'Nearby' is selected & location has had a major change, trigger a refresh...
            [super setCurrentMonth:self.currentMonth];
        }
        currentFilterLocation = nil;
    }
    [manager stopUpdatingLocation];
}


#pragma mark V8HorizontalPickerViewDelegate

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index
{
    NSLog(@"%s - %li", __func__,(long)index);
    
    [self updateDatePickerConstraintForMonth:index animated:YES];
    
    [super horizontalPickerView:picker didSelectElementAtIndex:index];
}

@end
