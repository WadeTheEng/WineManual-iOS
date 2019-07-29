//
//  WHFavouriteWineriesViewController.m
//  WineHound
//
//  Created by Mark Turner on 10/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <MagicalRecord/NSManagedObject+MagicalRequests.h>

#import <SWTableViewCell/SWTableViewCell.h>

#import "WHFavouriteWineriesViewController.h"
#import "WHWineryViewController.h"
#import "WHWineryViewCells.h"
#import "WHSearchResultsCell.h"
#import "WHFilterBarView.h"
#import "WHShareManager.h"

#import "WHWineryMO+Additions.h"
#import "WHWineryMO+Mapping.h"
#import "WHFavouriteMO+Additions.h"

@interface WHFavouriteWineriesViewController ()
<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController * _favouriteWineryResultsController;
    NSFetchedResultsController * _searchResultsController;

    WHShareManager * _shareManager;
}
@end

@implementation WHFavouriteWineriesViewController

#pragma mark
#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    [self.tableView registerNib:[WHWineryNormalViewCell nib]  forCellReuseIdentifier:[WHWineryNormalViewCell reuseIdentifier]];
    [self.tableView registerNib:[WHWineryPremiumViewCell nib] forCellReuseIdentifier:[WHWineryPremiumViewCell reuseIdentifier]];

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_favouriteWineryResultsController setDelegate:nil];
    [_searchResultsController setDelegate:nil];
}

- (void)refreshControlValueDidChange:(UIRefreshControl *)refreshControl
{
    [self reload];
    [super refreshControlValueDidChange:refreshControl];
}

- (void)reload
{
    _favouriteWineryResultsController = nil;
    _searchResultsController = nil;
    
    if ([[self favouriteWineryResultsController] performFetch:nil]) {
        [self setDisplayNoResults:!(self.favouriteWineryResultsController.fetchedObjects.count > 0)];

        [[self favouriteWineryResultsController] setDelegate:self];
        [self.tableView reloadData];
    }
}

- (NSString *)noResultsMessage
{
    return @"You haven't saved any Wineries to your\nFavourites yet!";
}

#pragma mark

- (void)setSearchResultsTableView:(UITableView *)searchResultsTableView
{
    [super setSearchResultsTableView:searchResultsTableView];
    [searchResultsTableView setDelegate:self];
    [searchResultsTableView setDataSource:self];
}

#pragma mark

- (NSFetchedResultsController *)favouriteWineryResultsController
{
    if (_favouriteWineryResultsController == nil) {
        NSManagedObjectContext * context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        NSArray * wineryFavourites = [WHFavouriteMO MR_findByAttribute:@"favouriteEntityName"
                                                             withValue:[WHWineryMO entityName]
                                                             inContext:context];
        NSArray * wineryIDs = [wineryFavourites valueForKey:@"favouriteId"];
        
        NSFetchRequest *request = [WHWineryMO MR_requestAllSortedBy:@"name"
                                                          ascending:YES
                                                      withPredicate:[NSPredicate predicateWithFormat:@"wineryId IN %@",wineryIDs]
                                                          inContext:context];
        [request setIncludesSubentities:NO];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                     managedObjectContext:context
                                                                                       sectionNameKeyPath:nil
                                                                                                cacheName:nil];
        [controller setDelegate:self];
        
        _favouriteWineryResultsController = controller;
    }
    return _favouriteWineryResultsController;
}

