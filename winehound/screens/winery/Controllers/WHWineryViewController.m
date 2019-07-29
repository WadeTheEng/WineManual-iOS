
//  WHWineryViewController.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWineryViewController.h"
#import <PCDefaults/PCDCollectionManager.h>
#import <PCDefaults/PCDCollectionTableViewManager.h>
#import <CoreLocation/CLLocation.h>
#import <MagicalRecord/NSManagedObject+MagicalRecord.h>
#import <MagicalRecord/NSManagedObject+MagicalRequests.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <RestKit/RestKit.h>
#import <BugSense-iOS/BugSenseController.h>

#import "WHWinerySectionHeaderView.h"
#import "WHWineViewController.h"
#import "WHEventViewController.h"
#import "WHWineRangesViewController.h"
#import "WHCellarDoorViewController.h"
#import "WHMapViewController.h"
#import "WHWebViewController.h"
#import "WHWineClubViewController.h"
#import "WHRestaurantViewController.h"
#import "WHPanoramaViewController.h"

#import "TableHeaderView.h"

#import "WHAboutCell.h"
#import "WHCellarDoorCell.h"
#import "WHContactCell.h"
#import "WHEventsTableCell.h"
#import "WHPhotographCell.h"
#import "WHWineCell.h"
#import "WHWineryMO+Mapping.h"
#import "WHWineryMO+Additions.h"
#import "WHWineRangeMO+Mapping.h"
#import "WHWineClubMO.h"
#import "WHWineMO+Mapping.h"
#import "WHEventMO.h"
#import "WHOpenTimeMO.h"
#import "WHFavouriteMO+Additions.h"
#import "WHPanoramaMO.h"
#import "WHPhotographMO.h"
#import "WHLoadingHUD.h"
#import "WHFavouriteAlertView.h"
#import "WHFavouriteManager.h"
#import "WHAlertView.h"
#import "WHSectionInfo.h"
#import "WHShareManager.h"

#import "PCFileDownloadManager.h"
#import "PCGalleryViewController.h"
#import "PCPhoto.h"

#import "UIViewController+Social.h"
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

NS_ENUM(NSInteger, WHWinerySectionEnum) {
    WHWinerySectionAbout = 10,
    WHWinerySectionDoor,
    WHWinerySectionWines,
    WHWinerySectionEvents,
    WHWinerySectionWineClub,
    WHWinerySectionRestaurant,
    WHWinerySectionCellarDoor360,
    WHWinerySectionContact,
    WHWinerySectionFacebook,
    WHWinerySectionTwitter,
    WHWinerySectionInstagram,
    WHWinerySectionCount
};

NSString * const WHWinerySectionTitles[] = {
    [WHWinerySectionAbout]      = @"About",
    [WHWinerySectionDoor]       = @"Cellar Door",
    [WHWinerySectionWines]      = @"Wines",
    [WHWinerySectionEvents]     = @"What's On",
    [WHWinerySectionWineClub]   = @"Wine Club",
    [WHWinerySectionCellarDoor360] = @"Cellar Door 360°",
    [WHWinerySectionContact]    = @"Contact",
    [WHWinerySectionRestaurant] = @"Restaurant",
    [WHWinerySectionFacebook]   = @"Facebook",
    [WHWinerySectionTwitter]    = @"Twitter",
    [WHWinerySectionInstagram]  = @"Instagram"
};

NSString * const WHWinerySectionImageNames[] = {
    [WHWinerySectionAbout]      = @"winery_about_icon",
    [WHWinerySectionDoor]       = @"winery_door_icon",
    [WHWinerySectionWines]      = @"winery_wines_icon",
    [WHWinerySectionEvents]     = @"winery_events_icon",
    [WHWinerySectionWineClub]   = @"winery_section_wineclub_icon",
    [WHWinerySectionRestaurant] = @"winery_restaurant_icon",
    [WHWinerySectionCellarDoor360] = @"winery_section_panorama_icon",
    [WHWinerySectionContact]    = @"winery_contact_icon",
    [WHWinerySectionFacebook]   = @"winery_section_facebook_icon",
    [WHWinerySectionTwitter]    = @"winery_section_twitter_icon",
    [WHWinerySectionInstagram]  = @"winery_section_instagram_icon"
};

@interface WHWineryViewController () <WHEventsTableCellDelegate,WHPhotographCellDelegate,WHWineCellDelegate>
{
    NSArray * _wineryRangesArray;
    BOOL _winesViewMore;
    BOOL _aboutViewMore;
    WHShareManager * _shareManager;
}
@property (nonatomic) WHWineryMO * winery;
@property (nonatomic) NSArray * sectionsArray;
@property (nonatomic) NSArray * orderedEventsArray;
@property (nonatomic) NSArray * orderedWinesArray;
@property (nonatomic,readonly) BOOL isLoadingWines;
@property (nonatomic) PCFileDownloadManager * panoramaDownloadManager;
@end

@implementation WHWineryViewController
@synthesize winery = _winery;
@dynamic isLoadingWines;

#pragma mark

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Winery"];

    [self setEdgesForExtendedLayout:UIRectEdgeAll];

    [self.tableView registerNib:[WHCellarDoorCell nib]  forCellReuseIdentifier:[WHCellarDoorCell reuseIdentifier]];
    [self.tableView registerNib:[WHWineCell nib]        forCellReuseIdentifier:[WHWineCell reuseIdentifier]];
    [self.tableView registerNib:[WHPhotographCell nib]  forCellReuseIdentifier:[WHPhotographCell reuseIdentifier]];
    
    [self setWinery:[self winery]];
    [self reload];
    
    UIBarButtonItem * shareBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(_shareBarButtonItemAction:)];
    [self.navigationItem setRightBarButtonItem:shareBarButtonItem];
    
    if (self.wineryId != nil) {
        [[Mixpanel sharedInstance] track:@"Show Winery" properties:@{@"winery_id": self.wineryId}];
        [BugSenseController leaveBreadcrumb:[NSString stringWithFormat:@"Show Winery: %@",self.wineryId]];
        NSLog(@"Displaying Winery: %@",self.wineryId);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableHeaderView.titleLabel setText:self.winery.name];
}

