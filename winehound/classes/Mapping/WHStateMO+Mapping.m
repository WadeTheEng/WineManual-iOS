//
//  WHStateMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 27/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHStateMO+Mapping.h"

@implementation WHStateMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];

    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];

    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping setIdentificationAttributes:@[[self idKey]]];
    return mapping;
}

+ (NSString *)idKey
{
    return @"primaryKey";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"         : [self idKey],
             @"country_id" : @"countryId",
             @"name"       : @"name"};
}

+ (NSString *)entityName
{
    return @"State";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"states";
}

@end
