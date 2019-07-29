//
//  WHRegionViewController.m
//  WineHound
//
//  Created by Mark Turner on 09/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <CoreLocation/CLLocation.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <forecast-ios-api/ForecastApi.h>

#import "WHRegionViewController.h"
#import "WHEventViewController.h"
#import "WHMapViewController.h"
#import "WHPDFViewController.h"
#import "WHWineriesViewController.h"
#import "WHWineriesMapViewController.h"
#import "WHWineriesListViewController.h"
#import "WHWebViewController.h"

#import "PCGalleryViewController.h"
#import "PCPhoto.h"

#import "WHEventsTableCell.h"
#import "WHAboutCell.h"
#import "WHRegionContactCell.h"
#import "WHPhotographMO.h"
#import "TableHeaderView.h"
#import "WHSectionInfo.h"

#import "UIViewController+Social.h"
#import "WHEventMO+Mapping.h"
#import "WHWinerySectionHeaderView.h"
#import "WHRegionMO+Additions.h"
#import "NSManagedObject+Additions.h"

NS_ENUM(NSInteger, WHRegionSectionEnum) {
    WHRegionSectionEvents,
    WHRegionSectionAbout,
    WHRegionSectionWineries,
    WHRegionSectionCideries,
    WHRegionSectionBreweries,
    WHRegionSectionDownloadPDF,
    WHRegionSectionContact,
    WHRegionSectionFacebook,
    WHRegionSectionTwitter,
    WHRegionSectionInstagram,
    WHRegionSectionCount,
};

NSString * const WHRegionSectionTitles[] = {
    [WHRegionSectionEvents]   = @"What's On",
    [WHRegionSectionAbout]    = @"About",
    [WHRegionSectionWineries] = @"Wineries",
    [WHRegionSectionCideries] = @"Cideries",
    [WHRegionSectionBreweries]= @"Breweries",
    [WHRegionSectionDownloadPDF] = @"Download Map",
    [WHRegionSectionContact]  = @"Contact",
    [WHRegionSectionFacebook] = @"Facebook",
    [WHRegionSectionTwitter]  = @"Twitter",
    [WHRegionSectionInstagram]= @"Instagram"
};

NSString * const WHRegionSectionImageNames[] = {
    [WHRegionSectionEvents]   = @"winery_events_icon",
    [WHRegionSectionAbout]    = @"winery_about_icon",
    [WHRegionSectionWineries] = @"region_wineries_icon",
    [WHRegionSectionCideries] = @"region_cideries_icon",
    [WHRegionSectionBreweries]= @"region_breweries_icon",
    [WHRegionSectionDownloadPDF] = @"region_map_section_icon",
    [WHRegionSectionContact]  = @"winery_contact_icon",
    [WHRegionSectionFacebook] = @"winery_section_facebook_icon",
    [WHRegionSectionTwitter]  = @"winery_section_twitter_icon",
    [WHRegionSectionInstagram]= @"winery_section_instagram_icon"
};

@interface WHRegionViewController ()
<
UITableViewDataSource,UITableViewDelegate,
WHEventsTableCellDataSource,WHEventsTableCellDelegate,
WHWinerySectionHeaderViewDelegate
>
{
    BOOL _aboutViewMore;
}
@property (nonatomic) WHRegionMO * region;
@property (nonatomic) NSArray * orderedEventsArray;
@property (nonatomic) NSArray * sectionArray;
@property (nonatomic) CLLocation * fetchWeatherLocation;
@property (nonatomic,strong) WHWineriesMapViewController * wineriesMapViewController;
@end

@implementation WHRegionViewController
@synthesize region = _region;

