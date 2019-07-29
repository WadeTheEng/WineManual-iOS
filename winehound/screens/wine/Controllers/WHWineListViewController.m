//
//  WHWineListViewController.m
//  WineHound
//
//  Created by Mark Turner on 18/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <PCDefaults/PCDefaults.h>
#import "WHWineVarietyMO+Mapping.h"

#import "WHWineListViewController.h"
#import "WHWineViewController.h"
#import "WHWineListCell.h"
#import "WHWineMO.h"
#import "WHLoadingHUD.h"
#import "WHSearchResultsCell.h"
#import "PCDCollectionMergeManagerFixStart.h"

#import "UIColor+WineHoundColors.h"

typedef NS_ENUM(NSInteger, WHWineListFilters){
    WHWineListFiltersVintage = 0,
    WHWineListFiltersVariety,
    WHWineListFiltersCount,
};

@interface WHListViewController ()
- (void)_hideFilterVC:(UIViewController *)vc;
@end

@interface WHWineListViewController () <PCDCollectionTableViewManagerDataSource>
@property (nonatomic,strong) NSMutableIndexSet * vintageFilterIndexSet;
@property (nonatomic,strong) NSMutableIndexSet * varietyFilterIndexSet;

@property (nonatomic,strong) NSArray * wineYears;
@property (nonatomic,strong) NSArray * wineVarieties;

@end

@implementation WHWineListViewController

#pragma mark
#pragma mark View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Wines"];
    
    [self fetchVarietiesFilters];

    UIButton * stateFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stateFilterButton addTarget:self action:@selector(_filterButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [stateFilterButton setImage:[UIImage imageNamed:@"event_filter_icon"] forState:UIControlStateNormal];
    [stateFilterButton setImage:[UIImage imageNamed:@"event_filter_selected_icon"] forState:UIControlStateHighlighted];
    [stateFilterButton setImage:[UIImage imageNamed:@"event_filter_selected_icon"] forState:UIControlStateSelected];
    [stateFilterButton setFrame:CGRectMake(.0, .0, 20.0, 44.0)];
    [stateFilterButton setHidden:YES];
    
    UIBarButtonItem * stateFilterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:stateFilterButton];
    [self.navigationItem setRightBarButtonItem:stateFilterButtonItem];

    
    CGFloat topEdgeInset = .0;
    topEdgeInset += [[UIApplication sharedApplication] statusBarFrame].size.height;
    topEdgeInset += CGRectGetHeight(self.navigationController.navigationBar.bounds);
    topEdgeInset += CGRectGetHeight(self.filterBarView.bounds);
    [self.tableView setContentInset:(UIEdgeInsets){.top = topEdgeInset}];
    [self.tableView setScrollIndicatorInsets:self.tableView.contentInset];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.tableView registerNib:[WHWineListCell nib]  forCellReuseIdentifier:[WHWineListCell reuseIdentifier]];
    [self.tableView setDelaysContentTouches:NO];
    [self.tableView setScrollsToTop:YES];
    
    PCDCollectionTableViewManager * tableManager = [[PCDCollectionTableViewManager alloc] initWithDecoratedObject:self];
    [tableManager setTableView:self.tableView];
    [self setTableManager:tableManager];
    [self updateFilters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.searchResultsTableView deselectRowAtIndexPath:[self.searchResultsTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"DisplayWine"]) {
        WHWineMO * wine = (WHWineMO *)sender;
        WHWineViewController * wineryVC = (WHWineViewController*)segue.destinationViewController;
        [wineryVC setWineryId:wine.wineryId];
        [wineryVC setSelectedWineId:wine.wineId];
        [wineryVC setRangeId:wine.wineRangeId];
    }
}

#pragma mark

- (NSMutableIndexSet *)vintageFilterIndexSet
{
    if (_vintageFilterIndexSet == nil) {
        NSMutableIndexSet * vintageFilterIndexSet = [NSMutableIndexSet new];
        _vintageFilterIndexSet = vintageFilterIndexSet;
    }
    return _vintageFilterIndexSet;
}

