//
//  WHEventViewController.m
//  WineHound
//
//  Created by Mark Turner on 20/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <RestKit/RestKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "WHEventViewController.h"
#import "WHEventMO+Mapping.h"
#import "WHEventMO+Additions.h"
#import "WHFavouriteMO+Additions.h"
#import "WHPhotographMO.h"
#import "WHRegionMO.h"

#import "PCGalleryViewController.h"
#import "PCPhoto.h"
#import "WHSectionInfo.h"
#import "WHWebViewController.h"

#import "WHAboutCell.h"
#import "WHEventInfoCell.h"
#import "WHEventWhenCell.h"
#import "WHEventButtonsCell.h"
#import "WHLoadingHUD.h"

#import "WHShareManager.h"
#import "WHFavouriteManager.h"
#import "WHAlertView.h"
#import "WHFavouriteAlertView.h"

#import "NSCalendar+WineHound.h"
#import "NSAttributedString+HTML.h"
#import "TableHeaderView.h"

NS_ENUM(NSInteger, WHEventSectionEnum) {
    WHEventSectionWhen,
    WHEventSectionInfo,
    WHEventSectionButtons,
    WHEventSectionCount
};

NS_ENUM(NSInteger, WHFeaturedEventSectionEnum) {
    WHFeaturedEventSectionAbout,
    WHFeaturedEventSectionWhatsOn,
    WHFeaturedEventSectionContact,
};

@interface WHEventViewController () <WHEventButtonsCellDelegate,EKEventEditViewDelegate,WHEventsTableCellDelegate>
{
    WHEventMO __weak * _event;

    WHShareManager * _shareManager;

    BOOL _aboutViewMore;
}
@property (nonatomic,weak) WHEventMO * event;
@property (nonatomic) NSArray * featuredEventSections;
@property (nonatomic) NSArray * orderedEventsArray;
@end

@implementation WHEventViewController

#pragma mark

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"What's On"];
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    
    [self.tableView registerNib:[WHEventInfoCell nib]    forCellReuseIdentifier:[WHEventInfoCell reuseIdentifier]];
    [self.tableView registerNib:[WHEventWhenCell nib]    forCellReuseIdentifier:[WHEventWhenCell reuseIdentifier]];
    [self.tableView registerNib:[WHEventButtonsCell nib] forCellReuseIdentifier:[WHEventButtonsCell reuseIdentifier]];
    
    [self setEvent:[self event]];
    
    [self reload];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                                style:UIBarButtonItemStyleBordered
                                                                               target:self
                                                                               action:@selector(_shareBarButtonItemAction:)]];
    [self.navigationItem  setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:self.event.name
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:nil
                                                                               action:NULL]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableHeaderView.titleLabel setText:self.event.name];
}

#pragma mark 

- (NSArray *)featuredEventSections
{
    if (_featuredEventSections == nil) {
        if (self.event.isFeatured) {
            NSMutableArray * featuredEventSections = @[].mutableCopy;
            
            WHSectionInfo * aboutSection = [WHSectionInfo sectionInfoWithSectionTitle:@"About" sectionImage:[UIImage imageNamed:@"events_about_icon"]];
            [aboutSection setRowCount:1];
            [aboutSection setIdentifier:WHFeaturedEventSectionAbout];
            [featuredEventSections addObject:aboutSection];
            
            if ([self.event.eventIds isKindOfClass:[NSArray class]]) {
                if ([(NSArray *)self.event.eventIds count] > 0) {
                    WHSectionInfo * eventsSection = [WHSectionInfo sectionInfoWithSectionTitle:@"What's On" sectionImage:[UIImage imageNamed:@"events_events_icon"]];
                    [eventsSection setRowCount:1];
                    [eventsSection setIdentifier:WHFeaturedEventSectionWhatsOn];
                    [featuredEventSections addObject:eventsSection];
                }
            }

            WHSectionInfo * contactSection = [WHSectionInfo sectionInfoWithSectionTitle:@"Contact" sectionImage:[UIImage imageNamed:@"events_contact_icon"]];
            [contactSection setRowCount:1];
            [contactSection setIdentifier:WHFeaturedEventSectionContact];
            [featuredEventSections addObject:contactSection];
            
            _featuredEventSections = [featuredEventSections copy];
        }
    }
    return _featuredEventSections;
}

