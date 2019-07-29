//
//  WHCellarDoorViewController.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalRequests.h>
#import <MagicalRecord/NSManagedObject+MagicalRecord.h>

#import "WHCellarDoorViewController.h"
#import "WHWineryMO+Additions.h"
#import "WHCellarDoorCell.h"
#import "WHPhotographMO+Mapping.h"

#import "TableHeaderView.h"

#import "PCGalleryViewController.h"
#import "PCPhoto.h"

@interface WHCellarDoorViewController ()
@property (nonatomic) WHWineryMO * winery;
@end

@implementation WHCellarDoorViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Cellar Door"];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView registerNib:[WHCellarDoorCell nib]  forCellReuseIdentifier:[WHCellarDoorCell reuseIdentifier]];
    
    [self.tableHeaderView reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableHeaderView.titleLabel setText:self.winery.name];
    [self.tableHeaderView.favouriteButton setHidden:YES];
}

- (BOOL)isLoadingOpeningTimes
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/cellar_door_open_times"];
    return operations.count > 0;
}

#pragma mark Accesor

- (WHWineryMO *)winery
{
    if (_winery == nil) {
        NSManagedObjectContext * context = [[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext];
        NSFetchRequest *request = [WHWineryMO MR_requestFirstByAttribute:@"wineryId" withValue:_wineryId inContext:context];
        [request setIncludesSubentities:NO];
        _winery = [WHWineryMO MR_executeFetchRequestAndReturnFirstObject:request];
    }
    return _winery;
}

#pragma mark
#pragma mark WHDetailViewControllerProtocol

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return NO;
}

- (NSInteger)numberOfPhotographs
{
    return [self.winery.cellarDoorPhotographs count];
}

- (NSURL *)photographURLAtIndex:(NSInteger)index
{
    WHPhotographMO * photograph = [self.winery.cellarDoorPhotographs objectAtIndex:index];
    return [NSURL URLWithString:photograph.imageThumbURL];
}

#pragma mark
#pragma mark 

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * hv = [UIView new];
    [hv setBackgroundColor:[UIColor whiteColor]];
    return hv;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WHCellarDoorCell cellHeightForWineryObject:self.winery truncated:NO];
}
                
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:[WHCellarDoorCell reuseIdentifier]];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHCellarDoorCell * cellarDoorCell = (WHCellarDoorCell*)cell;
    [cellarDoorCell setCellarDoorText:self.winery.cellarDoorDescription truncated:NO];
    [cellarDoorCell setOpeningHoursString:[NSAttributedString openHoursAttributedStringWithObject:self.winery]];
    [cellarDoorCell setDelegate:(id)self];
    [cellarDoorCell.readMoreButton setHidden:YES];
    
    if ([self isLoadingOpeningTimes]) {
        [cellarDoorCell.activityIndicatorView startAnimating];
    } else {
        [cellarDoorCell.activityIndicatorView stopAnimating];
    }
}

#pragma mark PCGalleryViewControllerDataSource

- (NSUInteger)numberOfPhotosInGallery:(PCGalleryViewController *)gallery
{
    return [self.winery.cellarDoorPhotographs count];
}

- (PCPhoto *)gallery:(PCGalleryViewController *)gallery photoAtIndex:(NSUInteger)index
{
    WHPhotographMO * photograph = [self.winery.cellarDoorPhotographs objectAtIndex:index];
    
    PCPhoto * photo = [PCPhoto new];
    [photo setPhotoURL:[NSURL URLWithString:photograph.imageURL]];
    [photo setThumbURL:[NSURL URLWithString:photograph.imageThumbURL]];
    return photo;
}


@end