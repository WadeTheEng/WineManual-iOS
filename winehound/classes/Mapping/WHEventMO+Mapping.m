//
//  WHEventMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 05/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>
#import <ISO8601DateFormatterValueTransformer/ISO8601DateFormatterValueTransformer.h>

#import "RKRelationshipMapping+ReplaceAssignment.h"

#import "WHEventMO+Mapping.h"
#import "WHPhotographMO+Mapping.h"

@implementation WHEventMO (Mapping)

+ (RKEntityMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [mapping addAttributeMappingsFromArray:[self mappingArray]];
    [mapping setIdentificationAttributes:@[[self idKey]]];
    [mapping setModificationAttributeForName:@"updatedDate"];
    
    RKAttributeMapping * updatedAt = [RKAttributeMapping attributeMappingFromKeyPath:@"updated_at" toKeyPath:@"updatedDate"];
    [updatedAt setValueTransformer:[RKISO8601DateFormatter defaultISO8601DateFormatter]];
    [mapping addPropertyMapping:updatedAt];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"photographs"
                                                                            toKeyPath:@"photographs"
                                                                          withMapping:[WHPhotographMO mapping]
                                                                     assignmentPolicy:RKAssignmentPolicySet]];

    RKAttributeMapping * regionsMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"regions" toKeyPath:@"regionIds"];
    [regionsMapping setPropertyValueClass:[NSArray class]];
    [mapping addPropertyMapping:regionsMapping];
    
    RKAttributeMapping * wineriesMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"wineries" toKeyPath:@"wineryIds"];
    [wineriesMapping setPropertyValueClass:[NSArray class]];
    [mapping addPropertyMapping:wineriesMapping];

    RKAttributeMapping * eventsMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"event_ids" toKeyPath:@"eventIds"];
    [eventsMapping setPropertyValueClass:[NSArray class]];
    [mapping addPropertyMapping:eventsMapping];
    
    //State value transformer
    RKAttributeMapping * statePropertyMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"state_ids" toKeyPath:@"stateIds"];
    [statePropertyMapping setPropertyValueClass:[NSString class]];
    [statePropertyMapping setValueTransformer:[RKBlockValueTransformer valueTransformerWithValidationBlock:^BOOL(__unsafe_unretained Class inputValueClass, __unsafe_unretained Class outputValueClass) {
        return ([inputValueClass isSubclassOfClass:[NSArray class]] && [outputValueClass isSubclassOfClass:[NSString class]]);
    } transformationBlock:^BOOL(id inputValue, __autoreleasing id *outputValue, __unsafe_unretained Class outputClass, NSError *__autoreleasing *error) {
        if ([inputValue isKindOfClass:[NSArray class]] && [inputValue count] > 0) {
            *outputValue = [inputValue componentsJoinedByString:@","];
        }
        return YES; //return yes to avoid any other transformation occuring.
    }]];
    [mapping addPropertyMapping:statePropertyMapping];
    
    //
    
    [mapping addConnectionForRelationship:@"featuredEvent" connectedBy:@{@"parentEventId":@"eventId"}];
    [mapping addConnectionForRelationship:@"wineries"      connectedBy:@{@"wineryIds":@"wineryId"}];
    [mapping addConnectionForRelationship:@"regions"       connectedBy:@{@"regionIds":@"regionId"}];
//
    //Only connect Event to Featured Event if parentEventId is not nil
    RKConnectionDescription * featuredEventConnection = [mapping connectionForRelationship:@"featuredEvent"];
    [featuredEventConnection setSourcePredicate:[NSPredicate predicateWithFormat:@"parentEventId != nil"]];

    //Only connect Event to Winery/Region if parentEventId is nil.
    RKConnectionDescription * wineriesConnection = [mapping connectionForRelationship:@"wineries"];
    [wineriesConnection setSourcePredicate:[NSPredicate predicateWithFormat:@"parentEventId == nil"]];
    
    RKConnectionDescription * regionsConnection = [mapping connectionForRelationship:@"regions"];
    [regionsConnection setSourcePredicate:[NSPredicate predicateWithFormat:@"parentEventId == nil"]];
    
    return mapping;
}

+ (NSString *)idKey
{
    return @"eventId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"                   :[self idKey],
             @"description"          :@"eventDescription",
             @"phone_number"         :@"phoneNumber",
             @"start_date"           :@"startDate",
             @"finish_date"          :@"finishDate",
             @"is_featured"          :@"featured",
             @"price_and_description":@"priceDescription",
             @"location_name"        :@"locationName",
             @"trade_event"          :@"tradeEvent",
             @"parent_event_id"      :@"parentEventId",
             @"address"              :@"address",
             @"region_id"            :@"regionId",
             @"winery_id"            :@"wineryId",
             @"event_length"         :@"eventLength"
             };
}

+ (NSArray *)mappingArray
{
    return @[@"name",
             @"visible",
             @"website",
             @"latitude",
             @"longitude"];
}

+ (NSString *)entityName
{
    return @"Event";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"events";
}

- (NSString *)primaryKey
{
    return [self valueForKey:[self.class idKey]];
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
}

@end