#pragma mark

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableHeaderView.weatherInfoButton setAlpha:0.0];
    [self.tableHeaderView.favouriteButton setHidden:YES];
    [self.tableHeaderView setImageIndicatorPosition:1];
    
    [self.tableView registerNib:[WHEventsTableCell nib] forCellReuseIdentifier:[WHEventsTableCell reuseIdentifier]];
    [self.tableView registerNib:[WHRegionContactCell nib] forCellReuseIdentifier:[WHRegionContactCell reuseIdentifier]];
    [self.tableView setTableFooterView:nil];
    
    [self setRegion:[self region]];

    if (self.regionId != nil) {
        [[Mixpanel sharedInstance] track:@"Show Region" properties:@{@"region_id": self.regionId}];
    }
    
    UIStoryboard * wineriesStoryboard = [UIStoryboard storyboardWithName:@"Wineries" bundle:[NSBundle mainBundle]];
    WHWineriesMapViewController * wmvc = [wineriesStoryboard instantiateViewControllerWithIdentifier:@"WHWineriesMapViewController"];
    /*
    [wmvc setDefinesPresentationContext:YES];
     */
    [self addChildViewController:wmvc];
    _wineriesMapViewController = wmvc;
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    //Gimme it back.
    [self addChildViewController:self.wineriesMapViewController];
    
    NSInteger contactSection = NSNotFound;
    for (WHSectionInfo * sectionInfo in _sectionArray) {
        if (sectionInfo.identifier == WHRegionSectionContact) {
            contactSection = [_sectionArray indexOfObject:sectionInfo];
            break;
        }
    }
    if (contactSection != NSNotFound) {
        if ([self.expandedSections containsIndex:contactSection] == YES) {
            [self.tableView reloadData];
        }
    }
    
    [super viewWillAppear:animated];
}
 */

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

#pragma mark

- (void)setRegionId:(NSNumber *)regionId
{
    _regionId = regionId;
    
    __weak typeof(self) blockSelf = self;
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"region"
                                                            object:@{@"regionId": _regionId}
                                                        parameters:nil
                                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                               [blockSelf setRegion:[blockSelf region]];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to fetch Region: %@",error);
    }];
}

- (void)setRegion:(WHRegionMO *)region
{
    _region = region;

    [self setTitle:@"Region"];
    
    _sectionArray = nil;
    [self sectionArray];
    
    [self.tableHeaderView.titleLabel setText:_region.name];
    [self.tableHeaderView reload];

    [self.tableView reloadData];

    [self updateWeatherInfo];
}

- (WHRegionMO *)region
{
    if (_region == nil) {
        WHRegionMO * region = [WHRegionMO MR_findFirstByAttribute:@"regionId" withValue:_regionId];
        _region = region;
    }
    return _region;
}

- (NSArray *)sectionArray
{
    if (_sectionArray == nil) {
        NSMutableArray * sections = @[].mutableCopy;
        
        WHSectionInfo * eventSection = [WHSectionInfo new];
        [eventSection setIdentifier:WHRegionSectionEvents];
        [eventSection setRowCount:1];
        [sections addObject:eventSection];

        if (self.region.about.length > 0) {
            WHSectionInfo * aboutSection = [WHSectionInfo new];
            [aboutSection setIdentifier:WHRegionSectionAbout];
            [aboutSection setRowCount:1];
            [sections addObject:aboutSection];
        }

        if (self.region.hasWineries.boolValue) {
            WHSectionInfo * wineriesSection = [WHSectionInfo new];
            [wineriesSection setIdentifier:WHRegionSectionWineries];
            [wineriesSection setRowCount:0];
            [sections addObject:wineriesSection];
        }

        if (self.region.hasCideries.boolValue) {
            WHSectionInfo * cideriesSection = [WHSectionInfo new];
            [cideriesSection setIdentifier:WHRegionSectionCideries];
            [cideriesSection setRowCount:0];
            [sections addObject:cideriesSection];
        }

        if (self.region.hasBreweries.boolValue) {
            WHSectionInfo * breweriesSection = [WHSectionInfo new];
            [breweriesSection setIdentifier:WHRegionSectionBreweries];
            [breweriesSection setRowCount:0];
            [sections addObject:breweriesSection];
        }
        
        if (self.region.pdfURL.length > 0) {
            WHSectionInfo * downloadMapSection = [WHSectionInfo new];
            [downloadMapSection setIdentifier:WHRegionSectionDownloadPDF];
            [downloadMapSection setRowCount:1];
            [sections addObject:downloadMapSection];
        }

        WHSectionInfo * contactSection = [WHSectionInfo new];
        [contactSection setIdentifier:WHRegionSectionContact];
        [contactSection setRowCount:1];
        [sections addObject:contactSection];

        if (self.region.facebook.length > 0) {
            WHSectionInfo * facebookSection = [WHSectionInfo new];
            [facebookSection setIdentifier:WHRegionSectionFacebook];
            [facebookSection setRowCount:0];
            [sections addObject:facebookSection];
        }
        if (self.region.twitter.length > 0) {
            WHSectionInfo * twitterSection = [WHSectionInfo new];
            [twitterSection setIdentifier:WHRegionSectionTwitter];
            [twitterSection setRowCount:0];
            [sections addObject:twitterSection];
        }
        if (self.region.instagram.length > 0) {
            WHSectionInfo * instagramSection = [WHSectionInfo new];
            [instagramSection setIdentifier:WHRegionSectionInstagram];
            [instagramSection setRowCount:0];
            [sections addObject:instagramSection];
        }
        
        _sectionArray = [NSArray arrayWithArray:sections];
    }
    return _sectionArray;
}

