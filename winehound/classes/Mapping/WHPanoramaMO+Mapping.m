//
//  WHPanoramaMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 28/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>
#import "RKRelationshipMapping+ReplaceAssignment.h"

#import "WHPanoramaMO+Mapping.h"
#import "WHPhotographMO+Mapping.h"

@implementation WHPanoramaMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    RKEntityMapping * photographMapping = [RKEntityMapping mappingForEntityForName:[WHPhotographMO entityName] inManagedObjectStore:managedObjectStore];
    [photographMapping addAttributeMappingsFromDictionary:@{@"image.url" :@"imageURL",@"image.thumb.url":@"imageThumbURL"}];
    /* either we scrap Panoramas using Photograph entity object, or we have panoramas photograph objects to pass id's.*/
    [photographMapping setIdentificationAttributes:@[@"imageURL"]];
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping setIdentificationAttributes:@[[self idKey]]];
    [mapping addConnectionForRelationship:@"winery" connectedBy:@"wineryId"];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image"
                                                                            toKeyPath:@"photograph"
                                                                          withMapping:photographMapping
                                                                     assignmentPolicy:RKAssignmentPolicySet]];
    return mapping;
}

+ (NSString *)idKey
{
    return @"identifier";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"       :[self idKey],
             @"winery_id":@"wineryId"};
}

+ (NSString *)entityName
{
    return @"Panorama";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"panoramas";
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:[self idKey] ascending:YES]];
}

@end