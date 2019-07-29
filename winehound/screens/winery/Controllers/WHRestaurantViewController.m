//
//  WHRestaurantViewController.m
//  WineHound
//
//  Created by Mark Turner on 20/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <RestKit/RestKit.h>

#import "WHRestaurantViewController.h"
#import "WHPDFViewController.h"
#import "WHWebViewController.h"

#import "WHRestaurantMO.h"
#import "WHPhotographMO+Mapping.h"
#import "WHRestaurantCell.h"
#import "WHLoadingHUD.h"

#import "TableHeaderView.h"
#import "PCGalleryViewController.h"
#import "PCPhoto.h"

@interface WHRestaurantViewController () <WHRestaurantCellDelegate>
@property (nonatomic,strong) WHRestaurantMO * restaurant;
@end

@implementation WHRestaurantViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Restaurant"];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView registerNib:[WHRestaurantCell nib]  forCellReuseIdentifier:[WHRestaurantCell reuseIdentifier]];
    
    if (self.wineryId != nil) {
        __weak typeof (self) weakSelf = self;

        [PCDHUD show];
        [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"restaurants"
                                                                object:@{@"wineryId":self.wineryId}
                                                            parameters:nil
                                                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                   [WHLoadingHUD dismiss];
                                                                   
                                                                   [weakSelf setRestaurant:nil];
                                                                   
                                                                   [weakSelf updateTableHeader];
                                                                   [weakSelf.tableView reloadData];
                                                               } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                   NSLog(@"Failed to fetch Restaurant: %@",error);
                                                               }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTableHeader];
}

- (void)updateTableHeader
{
    [self.tableHeaderView reload];
    [self.tableHeaderView.titleLabel setText:self.restaurant.restaurantName];
    [self.tableHeaderView.favouriteButton setHidden:YES];
}

#pragma mark Accesor

- (WHRestaurantMO *)restaurant
{
    if (_restaurant == nil && self.wineryId != nil) {
        NSManagedObjectContext * context = [[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext];
        WHRestaurantMO * restaurant = [WHRestaurantMO MR_findFirstByAttribute:@"wineryId" withValue:self.wineryId inContext:context];
        _restaurant = restaurant;
    }
    return _restaurant;
}

#pragma mark
#pragma mark WHDetailViewControllerProtocol

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return NO;
}

- (NSInteger)numberOfPhotographs
{
    return [self.restaurant.photographs count];
}

- (NSURL *)photographURLAtIndex:(NSInteger)index
{
    WHPhotographMO * photograph = [self.restaurant.photographs objectAtIndex:index];
    return [NSURL URLWithString:photograph.imageThumbURL];
}

#pragma mark 
#pragma mark PCGalleryViewControllerDataSource

- (NSUInteger)numberOfPhotosInGallery:(PCGalleryViewController *)gallery
{
    return [self.restaurant.photographs count];
}

- (PCPhoto *)gallery:(PCGalleryViewController *)gallery photoAtIndex:(NSUInteger)index
{
    WHPhotographMO * photograph = [self.restaurant.photographs objectAtIndex:index];
    
    PCPhoto * photo = [PCPhoto new];
    [photo setPhotoURL:[NSURL URLWithString:photograph.imageURL]];
    [photo setThumbURL:[NSURL URLWithString:photograph.imageThumbURL]];
    
    return photo;
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
    return [WHRestaurantCell cellHeightForRestaurantObject:self.restaurant];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:[WHRestaurantCell reuseIdentifier]];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHRestaurantCell * restaurantCell = (WHRestaurantCell*)cell;
    [restaurantCell setRestaurant:self.restaurant];
    [restaurantCell setDelegate:self];
}

#pragma mark
#pragma mark WHWineClubCellDelegate

- (void)restaurantCell:(WHRestaurantCell*)cell didTapViewMenuButton:(UIButton *)button
{
    if (self.restaurant.menuPdf != nil) {
        WHPDFViewController * pdfVC = [WHPDFViewController new];
        [pdfVC setPdfURL:[NSURL URLWithString:self.restaurant.menuPdf]];
        [self.navigationController pushViewController:pdfVC animated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kRestaurantNoPDFAlertTitle", nil)
                                    message:NSLocalizedString(@"kRestaurantNoPDFAlertMessage", nil)
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)restaurantCell:(WHRestaurantCell*)cell didTapURL:(NSURL *)url
{
    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:url];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
}

@end