- (NSFetchedResultsController *)searchWineriesResultsController
{
    if (_searchResultsController == nil) {
        NSManagedObjectContext * context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        NSArray * wineryFavourites = [WHFavouriteMO MR_findByAttribute:@"favouriteEntityName"
                                                             withValue:[WHWineryMO entityName]
                                                             inContext:context];
        NSArray * wineryIDs = [wineryFavourites valueForKey:@"favouriteId"];
        
        NSFetchRequest *request = [WHWineryMO MR_requestAllSortedBy:@"name"
                                                          ascending:YES
                                                      withPredicate:[NSPredicate predicateWithFormat:@"wineryId IN %@",wineryIDs]
                                                          inContext:context];
        [request setIncludesSubentities:NO];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                     managedObjectContext:context
                                                                                       sectionNameKeyPath:nil
                                                                                                cacheName:nil];
        [controller setDelegate:self];

        _searchResultsController = controller;
    }
    return _searchResultsController;
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self favouriteWineryResultsController] sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        NSString * searchString = self.filterBarView.searchTextField.text;
        if ([searchString isEqualToString:[NSString string]] || searchString.length == 0) {
            return 0;
        } else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[[self searchWineriesResultsController] sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineryMO * winery = nil;
    if ([tableView isEqual:self.tableView]) {
        winery = [[self favouriteWineryResultsController] objectAtIndexPath:indexPath];
    } else {
        winery = [[self searchWineriesResultsController] objectAtIndexPath:indexPath];
    }
    
    UITableViewCell * cell = nil;
    if ([tableView isEqual:self.tableView]) {
        WHWineryNormalViewCell *wineryCell = nil;
        if ([tableView isEqual:self.tableView]) {
            if ([winery isPremium] == NO) {
                wineryCell = [tableView dequeueReusableCellWithIdentifier:[WHWineryNormalViewCell reuseIdentifier]];
            } else {
                wineryCell = [tableView dequeueReusableCellWithIdentifier:[WHWineryPremiumViewCell reuseIdentifier]];
            }
        } else {
            wineryCell = [tableView dequeueReusableCellWithIdentifier:[WHSearchResultsCell reuseIdentifier]];
        }
        
        [wineryCell displaySwipeButtons:YES];
        [wineryCell setContainingTableView:tableView];
        [wineryCell setDelegate:self];
        
        [wineryCell setWinery:winery];
        [wineryCell setDistance:[[self.locationManager location] distanceFromLocation:winery.location]];
        
        cell = wineryCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:[WHSearchResultsCell reuseIdentifier]];
        [cell.textLabel setText:winery.name];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([tableView isEqual:self.tableView]) {
            WHWineryMO * winery = [[self favouriteWineryResultsController] objectAtIndexPath:indexPath];
            if ([winery isPremium] == NO) {
                return [WHWineryNormalViewCell cellHeight];
            } else {
                return [WHWineryPremiumViewCell cellHeight];
            }
        } else {
            return [WHSearchResultsCell cellHeight];
        }
    }
    return .0;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineryMO * winery = nil;
    if ([tableView isEqual:self.tableView]) {
        winery = [[self favouriteWineryResultsController] objectAtIndexPath:indexPath];
    } else {
        winery = [[self searchWineriesResultsController] objectAtIndexPath:indexPath];
    }
    
    UIStoryboard * wineriesStoryboard = [UIStoryboard storyboardWithName:@"Wineries" bundle:[NSBundle mainBundle]];
    WHWineryViewController * wineryVC = [wineriesStoryboard instantiateViewControllerWithIdentifier:@"WHWineryViewController"];
    [wineryVC setWineryId:winery.wineryId];
    
    [self.navigationController pushViewController:wineryVC animated:YES];
}

#pragma mark
#pragma mark SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSLog(@"%s - %li", __func__,(long)index);
    WHWineryNormalViewCell * wineryCell = (WHWineryNormalViewCell*)cell;
    if (index == 0) {
        //Tapped Share
         _shareManager = [WHShareManager new];
        [_shareManager presentShareAlertWithObject:wineryCell.winery];
    } else {
        //Tapped delete
        if (wineryCell.winery != nil) {
            [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName] identifier:wineryCell.winery.wineryId];
            [self reload];
        }
    }
}

#pragma mark
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"%s", __func__);
    if ([controller isEqual:self.searchWineriesResultsController]) {
        [self.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}
#pragma mark UITextFieldDelegate

- (BOOL) textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *) string
{
    UITextPosition * beginning = [textField beginningOfDocument];
    UITextPosition * start     = [textField positionFromPosition:beginning offset:range.location];
    NSInteger cursorOffset = [textField offsetFromPosition:beginning toPosition:start] + string.length;

    NSString * searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [textField setText:searchString];
    
    if ([searchString length]) {
        //MT TODO - reuse favourite wineryIDs.
        NSArray * wineryFavourites = [WHFavouriteMO MR_findByAttribute:@"favouriteEntityName"
                                                             withValue:[WHWineryMO entityName]
                                                             inContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
        NSArray * wineryIDs = [wineryFavourites valueForKey:@"favouriteId"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ && wineryId == YES",wineryIDs];
        [[[self searchWineriesResultsController] fetchRequest] setPredicate:predicate];
    }

    NSError * error = nil;
    if ([[self searchWineriesResultsController] performFetch:&error]) {
        [self.searchResultsTableView reloadData];
    } else {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    UITextPosition * newCursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
    UITextRange * newSelectedRange     = [textField textRangeFromPosition:newCursorPosition toPosition:newCursorPosition];
    [textField setSelectedTextRange:newSelectedRange];
    
    return NO;
}

@end