- (NSMutableIndexSet *)varietyFilterIndexSet
{
    if (_varietyFilterIndexSet == nil) {
        NSMutableIndexSet * varietyFilterIndexSet = [NSMutableIndexSet new];
        _varietyFilterIndexSet = varietyFilterIndexSet;
    }
    return _varietyFilterIndexSet;
}

#pragma mark 

- (void)updateFilterButton
{
    [self.navigationItem.rightBarButtonItem.customView setHidden:!(self.wineYears.count > 0 && self.wineVarieties.count > 0)];
}

- (void)fetchVarietiesFilters
{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[WHWineVarietyMO mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"/api/wines"
                                                                                           keyPath:@"meta.wine_data.all_varieties"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    __weak typeof (self) weakSelf = self;
    
    NSURLRequest * request = [[RKObjectManager sharedManager] requestWithObject:nil method:RKRequestMethodGET path:@"/api/wines?meta=" parameters:nil];
    
    RKManagedObjectRequestOperation * operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray * sorted = [mappingResult.array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [weakSelf setWineVarieties:sorted];
        
        NSError * parseError = nil;
        NSString * responseString = operation.HTTPRequestOperation.responseString;
        
        if (responseString && ![responseString isEqualToString:@" "]) {
            NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            if (data != nil) {
                NSDictionary * responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if (parseError == nil) {
                    /*
                    NSArray * allVintages = responseJSON[@"meta.wine_data.all_vintages"];
                     */
                    NSArray * allVintages = responseJSON[@"meta"][@"wine_data"][@"all_vintages"];
                    /*
                     No need
                    NSArray * sorted = [allVintages sortedArrayUsingSelector: @selector(compare:)];
                     */
                    [weakSelf setWineYears:allVintages];
                }
            }
        }
        [weakSelf updateFilterButton];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
    
    RKManagedObjectStore * store = [[RKObjectManager sharedManager] managedObjectStore];
    [operation setManagedObjectContext:store.mainQueueManagedObjectContext];
    [operation setManagedObjectCache:store.managedObjectCache];
    
    [operation start];
}

#pragma mark
#pragma mark WHListViewController override

- (PCDCollectionManager *)searchCollectionManager
{
    if (_searchCollectionManager == nil) {
        __weak typeof (self) weakSelf = self;
        PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHWineMO class]];
        [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
            //Dangerous
            WHWineMO * wine = [weakSelf.tableManager.collectionManager.objects objectAtIndex:index];
            return @{ @"name" : [wine name] ?: @"" };
        }];
        _searchCollectionManager = (PCDCollectionManager *)collectionManager;
    }
    return _searchCollectionManager;
}

- (void)setSearchResultsTableView:(UITableView *)searchResultsTableView
{
    _searchResultsTableView = searchResultsTableView;
    
    NSString * searchText = [(WHSearchBarView *)self.filterBarView searchTextField].text;

    PCDCollectionManager * collectionManager = [self searchCollectionManager];
    [collectionManager setHudClass:[UIActivityIndicatorView class]];
    [collectionManager addFilter:[self filterWithString:searchText]];
    
    PCDCollectionTableViewManager * searchTableManager = nil;
    searchTableManager = [[PCDCollectionTableViewManager alloc] initWithDecoratedObject:self
                                                                      collectionManager:collectionManager
                                                                              tableView:searchResultsTableView];
    _searchTableManager = searchTableManager;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [_searchTableManager.collectionManager reloadWithFilter:[self filterWithString:searchText]];
    return YES;
}

- (PCDCollectionFilter *)filterWithString:(NSString *)string
{
    PCDCollectionFilter * searchFilter = [PCDCollectionFilter new];
    if (string.length) {
        NSString * searchText = [string copy];
        NSPredicate * namePredicate        = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchText];
        NSPredicate * varietyNamePredicate = [NSPredicate predicateWithFormat:@"ANY varieties.name CONTAINS[c] %@", searchText];
        NSPredicate * wineryNamePredicate  = [NSPredicate predicateWithFormat:@"ANY wineries.name CONTAINS[c] %@", searchText];
        NSPredicate * compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[namePredicate,varietyNamePredicate,wineryNamePredicate]];
        [searchFilter setPredicate:compoundPredicate];
        [searchFilter setParameters:@{@"name":searchText}];
    }
    return searchFilter;
}

