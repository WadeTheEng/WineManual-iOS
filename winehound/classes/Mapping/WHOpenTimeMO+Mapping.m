//
//  WHOpenTimeMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 15/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHOpenTimeMO+Mapping.h"

@implementation WHOpenTimeMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    /*
     Backend open times identifiers are not global.
    [mapping setIdentificationAttributes:@[[self idKey]]];
     */

    return mapping;
}

+ (NSString *)idKey
{
    return @"identifier";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"        :[self idKey],
             @"day"       :@"day",
             @"date"      :@"date",
             @"open_time" :@"openTime",
             @"close_time":@"closeTime"};
}

+ (NSString *)entityName
{
    return @"OpenTime";
}

+ (NSString *)keypath
{
    return @"";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSManagedObject *)insertInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"openTime"  ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"closeTime" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"day"       ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"date"      ascending:YES]];
}


@end