#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"DisplayRanges"]) {
        WHWineRangesViewController * rangesVC = (id)segue.destinationViewController;
        [rangesVC setWineryId:sender];
    }
    if ([segue.identifier isEqualToString:@"DisplayCellarDoor"]) {
        WHCellarDoorViewController * cellarDoorVC = (id)segue.destinationViewController;
        [cellarDoorVC setWineryId:sender];
    }
    if ([segue.identifier isEqualToString:@"DisplayWineClub"]) {
        if ([sender isKindOfClass:[WHWineClubMO class]]) {
            WHWineClubMO * wineClub = (WHWineClubMO *)sender;
            WHWineClubViewController * wineClubVC = (id)segue.destinationViewController;
            [wineClubVC setWineryId:wineClub.wineryId wineClubId:wineClub.clubIdentifier];
        }
    }
    if ([segue.identifier isEqualToString:@"DisplayRestaurant"]) {
        WHRestaurantViewController * restaurantVC = (WHRestaurantViewController*)segue.destinationViewController;
        [restaurantVC setWineryId:self.wineryId];
    }
    if ([segue.identifier isEqualToString:@"DisplayPanorama"]) {
        WHPanoramaViewController * panoramaVC = (WHPanoramaViewController*)segue.destinationViewController;
        [panoramaVC setPathToPanoramaTexture:sender];
    }
}

#pragma mark

- (void)reload
{
    NSAssert(_wineryId != nil, @"Error - No winery ID provided");
    
    [PCDHUD show];
    __weak typeof (self) weakSelf = self;
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"winery"
                                                            object:@{@"wineryId": _wineryId}
                                                        parameters:nil
                                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                               [WHLoadingHUD dismiss];
                                                               [weakSelf setWinery:[weakSelf winery]];
                                                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                               [PCDHUD showError:error];
                                                           }];
}

#pragma mark

- (WHWineryMO *)winery
{
    if (_winery == nil) {
        NSManagedObjectContext * context = [[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext];
        NSFetchRequest *request = [WHWineryMO MR_requestFirstByAttribute:@"wineryId" withValue:_wineryId inContext:context];
        [request setIncludesSubentities:NO];
        
        WHWineryMO * winery = [WHWineryMO MR_executeFetchRequestAndReturnFirstObject:request];
        /*
        if (winery == nil) {
             If a no Winery object was returned, check for a WineryListItem object,
             but be sure not to fetch any relationship objects.

            [request setIncludesSubentities:YES];
            
            winery = [WHWineryMO MR_executeFetchRequestAndReturnFirstObject:request];
        }
        */
        _winery = winery;
    }
    return _winery;
}

- (void)setWinery:(WHWineryMO *)winery
{
    if (NO == [winery isKindOfClass:[WHWineryMO class]]) {
        //be sure to fetch Winery
    }
    
    _winery = winery;
    _wineryRangesArray = nil;
    _sectionsArray = nil;
    _orderedWinesArray = nil;
    
    [self sectionsArray];

    if ([_winery isPremium] == NO) {
        [self.expandedSections addIndex:[self sectionIndexForIdentifier:WHWinerySectionContact]];
    }

    [self.tableHeaderView reload];
    [self.tableHeaderView.titleLabel setText:_winery.name];
    [self.tableHeaderView.favouriteButton setHidden:NO];

    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHWineryMO entityName] identifier:_winery.wineryId];
    [self.tableHeaderView.favouriteButton setSelected:favourite!=nil];
    
    if (_winery == nil || [self isViewLoaded] == NO || [_winery isPremium] == NO) {
        [self.tableView reloadData];
    } else {
        [self.tableView reloadData];

        /*
        NSMutableIndexSet * reloadSections = [NSMutableIndexSet new];
        [reloadSections addIndex:WHWineryPremiumSectionAbout];
        [reloadSections addIndex:WHWineryPremiumSectionDoor];
        [reloadSections addIndex:WHWineryPremiumSectionEvents];
        [reloadSections addIndex:WHWineryPremiumSectionContact];
        [self.tableView reloadSections:reloadSections withRowAnimation:UITableViewRowAnimationNone];
         */
        
        /*
        if (self.isLoadingWines == NO && winesBeforeUpdateCount != [self.winesArray count]) {
            
            [self.tableView beginUpdates];
            if (winesBeforeUpdateCount > self.winesArray.count) {
                
                NSMutableArray * deleteIndexPaths = @[].mutableCopy;
                
                NSInteger rowsToDelete = winesBeforeUpdateCount - self.winesArray.count;
                while (rowsToDelete > 0) {
                    [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:(winesBeforeUpdateCount-rowsToDelete)-1 inSection:WHWineryPremiumSectionWines]];
                    rowsToDelete --;
                }
                [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                
            } else {
                
                NSMutableArray * insertIndexPaths = @[].mutableCopy;
                
                NSInteger rowsToAdd = self.winesArray.count - winesBeforeUpdateCount;
                while (rowsToAdd > 0) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForRow:(winesBeforeUpdateCount+rowsToAdd)-1 inSection:WHWineryPremiumSectionWines]];
                    rowsToAdd --;
                }
                
                //remove loading cell?
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:WHWineryPremiumSectionWines]] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                
            }
            [self.tableView endUpdates];
            
        } else {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:WHWineryPremiumSectionWines] withRowAnimation:UITableViewRowAnimationFade];
        }
         */
    }
}

- (NSArray *)sectionsArray
{
    if (_sectionsArray == nil) {
        NSMutableArray * sections = @[].mutableCopy;
        
        if (self.winery.tierValue < WHWineryTierBasic) {
            if (self.winery.about.length > 0) {
                WHSectionInfo * aboutSection = [WHSectionInfo new];
                [aboutSection setIdentifier:WHWinerySectionAbout];
                [aboutSection setRowCount:1];
                [sections addObject:aboutSection];
            }
        }
        
        if (self.winery.cellarDoorDescription.length > 0) {
            WHSectionInfo * doorSection = [WHSectionInfo new];
            [doorSection setIdentifier:WHWinerySectionDoor];
            [doorSection setRowCount:1];
            [sections addObject:doorSection];
        }
   
        if (self.winery.tierValue < WHWineryTierBasic) {
            WHSectionInfo * winesSection = [WHSectionInfo new];
            [winesSection setIdentifier:WHWinerySectionWines];
            [winesSection setRowCount:1]; //View More button
            [sections addObject:winesSection];
            
            WHSectionInfo * eventsSection = [WHSectionInfo new];
            [eventsSection setIdentifier:WHWinerySectionEvents];
            [eventsSection setRowCount:1];
            [sections addObject:eventsSection];
            
            if (self.winery.tierValue <= WHWineryTierSilver) {
                if (self.winery.hasWineClubs.boolValue == YES) {
                    WHSectionInfo * wineClubSection = [WHSectionInfo new];
                    [wineClubSection setIdentifier:WHWinerySectionWineClub];
                    [wineClubSection setRowCount:self.winery.wineClubs.count];
                    [sections addObject:wineClubSection];
                }
                if (self.winery.hasRestaurants.boolValue == YES) {
                    WHSectionInfo * restaurantSection = [WHSectionInfo new];
                    [restaurantSection setIdentifier:WHWinerySectionRestaurant];
                    [sections addObject:restaurantSection];
                }
                if (self.winery.hasPanoramas.boolValue) {
                    WHSectionInfo * cellarDoorPanoramaSection = [WHSectionInfo new];
                    [cellarDoorPanoramaSection setIdentifier:WHWinerySectionCellarDoor360];
                    [cellarDoorPanoramaSection setRowCount:self.winery.cellarDoorPanoramas.count ?: 1]; //loading cell
                    [sections addObject:cellarDoorPanoramaSection];
                }
            }
        }
        
        WHSectionInfo * contactSection = [WHSectionInfo new];
        [contactSection setIdentifier:WHWinerySectionContact];
        [contactSection setRowCount:1];
        [sections addObject:contactSection];
        
        if (self.winery.tierValue < WHWineryTierBronze) {
            
            if (self.winery.facebook.length > 0) {
                WHSectionInfo * facebookSection = [WHSectionInfo new];
                [facebookSection setIdentifier:WHWinerySectionFacebook];
                [facebookSection setRowCount:0];
                [sections addObject:facebookSection];
            }
            if (self.winery.twitter.length > 0) {
                WHSectionInfo * twitterSection = [WHSectionInfo new];
                [twitterSection setIdentifier:WHWinerySectionTwitter];
                [twitterSection setRowCount:0];
                [sections addObject:twitterSection];
            }
            if (self.winery.instagram.length > 0) {
                WHSectionInfo * instagramSection = [WHSectionInfo new];
                [instagramSection setIdentifier:WHWinerySectionInstagram];
                [instagramSection setRowCount:0];
                [sections addObject:instagramSection];
            }
        }
        
        _sectionsArray = [NSArray arrayWithArray:sections];
    }
    return _sectionsArray;
}

