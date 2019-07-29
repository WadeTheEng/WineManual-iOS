//
//  WHWineriesScheduledLocationManager.m
//  WineHound
//
//  Created by Mark Turner on 11/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <RestKit/RestKit.h>
#import <MagicalRecord/NSManagedObject+MagicalRequests.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>

#import "WHWineriesScheduledLocationManager.h"

#import "WHWineryMO+Mapping.h"
#import "WHWineryMO+Additions.h"
#import "WHRegionMO+Additions.h"

NSString * const kWHUserDefaultsPushEnabled           = @"wineries_push_enabled";

NSString * const kWHNotificationAlertActionKey        = @"action";
NSString * const kWHNotificationAlertActionOpenWinery = @"open_winery";
NSString * const kWHNotificationWineryIDKey           = @"winery_id";

#define radToDeg(radians) ((radians) * (180.0 / M_PI))
#define degToRad(angle) ((angle) / 180.0 * M_PI)
#define kEarthRadius 6371.0

@interface WHWineriesScheduledLocationManager () <CLLocationManagerDelegate>
{
    UIBackgroundTaskIdentifier _backgroundTask;
}
@property (nonatomic) CLLocationManager * locationManager;
@end

@implementation WHWineriesScheduledLocationManager

#pragma mark

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        CLLocationManager * locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [locationManager setPausesLocationUpdatesAutomatically:NO];
        /*
        locationManager.activityType = CLActivityTypeAutomotiveNavigation;
         */
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void)startUpdates
{
    NSLog(@"%s", __func__);

    BOOL pushEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kWHUserDefaultsPushEnabled];
    
    if ([self.class locationServiceAvailable]  && pushEnabled) {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [self.locationManager setDelegate:self];
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void)scheduleLocalNotificationForWinery:(WHWineryMO *)winery
{
    [winery setLastPushDate:[NSDate date]];
    [winery.managedObjectContext saveToPersistentStore:nil];
    
    CLLocationDistance distance = [self.locationManager.location distanceFromLocation:winery.location];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    [localNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
    [localNotification setAlertAction:@"View Winery"];
    [localNotification setSoundName:UILocalNotificationDefaultSoundName];

    if (winery.notificationMessage.length > 0) {
        [localNotification setAlertBody:winery.notificationMessage];
    } else {
        [localNotification setAlertBody:[NSString stringWithFormat:@"You are %.2f km from: %@",(distance/1000.0),winery.name]];
    }
    if (winery.wineryId != nil) {
        [localNotification setUserInfo:@{kWHNotificationAlertActionKey:kWHNotificationAlertActionOpenWinery,
                                         kWHNotificationWineryIDKey:winery.wineryId}];
    }
    
    NSLog(@"Send location notification for Winery: %@",winery.name);
    /*
     [localNotification setApplicationIconBadgeNumber:0];
     */
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    if (winery.wineryId != nil) {
        [[Mixpanel sharedInstance] track:@"Push notification"  properties:@{@"winery_id":winery.wineryId}];
    }
}

/*
- (void)updateLocationManagerRegionMonitoring
{
 
    Only fetch Wineries within a 200km radius?
 
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(wineries, $winery, $winery.tier == %i).@count > 0",WHWineryTierGoldPlus];
    NSArray * regions = [WHRegionMO MR_findAllWithPredicate:predicate];
    for (WHRegionMO * region in regions) {
        CGFloat maxRadius = 0;
        NSArray * wineries = [WHWineryMO MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"ANY regions.regionId == %@ AND tier == %i",region.regionId,WHWineryTierGoldPlus]];

        //figure out the distance from the gold wineries to the region center.
        for (WHWineryMO * winery in wineries) {
            CGFloat wineryDistanceFromRegionCenter = [winery.location distanceFromLocation:region.location];
            if (wineryDistanceFromRegionCenter > maxRadius) {
                maxRadius = wineryDistanceFromRegionCenter;
            }
        }
        
        maxRadius = ceilf(maxRadius) + 100.0;
        if (region.regionId != nil && maxRadius > 0) {
            CLLocationCoordinate2D centreLoc = {region.latitude.doubleValue,region.longitude.doubleValue};
            CLCircularRegion * circularRegion = [[CLCircularRegion alloc] initWithCenter:centreLoc radius:maxRadius identifier:region.regionId.stringValue];
            [self.locationManager startMonitoringForRegion:circularRegion];
        }
    }
}
 */

#pragma mark
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%s", __func__);
    
    UIApplication * sharedApplication = [UIApplication sharedApplication];
    if ([sharedApplication applicationState] == UIApplicationStateBackground)
    {
        if (_backgroundTask == UIBackgroundTaskInvalid) {
            [sharedApplication endBackgroundTask:_backgroundTask];
            _backgroundTask = UIBackgroundTaskInvalid;
        }
        
        _backgroundTask = [sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
            _backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        CLLocation * location = [locations lastObject];
        if (location != nil) {
            
            //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            double filterDistance = 20; // max radius km
            double angularFilterDistance = radToDeg(filterDistance / kEarthRadius);
            
            double maxLat = location.coordinate.latitude + angularFilterDistance;
            double minLat = location.coordinate.latitude - angularFilterDistance;
            
            // Compensate for degrees of longitude getting smaller with increasing latitude
            double maxLon = location.coordinate.longitude + radToDeg(filterDistance / kEarthRadius / cos(degToRad(location.coordinate.latitude)));
            double minLon = location.coordinate.longitude - radToDeg(filterDistance / kEarthRadius / cos(degToRad(location.coordinate.latitude)));
            
            // NB: This does NOT deal with the 180th meridian, which cuts through Fiji and parts of Russia.
            // The approach to fix that would be to detect it (maxLat < minLat I think) and split the bounding box into two.
            
            NSPredicate * distancePredicate   = [NSPredicate predicateWithFormat:@"latitude > %f AND latitude < %f AND longitude > %f AND longitude < %f",minLat, maxLat, minLon, maxLon];
            //Support for old Winery objects.
            NSPredicate * allowPushPredicate  = [NSPredicate predicateWithFormat:@"allowPushNotifications == %@ OR allowPushNotifications == nil",@(YES)];
            
            NSPredicate * predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[distancePredicate, allowPushPredicate]];
            NSManagedObjectContext * context = [[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext];

            if (context != nil) {
                NSFetchRequest * fetchRequest = [WHWineryMO MR_requestAllWithPredicate:predicate inContext:context];
                [fetchRequest setIncludesSubentities:NO];
                
                NSError * fetchError = nil;
                NSArray * wineries = [context executeFetchRequest:fetchRequest error:&fetchError];
                
                if (fetchError == nil && wineries.count > 0) {
                    __block WHWineryMO * notificationWinery = nil;

                    [wineries enumerateObjectsUsingBlock:^(WHWineryMO * winery, NSUInteger idx, BOOL *stop) {
                        CLLocationDistance distanceFromUser = [winery.location distanceFromLocation:location];
                        if (winery.notificationRadius != nil && winery.allowPushNotifications.boolValue) {
                            if (distanceFromUser <= winery.notificationRadius.doubleValue) {
                                notificationWinery = winery;
                                *stop = YES;
                            }
                        } else {
                            //Support for old Wineries
                            if (distanceFromUser < 15.0 && winery.tierValue == WHWineryTierGoldPlus) {
                                notificationWinery = winery;
                                *stop = YES;
                            }
                        }
                    }];
                    
                    if (notificationWinery != nil) {
                        NSTimeInterval timeSinceLastAlert = [[NSDate date] timeIntervalSinceDate:notificationWinery.lastPushDate];
                        if (notificationWinery.lastPushDate == nil || timeSinceLastAlert > (24*60*60)) {
                            [self scheduleLocalNotificationForWinery:notificationWinery];
                        }
                    }
                }
            }
        }
        
        [sharedApplication endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s", __func__);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"%s", __func__);
}

#pragma mark
#pragma mark Helpers

+ (BOOL)locationServiceAvailable
{
    if ([CLLocationManager locationServicesEnabled] == NO ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        return NO;
    } else {
        return YES;
    }
}

@end
