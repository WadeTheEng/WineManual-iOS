//
//  WHWineRangeMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 06/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>

#import "WHWineRangeMO+Mapping.h"

@implementation WHWineRangeMO (Mapping)

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
    return @"rangeId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"         :[self idKey],
             @"name"       :@"name",
             @"description":@"rangeDescription"};
}

+ (NSString *)entityName
{
    return @"WineRange";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"wine_ranges";
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:[self idKey] ascending:YES]];
}

@end