- (NSArray *)rangesArray
{
    if (_wineryRangesArray == nil) {
        _wineryRangesArray = [self.winery.ranges sortedArrayUsingDescriptors:[WHWineRangeMO sortDescriptors]];
    }
    return _wineryRangesArray;
}

- (NSArray *)orderedWinesArray
{
    if (_orderedWinesArray == nil) {
        _orderedWinesArray = [WHWineMO MR_findAllSortedBy:@"winerySortPosition"
                                                ascending:YES
                                            withPredicate:[NSPredicate predicateWithFormat:@"wineryId == %@",self.wineryId]];
    }
    return _orderedWinesArray;
}

#pragma mark

- (NSInteger)sectionIndexForIdentifier:(enum WHWinerySectionEnum)identifier
{
    NSInteger sectionIndex = NSNotFound;
    WHSectionInfo * sectionInfo = [self sectionInfoForIdentifier:identifier];
    if (sectionInfo != nil) {
        sectionIndex = [self.sectionsArray indexOfObject:sectionInfo];
    }
    return sectionIndex;
}

- (WHSectionInfo *)sectionInfoForIdentifier:(enum WHWinerySectionEnum)identifier
{
    WHSectionInfo * returnSectionInfo = nil;
    for (WHSectionInfo * sectionInfo in self.sectionsArray) {
        if (sectionInfo.identifier == identifier) {
            returnSectionInfo = sectionInfo;
            break;
        }
    }
    return returnSectionInfo;
}

#pragma mark

- (BOOL)isLoadingWines
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/wineries/:wineryId/wines"];
    return operations.count > 0;
}

- (BOOL)isLoadingEvents
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/events"];
    return operations.count > 0;
}

- (BOOL)isLoadingOpeningTimes
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/wineries/:wineryId/cellar_door_open_times"];
    return operations.count > 0;
}

- (BOOL)isLoadingWinery
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/wineries/:wineryId"];
    return operations.count > 0;
}

- (BOOL)isLoadingPanoramas
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/wineries/:wineryId/panoramas"];
    return operations.count > 0;
}

#pragma mark
#pragma mark Actions

- (void)headerFavouriteButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHWineryMO entityName] identifier:self.wineryId];
    if (favourite == nil) {
        AFNetworkReachabilityStatus reachability = [[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus];
        if (reachability == AFNetworkReachabilityStatusReachableViaWWAN || reachability == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHFavouriteAlertView" owner:nil options:nil];
            WHFavouriteAlertView * favouriteAlertView = [views firstObject];
            [favouriteAlertView setDelegate:(id)self];
            
            if ([WHFavouriteManager email] == nil) {
                [favouriteAlertView displayEmailEntry];
            }
            
            [WHAlertView presentView:favouriteAlertView animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoInternetAlertTitle", nil)
                                        message:NSLocalizedString(@"kFavouriteNoInternetAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    } else {
        BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName] identifier:[self.winery wineryId]];
        [button setSelected:didFavourite];
    }
}

- (void)_viewMoreWineButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    if ([self.winery isGold] && self.winery.ranges.count > 0) {
        [self performSegueWithIdentifier:@"DisplayRanges" sender:self.winery.wineryId];
    } else {
        WHSectionInfo * winesSection = [self sectionInfoForIdentifier:WHWinerySectionWines];
        if (winesSection != nil) {
            NSInteger currentWineCells = MIN([self.orderedWinesArray count], 3);
            NSInteger cellsToAdd = [self.orderedWinesArray count] - currentWineCells;
            NSInteger section = [self.sectionsArray indexOfObject:winesSection];

            if (cellsToAdd > 0) {
                [self.tableView beginUpdates];
                
                _winesViewMore = YES;
                
                //Reload the view more button cell.
                NSIndexPath * viewMoreIndexPath = [NSIndexPath indexPathForRow:currentWineCells inSection:section];
                
                //Add the wine cells
                NSMutableArray * newIndexPaths = @[].mutableCopy;
                for (NSInteger index = 1; index < cellsToAdd; index ++) {
                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:currentWineCells+index inSection:section];
                    [newIndexPaths addObject:indexPath];
                }
                
                [self.tableView reloadRowsAtIndexPaths:@[viewMoreIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
                [self.tableView insertRowsAtIndexPaths:newIndexPaths        withRowAnimation:UITableViewRowAnimationBottom];
                
                [self.tableView endUpdates];
            }
        }
    }
}

- (void)refreshWinesSection
{
    [self setOrderedWinesArray:nil];
    [self orderedWinesArray];
    
    NSInteger winesSection = [self sectionIndexForIdentifier:WHWinerySectionWines];
    if (winesSection != NSNotFound) {
        
        //Check the user hasn't collapsed the section.
        if ([self.expandedSections containsIndex:winesSection] == YES) {
            
            //Remove the exising cells. ie loading cell.
            NSInteger currentRowCount = [self.tableView numberOfRowsInSection:winesSection];
            NSMutableArray * deleteRows = @[].mutableCopy;
            while (currentRowCount > 0) {
                [deleteRows addObject:[NSIndexPath indexPathForRow:currentRowCount-1 inSection:winesSection]];
                currentRowCount --;
            }
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationTop];
            
            if (self.orderedWinesArray.count > 0) {
                
                NSInteger numRows =  [self.orderedWinesArray count] > 3
                ? 3 + 1 //Display max 3 + view more
                : [self.orderedWinesArray count];
                
                NSMutableArray * newIndexPaths = @[].mutableCopy;
                for (NSInteger index = 0; index < numRows; index ++) {
                    [newIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:winesSection]];
                }
                [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationTop];
            } else {
                //No results cell.
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:winesSection] ]
                                      withRowAnimation:UITableViewRowAnimationTop];
            }
            [self.tableView endUpdates];
        }
    }
}