- (NSArray *)orderedEventsArray
{
    if (_orderedEventsArray == nil) {
        _orderedEventsArray = [self.event.events sortedArrayUsingDescriptors:[WHEventMO sortDescriptors]];
    }
    return _orderedEventsArray;
}

#pragma mark WHDetailViewControllerProtocol

- (NSString *)titleForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    if (self.event.isFeatured) {
        WHSectionInfo * sectionInfo = [self.featuredEventSections objectAtIndex:section];
        return sectionInfo.title;
    }
    return nil;
}

- (UIImage *)imageForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    if (self.event.isFeatured) {
        WHSectionInfo * sectionInfo = [self.featuredEventSections objectAtIndex:section];
        return sectionInfo.image;
    }
    return nil;
}

- (NSString *)name
{
    return self.event.name;
}

- (NSString *)phoneNumber
{
    return self.event.phoneNumber;
}

- (NSString *)website
{
    return self.event.website;
}

- (CLLocation *)location
{
    return [[CLLocation alloc] initWithLatitude:self.event.latitude.doubleValue
                                      longitude:self.event.longitude.doubleValue];
}

- (NSString *)aboutDescription
{
    return self.event.eventDescription;
}

- (NSInteger)numberOfPhotographs
{
    return [self.event.photographs count];
}

- (NSURL *)photographURLAtIndex:(NSInteger)index
{
    WHPhotographMO * photograph = [self.event.photographs objectAtIndex:index];
    return [NSURL URLWithString:photograph.imageURL];
}

- (void)headerFavouriteButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHEventMO entityName] identifier:self.eventId];
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
        BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHEventMO entityName] identifier:self.eventId];
        [button setSelected:didFavourite];
    }
}

#pragma mark WHFavouriteAlertViewDelegate

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapOptOutButton:(UIButton *)button
{
    BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHEventMO entityName] identifier:self.eventId];
    [self.tableHeaderView.favouriteButton setSelected:didFavourite];
    
    [[WHAlertView currentAlertView] dismiss];
    
    if (self.eventId != nil) {
        [[Mixpanel sharedInstance] track:@"Favourited Event" properties:@{@"event_id" : self.eventId,
                                                                          @"opted_out": @(YES)}];
    }
}

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapFavouriteButton:(UIButton *)button
{
    /* Note, this could easily be refactored into WHDetailViewController */
    
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
        
        [WHFavouriteManager favouriteKey:@"event_id"
                          withIdentifier:self.eventId
                               withEmail:email
                                callback:^(BOOL success, NSError *error) {
                                    if (success) {
                                        [WHLoadingHUD dismiss];
                                        
                                        BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHEventMO entityName] identifier:blockSelf.eventId];
                                        [blockSelf.tableHeaderView.favouriteButton setSelected:didFavourite];
                                        
                                        //TODO - Implement shared WHAlertView getter
                                        WHAlertView * alertView = (WHAlertView*)view.superview;
                                        [alertView dismiss];
                                        
                                        if (blockSelf.eventId != nil) {
                                            [[Mixpanel sharedInstance] track:@"Favourited Event" properties:@{@"event_id": blockSelf.eventId}];
                                        }
                                        
                                    } else {
                                        NSLog(@"Failed to add to mailing list: %@",error);
                                        [PCDHUD showError:error];
                                    }
                                }];
    }
}

#pragma mark Actions

- (void)_shareBarButtonItemAction:(UIBarButtonItem *)sender
{
    _shareManager = [WHShareManager new];
    [_shareManager presentShareAlertWithObject:self.event];
}

#pragma mark PCGalleryViewControllerDataSource

- (NSUInteger)numberOfPhotosInGallery:(PCGalleryViewController *)gallery
{
    return [self.event.photographs count];
}

- (PCPhoto *)gallery:(PCGalleryViewController *)gallery photoAtIndex:(NSUInteger)index
{
    WHPhotographMO * photograph = [self.event.photographs objectAtIndex:index];
    
    PCPhoto * photo = [PCPhoto new];
    [photo setPhotoURL:[NSURL URLWithString:photograph.imageURL]];
    [photo setThumbURL:[NSURL URLWithString:photograph.imageThumbURL]];
    return photo;
}

#pragma mark

