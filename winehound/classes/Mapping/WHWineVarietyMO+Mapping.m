//
//  WHWineVarietyMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 20/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHWineVarietyMO+Mapping.h"

@implementation WHWineVarietyMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping setIdentificationAttributes:@[[self idKey]]];
    [mapping setModificationAttributeForName:@"updatedAt"];
    return mapping;
}

+ (NSString *)idKey
{
    return @"varietyId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"        :[self idKey],
             @"name"      :@"name",
             @"created_at":@"createdAt",
             @"updated_at":@"updatedAt"
             };
}

+ (NSString *)entityName
{
    return @"WineVariety";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"all_varieties";
}

@end
