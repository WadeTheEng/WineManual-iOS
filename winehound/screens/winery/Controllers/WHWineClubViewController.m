//
//  WHWineClubViewController.m
//  WineHound
//
//  Created by Mark Turner on 12/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <RestKit/RestKit.h>

#import "WHWineClubViewController.h"
#import "WHWebViewController.h"
#import "WHWineryMO+Additions.h"
#import "WHPhotographMO+Mapping.h"

#import "WHWineClubMO.h"
#import "WHWineClubCell.h"
#import "WHLoadingHUD.h"
#import "TableHeaderView.h"

#import "PCGalleryViewController.h"
#import "PCPhoto.h"

@interface WHWineClubViewController () <WHWineClubCellDelegate>

@property (nonatomic) NSNumber * wineryID;
@property (nonatomic) NSNumber * wineClubID;

@property (nonatomic,weak) WHWineClubMO * wineClub;

@end

@implementation WHWineClubViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Wine Club"];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView registerNib:[WHWineClubCell nib]  forCellReuseIdentifier:[WHWineClubCell reuseIdentifier]];
    
    [self.tableHeaderView reload];

    [PCDHUD show];
    
    __weak typeof (self) weakSelf = self;
    [[RKObjectManager sharedManager] getObject:self.wineClub
                                          path:nil
                                    parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                        [WHLoadingHUD dismiss];
                                        [weakSelf setWineClub:[weakSelf wineClub]];
                                        [weakSelf.tableView reloadData];
                                        [weakSelf.tableHeaderView reload];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to fetch Wine club: %@",error);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [WHLoadingHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableHeaderView.titleLabel setText:self.wineClub.clubName];
    [self.tableHeaderView.favouriteButton setHidden:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)isLoadingOpeningTimes
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/cellar_door_open_times"];
    return operations.count > 0;
}

- (NSString *)website
{
    return self.wineClub.website;
}

#pragma mark

- (void)setWineryId:(NSNumber *)wineryId wineClubId:(NSNumber *)wineClubId;
{
    _wineryID   = wineryId;
    _wineClubID = wineClubId;
}

#pragma mark Accesor

- (WHWineClubMO *)wineClub
{
    if (_wineClub == nil) {
        NSAssert(self.wineClubID != nil || self.wineryID != nil, @"Error = no Winery ID provided");
        
        NSManagedObjectContext * context = [[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext];
        WHWineClubMO * wineClub = [WHWineClubMO MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"wineryId == %@ && clubIdentifier == %@",self.wineryID,self.wineClubID]
                                                                inContext:context];
        _wineClub = wineClub;
    }
    return _wineClub;
}

#pragma mark
#pragma mark WHDetailViewControllerProtocol

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return NO;
}

- (NSInteger)numberOfPhotographs
{
    if (self.wineClub.photographs.count > 0) {
        return [self.wineClub.photographs count];
    } else {
        WHWineryMO * winery = [self.wineClub.clubWineries anyObject];
        return [winery.photographs count];
    }
    return 0;
}

- (NSURL *)photographURLAtIndex:(NSInteger)index
{
    WHPhotographMO * photograph = nil;
    if (self.wineClub.photographs.count > 0) {
        photograph = [self.wineClub.photographs objectAtIndex:index];
    } else {
        WHWineryMO * winery = [self.wineClub.clubWineries anyObject];
        photograph = [winery.photographs objectAtIndex:index];
    }
    return [NSURL URLWithString:photograph.imageThumbURL];
}

#pragma mark
#pragma mark

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
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
    return [WHWineClubCell cellHeightForWineClubObject:self.wineClub];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:[WHWineClubCell reuseIdentifier]];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHWineClubCell * wineClubCell = (WHWineClubCell*)cell;
    [wineClubCell setWineClub:self.wineClub];
    [wineClubCell setDelegate:self];
}

#pragma mark

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

#pragma mark 
#pragma mark WHWineClubCellDelegate

- (void)wineClubCell:(WHWineClubCell*)cell didTapWebsiteButton:(UIButton *)button
{
    if (self.website != nil) {
        WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrlString:self.website];
        UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)wineClubCell:(WHWineClubCell*)cell didTapURL:(NSURL *)url
{
    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:url];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
}

@end
