//
//  WHFavouriteWinesViewController.m
//  WineHound
//
//  Created by Mark Turner on 10/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <MagicalRecord/NSManagedObject+MagicalRequests.h>
#import <MagicalRecord/NSManagedObjectContext+MagicalThreading.h>
#import <PCDefaults/PCDAbstractCollectionManager.h>
#import <PCDefaults/PCDCollectionMergeManager.h>
#import <PCDefaults/PCDCollectionFilter.h>

#import "WHFavouriteWinesViewController.h"
#import "WHWineViewController.h"
#import "WHFavouriteWineCell.h"
#import "WHWineryViewCells.h"
#import "WHSearchResultsCell.h"
#import "WHFilterBarView.h"
#import "WHShareManager.h"
#import "WHFavouriteWineSearchBarView.h"
#import "WHNoResultsView.h"

#import "WHWineMO+Mapping.h"
#import "WHWineMO+Additions.h"
#import "WHFavouriteMO+Additions.h"
#import "WHWineVarietyMO.h"

#import "UIFont+Edmondsans.h"

@interface WHFavouriteWinesViewController ()
<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,NSFetchedResultsControllerDelegate>
{
    WHShareManager * _shareManager;
}

@property (nonatomic,readonly) NSFetchedResultsController * favouriteWinesResultsController;
@property (nonatomic) PCDCollectionMergeManager * collectionManager;

@property (nonatomic) NSArray * searchResults;

@property (nonatomic,readonly) NSArray * wineVarieties;
@property (nonatomic,strong) NSMutableIndexSet * varietyFilterIndexSet;

@end

@implementation WHFavouriteWinesViewController
@synthesize wineVarieties = _wineVarieties;

#pragma mark
#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    if ([self.filterBarView isKindOfClass:[WHFavouriteWineSearchBarView class]]) {
        [[(WHFavouriteWineSearchBarView *)self.filterBarView filterButton] addTarget:self
                                                                              action:@selector(filterBarFilterButtonTouchedUpInside:)
                                                                    forControlEvents:UIControlEventTouchUpInside];
    }
    __weak typeof(self) weakSelf = self;
    
    [self setCollectionManager:[PCDCollectionMergeManager collectionManagerWithClass:[WHWineMO class]]];
    [self.collectionManager setSectionNameKeyPath:@"wineTypeName"];
    [self.collectionManager setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"wineTypeName" ascending:YES],
                                                 [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                               ascending:YES
                                                                                selector:@selector(caseInsensitiveCompare:)]]];
    [self.collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
        [weakSelf setDisplayNoResults:noResults];
    }];

    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setContentOffset:CGPointMake(0, 50.0) animated:NO];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reload];
    
    [self.collectionManager.fetchedResultsController setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.collectionManager.fetchedResultsController setDelegate:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_searchResultsTableView setFrame:(CGRect){
        .0,
        50.0,
        CGRectGetWidth(self.view.frame),
        CGRectGetHeight(self.view.frame) - 50.0
    }];
}

#pragma mark
#pragma mark

- (void)refreshControlValueDidChange:(UIRefreshControl *)refreshControl
{
    [self reload];
    
    [super refreshControlValueDidChange:refreshControl];
}

#pragma mark

- (void)reload
{
    NSArray * wineFavourites = [WHFavouriteMO MR_findByAttribute:@"favouriteEntityName"
                                                       withValue:[WHWineMO entityName]
                                                       inContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    NSArray * wineIDs = [wineFavourites valueForKey:@"favouriteId"];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"wineId IN %@",wineIDs];
    if (self.varietyFilterIndexSet.count > 0) {
        NSArray * selectedVarieties  = [self.wineVarieties objectsAtIndexes:self.varietyFilterIndexSet];
        NSMutableArray * selectedIds = [[selectedVarieties valueForKey:@"varietyId"] mutableCopy];
        [selectedIds removeObjectIdenticalTo:[NSNull null]];
        
        NSPredicate * varietiesPredicate = [NSPredicate predicateWithFormat:@"ANY varieties.varietyId IN %@",selectedIds];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate,varietiesPredicate]];
    }
    
    PCDCollectionFilter * filter = [PCDCollectionFilter new];
    [filter setParameters:@{@"wine_ids": wineIDs}];
    [filter setPredicate:predicate];
    [self.collectionManager reloadWithFilter:filter];

    [self.tableView reloadData];

    /*
    [[(WHFavouriteWineSearchBarView *)self.filterBarView filterButton]
     setHidden:!(self.favouriteWinesResultsController.fetchedObjects.count > 0)];
     */
}