- (void)refreshEventsSection
{
    if (self.winery) {
        NSArray * eventsBYWinery = [WHEventMO
                                    MR_findAllSortedBy:@"startDate"
                                    ascending:YES
                                    withPredicate:[NSPredicate predicateWithFormat:@"%@ IN wineries",self.winery]];
        [self setOrderedEventsArray:eventsBYWinery];
    }
    
    NSInteger eventsSectionIndex = [self sectionIndexForIdentifier:WHWinerySectionEvents];
    if (eventsSectionIndex != NSNotFound) {
        
        //Check the user hasn't collapsed the section.
        if ([self.expandedSections containsIndex:eventsSectionIndex] == YES) {

            WHEventsTableCell * eventCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:eventsSectionIndex]];
            if ([eventCell respondsToSelector:@selector(activityIndicator)]) {
                [eventCell.activityIndicator stopAnimating];
            }

            if ([self.orderedEventsArray count] > 0) {
                [eventCell.noEventsLabel setHidden:YES];
                
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
                
                [eventCell reload];
            } else {
                [eventCell.noEventsLabel setText:@"No events for this Winery"];
                [eventCell.noEventsLabel setHidden:NO];
            }
        }
    }
}

- (void)refreshPanoramasSection
{
    NSInteger panoramaSection = NSNotFound;
    for (WHSectionInfo * sectionInfo in self.sectionsArray) {
        if (sectionInfo.identifier == WHWinerySectionCellarDoor360) {
            [sectionInfo setRowCount:self.winery.cellarDoorPanoramas.count];
            panoramaSection = [self.sectionsArray indexOfObject:sectionInfo];
            break;
        }
    }
    if (panoramaSection != NSNotFound) {
        
        //Check the user hasn't collapsed the section.
        if ([self.expandedSections containsIndex:panoramaSection] == YES) {
            NSInteger currentRowCount = [self.tableView numberOfRowsInSection:panoramaSection];
            
            [self.tableView beginUpdates];
            
            NSInteger panoramaCount = self.winery.cellarDoorPanoramas.count;
            if (currentRowCount > panoramaCount) {
                //delete rows
                NSMutableArray * deleteRows = @[].mutableCopy;
                while (currentRowCount > panoramaCount) {
                    [deleteRows addObject:[NSIndexPath indexPathForRow:currentRowCount-1 inSection:panoramaSection]];
                    currentRowCount --;
                }
                [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationTop];
            } else if (currentRowCount < panoramaCount) {
                //add rows
                NSMutableArray * newIndexPaths = @[].mutableCopy;
                for (NSInteger index = currentRowCount; index < self.winery.cellarDoorPanoramas.count; index ++) {
                    [newIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:panoramaSection]];
                }
                [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationTop];
            }
            
            if (currentRowCount > 0) {
                NSMutableArray * reloadCells = @[].mutableCopy;
                for (NSInteger reloadIndex = 0; reloadIndex < currentRowCount; reloadIndex ++) {
                    [reloadCells addObject:[NSIndexPath indexPathForRow:reloadIndex inSection:panoramaSection]];
                }
                [self.tableView reloadRowsAtIndexPaths:reloadCells withRowAnimation:UITableViewRowAnimationNone];
            }
            
            [self.tableView endUpdates];
        }
    }
    
}

- (void)_shareBarButtonItemAction:(UIBarButtonItem *)sender
{
    _shareManager = [WHShareManager new];
    [_shareManager presentShareAlertWithObject:self.winery];
}

#pragma mark
#pragma mark WHDetailViewControllerProtocol

- (NSString *)titleForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:section];
    return WHWinerySectionTitles[sectionInfo.identifier];
}

- (UIImage *)imageForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:section];
    return [UIImage imageNamed:WHWinerySectionImageNames[sectionInfo.identifier]];
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return YES;
}

- (NSString *)name
{
    return self.winery.name;
}

- (NSString *)phoneNumber
{
    return self.winery.phoneNumber;
}

- (NSString *)email
{
    return self.winery.email;
}

- (NSString *)website
{
    return self.winery.website;
}

- (CLLocation *)location
{
    return [[CLLocation alloc] initWithLatitude:self.winery.latitude.doubleValue
                                      longitude:self.winery.longitude.doubleValue];
}

- (NSString *)aboutDescription
{
    return self.winery.about;
}

- (NSString *)cellarDoorDescription
{
    NSString * cellarDoorDescription = self.winery.cellarDoorDescription;
    cellarDoorDescription = [cellarDoorDescription stringByAppendingString:@"\n\n"];
    return cellarDoorDescription;
}

- (NSInteger)numberOfPhotographs
{
    if (self.winery.photographs.count <= 0)  {
        return 1;
    }
    return [self.winery.photographs count];
}

- (NSURL *)photographURLAtIndex:(NSInteger)index
{
    if (self.winery.photographs.count <= 0)  {
        NSString * wineryPlaceholderPath = [[NSBundle mainBundle] pathForResource:@"winery_placeholder" ofType:@"png"];
        return [NSURL fileURLWithPath:wineryPlaceholderPath];
    }

    WHPhotographMO * photograph = [self.winery.photographs objectAtIndex:index];
    return [NSURL URLWithString:photograph.imageThumbURL];
}

#pragma mark PCGalleryViewControllerDataSource

- (NSUInteger)numberOfPhotosInGallery:(PCGalleryViewController *)gallery
{
    if (self.winery.tierValue >= WHWineryTierBasic) {
        return [self.winery.photographs count] > 0 ? 1 : 0;
    }
    return [self.winery.photographs count];
}