- (void)reload
{
    NSAssert(self.eventId != nil, @"Error - No winery ID provided");

    __weak typeof (self) weakSelf = self;
    [PCDHUD show];
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"event"
                                                            object:@{@"eventId": self.eventId}
                                                        parameters:nil
                                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                               [WHLoadingHUD dismiss];
                                                               [weakSelf setEvent:[mappingResult firstObject]];
                                                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                               [PCDHUD showError:error];
                                                           }];
    //Update event region & wineries relationships.
    if (self.event.regionId != nil && self.event.regions.count <= 0) {
        [[RKObjectManager sharedManager] getObjectsAtPathForRelationship:@"regions"  ofObject:self.event parameters:nil success:nil failure:nil];
    }
    if (self.event.wineryId != nil && self.event.wineries.count <= 0) {
        [[RKObjectManager sharedManager] getObjectsAtPathForRelationship:@"wineries" ofObject:self.event parameters:nil success:nil failure:nil];
    }
}

- (BOOL)isLoadingEvents
{
    NSArray * operations = [[RKObjectManager sharedManager] enqueuedObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/api/events/:eventId/events"];
    return operations.count > 0;
}

#pragma mark

- (void)setEvent:(WHEventMO *)event
{
    _event = event;
    
    _featuredEventSections = nil;
    _orderedEventsArray    = nil;
    
    [self featuredEventSections];
    [self orderedEventsArray];
    
    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHEventMO entityName] identifier:self.eventId];
    [self.tableHeaderView.favouriteButton setSelected:favourite!=nil];
    [self.tableHeaderView.titleLabel setText:self.event.name];
    [self.tableHeaderView reload];

    [self.tableView reloadData];
}

