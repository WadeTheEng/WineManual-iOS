//
//  WHWineMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 05/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>
#import "RKRelationshipMapping+ReplaceAssignment.h"

#import "WHWineMO+Mapping.h"
#import "WHPhotographMO+Mapping.h"
#import "WHWineVarietyMO+Mapping.h"

@implementation WHWineMO (Mapping)

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
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"varieties"
                                                                            toKeyPath:@"varieties"
                                                                          withMapping:[WHWineVarietyMO mapping]
                                                                     assignmentPolicy:RKAssignmentPolicySet]];
    
    [mapping addConnectionForRelationship:@"wineries" connectedBy:@"wineryId"];
    
    return mapping;
}

+ (NSString *)idKey
{
    return @"wineId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"             :[self idKey],
             @"description"    :@"wineDescription",
             @"display_variety":@"displayVariety",
             @"wine_range_id"  :@"wineRangeId",
             @"winery_id"      :@"wineryId",
             @"alcohol_content":@"alcoholContent",
             @"date_bottled"   :@"dateBottled",
             @"tasting_notes_pdf.tasting_notes_pdf.url":@"pdfUrl",
             @"updated_at"     :@"updatedAt",
             @"wine_type.name" :@"wineTypeName",//just store name for now.
             @"default_sort_position"   :@"winerySortPosition",
             @"wine_range_sort_position":@"wineRangeSortPosition"
             };
}

+ (NSArray *)mappingArray
{
    return @[@"name",
             @"vintage",
             @"cost",
             @"colour",
             @"aroma",
             @"palate",
             @"vineyard",
             @"winemakers",
             @"ph",
             @"closure",
             @"website"];
}

+ (NSString *)entityName
{
    return @"Wine";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"wines";
}

- (NSString *)primaryKey
{
    return [self valueForKey:[self.class idKey]];
}

+ (NSArray *)sortDescriptors
{
    return @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

@end
