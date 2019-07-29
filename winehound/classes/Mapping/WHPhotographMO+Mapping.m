//
//  WHPhotographMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 12/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>

#import "WHPhotographMO+Mapping.h"

@implementation WHPhotographMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping setModificationAttributeForName:@"updatedAt"];
    [mapping setIdentificationAttributes:@[[self idKey],@"subjectId",@"subjectType"]];
 
    return mapping;
}

+ (NSString *)idKey
{
    return @"photographId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"             :[self idKey],
             @"created_at"     :@"createdAt",
             @"updated_at"     :@"updatedAt",
             @"image.url"      :@"imageURL",
             @"image.thumb.url":@"imageThumbURL",
             @"image.wine_thumb.url":@"imageWineThumbURL",
             @"subject_id"     :@"subjectId",
             @"subject_type"   :@"subjectType",
             @"position"       :@"position",

             //redundant
             @"winery_id"      :@"wineryId",
             @"region_id"      :@"regionId",
             @"wine_id"        :@"wineId",
             @"event_id"       :@"eventId",
             };
}

+ (NSString *)entityName
{
    return @"Photograph";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"photographs";
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

@end