- (BOOL)isLoadingEvents
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/events"];
    return operations.count > 0;
}


- (void)updateWeatherInfo
{
    if ([self.fetchWeatherLocation isEqual:self.region.location] == NO) {
        if (self.region.latitude != nil && self.region.longitude != nil) {
            
            [self setFetchWeatherLocation:self.region.location];
            
            __weak typeof (self) weakSelf = self;
            [[ForecastApi sharedInstance] getCurrentDataForLatitude:self.fetchWeatherLocation.coordinate.latitude
                                                          longitude:self.fetchWeatherLocation.coordinate.longitude
                                                            success:^(ForecastData *data) {
                                                                NSLog(@"temp: %@ at lat: %@ long: %@",@(data.temperature),@(self.fetchWeatherLocation.coordinate.latitude),@(self.fetchWeatherLocation.coordinate.longitude));
                                                                [weakSelf displayWeatherWithForecastData:data];
                                                            } failure:^(NSError *error) {
                                                                NSLog(@"Failed to fetch weather update - %@", error);
                                                            }];
        }
    }
}

- (void)displayWeatherWithForecastData:(ForecastData *)forecastData
{
    UIImage * weatherIcon = [UIImage imageNamed:[NSString stringWithFormat:@"%@_weatherIcon",forecastData.icon]];
    if (weatherIcon != nil) {
        [self.tableHeaderView.weatherInfoButton setImage:weatherIcon forState:UIControlStateNormal];
        [self.tableHeaderView.weatherInfoButton setTitle:[NSString stringWithFormat:@"%@°",@(floorf(forecastData.temperature))] forState:UIControlStateNormal];
        [self.tableHeaderView.weatherInfoButton setNeedsLayout];
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            [self.tableHeaderView.weatherInfoButton setAlpha:1.0];
        } completion:nil];
    }
}

#pragma mark Notifications

- (void)_applicationDidBecomeActive:(NSNotification *)notification
{
    [self setFetchWeatherLocation:nil];
    [self updateWeatherInfo];
}

#pragma mark
#pragma mark WHDetailViewControllerProtocol

- (NSString *)titleForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:section];
    return WHRegionSectionTitles[sectionInfo.identifier];
}

- (UIImage *)imageForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:section];
    return [UIImage imageNamed:WHRegionSectionImageNames[sectionInfo.identifier]];
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return YES;
}

- (NSString *)name
{
    return self.region.name;
}

- (NSString *)phoneNumber
{
    return self.region.phoneNumber;
}

- (NSString *)email
{
    return self.region.email;
}

- (NSString *)website
{
    return self.region.websiteUrl;
}

- (CLLocation *)location
{
    return [[CLLocation alloc] initWithLatitude:self.region.latitude.doubleValue
                                      longitude:self.region.longitude.doubleValue];
}

- (NSString *)aboutDescription
{
    return self.region.about;
}

- (NSInteger)numberOfPhotographs
{
    if (self.region.photographs.count <= 0) {
        return 1;
    }
    return [self.region.photographs count];
}

