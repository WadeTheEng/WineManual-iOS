//
//  WHWineClubMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 12/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "RKRelationshipMapping+ReplaceAssignment.h"

#import "WHWineClubMO+Mapping.h"
#import "WHPhotographMO+Mapping.h"

@implementation WHWineClubMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping setIdentificationAttributes:@[[self idKey]]];
    
    [mapping addConnectionForRelationship:@"clubWineries" connectedBy:@"wineryId"];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"photographs"
                                                                            toKeyPath:@"photographs"
                                                                          withMapping:[WHPhotographMO mapping]
                                                                     assignmentPolicy:RKAssignmentPolicySet]];
    
    return mapping;
}

+ (NSString *)idKey
{
    return @"clubIdentifier";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"          :[self idKey],
             @"name"        :@"clubName",
             @"description" :@"clubDescription",
             @"winery_id"   :@"wineryId",
             @"created_at"  :@"created",
             @"updated_at"  :@"updated",
             @"website"     :@"website"};
}

+ (NSString *)entityName
{
    return @"WineClub";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"wine_clubs";
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"clubIdentifier" ascending:YES]];
}

@end