- (PCPhoto *)gallery:(PCGalleryViewController *)gallery photoAtIndex:(NSUInteger)index
{
    WHPhotographMO * photograph = [self.winery.photographs objectAtIndex:index];

    PCPhoto * photo = [PCPhoto new];
    [photo setPhotoURL:[NSURL URLWithString:photograph.imageURL]];
    [photo setThumbURL:[NSURL URLWithString:photograph.imageThumbURL]];
    return photo;
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionsArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WHWinerySectionHeaderView * winerySectionHeaderView = (WHWinerySectionHeaderView*)[super tableView:tableView viewForHeaderInSection:section];
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:section];
    if (sectionInfo.identifier == WHWinerySectionFacebook   ||
        sectionInfo.identifier == WHWinerySectionTwitter    ||
        sectionInfo.identifier == WHWinerySectionInstagram  ||
        sectionInfo.identifier == WHWinerySectionRestaurant) {
        [winerySectionHeaderView.sectionAccesoryView setTransform:CGAffineTransformMakeRotation(M_PI_2*3)];
    }
    return winerySectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self tableView:tableView canCollapseSection:section] == YES) {
        if ([self.expandedSections containsIndex:section]) {
            
            WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:section];
            switch (sectionInfo.identifier) {
                case WHWinerySectionWines:
                    if ([self.winery isGold] && self.winery.ranges.count > 0) {
                        return [self.rangesArray count];
                    } else {
                        if (self.isLoadingWines == YES) {
                            return 1;
                        } else {
                            if ([self.orderedWinesArray count] > 0) {
                                if (_winesViewMore == YES) {
                                    return [self.orderedWinesArray count];
                                } else {
                                    return [self.orderedWinesArray count] > 3
                                    ? 3 + 1 //Display max 3 + view more
                                    : [self.orderedWinesArray count];
                                }
                            } else {
                                return 1; //display no wines cell
                            }
                        }
                    }
                    break;
                default:
                    return sectionInfo.rowCount;
                    break;
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:indexPath.section];

    if ([self.winery isPremium]) {
        switch (sectionInfo.identifier) {
            case WHWinerySectionAbout:
                return [tableView dequeueReusableCellWithIdentifier:[WHAboutCell reuseIdentifier]];
                break;
            case WHWinerySectionDoor:
                return [tableView dequeueReusableCellWithIdentifier:[WHCellarDoorCell reuseIdentifier]];
                break;
            case WHWinerySectionWines:
            {
                if ([self.winery isGold] && self.winery.ranges.count > 0) {
                    
                    //Displaying wine ranges cells
                    UITableViewCell * cell = [UITableViewCell new];
                    [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"winery_standard_accesory"]]];
                    [cell.textLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
                    [cell.textLabel setTextColor:[UIColor wh_grey]];
                    return cell;

                } else {
                    
                    if (self.isLoadingWines == YES) {
                        //Display loading cell
                        UITableViewCell * cell = [UITableViewCell new];
                        [cell.textLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
                        [cell.textLabel setTextColor:[UIColor wh_grey]];
                        UIActivityIndicatorView * activityIndicator = [UIActivityIndicatorView new];
                        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                        [activityIndicator startAnimating];
                        [cell.contentView addSubview:activityIndicator];
                        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
                        
                        [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
                        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[activityIndicator]-|"
                                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                                 metrics:nil
                                                                                                   views:NSDictionaryOfVariableBindings(activityIndicator)]];
                        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[activityIndicator]-|"
                                                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                                                 metrics:nil
                                                                                                   views:NSDictionaryOfVariableBindings(activityIndicator)]];
                        return cell;
                    } else if (self.winery.wines.count <= 0) {
                        UITableViewCell * cell = [UITableViewCell new];
                        [cell.textLabel setFont:[UIFont edmondsansRegularOfSize:17.0]];
                        [cell.textLabel setTextColor:[UIColor wh_grey]];
                        [cell.textLabel setText:@"No Wines for this Winery"];
                        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                        return cell;
                    }

                    // Display Wine Cells
                    
                    if (_winesViewMore == YES || indexPath.row < MIN([self.orderedWinesArray count], 3)) {
                        return [tableView dequeueReusableCellWithIdentifier:[WHWineCell reuseIdentifier]];
                    } else {
                        
                        static NSString * const kViewMoreCellIdentifier = @"viewMoreCell";
                        UITableViewCell * viewMoreCell = [tableView dequeueReusableCellWithIdentifier:kViewMoreCellIdentifier];
                        if (viewMoreCell == nil) {
                            viewMoreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kViewMoreCellIdentifier];
                            
                            UIButton * viewMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
                            [viewMoreButton setTitle:@"View More" forState:UIControlStateNormal];
                            [viewMoreButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
                            [viewMoreButton setTitleColor:[UIColor wh_grey]     forState:UIControlStateHighlighted];
                            [viewMoreButton.titleLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
                            [viewMoreButton setFrame:CGRectMake(9.0, 12.0, 70.0, 16.0)];
                            [viewMoreButton addTarget:self action:@selector(_viewMoreWineButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
                            [viewMoreCell.contentView addSubview:viewMoreButton];
                            [viewMoreCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                        return viewMoreCell;
                    }
                }
            }
                break;
            case WHWinerySectionEvents: {
                WHEventsTableCell * eventsCell = [tableView dequeueReusableCellWithIdentifier:[WHEventsTableCell reuseIdentifier]];
                __weak UIPanGestureRecognizer * collectionViewPanGesture = eventsCell.collectionView.panGestureRecognizer;
                [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:collectionViewPanGesture];
                return eventsCell;
            }
                break;
            case WHWinerySectionWineClub:
            {
                UITableViewCell * cell = [UITableViewCell new];
                [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"winery_standard_accesory"]]];
                [cell.textLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
                [cell.textLabel setTextColor:[UIColor wh_grey]];
                return cell;
            }
                break;
                
            case WHWinerySectionCellarDoor360: {
                return [tableView dequeueReusableCellWithIdentifier:[WHPhotographCell reuseIdentifier]];
            }
                break;
            case WHWinerySectionContact:
                return [tableView dequeueReusableCellWithIdentifier:[WHContactCell reuseIdentifier]];
                break;
            default:
                break;
        }
    } else {
        switch (sectionInfo.identifier) {
            case WHWinerySectionContact:
                return [tableView dequeueReusableCellWithIdentifier:[WHContactCell reuseIdentifier]];
                break;
            default:
                break;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:indexPath.section];

    if ([self.winery isPremium]) {
        switch (sectionInfo.identifier) {

            case WHWinerySectionAbout: {
                WHAboutCell * aboutCell = (WHAboutCell*)cell;
                [aboutCell setAboutText:self.winery.about truncated:_aboutViewMore?NO:YES];
                [aboutCell setDelegate:(id)self];
            }
                break;
            case WHWinerySectionDoor: {
                WHCellarDoorCell * cellarDoorCell = (WHCellarDoorCell*)cell;
                [cellarDoorCell setCellarDoorText:self.winery.cellarDoorDescription];
                [cellarDoorCell setOpeningHoursString:[NSAttributedString openHoursAttributedStringWithObject:self.winery]]; //keep reference to this attributed string.
                [cellarDoorCell setDelegate:(id)self];
                
                if ([self isLoadingOpeningTimes]) {
                    [cellarDoorCell.activityIndicatorView startAnimating];
                } else {
                    [cellarDoorCell.activityIndicatorView stopAnimating];
                }
            }
                break;
            case WHWinerySectionWines:
                if ([self.winery isGold] && self.winery.ranges.count > 0) {
                    WHWineRangeMO * wineRange = [self.rangesArray objectAtIndex:indexPath.row];
                    [cell.textLabel setText:wineRange.name];
                } else if (self.isLoadingWines == NO) {
                    if (_winesViewMore == YES || indexPath.row < MIN([self.orderedWinesArray count], 3)) {
                        WHWineMO * wineObject = [self.orderedWinesArray objectAtIndex:indexPath.row];
                        WHWineCell * wineCell = (WHWineCell*)cell;
                        [wineCell setWine:wineObject];
                        [wineCell setDelegate:self];
                    }
                }
                break;
            case WHWinerySectionEvents:
            {
                WHEventsTableCell * eventsCell = (WHEventsTableCell*)cell;
                [eventsCell setDataSource:self];
                [eventsCell setDelegate:self];
                [eventsCell reload];
                [eventsCell.noEventsLabel setHidden:YES];
                
                if ([self isLoadingEvents]) {
                    [eventsCell.activityIndicator startAnimating];
                } else {
                    [eventsCell.activityIndicator stopAnimating];
                }
            }
                break;
            case WHWinerySectionWineClub:
            {
                if (self.winery.wineClubs.count > 0) {
                    //TODO - keep reference to sorted rather than on each cell for load.
                    NSArray * wineclubs = [self.winery.wineClubs
                                           sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"clubIdentifier" ascending:YES]]];
                    WHWineClubMO * wineClub = [wineclubs objectAtIndex:indexPath.row];
                    [cell.textLabel setText:wineClub.clubName];
                }
            }
                break;
            case WHWinerySectionCellarDoor360: {
                WHPhotographCell * photographCell = (WHPhotographCell *)cell;
                [photographCell setDelegate:self];
                if (self.isLoadingPanoramas || self.winery.cellarDoorPanoramas.count <= 0) {
                    [photographCell setPhotograph:nil];
                    [photographCell.activityIndicatorView startAnimating];
                } else {
                    WHPanoramaMO * panorama = [self.winery.cellarDoorPanoramas objectAtIndex:indexPath.row];
                    [photographCell setPhotograph:panorama.photograph];
                }
            }
                break;
            case WHWinerySectionContact:
            {
                WHContactCell * contactCell = (WHContactCell*)cell;
                [contactCell setDelegate:self];
                [contactCell setWinery:self.winery];
            }
                break;
            default:
                break;
        }
    } else {
        switch (sectionInfo.identifier) {
            case WHWinerySectionContact:
            {
                WHContactCell * contactCell = (WHContactCell*)cell;
                [contactCell setDelegate:self];
                [contactCell setWinery:self.winery];
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:indexPath.section];

    if ([self.winery isPremium]) {
        switch (sectionInfo.identifier) {
            case WHWinerySectionAbout:
                return [WHAboutCell cellHeightForAboutText:self.winery.about truncated:_aboutViewMore?NO:YES];
                break;
            case WHWinerySectionDoor:
                return [WHCellarDoorCell cellHeightForWineryObject:self.winery];
                break;
            case WHWinerySectionWines:
                if ([self.winery isGold] && self.winery.ranges.count > 0) {
                    return 50.0;
                } else {
                    if (self.isLoadingWines == YES) {
                        return 50.0; //Loading cell
                    } else {
                        if (_winesViewMore == YES || indexPath.row < MIN([self.orderedWinesArray count], 3)) {
                            return [WHWineCell cellHeight];
                        } else {
                            return 40.0; //View more button.
                        }
                    }
                }
                break;
            case WHWinerySectionEvents:
                if ([self isLoadingEvents] == NO && (self.orderedEventsArray.count > 0)) {
                    return [WHEventsTableCell cellHeight];
                } else {
                    return 50.0;
                }
                break;
            case WHWinerySectionWineClub:
                return 50.0;
                break;
            case WHWinerySectionCellarDoor360:
                return 100.0;
                break;
            case WHWinerySectionContact:
                return [WHContactCell cellHeightForWineryObject:self.winery];
                break;
            default:
                break;
        }
    } else {
        switch (sectionInfo.identifier) {
            case WHWinerySectionContact:
                return [WHContactCell cellHeightForWineryObject:self.winery];
                break;
            default:
                break;
        }
    }
    return 100.0;
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.winery.tierValue < WHWineryTierBronze) && (self.isLoadingWines == NO)) {
        WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:indexPath.section];
        return (sectionInfo.identifier == WHWinerySectionWines) ||
               (sectionInfo.identifier == WHWinerySectionWineClub);
    } else {
        return NO;
    }
}

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if view more cell return nil;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:indexPath.section];
    if (sectionInfo.identifier == WHWinerySectionWines) {
        UIStoryboard * wineStoryboard = [UIStoryboard storyboardWithName:@"Wine" bundle:[NSBundle mainBundle]];
        WHWineViewController * wineViewController = [wineStoryboard instantiateInitialViewController];
        if (self.winery.ranges.count > 0) {
            WHWineRangeMO * wineRange = [self.rangesArray objectAtIndex:indexPath.row];
            [wineViewController setWineryId:self.winery.wineryId];
            [wineViewController setRangeId:wineRange.rangeId];
        } else if (self.orderedWinesArray.count > 0) {
            WHWineMO * wineObject = [self.orderedWinesArray objectAtIndex:indexPath.row];
            [wineViewController setWineryId:wineObject.wineryId];
            [wineViewController setSelectedWineId:wineObject.wineId];
        }
        [self.navigationController pushViewController:wineViewController animated:YES];
    }

    if (sectionInfo.identifier == WHWinerySectionWineClub) {
        if (self.winery.wineClubs.count > 0) {
            WHWineClubMO * wineClub = [self.winery.wineClubs objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"DisplayWineClub" sender:wineClub];
        }
    }
}

