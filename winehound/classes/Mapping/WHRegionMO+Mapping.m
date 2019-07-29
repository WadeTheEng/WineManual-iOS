//
//  WHRegionMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 04/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>
#import "RKRelationshipMapping+ReplaceAssignment.h"

#import "WHRegionMO+Mapping.h"
#import "WHPhotographMO+Mapping.h"

@implementation WHRegionMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping addAttributeMappingsFromArray:[self mappingArray]];
    [mapping setIdentificationAttributes:@[[self idKey]]];
    [mapping setModificationAttributeForName:@"updatedAt"];

    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"photographs"
                                                                            toKeyPath:@"photographs"
                                                                          withMapping:[WHPhotographMO mapping]
                                                                     assignmentPolicy:RKAssignmentPolicySet]];
    
    /*
     Not possible since we can't use a predicate to find an id in transformable array.
     
    [mapping addConnectionForRelationship:@"wineries" connectedBy:@{@"regionId":@"regionIds"}];
    [mapping addConnectionForRelationship:@"events"   connectedBy:@{@"regionId":@"regionIds"}];
     */
    return mapping;
}

+ (NSString *)idKey
{
    return @"regionId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"           :[self idKey],
             @"state_id"     :@"stateId",
             @"phone_number" :@"phoneNumber",
             @"website_url"  :@"websiteUrl",
             @"zone"         :@"regionZone",
             @"map_pdf"      :@"pdfURL",
             @"zoom_level"   :@"zoomLevel",
             @"has_wineries" :@"hasWineries",
             @"has_breweries":@"hasBreweries",
             @"has_cideries" :@"hasCideries",
             @"country_id"   :@"countryId",
             @"updated_at"   :@"updatedAt"};
}

+ (NSArray *)mappingArray
{
    return @[@"name",
             @"longitude",
             @"latitude",
             @"about",
             @"email",
             @"facebook",
             @"twitter",
             @"instagram"];
}

+ (NSString *)entityName
{
    return @"Region";
}

+ (NSString *)keypath
{
    return @"regions";
}

- (NSString *)primaryKey
{
    return [self valueForKey:[self.class idKey]];
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

@end