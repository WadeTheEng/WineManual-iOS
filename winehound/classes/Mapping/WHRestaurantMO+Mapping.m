//
//  WHRestaurantMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 19/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "RKRelationshipMapping+ReplaceAssignment.h"

#import "WHRestaurantMO+Mapping.h"
#import "WHOpenTimeMO+Mapping.h"
#import "WHPhotographMO+Mapping.h"

@implementation WHRestaurantMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping setIdentificationAttributes:@[[self idKey]]];
    
    [mapping addConnectionForRelationship:@"winery" connectedBy:@"wineryId"];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"restaurant_open_times"
                                                                            toKeyPath:@"openTimes"
                                                                          withMapping:[WHOpenTimeMO mapping]
                                                                     assignmentPolicy:RKAssignmentPolicyReplace]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"photographs"
                                                                            toKeyPath:@"photographs"
                                                                          withMapping:[WHPhotographMO mapping]
                                                                     assignmentPolicy:RKAssignmentPolicySet]];
    
    return mapping;
}

+ (NSString *)idKey
{
    return @"restaurantId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"                   :[self idKey],
             @"name"                 :@"restaurantName",
             @"description"          :@"restaurantDescription",
             @"menu_pdf.menu_pdf.url":@"menuPdf",
             @"winery_id"            :@"wineryId"
             };
}

+ (NSString *)entityName
{
    return @"Restaurant";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"restaurants";
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

@end