- (WHEventMO *)event
{
    if (_event == nil) {
        _event = [WHEventMO MR_findFirstByAttribute:@"eventId"
                                          withValue:self.eventId
                                          inContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    }
    return _event;
}

#pragma mark WHWinerySectionHeaderViewDelegate

- (void)didSelectTableViewHeaderSection:(WHWinerySectionHeaderView *)headerView
{
    WHSectionInfo * sectionInfo = [self.featuredEventSections objectAtIndex:headerView.section];
    if (self.event.isFeatured) {
        if (sectionInfo.identifier == WHFeaturedEventSectionWhatsOn) {
            if ([self.expandedSections containsIndex:headerView.section] == NO) {
                if ([self isLoadingEvents] == NO) {
                    __weak typeof (self) weakSelf = self;
                    [[RKObjectManager sharedManager]
                     getObjectsAtPathForRelationship:@"events"
                     ofObject:self.event
                     parameters:nil
                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                         
                         WHEventsTableCell * eventCell = (id)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:WHFeaturedEventSectionWhatsOn]];
                         [eventCell.activityIndicator stopAnimating];
                         if ([mappingResult count] > 0) {
                             
                             NSDate * dateToday = [NSDate date];
                             NSArray * sortedEvents = [mappingResult.array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(startDate > %@) OR (finishDate > %@)",dateToday,dateToday]];
                             sortedEvents = [sortedEvents sortedArrayUsingDescriptors:[WHEventMO sortDescriptors]];
                             [weakSelf setOrderedEventsArray:sortedEvents];
                             
                             //Trigger resize of event cell.
                             [weakSelf.tableView beginUpdates];
                             [weakSelf.tableView endUpdates];
                             
                             [eventCell.noEventsLabel setHidden:YES];
                             [eventCell reload];
                         } else {
                             [eventCell.noEventsLabel setText:@"No events."];
                             [eventCell.noEventsLabel setHidden:NO];
                         }
                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                         WHEventsTableCell * eventCell = (id)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:WHFeaturedEventSectionWhatsOn]];
                         [eventCell.noEventsLabel setText:@"Failed to load events."];
                         [eventCell.noEventsLabel setHidden:NO];
                         [eventCell.activityIndicator stopAnimating];
                     }];
                } else {
                    WHEventsTableCell * eventCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:WHFeaturedEventSectionWhatsOn]];
                    [eventCell.activityIndicator startAnimating];
                }
            }
        } else if (sectionInfo.identifier == WHFeaturedEventSectionAbout) {
            _aboutViewMore = NO;
        }
    }
    [super didSelectTableViewHeaderSection:headerView];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.event.isFeatured) {
        return self.featuredEventSections.count;
    } else {
        return WHEventSectionCount;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.event.isFeatured) {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
    return 0.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.event.isFeatured && [self tableView:tableView canCollapseSection:section]) {
        if ([self.expandedSections containsIndex:section]) {
            WHSectionInfo * sectionInfo = [self.featuredEventSections objectAtIndex:section];
            return sectionInfo.rowCount;
        } else {
            return 0;
        }
    } else {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.event.isFeatured) {
        WHSectionInfo * sectionInfo = [self.featuredEventSections objectAtIndex:indexPath.section];
        switch (sectionInfo.identifier) {
            case WHFeaturedEventSectionAbout: {
                return [WHAboutCell cellHeightForEventObject:self.event truncated:!_aboutViewMore];
            }
                break;
            case WHFeaturedEventSectionWhatsOn:
                if (self.orderedEventsArray.count > 0) {
                    return [WHEventsTableCell featuredCellHeight];
                } else {
                    return 50.0;
                }
                break;
            case WHFeaturedEventSectionContact: {
                return [WHContactCell cellHeightForEventObject:self.event];
            }
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case WHEventSectionWhen:
                return [WHEventWhenCell cellHeightForEventObject:self.event];
                break;
            case WHEventSectionInfo:
                return [WHEventInfoCell cellHeightForEventObject:self.event];
                break;
            case WHEventSectionButtons:
                return [WHEventButtonsCell cellHeight];
                break;
        }
    }
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.event.isFeatured) {
        WHSectionInfo * sectionInfo = [self.featuredEventSections objectAtIndex:indexPath.section];
        switch (sectionInfo.identifier) {
            case WHFeaturedEventSectionAbout:
                return [tableView dequeueReusableCellWithIdentifier:[WHAboutCell reuseIdentifier]];
                break;
            case WHFeaturedEventSectionWhatsOn:
                return [tableView dequeueReusableCellWithIdentifier:[WHEventsTableCell reuseIdentifier]];
                break;
            case WHFeaturedEventSectionContact:
                return [tableView dequeueReusableCellWithIdentifier:[WHContactCell reuseIdentifier]];
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case WHEventSectionWhen:
                return [tableView dequeueReusableCellWithIdentifier:[WHEventWhenCell reuseIdentifier]];
                break;
            case WHEventSectionInfo:
                return [tableView dequeueReusableCellWithIdentifier:[WHEventInfoCell reuseIdentifier]];
                break;
            case WHEventSectionButtons:
                return [tableView dequeueReusableCellWithIdentifier:[WHEventButtonsCell reuseIdentifier]];
                break;
        }
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.event.isFeatured) {
        WHSectionInfo * sectionInfo = [self.featuredEventSections objectAtIndex:indexPath.section];
        switch (sectionInfo.identifier) {
            case WHFeaturedEventSectionAbout: {
                WHAboutCell * aboutCell = (WHAboutCell*)cell;
                [aboutCell setDelegate:(id)self];
                [aboutCell setEvent:self.event truncated:!_aboutViewMore];
            }
                break;
            case WHFeaturedEventSectionWhatsOn: {
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
            case WHFeaturedEventSectionContact: {
                WHContactCell * contactCell = (WHContactCell*)cell;
                [contactCell setDelegate:self];
                [contactCell setEvent:self.event];
            }
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case WHEventSectionWhen:
            {
                WHEventWhenCell * whenCell = (id)cell;
                [whenCell setEvent:self.event];
            }
                break;
            case WHEventSectionInfo:
            {
                WHEventInfoCell * infoCell = (id)cell;
                [infoCell setEvent:self.event];
            }
                break;
            case WHEventSectionButtons:
            {
                WHEventButtonsCell * buttonsCell = (id)cell;
                [buttonsCell setDelegate:self];
            }
                break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark
#pragma mark WHEventsTableCellDataSource

- (NSInteger)numberOfEventsInEventsCell:(WHEventsTableCell *)eventsCell
{
    return [self.orderedEventsArray count];
}

- (WHEventMO *)eventsCell:(WHEventsTableCell *)eventsCell eventObjectForIndex:(NSInteger)index
{
    RKManagedObjectStore * store = [[RKObjectManager sharedManager] managedObjectStore];
    WHEventMO * faultedEvent = [self.orderedEventsArray objectAtIndex:index];
    return (WHEventMO *)[store.mainQueueManagedObjectContext objectWithID:faultedEvent.objectID];
}

#pragma mark WHEventsTableCellDelegate

- (void)eventsCell:(WHEventsTableCell *)eventsCell didSelectEventAtIndex:(NSInteger)index
{
    WHEventMO * faultedEvent = [self.orderedEventsArray objectAtIndex:index];
 
    RKManagedObjectStore * store = [[RKObjectManager sharedManager] managedObjectStore];
    WHEventMO * event = (WHEventMO *)[store.mainQueueManagedObjectContext objectWithID:faultedEvent.objectID];
    
    if (event != nil) {
        [[Mixpanel sharedInstance] track:@"View Event from Featured Event"
                              properties:@{@"event_id"           :event.eventId   ?: @"",
                                           @"event_name"         :event.name      ?: @"",
                                           @"featured_event_id"  :self.eventId    ?: @"",
                                           @"featured_event_name":self.event.name ?: @""}];
    }
    
    UIStoryboard * eventStoryboard = [UIStoryboard storyboardWithName:@"Event" bundle:[NSBundle mainBundle]];
    WHEventViewController * eventViewController = [eventStoryboard instantiateInitialViewController];
    [eventViewController setEventId:event.eventId];
    [self.navigationController pushViewController:eventViewController animated:YES];
}


#pragma mark WHEventButtonsCellDelegate

- (void)eventButtonCell:(WHEventButtonsCell *)cell didTapWebsiteButton:(UIButton *)button
{
    NSLog(@"%s", __func__);

    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrlString:self.event.website];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
}


+ (NSDate *)convertDate:(NSDate *)date
{
    NSDateComponents * startDateTimeZoneComponent  = [[NSCalendar currentCalendar] components:(NSCalendarUnitTimeZone) fromDate:date];
    NSTimeZone * timeZone = startDateTimeZoneComponent.timeZone;
    
    NSInteger destinationGMTOffset = [timeZone secondsFromGMTForDate:date];
    NSTimeInterval correctedTimeForCalendarEvent = destinationGMTOffset + (2*(-1*destinationGMTOffset));
    NSDate * newStartDate = [[NSDate alloc] initWithTimeInterval:correctedTimeForCalendarEvent sinceDate:date];
    
    return newStartDate;
}

- (void)eventButtonCell:(WHEventButtonsCell *)cell didTapCalendarButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    WHEventMO * event = self.event;
    
    NSDate * timeZoneStrippedStartDate  = [self.class convertDate:event.startDate];
    NSDate * timeZoneStrippedFinishDate = [self.class convertDate:event.finishDate];

    if (timeZoneStrippedStartDate != nil && timeZoneStrippedStartDate != nil) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:error.localizedDescription
                                               delegate:nil
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil] show];
                } else if (!granted) {
                    [[[UIAlertView alloc] initWithTitle:@"Sorry"
                                                message:NSLocalizedString(@"kCalendarAccessDeniedMessage", nil)
                                               delegate:nil
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil] show];
                } else {
                    NSDateComponents * startDateTimeZoneComponent  = [[NSCalendar currentCalendar] components:(NSCalendarUnitTimeZone) fromDate:event.startDate];
                    NSTimeZone * timeZone = startDateTimeZoneComponent.timeZone;

                    EKEvent * calendarEvent  = [EKEvent eventWithEventStore:eventStore];
                    [calendarEvent setTitle:event.name];
                    [calendarEvent setStartDate:timeZoneStrippedStartDate];
                    [calendarEvent setEndDate:timeZoneStrippedFinishDate];
                    [calendarEvent setTimeZone:timeZone];
                    [calendarEvent setNotes:[[NSAttributedString wh_attributedStringWithHTMLString:event.eventDescription] string]];
                    [calendarEvent setURL:[NSURL URLWithString:event.website]];
                    [calendarEvent setLocation:[NSString stringWithFormat:@"%@ - %@",event.locationName?:@"",event.address?:@""]];
                    
                    EKEventEditViewController * eventViewController = [EKEventEditViewController new];
                    [eventViewController setEventStore:eventStore];
                    [eventViewController setEvent:calendarEvent];
                    [eventViewController setEditViewDelegate:self];
                    
                    [self presentViewController:eventViewController animated:YES completion:nil];
                }
            });
            
        }];
    }
}

#pragma mark
#pragma mark WHAboutCellDelegate

- (void)aboutCell:(WHAboutCell *)cell didTapReadMoreButton:(UIButton *)button
{
    if (self.event.isFeatured) {
        _aboutViewMore = YES;
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:WHFeaturedEventSectionAbout]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark
#pragma mark EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    NSLog(@"%s", __func__);
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