#pragma mark Actions

- (void)_filterButtonTouchedUpInside:(UIButton *)button
{
    /*
     TODO - Refactor.
     */

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
        [self.view insertSubview:filterViewController.view aboveSubview:self.filterBarView];
        [self addChildViewController:filterViewController];
        [filterViewController didMoveToParentViewController:self];
        
        _filterViewController = filterViewController;
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [filterViewController.view setFrame:(CGRect){
                                 0.0,CGRectGetMinY(self.filterBarView.frame),
                                 CGRectGetWidth(self.view.frame),
                                 CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.filterBarView.frame)}];
                         } completion:nil];

    }
}

#pragma mark

- (void)updateFilters
{
    NSLog(@"%s", __func__);

    PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHWineMO class]];
    if (self.vintageFilterIndexSet.count > 0) {
        NSArray * selectedYears = [self.wineYears objectsAtIndexes:self.vintageFilterIndexSet];

        PCDCollectionFilter * vintageFilter = [PCDCollectionFilter new];
        [vintageFilter setPredicate:[NSPredicate predicateWithFormat:@"ANY %@ CONTAINS vintage",selectedYears]];
        [vintageFilter setParameters:@{@"vintages":selectedYears}];
        [collectionManager addFilter:vintageFilter];
    }
    if (self.varietyFilterIndexSet.count > 0) {
        NSArray * selectedVarieties  = [self.wineVarieties objectsAtIndexes:self.varietyFilterIndexSet];
        NSMutableArray * selectedIds = [[selectedVarieties valueForKey:@"varietyId"] mutableCopy];
        [selectedIds removeObjectIdenticalTo:[NSNull null]];
        
        PCDCollectionFilter * varietyFilter = [PCDCollectionFilter new];
        [varietyFilter setPredicate:[NSPredicate predicateWithFormat:@"ANY varieties.varietyId IN %@",selectedIds]];
        [varietyFilter setParameters:@{@"varieties":selectedIds}];
        [collectionManager addFilter:varietyFilter];
    }
    
    __weak typeof (self) blockSelf = self;
    [self.tableManager setCollectionManager:collectionManager];
    [collectionManager setHudClass:[WHLoadingHUD class]];
    [collectionManager.fetchedResultsController.fetchRequest setRelationshipKeyPathsForPrefetching:@[@"photographs"]];
    [collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
        [blockSelf setDisplayNoResults:noResults];
        [blockSelf.tableView setTableFooterView:nil];
    }];
    [collectionManager setSortKeyParamsBlock:^id(NSInteger index) {
        WHWineMO * wine = [blockSelf.tableManager.collectionManager.objects objectAtIndex:index];
        return @{ @"name" : [wine name] ?: @"" };
    }];
    
    [self setDisplayNoResults:NO];
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(.0, -self.tableView.contentInset.top) animated:NO];
    
    [collectionManager reload];
}