- (NSString *)noResultsMessage
{
    return @"You haven't saved any Wines to your\nFavourites yet!";
}

- (NSArray *)wineVarieties
{
    if (_wineVarieties == nil) {
        _varietyFilterIndexSet = nil;

        NSArray * wines = self.favouriteWinesResultsController.fetchedObjects;
        _wineVarieties = [WHWineVarietyMO MR_findAllSortedBy:@"name"
                                                   ascending:YES
                                               withPredicate:[NSPredicate predicateWithFormat:@"ANY wines IN %@",wines]
                                                   inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    return _wineVarieties;
}

- (NSMutableIndexSet *)varietyFilterIndexSet
{
    if (_varietyFilterIndexSet == nil) {
        NSMutableIndexSet * varietyFilterIndexSet = [NSMutableIndexSet new];
        _varietyFilterIndexSet = varietyFilterIndexSet;
    }
    return _varietyFilterIndexSet;
}


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
        [filterViewController.view setFrame:(CGRect){
            -CGRectGetWidth(self.view.frame),
            CGRectGetMaxY(self.filterBarView.frame),
            CGRectGetWidth(self.view.frame),
            CGRectGetHeight(self.view.frame) - (CGRectGetMaxY(self.filterBarView.frame))}];
        
        [filterViewController willMoveToParentViewController:self];
        [self.view addSubview:filterViewController.view];
        [self addChildViewController:filterViewController];
        [filterViewController didMoveToParentViewController:self];
        
        _filterViewController = filterViewController;
        
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [filterViewController.view setFrame:(CGRect){
                                 0.0,
                                 CGRectGetMaxY(self.filterBarView.frame),
                                 CGRectGetWidth(self.view.frame),
                                 CGRectGetHeight(self.view.frame) - (CGRectGetMaxY(self.filterBarView.frame))}];
                         } completion:nil];
    }
}

- (void)_hideFilterVC:(UIViewController *)vc
{
    [self reload];

    [vc willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [vc.view setFrame:(CGRect){
                             CGRectGetWidth(self.view.frame),
                             CGRectGetMaxY(self.filterBarView.frame),
                             CGRectGetWidth(self.view.frame),
                             CGRectGetHeight(self.view.frame) - (CGRectGetMaxY(self.filterBarView.frame))}];
                     } completion:^(BOOL finished) {
                         [vc.view removeFromSuperview];
                         [vc removeFromParentViewController];
                     }];
}

#pragma mark 

- (void)setSearchResultsTableView:(UITableView *)searchResultsTableView
{
    [super setSearchResultsTableView:searchResultsTableView];
    [searchResultsTableView setDelegate:self];
    [searchResultsTableView setDataSource:self];
    [searchResultsTableView setContentInset:UIEdgeInsetsZero];
}

#pragma mark

- (NSFetchedResultsController *)favouriteWinesResultsController
{
    return self.collectionManager.fetchedResultsController;
}