- (NSURL *)photographURLAtIndex:(NSInteger)index
{
    if (self.region.photographs.count <= 0) {
        NSString * regionPlaceholderPath = [[NSBundle mainBundle] pathForResource:@"region_placeholder" ofType:@"png"];
        return [NSURL fileURLWithPath:regionPlaceholderPath];
    }
    WHPhotographMO * photograph = [self.region.photographs objectAtIndex:index];
    return [NSURL URLWithString:photograph.imageThumbURL];
}

#pragma mark PCGalleryViewControllerDataSource

- (NSUInteger)numberOfPhotosInGallery:(PCGalleryViewController *)gallery
{
    return [self.region.photographs count];
}

- (PCPhoto *)gallery:(PCGalleryViewController *)gallery photoAtIndex:(NSUInteger)index
{
    WHPhotographMO * photograph = [self.region.photographs objectAtIndex:index];
    
    PCPhoto * photo = [PCPhoto new];
    [photo setPhotoURL:[NSURL URLWithString:photograph.imageURL]];
    [photo setThumbURL:[NSURL URLWithString:photograph.imageThumbURL]];
    return photo;
}

#pragma mark WHWinerySectionHeaderViewDelegate

- (void)didSelectTableViewHeaderSection:(WHWinerySectionHeaderView *)headerView
{
    WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:headerView.section];
    
    switch (sectionInfo.identifier) {
        case WHRegionSectionWineries: {
            UIStoryboard * wineriesStoryboard = [UIStoryboard storyboardWithName:@"Wineries" bundle:[NSBundle mainBundle]];
            WHWineriesViewController * vc = [wineriesStoryboard instantiateViewControllerWithIdentifier:@"WHWineriesViewController"];
            [vc setRegionId:self.regionId];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case WHRegionSectionCideries:
        case WHRegionSectionBreweries: {
            UIStoryboard * wineriesStoryboard = [UIStoryboard storyboardWithName:@"Wineries" bundle:[NSBundle mainBundle]];
            WHWineriesListViewController * vc = [wineriesStoryboard instantiateViewControllerWithIdentifier:@"WHWineriesListViewController"];
            [vc setRegionId:self.regionId];
            if (sectionInfo.identifier == WHRegionSectionCideries) {
                [vc setFetchWineryType:WHWineryTypeCidery];
                [vc setTitle:@"Cideries"];
            }
            if (sectionInfo.identifier == WHRegionSectionBreweries) {
                [vc setFetchWineryType:WHWineryTypeBrewery];
                [vc setTitle:@"Breweries"];
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case WHRegionSectionDownloadPDF: {
            WHPDFViewController * pdfVC = [WHPDFViewController new];
            [pdfVC setPdfURL:[NSURL URLWithString:self.region.pdfURL]];
            [self.navigationController pushViewController:pdfVC animated:YES];
        }
            break;
        case WHRegionSectionFacebook: {
            NSString * facebookHandle = [self.region.facebook copy];
            [self openInstagramAppOrPresentWebviewWithHandle:facebookHandle];
            return;
        }
        case WHRegionSectionTwitter: {
            NSString * twitterHandle = [self.region.twitter copy];
            [self openTwitterAppOrPresentWebviewWithHandle:twitterHandle];
            return;
        }
            break;
        case WHRegionSectionInstagram: {
            NSString * instagramHandle = [self.region.instagram copy];
            [self openInstagramAppOrPresentWebviewWithHandle:instagramHandle];
            return;
        }
        /*
        case WHRegionSectionContact: {
             TODO - we can introduce a completion block when section has been collapsed & then remove child vc.
             
            if ([self.expandedSections containsIndex:headerView.section] == YES) {
                [self.wineriesMapViewController willMoveToParentViewController:nil];
                [self.wineriesMapViewController.view removeFromSuperview];
                [self.wineriesMapViewController removeFromParentViewController];
            }
        }
         */
        case WHRegionSectionEvents: {
            if ([self isLoadingEvents] == NO && ([self.expandedSections containsIndex:headerView.section] == NO)) {
                
                __weak typeof(self) weakSelf = self;
                
                [[RKObjectManager sharedManager]
                 getObjectsAtPathForRouteNamed:@"events"
                 object:nil
                 parameters:@{@"region": self.regionId}
                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                     
                     WHEventsTableCell * eventCell = (id)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:headerView.section]];
                     [eventCell.activityIndicator stopAnimating];
                     
                     [weakSelf setOrderedEventsArray:[WHEventMO MR_findAllSortedBy:@"startDate"
                                                                         ascending:YES
                                                                     withPredicate:[NSPredicate predicateWithFormat:@"%@ IN regions",weakSelf.region]]];
                     
                     if ([weakSelf.orderedEventsArray count] > 0) {
                         [eventCell.noEventsLabel setHidden:YES];
                         [eventCell.collectionView setHidden:NO];
                         
                         [weakSelf.tableView beginUpdates];
                         [weakSelf.tableView endUpdates];
                         
                         [eventCell reload];
                     } else {
                         [eventCell.noEventsLabel setText:@"No events for this Region"];
                         [eventCell.noEventsLabel setHidden:NO];
                     }
                     
                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                     WHEventsTableCell * eventCell = (id)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:headerView.section]];
                     [eventCell.noEventsLabel setText:@"Failed to fetch events."];
                     [eventCell.noEventsLabel setHidden:NO];
                     [eventCell.activityIndicator stopAnimating];
                 }];
            } else if ([self isLoadingEvents]) {
                [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodGET
                                                                        matchingPathPattern:@"/api/events"];
            }
            [super didSelectTableViewHeaderSection:headerView];
            break;
        }
        case WHRegionSectionAbout: {
            _aboutViewMore = NO;
            [super didSelectTableViewHeaderSection:headerView];
            break;
        }
        default:
            [super didSelectTableViewHeaderSection:headerView];
            break;
    }
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WHWinerySectionHeaderView * winerySectionHeaderView = (WHWinerySectionHeaderView *)[super tableView:tableView viewForHeaderInSection:section];

    WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:section];
    if (sectionInfo.identifier == WHRegionSectionWineries    ||
        sectionInfo.identifier == WHRegionSectionCideries    ||
        sectionInfo.identifier == WHRegionSectionBreweries   ||
        sectionInfo.identifier == WHRegionSectionDownloadPDF ||
        sectionInfo.identifier == WHRegionSectionFacebook    ||
        sectionInfo.identifier == WHRegionSectionTwitter     ||
        sectionInfo.identifier == WHRegionSectionInstagram) {

        [winerySectionHeaderView.sectionAccesoryView setTransform:CGAffineTransformMakeRotation(M_PI_2*3)];
    }
    return winerySectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.expandedSections containsIndex:section]) {
        WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:section];
        if (sectionInfo.identifier == WHRegionSectionWineries) {
            return 0;
        } else {
            return 1; //For now each section only has one cell.
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:indexPath.section];
    switch (sectionInfo.identifier) {
        case WHRegionSectionEvents:
            return [tableView dequeueReusableCellWithIdentifier:[WHEventsTableCell reuseIdentifier]];
            break;
        case WHRegionSectionAbout:
            return [tableView dequeueReusableCellWithIdentifier:[WHAboutCell reuseIdentifier]];
            break;
        case WHRegionSectionContact: {
            WHRegionContactCell * regionContactCell = [tableView dequeueReusableCellWithIdentifier:[WHRegionContactCell reuseIdentifier]];
            [self.wineriesMapViewController setRegionId:self.regionId];
            [regionContactCell.mapContainerView addSubview:self.wineriesMapViewController.view];
            [self.wineriesMapViewController setMapInteractionEnabled:NO];
            [self.wineriesMapViewController setContentEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
            [self.wineriesMapViewController didMoveToParentViewController:self];
            return regionContactCell;
        }
            break;
        default:
            break;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:indexPath.section];
    switch (sectionInfo.identifier) {
        case WHRegionSectionEvents:
        {
            WHEventsTableCell * eventsCell = (WHEventsTableCell*)cell;
            [eventsCell setDataSource:self];
            [eventsCell setDelegate:self];
            [eventsCell reload];
            
            [eventsCell.noEventsLabel setHidden:YES];
            
            if ([self isLoadingEvents]) {
                [eventsCell.activityIndicator startAnimating];
                [eventsCell.collectionView setHidden:YES];
            } else {
                [eventsCell.activityIndicator stopAnimating];
            }
        }
            break;
        case WHRegionSectionAbout:
        {
            WHAboutCell * aboutCell = (WHAboutCell*)cell;
            [aboutCell setAboutText:self.region.about truncated:_aboutViewMore?NO:YES];
            [aboutCell setDelegate:(id)self];
        }
            break;
        case WHRegionSectionContact:
        {
            WHContactCell * contactCell = (WHContactCell*)cell;
            [contactCell setDelegate:self];
            [contactCell setRegion:self.region];
        }
            break;
        default:
            break;
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHSectionInfo * sectionInfo = [self.sectionArray objectAtIndex:indexPath.section];
    switch (sectionInfo.identifier) {
        case WHRegionSectionEvents:
            if ([self isLoadingEvents] == NO && (self.orderedEventsArray.count > 0)) {
                return [WHEventsTableCell cellHeight];
            } else {
                return 50.0;
            }
        case WHRegionSectionAbout:
            return [WHAboutCell cellHeightForAboutText:self.region.about truncated:_aboutViewMore?NO:YES];
        case WHRegionSectionContact:
            return [WHContactCell cellHeightForRegionObject:self.region];
            break;
        default:
            break;
    }
    return 100.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.region.photographs.count <= 0) {
        return;
    }
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark
#pragma mark WHEventsTableCellDataSource

- (NSInteger)numberOfEventsInEventsCell:(WHEventsTableCell *)eventsCell
{
    return [self.orderedEventsArray count];
}

- (WHEventMO *)eventsCell:(WHEventsTableCell *)eventsCell eventObjectForIndex:(NSInteger)index
{
    if ([self isLoadingEvents] == NO) {
        return [self.orderedEventsArray objectAtIndex:index];
    } else {
        return 0;
    }
}

#pragma mark WHEventsTableCellDelegate

- (void)eventsCell:(WHEventsTableCell *)eventsCell didSelectEventAtIndex:(NSInteger)index
{
    WHEventMO * event = [self.orderedEventsArray objectAtIndex:index];
    
    if (event != nil) {
        [[Mixpanel sharedInstance] track:@"View Event from Region"
                              properties:@{@"event_id"   :event.eventId    ?: @"",
                                           @"event_name" :event.name       ?: @"",
                                           @"region_id"  :self.regionId    ?: @"",
                                           @"region_name":self.region.name ?: @""}];
    }
    
    UIStoryboard * eventStoryboard = [UIStoryboard storyboardWithName:@"Event" bundle:[NSBundle mainBundle]];
    WHEventViewController * eventViewController = [eventStoryboard instantiateInitialViewController];
    [eventViewController setEventId:event.eventId];
    [self.navigationController pushViewController:eventViewController animated:YES];
}


- (void)contactCell:(WHContactCell *)contactCell didTapMapView:(GMSMapView *)mapView;
{
    /*
     todo avoid creating a second map vc
    [self.wineriesMapViewController willMoveToParentViewController:nil];
    [self.wineriesMapViewController removeFromParentViewController];
    [self.navigationController pushViewController:self.wineriesMapViewController animated:YES];
     */
    UIStoryboard * wineriesStoryboard = [UIStoryboard storyboardWithName:@"Wineries" bundle:[NSBundle mainBundle]];
    WHWineriesMapViewController * wmvc = [wineriesStoryboard instantiateViewControllerWithIdentifier:@"WHWineriesMapViewController"];
    [wmvc setRegionId:self.regionId];
    [self.navigationController pushViewController:wmvc animated:YES];

}

#pragma mark
#pragma mark WHAboutCellDelegate

- (void)aboutCell:(WHAboutCell *)cell didTapReadMoreButton:(UIButton *)button
{
    NSInteger sectionIndex = NSNotFound;
    for (WHSectionInfo * sectionInfo in self.sectionArray) {
        if (sectionInfo.identifier == WHRegionSectionAbout) {
            sectionIndex = [self.sectionArray indexOfObject:sectionInfo];
            break;
        }
    }

    if (sectionIndex != NSNotFound) {
        _aboutViewMore = YES;
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

@end