#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [WHWineListCell cellHeight];
    } else {
        return [WHSearchResultsCell cellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView contentCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineMO * wine = nil;
    if ([tableView isEqual:self.tableView]) {
        wine = [self.tableManager.collectionManager.objects objectAtIndex:indexPath.row];
    } else {
        wine = [_searchTableManager.collectionManager.objects objectAtIndex:indexPath.row];
    }
    
    if ([tableView isEqual:self.tableView]) {
        WHWineListCell * wineCell = [self.tableView dequeueReusableCellWithIdentifier:[WHWineListCell reuseIdentifier]];
        [wineCell setWine:wine];
        return wineCell;
    } else {
        WHSearchResultsCell * cell = [tableView dequeueReusableCellWithIdentifier:[WHSearchResultsCell reuseIdentifier]];
        [cell.textLabel setText:wine.name];
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineMO * wine = nil;
    if ([tableView isEqual:self.tableView]) {
        wine = [self.tableManager.collectionManager.objects objectAtIndex:indexPath.row];
    } else {
        wine = [_searchTableManager.collectionManager.objects objectAtIndex:indexPath.row];
    }
    [self performSegueWithIdentifier:@"DisplayWine" sender:wine];
}

#pragma mark
#pragma mark WHFilterViewControllerDelegate

- (BOOL)filterViewController:(WHFilterViewController *)vc filterItemSelected:(NSIndexPath *)indexPath
{
    if (indexPath.section == WHWineListFiltersVintage) {
        return [self.vintageFilterIndexSet containsIndex:indexPath.row];
    } else if (indexPath.section == WHWineListFiltersVariety) {
        return [self.varietyFilterIndexSet containsIndex:indexPath.row];
    }
    return NO;
}

- (void)filterViewController:(WHFilterViewController *)vc didSelectFilterItem:(NSIndexPath *)indexPath;
{
    if (indexPath.section == WHWineListFiltersVintage) {
        if ([self.vintageFilterIndexSet containsIndex:indexPath.row]) {
            [self.vintageFilterIndexSet removeIndex:indexPath.row];
        } else {
            [self.vintageFilterIndexSet addIndex:indexPath.row];
        }
    } else if (indexPath.section == WHWineListFiltersVariety) {
        if ([self.varietyFilterIndexSet containsIndex:indexPath.row]) {
            [self.varietyFilterIndexSet removeIndex:indexPath.row];
        } else {
            [self.varietyFilterIndexSet addIndex:indexPath.row];
        }
    }
    BOOL filters = self.vintageFilterIndexSet.count>0||self.varietyFilterIndexSet.count>0;
    UIButton * filterButton = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
    [filterButton setSelected:filters];
}

#pragma mark WHFilterViewControllerDataSource

- (NSInteger)filterViewControllerNumberOfFilterSections:(WHFilterViewController *)vc
{
    return WHWineListFiltersCount;
}

- (NSString *)filterViewController:(WHFilterViewController *)vc titleForFilterSection:(NSInteger)section
{
    if (section == WHWineListFiltersVintage) {
        return @"Vintage";
    } else if (section == WHWineListFiltersVariety) {
        return @"Variety";
    }
    return nil;
}

- (NSString *)filterViewController:(WHFilterViewController *)vc detailForFilterSection:(NSInteger)section
{
    if (section == WHWineListFiltersVintage) {
        NSArray * selectedYears = [self.wineYears objectsAtIndexes:self.vintageFilterIndexSet];
        return [selectedYears componentsJoinedByString:@", "];
    } else if (section == WHWineListFiltersVariety) {
        NSArray * varietyNames = [[self.wineVarieties objectsAtIndexes:self.varietyFilterIndexSet] valueForKey:@"name"];
        return [varietyNames componentsJoinedByString:@", "];
    }
    return nil;
}

- (NSInteger)filterViewController:(WHFilterViewController *)vc numerOfItemsForFilterSection:(NSInteger)section
{
    if (section == WHWineListFiltersVintage) {
        return [self.wineYears count];
    } else if (section == WHWineListFiltersVariety) {
        return [self.wineVarieties count];
    }
    return 0;
}

- (NSString *)filterViewController:(WHFilterViewController *)vc filterItemTitleForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WHWineListFiltersVintage) {
        NSString * year = [self.wineYears objectAtIndex:indexPath.row];
        return year;
    } else if (indexPath.section == WHWineListFiltersVariety) {
        RKManagedObjectStore * store = [[RKObjectManager sharedManager] managedObjectStore];
        NSManagedObjectContext * context = store.mainQueueManagedObjectContext;

        WHWineVarietyMO * variety = [self.wineVarieties objectAtIndex:indexPath.row];

        WHWineVarietyMO * wineVariety = (WHWineVarietyMO*)[context objectWithID:variety.objectID];
        return [wineVariety name];
    }
    return nil;
}

@end