#pragma mark
#pragma mark

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
    
    _searchResults = nil;
    
    if ([searchString length]) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@",searchString];
        _searchResults = [self.favouriteWinesResultsController.fetchedObjects filteredArrayUsingPredicate:predicate];
        [self.searchResultsTableView reloadData];
    }
    
    return YES;
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        return [[[self favouriteWinesResultsController] sections] count];
    } else {
        return self.searchResults.count > 0 ? 1: 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self favouriteWinesResultsController] sections] objectAtIndex:section];
        if (sectionInfo.name.length > 0) {
            return 22.0;
        }
    }
    return 0.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self favouriteWinesResultsController] sections] objectAtIndex:section];
        return [sectionInfo name];
    }
    return nil;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self favouriteWinesResultsController] sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        return [self.searchResults count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = nil;
    if ([tableView isEqual:self.tableView]) {
        WHFavouriteWineCell * cell = (WHFavouriteWineCell*)[tableView dequeueReusableCellWithIdentifier:[WHFavouriteWineCell reuseIdentifier]];
        [cell setContainingTableView:tableView];
        [cell setDelegate:self];

        WHWineMO * wineObject = [[self favouriteWinesResultsController] objectAtIndexPath:indexPath];
        [cell setWine:wineObject];

        return cell;
    } else {
        WHSearchResultsCell * searchCell = [tableView dequeueReusableCellWithIdentifier:[WHSearchResultsCell reuseIdentifier]];

        WHWineMO * wineObject = [self.searchResults objectAtIndex:indexPath.row];
        [searchCell.textLabel setText:wineObject.name];
        
        return searchCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [WHFavouriteWineCell cellHeight];
    } else {
        return [WHSearchResultsCell cellHeight];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineMO * wineObject = nil;
    if ([tableView isEqual:self.tableView]) {
        wineObject = [[self favouriteWinesResultsController] objectAtIndexPath:indexPath];
    } else {
        wineObject = [self.searchResults objectAtIndex:indexPath.row];
    }
    UIStoryboard * wineStoryboard = [UIStoryboard storyboardWithName:@"Wine" bundle:[NSBundle mainBundle]];
    WHWineViewController * wineViewController = [wineStoryboard instantiateInitialViewController];
    [wineViewController setSelectedWineId:wineObject.wineId];
    
    [self.navigationController pushViewController:wineViewController animated:YES];
}

#pragma mark 
#pragma mark SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSLog(@"%s - %li", __func__,(long)index);
    WHFavouriteWineCell * wineCell = (WHFavouriteWineCell*)cell;
    if (index == 0) {
        //Tapped Share
         _shareManager = [WHShareManager new];
        [_shareManager presentShareAlertWithObject:wineCell.wine];
    } else {
        //Tapped delete
        if (wineCell.wine != nil) {
            [WHFavouriteMO favouriteEntityName:[WHWineMO entityName] identifier:wineCell.wine.wineId];
            [self reload];
        }
    }
}

#pragma mark 
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"%s", __func__);
    if ([controller isEqual:self.favouriteWinesResultsController]) {
        [self.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark
#pragma mark WHFilterViewControllerDelegate

- (BOOL)filterViewController:(WHFilterViewController *)vc filterItemSelected:(NSIndexPath *)indexPath
{
    return [self.varietyFilterIndexSet containsIndex:indexPath.row];
}

- (void)filterViewController:(WHFilterViewController *)vc didSelectFilterItem:(NSIndexPath *)indexPath
{
    if ([self.varietyFilterIndexSet containsIndex:indexPath.row]) {
        [self.varietyFilterIndexSet removeIndex:indexPath.row];
    } else {
        [self.varietyFilterIndexSet addIndex:indexPath.row];
    }
}

- (void)filterViewController:(WHFilterViewController *)vc didTapHideButton:(UIButton *)hideButton
{
    [super filterViewController:vc didTapHideButton:hideButton];
}

#pragma mark WHFilterViewControllerDataSource

- (NSInteger)filterViewControllerNumberOfFilterSections:(WHFilterViewController *)vc
{
    return 1;
}

- (NSString *)filterViewController:(WHFilterViewController *)vc titleForFilterSection:(NSInteger)section
{
    return @"Varieties";
}

- (NSString *)filterViewController:(WHFilterViewController *)vc detailForFilterSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)filterViewController:(WHFilterViewController *)vc numerOfItemsForFilterSection:(NSInteger)section
{
    return [self.wineVarieties count];
}

- (NSString *)filterViewController:(WHFilterViewController *)vc filterItemTitleForIndexPath:(NSIndexPath *)indexPath
{
    WHWineVarietyMO * variety = [self.wineVarieties objectAtIndex:indexPath.row];
    return [variety name];
}

@end