- (void)didSelectTableViewHeaderSection:(WHWinerySectionHeaderView *)headerView
{
    WHSectionInfo * sectionInfo = [self.sectionsArray objectAtIndex:headerView.section];
    NSInteger section = headerView.section;
    
    switch (sectionInfo.identifier) {
        case WHWinerySectionAbout:
            _aboutViewMore = NO;
            break;
        case WHWinerySectionFacebook: {
            NSString * facebookURL = [self.winery.facebook copy];
            [self openFacebookAppOrPresentWebviewWithHandle:facebookURL];
        }
            return;
            break;
        case WHWinerySectionTwitter: {
            NSString * twitterHandle = [self.winery.twitter copy];
            [self openTwitterAppOrPresentWebviewWithHandle:twitterHandle];
            return;
        }
            break;
        case WHWinerySectionInstagram: {
            NSString * instagramHandle = [self.winery.instagram copy];
            [self openInstagramAppOrPresentWebviewWithHandle:instagramHandle];
            return;
        }
        case WHWinerySectionRestaurant: {
            [self performSegueWithIdentifier:@"DisplayRestaurant" sender:nil];
            return;
        }
            break;
        default:
            break;
    }
    
    if ([self.expandedSections containsIndex:section] == YES) {
        switch (sectionInfo.identifier) {
            case WHWinerySectionWines:
                if ([self isLoadingWines]) {
                    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodGET
                                                                            matchingPathPattern:@"/api/wineries/:wineryId/wines"];
                }
                break;
            case WHWinerySectionEvents:
                if ([self isLoadingEvents]) {
                    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodGET
                                                                            matchingPathPattern:@"/api/events"];
                }
                break;
            case WHWinerySectionDoor:
                if ([self isLoadingOpeningTimes]) {
                    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodGET
                                                                            matchingPathPattern:@"/api/wineries/:wineryId/cellar_door_open_times"];
                }
                break;
            case WHWinerySectionCellarDoor360: {
                if ([self isLoadingPanoramas] == NO) {
                    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodGET
                                                                            matchingPathPattern:@"/api/wineries/:wineryId/panoramas"];
                }
                [self.panoramaDownloadManager cancel];
            }
                break;
        }
    } else {
        
        CFTimeInterval expandedSectionTime = CACurrentMediaTime();

        switch (sectionInfo.identifier) {
            case WHWinerySectionWines:
            {
                if (([self.winery isGold] == NO || self.winery.ranges.count <= 0) && ([self isLoadingWines] == NO)) {

                    if ([self.winery isMemberOfClass:[WHWineryMO class]]) {

                        _winesViewMore = NO;
                        
                        __weak typeof(self) blockSelf = self;
                        [[RKObjectManager sharedManager]
                         getObjectsAtPathForRelationship:@"wines"
                         ofObject:self.winery
                         parameters:nil
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

                             CFTimeInterval duration = CACurrentMediaTime() - expandedSectionTime;
                             double delayInSeconds = duration<1.0?1.0-duration:0.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                                 [blockSelf refreshWinesSection];

                             });
                         }
                         failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             /*
                              TODO: Present a short term message 'displaying offline results' & display offline results
                              */
                             if (!([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled)) {
                                 NSLog(@"Error - Fetch Wines Failure: %@",error);
                                 if (blockSelf.orderedWinesArray.count <= 0) {
                                     UITableViewCell * cell = [blockSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
                                     [cell.textLabel setText:@"Failed to load Wines"];
                                 } else {
                                     [blockSelf refreshWinesSection];
                                 }
                             }
                         }];
                    } else {
                        if ([self isLoadingWinery] == NO) {
                            //Reload & trigger fetch of Wines?
                        }
                    }
                }
            }
                break;
            case WHWinerySectionEvents:
            {
                if ([self isLoadingEvents] == NO) {
                    if ([self.winery isMemberOfClass:[WHWineryMO class]]) {
                        
                        __weak typeof(self) blockSelf = self;
                        [[RKObjectManager sharedManager]
                         getObjectsAtPathForRouteNamed:@"events"
                         object:nil
                         parameters:@{@"winery": self.wineryId}
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

                             CFTimeInterval duration = CACurrentMediaTime() - expandedSectionTime;
                             double delayInSeconds = duration<1.0?1.0-duration:0.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 [blockSelf refreshEventsSection];
                             });
                             
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             if (!([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled)) {
                                 if (blockSelf.winery.events.count <= 0) {
                                     WHEventsTableCell * eventCell = (id)[blockSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
                                     [eventCell.noEventsLabel setText:@"Failed to load events."];
                                     [eventCell.noEventsLabel setHidden:NO];
                                     [eventCell.activityIndicator stopAnimating];
                                 } else {
                                     [blockSelf refreshEventsSection];
                                 }
                             }
                         }];
                    } else {
                        if ([self isLoadingWinery] == NO) {
                            //Reload & trigger fetch of Wines?
                        }
                    }
                }
            }
                break;
            case WHWinerySectionDoor:
            {
                if ([self isLoadingOpeningTimes] == NO) {

                    if ([self.winery isMemberOfClass:[WHWineryMO class]]) {
                        
                        __weak typeof(self) blockSelf = self;
                        [[RKObjectManager sharedManager]
                         getObjectsAtPathForRelationship:@"cellarDoorOpenTimes"
                         ofObject:self.winery
                         parameters:nil
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             
                             [blockSelf.winery setCellarDoorOpenTimes:mappingResult.set];

                             CFTimeInterval duration = CACurrentMediaTime() - expandedSectionTime;
                             double delayInSeconds = duration<1.0?1.0-duration:0.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                                 //Check the user hasn't collapsed the section.
                                 if ([blockSelf.expandedSections containsIndex:section] == YES) {
                                     WHCellarDoorCell * cellarDoorCell = (WHCellarDoorCell*)[blockSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
                                     if (cellarDoorCell != nil) {
                                         [blockSelf.tableView beginUpdates];
                                         [cellarDoorCell setOpeningHoursString:[NSAttributedString openHoursAttributedStringWithObject:self.winery]]; //TODO - keep reference to this attributed string.
                                         [cellarDoorCell.activityIndicatorView stopAnimating];
                                         [blockSelf.tableView endUpdates];
                                     }
                                 }
                             });
                             
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             if (!([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled)) {
                                 NSLog(@"Error - Fetch Cellar Door Open Times Failure: %@",error);
                                 
                                 //Display error
                                 WHCellarDoorCell * cellarDoorCell = (WHCellarDoorCell*)[blockSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
                                 [cellarDoorCell.activityIndicatorView stopAnimating];
                             }
                         }];
                    } else {
                        if ([self isLoadingWinery] == NO) {
                            //Reload & trigger fetch of Wines?
                        }
                    }
                }
            }
                break;
                
            case WHWinerySectionCellarDoor360:
            {
                if ([self isLoadingPanoramas] == NO) {

                    __weak typeof(self) weakSelf = self;

                    [[RKObjectManager sharedManager]
                     getObjectsAtPathForRelationship:@"panoramas"
                     ofObject:self.winery
                     parameters:nil
                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                         
                         CFTimeInterval duration = CACurrentMediaTime() - expandedSectionTime;
                         double delayInSeconds = duration<0.5?0.5-duration:0.0;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [weakSelf refreshPanoramasSection];
                         });
                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                         [weakSelf refreshPanoramasSection];
                     }];
                }
            }
                break;
            default:
                break;
        }
    }
    [super didSelectTableViewHeaderSection:headerView];
}

