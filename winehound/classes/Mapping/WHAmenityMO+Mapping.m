//
//  WHAmenityMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 12/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>

#import "WHAmenityMO+Mapping.h"

@implementation WHAmenityMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];

    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping addAttributeMappingsFromArray:[self mappingArray]];

    /*
    [mapping setIdentificationAttributes:@[[self idKey]]];
     */
    
    return mapping;
}

+ (NSString *)idKey
{
    return @"amenityId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"             :[self idKey],
             @"icon_identifier":@"iconIdentifier"};
}

+ (NSArray *)mappingArray
{
    return @[@"name"];
}

+ (NSString *)entityName
{
    return @"Amenity";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"amenities";
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

@end
