//
//  WHWineryMO+Mapping.m
//  WineHound
//
//  Created by Mark Turner on 04/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <RestKit/CoreData.h>
#import <RestKit/CoreData/RKEntityMapping.h>

#import "RKRelationshipMapping+ReplaceAssignment.h"

#import "WHWineryMO+Mapping.h"
#import "WHRegionMO+Mapping.h"
#import "WHAmenityMO+Mapping.h"
#import "WHPhotographMO+Mapping.h"
#import "WHWineRangeMO+Mapping.h"
#import "WHWineMO+Mapping.h"
#import "WHWineClubMO+Mapping.h"

NSString * const WHWineryTierString[] = {
    [WHWineryTierGoldPlus] = @"Gold+",
    [WHWineryTierGold]     = @"Gold",
    [WHWineryTierSilver]   = @"Silver",
    [WHWineryTierBronze]   = @"Bronze",
    [WHWineryTierBasic]    = @"Basic",
};

@implementation WHWineryMO (Mapping)
@dynamic tierValue;

+ (RKMapping *)mapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping * wineryMapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:managedObjectStore];
    [wineryMapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [wineryMapping addAttributeMappingsFromArray:[self mappingArray]];
    [wineryMapping setIdentificationAttributes:@[[self idKey]]];
    [wineryMapping setModificationAttributeForName:@"updatedAt"];

    //State value transformer

    RKAttributeMapping * statePropertyMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"state_ids" toKeyPath:@"stateIds"];
    [statePropertyMapping setPropertyValueClass:[NSString class]];
    [statePropertyMapping setValueTransformer:[RKBlockValueTransformer valueTransformerWithValidationBlock:^BOOL(__unsafe_unretained Class inputValueClass, __unsafe_unretained Class outputValueClass) {
        return ([inputValueClass isSubclassOfClass:[NSArray class]] && [outputValueClass isSubclassOfClass:[NSString class]]);
    } transformationBlock:^BOOL(id inputValue, __autoreleasing id *outputValue, __unsafe_unretained Class outputClass, NSError *__autoreleasing *error) {
        if ([inputValue isKindOfClass:[NSArray class]]) {
            *outputValue = [inputValue componentsJoinedByString:@","];
        }
        return YES;
    }]];

    [wineryMapping addPropertyMapping:statePropertyMapping];
    
    //Relationships
    [wineryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"amenities"
                                                                                  toKeyPath:@"amenities"
                                                                                withMapping:[WHAmenityMO mapping]
                                                                           assignmentPolicy:RKAssignmentPolicySet]];
    [wineryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"photographs"
                                                                                  toKeyPath:@"photographs"
                                                                                withMapping:[WHPhotographMO mapping]
                                                                           assignmentPolicy:RKAssignmentPolicySet]];

    RKEntityMapping * cellarDoorPhotographMapping = (RKEntityMapping *)[WHPhotographMO mapping];
    [cellarDoorPhotographMapping setIdentificationAttributes:@[[self idKey]]];
    [cellarDoorPhotographMapping setIdentificationPredicate:[NSPredicate predicateWithFormat:@"subjectId == nil"]];
    [wineryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cellar_door_photographs"
                                                                                  toKeyPath:@"cellarDoorPhotographs"
                                                                                withMapping:cellarDoorPhotographMapping
                                                                           assignmentPolicy:RKAssignmentPolicySet]];
    
    [wineryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wine_ranges"
                                                                                  toKeyPath:@"ranges"
                                                                                withMapping:[WHWineRangeMO mapping]
                                                                           assignmentPolicy:RKAssignmentPolicySet]];
    [wineryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wines"
                                                                                  toKeyPath:@"wines"
                                                                                withMapping:[WHWineMO mapping]
                                                                           assignmentPolicy:RKAssignmentPolicySet]];
    [wineryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wine_clubs"
                                                                                  toKeyPath:@"wineClubs"
                                                                                withMapping:[WHWineClubMO mapping]
                                                                           assignmentPolicy:RKAssignmentPolicySet]];
    
    [wineryMapping addConnectionForRelationship:@"regions" connectedBy:@{@"regionIds":@"regionId"}];
    
    //Brewery & Cidery Dynamic mapping.
    RKEntityMapping * cideryMapping  = [RKEntityMapping mappingForEntityForName:@"Cidery" inManagedObjectStore:managedObjectStore];
    [cideryMapping setIdentificationAttributes:@[[self idKey]]];
    [cideryMapping setModificationAttributeForName:@"updatedAt"];
    [cideryMapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [cideryMapping addAttributeMappingsFromArray:[self mappingArray]];
    [cideryMapping addConnectionForRelationship:@"regions" connectedBy:@{@"regionIds":@"regionId"}];

    RKEntityMapping * breweryMapping = [RKEntityMapping mappingForEntityForName:@"Brewery" inManagedObjectStore:managedObjectStore];
    [breweryMapping setIdentificationAttributes:@[[self idKey]]];
    [breweryMapping setModificationAttributeForName:@"updatedAt"];
    [breweryMapping addAttributeMappingsFromDictionary:[self mappingDictionary]];
    [breweryMapping addAttributeMappingsFromArray:[self mappingArray]];
    [breweryMapping addConnectionForRelationship:@"regions" connectedBy:@{@"regionIds":@"regionId"}];
    
    RKDynamicMapping * dynamicMapping = [RKDynamicMapping new];
    [dynamicMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type"
                                                            expectedValue:@(WHWineryTypeWinery)
                                                            objectMapping:wineryMapping]];
    [dynamicMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type"
                                                            expectedValue:@(WHWineryTypeCidery)
                                                            objectMapping:cideryMapping]];
    [dynamicMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type"
                                                            expectedValue:@(WHWineryTypeBrewery)
                                                            objectMapping:breweryMapping]];
    //Return Wineries if no 'type' attribute exists.
    [dynamicMapping setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation) {
        id value = [representation valueForKeyPath:@"type"];
        if (value == nil || [value isEqual:[NSNull null]]) {
            return wineryMapping;
        }
        return nil;
    }];
    
    return dynamicMapping;
}

+ (NSString *)idKey
{
    return @"wineryId";
}

+ (NSDictionary *)mappingDictionary
{
    return @{@"id"                     :[self idKey],
             @"id"                     :@"identifier", //this line is actually redundant. for backwards compatability we are keeping winery_id mapping.
             @"cellar_door_description":@"cellarDoorDescription",
             @"phone_number"           :@"phoneNumber",
             @"region_ids"             :@"regionIds",
             @"any_restaurants"        :@"hasRestaurants",
             @"any_wine_clubs"         :@"hasWineClubs",
             @"any_panoramas"          :@"hasPanoramas",
             @"logo.logo.thumb.url"    :@"logoURL",
             @"zoom_level"             :@"zoomLevel",
             @"country_id"             :@"countryId",
             @"updated_at"             :@"updatedAt"
             };
}

+ (NSArray *)mappingArray
{
    return @[@"name",
             @"longitude",
             @"latitude",
             @"tier",
             @"about",
             @"address",
             @"timezone",
             @"website",
             @"facebook",
             @"twitter",
             @"instagram",
             @"visible",
             @"email",
             @"type"
             ];
}

+ (NSString *)entityName
{
    return @"Winery";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSString *)keypath
{
    return @"wineries";
}

+ (NSArray *)sortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

- (NSString *)primaryKey
{
    return [self valueForKey:[self.class idKey]];
}

#pragma mark

- (WHWineryTier)tierValue
{
    return (WHWineryTier)[self.tier integerValue];
}

@end