#pragma mark

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.winery.photographs.count <= 0)  {
        return;
    }
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark
#pragma mark WHEventsTableCellDataSource

- (NSInteger)numberOfEventsInEventsCell:(WHEventsTableCell *)eventsCell
{
    if ([self isLoadingEvents] == NO) {
        return [self.orderedEventsArray count];
    } else {
        return 0;
    }
}

- (WHEventMO *)eventsCell:(WHEventsTableCell *)eventsCell eventObjectForIndex:(NSInteger)index
{
    return [self.orderedEventsArray objectAtIndex:index];
}

#pragma mark WHEventsTableCellDelegate

- (void)eventsCell:(WHEventsTableCell *)eventsCell didSelectEventAtIndex:(NSInteger)index
{
    WHEventMO * event = [self.orderedEventsArray objectAtIndex:index];
    if (event != nil) {
        [[Mixpanel sharedInstance] track:@"View Event from Winery"
                              properties:@{@"event_id"   :event.eventId    ?: @"",
                                           @"event_name" :event.name       ?: @"",
                                           @"winery_id"  :self.wineryId    ?: @"",
                                           @"winery_name":self.winery.name ?: @""}];
        
        UIStoryboard * eventStoryboard = [UIStoryboard storyboardWithName:@"Event" bundle:[NSBundle mainBundle]];
        WHEventViewController * eventViewController = [eventStoryboard instantiateInitialViewController];
        [eventViewController setEventId:event.eventId];
        [self.navigationController pushViewController:eventViewController animated:YES];
    }
}

