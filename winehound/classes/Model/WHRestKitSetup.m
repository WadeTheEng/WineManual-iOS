//
//  WHRestKitSetup.m
//  WineHound
//
//  Created by Mark Turner on 13/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/Network/RKPathMatcher.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>

#import "WHRestKitSetup.h"

#import "WHWineryMO+Mapping.h"
#import "WHRegionMO+Mapping.h"
#import "WHWineMO+Mapping.h"
#import "WHEventMO+Mapping.h"
#import "WHOpenTimeMO+Mapping.h"
#import "WHWineClubMO+Mapping.h"
#import "WHRestaurantMO+Mapping.h"
#import "WHPanoramaMO+Mapping.h"
#import "WHStateMO+Mapping.h"

@implementation WHRestKitSetup

+ (void)setupWithObjectManager:(RKObjectManager *)objectManager
{
    RKLogConfigureByName("RestKit", RKlcl_vOff);
    RKLogConfigureByName("RestKit/Network", RKlcl_vInfo);
    RKLogConfigureByName("RestKit/ObjectMapping", RKlcl_vOff);
    RKLogConfigureByName("RestKit/CoreData", RKlcl_vOff);

    [self registerResponseMappings:objectManager];
    [self registerRoutes:objectManager];
    [self registerFetchRequestBlocks:objectManager];
}

#pragma mark
#pragma mark RestKit Setup

+ (void)registerResponseMappings:(RKObjectManager *)objectManager
{
    /*
     [RKMIMETypeSerialization registerClass:[HDAppointmentObject class] forMIMEType:RKMIMETypeJSON];
     */
    
    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHWineMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/wineries/:wineryId/wines"
                                                                                     keyPath:@"wines"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHWineMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/wines/:wineId"
                                                                                     keyPath:@"wine"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHWineryMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/wineries/:wineryId"
                                                                                     keyPath:@"winery"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHRegionMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/regions/:regionId"
                                                                                     keyPath:@"region"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHStateMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/regions.json"
                                                                                     keyPath:@"states"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHStateMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/states"
                                                                                     keyPath:@"states"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHEventMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/events/:eventId"
                                                                                     keyPath:@"event"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHEventMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/events"
                                                                                     keyPath:@"events"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHEventMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/events/:eventId/events"
                                                                                     keyPath:@"events"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHOpenTimeMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/wineries/:wineryId/cellar_door_open_times"
                                                                                     keyPath:@"cellar_door_open_times"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHWineClubMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/wineries/:wineryId/wine_clubs/:clubIdentifier"
                                                                                     keyPath:@"wine_club"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHRestaurantMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/wineries/:wineryId/restaurants"
                                                                                     keyPath:@"restaurants"
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[WHPanoramaMO mapping]
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:@"/api/wineries/:wineryId/panoramas"
                                                                                     keyPath:[WHPanoramaMO keypath]
                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

}

+ (void)registerRoutes:(RKObjectManager *)objectManager
{
    [objectManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"wines"
                                                                   objectClass:[WHWineryMO class]
                                                                   pathPattern:@"/api/wineries/:wineryId/wines"
                                                                        method:RKRequestMethodGET]];

    [objectManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"regions"
                                                                   objectClass:[WHEventMO class]
                                                                   pathPattern:@"/api/regions/:regionId"
                                                                        method:RKRequestMethodGET]];

    [objectManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"wineries"
                                                                   objectClass:[WHEventMO class]
                                                                   pathPattern:@"/api/wineries/:wineryId"
                                                                        method:RKRequestMethodGET]];

    [objectManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"cellarDoorOpenTimes"
                                                                   objectClass:[WHWineryMO class]
                                                                   pathPattern:@"/api/wineries/:wineryId/cellar_door_open_times"
                                                                        method:RKRequestMethodGET]];

    [objectManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"events"
                                                                   objectClass:[WHEventMO class]
                                                                   pathPattern:@"/api/events/:eventId/events"
                                                                        method:RKRequestMethodGET]];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"panoramas"
                                                                   objectClass:[WHWineryMO class]
                                                                   pathPattern:@"/api/wineries/:wineryId/panoramas"
                                                                        method:RKRequestMethodGET]];

    [objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"winery"
                                                       pathPattern:@"/api/wineries/:wineryId"
                                                            method:RKRequestMethodGET]];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"region"
                                                       pathPattern:@"/api/regions/:regionId"
                                                            method:RKRequestMethodGET]];

    [objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"event"
                                                       pathPattern:@"/api/events/:eventId"
                                                            method:RKRequestMethodGET]];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"events"
                                                       pathPattern:@"/api/events"
                                                            method:RKRequestMethodGET]];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"restaurants"
                                                       pathPattern:@"/api/wineries/:wineryId/restaurants"
                                                            method:RKRequestMethodGET]];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[WHWineClubMO class]
                                                        pathPattern:@"/api/wineries/:wineryId/wine_clubs/:clubIdentifier"
                                                             method:RKRequestMethodGET]];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"states"
                                                       pathPattern:@"/api/states"
                                                            method:RKRequestMethodGET]];

}

+ (void)registerFetchRequestBlocks:(RKObjectManager *)objectManager
{
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/wineries/:wineryId/wines"];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
            NSString * wineryId = argsDict[@"wineryId"];
            if (wineryId != nil) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[WHWineMO entityName]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"wineryId == %@",wineryId]];
                [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                return fetchRequest;
            }
        }
        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/wineries/:wineryId/restaurants"];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
            NSString * wineryId = argsDict[@"wineryId"];
            if (wineryId != nil) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[WHRestaurantMO entityName]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"wineryId == %@",wineryId]];
                [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"restaurantId" ascending:YES]]];
                return fetchRequest;
            }
        }
        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/wineries/:wineryId/panoramas"];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
            NSString * wineryId = argsDict[@"wineryId"];
            if (wineryId != nil) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[WHPanoramaMO entityName]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"wineryId == %@",wineryId]];
                [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]]];
                return fetchRequest;
            }
        }
        return nil;
    }];
    
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/events/:eventId/events"];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
            NSString * eventId = argsDict[@"eventId"];
            if (eventId != nil) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[WHEventMO entityName]];
                [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"eventId" ascending:YES]]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentEventId == %i",eventId.integerValue]];
                return fetchRequest;
            }
        }
        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/events"];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativeString] tokenizeQueryStrings:YES parsedArguments:&argsDict]) {
            NSString * regionId = argsDict[@"region"];
            NSString * wineryId = argsDict[@"winery"];
            if (regionId || wineryId) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[WHEventMO entityName]];
                [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"eventId" ascending:YES]]];
                /*
                 Since we can't check if an id exists in a a transformable attribute, we much check object exists in relationship.
                 */
                if (wineryId != nil) {
                    WHWineryMO * winery = [WHWineryMO MR_findFirstByAttribute:@"wineryId" withValue:wineryId];
                    if (winery) {
                        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN wineries",winery]];
                        return fetchRequest;
                    }
                } else if (regionId != nil) {
                    WHRegionMO * region = [WHRegionMO MR_findFirstByAttribute:@"regionId" withValue:regionId];
                    if (region) {
                        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN regions",region]];
                        return fetchRequest;
                    }
                }
            }
        }
        return nil;
    }];
}

@end
