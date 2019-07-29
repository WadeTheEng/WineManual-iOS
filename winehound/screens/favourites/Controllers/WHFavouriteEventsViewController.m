//
//  WHFavouriteEventsViewController.m
//  WineHound
//
//  Created by Mark Turner on 24/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <MagicalRecord/NSManagedObject+MagicalRequests.h>

#import "WHFavouriteEventsViewController.h"
#import "WHEventListCellView.h"
#import "WHFavouriteMO+Additions.h"
#import "WHEventListCellView.h"
#import "WHEventMO+Mapping.h"
#import "WHEventMO+Additions.h"
#import "WHEventViewController.h"
#import "WHShareManager.h"

@interface WHFavouriteEventsViewController ()
<UITableViewDataSource,UITabBarDelegate,NSFetchedResultsControllerDelegate,SWTableViewCellDelegate>
{
    WHShareManager * _shareManager;
}
@property (nonatomic) NSFetchedResultsController * favouriteEventsResultsController;
@end

@implementation WHFavouriteEventsViewController

#pragma mark 
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    [self.tableView registerNib:[WHEventListCellView nib] forCellReuseIdentifier:[WHEventListCellView reuseIdentifier]];
    
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
    [self.favouriteEventsResultsController setDelegate:nil];
}

- (void)reload
{
    _favouriteEventsResultsController = nil;
    
    NSError * error = nil;
    if ([[self favouriteEventsResultsController] performFetch:&error]) {
        [self setDisplayNoResults:!(self.favouriteEventsResultsController.fetchedObjects.count > 0)];

        [self.tableView reloadData];
        [self.favouriteEventsResultsController setDelegate:self];
    } else {
        NSLog(@"Events favourites fetch error: %@",error);
    }
}

- (NSString *)noResultsMessage
{
    return @"You haven't saved any Events to your\nFavourites yet!";
}

#pragma mark

- (NSFetchedResultsController *)favouriteEventsResultsController
{
    if (_favouriteEventsResultsController == nil) {
        NSManagedObjectContext * context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        NSArray * eventFavourites = [WHFavouriteMO MR_findByAttribute:@"favouriteEntityName"
                                                            withValue:[WHEventMO entityName]
                                                            inContext:context];
        NSArray * eventIDs = [eventFavourites valueForKey:@"favouriteId"];
        NSFetchedResultsController * fetchResultsController = [WHEventMO MR_fetchAllGroupedBy:nil
                                                                                withPredicate:[NSPredicate predicateWithFormat:@"eventId IN %@",eventIDs]
                                                                                     sortedBy:@"name"
                                                                                    ascending:YES
                                                                                     delegate:self];
        _favouriteEventsResultsController = fetchResultsController;
    }
    return _favouriteEventsResultsController;
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self favouriteEventsResultsController] sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHEventListCellView * eventCell = [tableView dequeueReusableCellWithIdentifier:[WHEventListCellView reuseIdentifier]];
    [eventCell setEvent:[[self favouriteEventsResultsController] objectAtIndexPath:indexPath]];
    [eventCell displaySwipeButtons:YES];
    [eventCell setContainingTableView:tableView];
    [eventCell setDelegate:self];
    return eventCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHEventMO * event = [[self favouriteEventsResultsController] objectAtIndexPath:indexPath];
    if (event.featured.boolValue == YES && event.photographs.count > 0) {
        return 155.0;
    }
    return 70.0;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHEventMO * event = [[self favouriteEventsResultsController] objectAtIndexPath:indexPath];
    
    UIStoryboard * eventStoryboard = [UIStoryboard storyboardWithName:@"Event" bundle:[NSBundle mainBundle]];
    WHEventViewController * eventViewController = [eventStoryboard instantiateInitialViewController];
    [eventViewController setEventId:event.eventId];
    
    [self.navigationController pushViewController:eventViewController animated:YES];
}

#pragma mark
#pragma mark SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSLog(@"%s - %li", __func__,(long)index);
    WHEventListCellView * eventCell = (WHEventListCellView*)cell;
    if (index == 0) {
        //Tapped Share
         _shareManager = [WHShareManager new];
        [_shareManager presentShareAlertWithObject:eventCell.event];
    } else {
        //Tapped delete
        if (eventCell.event != nil) {
            [WHFavouriteMO favouriteEntityName:[WHEventMO entityName] identifier:eventCell.event.eventId];
            [self reload];
        }
    }
}

#pragma mark
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"%s", __func__);
    [self.tableView reloadData];
}

@end