#pragma mark -
#pragma mark WHContactCellDelegate

- (void)contactCell:(WHContactCell *)contactCell didTapMapView:(GMSMapView *)mapView
{
    UIStoryboard * mapStoryboard = [UIStoryboard storyboardWithName:@"Map" bundle:[NSBundle mainBundle]];
    WHMapViewController * mapVC = [mapStoryboard instantiateInitialViewController];
    [mapVC setMarkerLocation:self.winery.location.coordinate];
    if (contactCell.wineryMarker != nil) {
        [mapVC setMarkerIcon:contactCell.wineryMarker];
    } else {
        [mapVC setMarkerIcon:[UIImage imageNamed:WHWineryMarkerImageName[self.winery.tierValue]]];
    }
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark
#pragma mark WHAboutCellDelegate

- (void)aboutCell:(WHAboutCell *)cell didTapReadMoreButton:(UIButton *)button
{
    _aboutViewMore = YES;
    
    NSInteger sectionIndex = [self sectionIndexForIdentifier:WHWinerySectionAbout];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark WHCellarDoorCellDelegate

- (void)cellarDoorCell:(WHCellarDoorCell *)cell didSelectReadMoreButton:(UIButton *)button
{
    [self performSegueWithIdentifier:@"DisplayCellarDoor" sender:self.wineryId];
}

#pragma mark WHPhotographCellDelegate

- (void)photographCellDidTouchUpInside:(WHPhotographCell *)cell
{
    NSLog(@"%s", __func__);
    if (cell.photograph != nil) {
        if (self.panoramaDownloadManager == nil) {
            PCFileDownloadManager * fileDownloadManager = [PCFileDownloadManager new];
            _panoramaDownloadManager = fileDownloadManager;
        }
        
        [cell setDownloadProgress:0.001]; //display progress immediately.

        __weak typeof (cell) weakCell = cell;
        [self.panoramaDownloadManager cancel];
        [self.panoramaDownloadManager downloadURL:[NSURL URLWithString:cell.photograph.imageURL] progressBlock:^(CGFloat progress) {
            [weakCell setDownloadProgress:progress];
        } completion:^(NSString *filePath, NSError *error) {
            if (filePath != nil) {
                [self performSegueWithIdentifier:@"DisplayPanorama" sender:filePath];
                
            }
            [weakCell setDownloadProgress:0.0];
        }];
    }
}

#pragma mark WHFavouriteAlertViewDelegate

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapOptOutButton:(UIButton *)button
{
    BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName]
                                                identifier:self.wineryId];
    [self.tableHeaderView.favouriteButton setSelected:didFavourite];
    
    [[WHAlertView currentAlertView] dismiss];
    
    if (self.wineryId != nil) {
        [[Mixpanel sharedInstance] track:@"Favourited Winery" properties:@{@"winery_id": self.wineryId,
                                                                           @"opted_out": @(YES)}];
    }
}

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapFavouriteButton:(UIButton *)button
{
    if ([WHFavouriteManager email] == nil) {
        if ([view.textField.text isEqualToString:[NSString string]] || view.textField.text == nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoEmailAlertTitle",nil)
                                        message:NSLocalizedString(@"kFavouriteNoEmailAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            return;
        } else {
            [view.textField resignFirstResponder];
            [WHFavouriteManager setEmail:view.textField.text];
        }
    }
    NSString * email = [WHFavouriteManager email];
    
    if (email != nil) {
        [PCDHUD show];
        
        __weak typeof(self) blockSelf = self;
        [WHFavouriteManager favouriteWineryId:self.wineryId
                                    withEmail:email
                                     callback:^(BOOL success, NSError *error) {
                                         if (success ) {
                                             [WHLoadingHUD dismiss];

                                             BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName] identifier:blockSelf.wineryId];
                                             [blockSelf.tableHeaderView.favouriteButton setSelected:didFavourite];
                                             
                                             //TODO - Implement shared WHAlertView getter
                                             WHAlertView * alertView = (WHAlertView*)view.superview;
                                             [alertView dismiss];
                                             
                                             if (blockSelf.wineryId != nil) {
                                                 [[Mixpanel sharedInstance] track:@"Favourited Winery" properties:@{@"winery_id": blockSelf.wineryId}];
                                             }

                                         } else {
                                             NSLog(@"Failed to add to mailing list: %@",error);
                                             [PCDHUD showError:error];
                                         }
                                     }];
    }
}

#pragma mark WHWineCellDelegate

- (void)wineCell:(WHWineCell *)wineCell didTapFavouriteButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    /* Favouriting a Wine doesn't require user to be added to mailing list */
    
    BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineMO entityName]
                                                identifier:wineCell.wine.wineId];
    [button setSelected:didFavourite];
    
    if (didFavourite == YES) {
        AFNetworkReachabilityStatus reachability = [[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus];
        if (reachability == AFNetworkReachabilityStatusReachableViaWWAN || reachability == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHFavouriteAlertView" owner:nil options:nil];
            WHFavouriteAlertView * favouriteAlertView = [views firstObject];
            [favouriteAlertView setDelegate:(id)self];
            
            if ([WHFavouriteManager email] == nil) {
                [favouriteAlertView displayEmailEntry];
            }
            
            [WHAlertView presentView:favouriteAlertView animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoInternetAlertTitle", nil)
                                        message:NSLocalizedString(@"kFavouriteNoInternetAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }
}

@end

