//
//  WHFavouriteMO+Additions.m
//  WineHound
//
//  Created by Mark Turner on 10/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHFavouriteMO+Additions.h"

#import <MagicalRecord/NSManagedObject+MagicalRecord.h>
#import <MagicalRecord/NSManagedObject+MagicalRequests.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>

@implementation WHFavouriteMO (Additions)

+ (NSString *)entityName
{
    return @"Favourite";
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (NSManagedObject *)insertInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:ctx];
}

+ (BOOL)favouriteEntityName:(NSString *)entityName identifier:(NSNumber *)identifier
{
    NSManagedObjectContext * mainContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    WHFavouriteMO * existingFavourite = [self favouriteWithEntityName:entityName identifier:identifier];
    if (existingFavourite != nil) {
        [mainContext deleteObject:existingFavourite];
    } else {
        WHFavouriteMO * favouriteMo = [WHFavouriteMO MR_createInContext:mainContext];
        [favouriteMo setFavouriteEntityName:entityName];
        [favouriteMo setFavouriteId:identifier];
    }
    
    NSError * saveError = nil;
    if ([mainContext saveToPersistentStore:&saveError]) {
        return existingFavourite==nil;
    } else {
        NSLog(@"Error saving context: %@",saveError);
    }
    return NO;
}

+ (WHFavouriteMO *)favouriteWithEntityName:(NSString *)entityName identifier:(NSNumber *)identifier context:(NSManagedObjectContext*)ctx
{
    NSPredicate * favouritePredicate = [NSPredicate predicateWithFormat:@"(favouriteEntityName == %@) && (favouriteId == %@)",entityName,identifier];
    return [WHFavouriteMO MR_findFirstWithPredicate:favouritePredicate inContext:ctx];
}

+ (WHFavouriteMO *)favouriteWithEntityName:(NSString *)entityName identifier:(NSNumber *)identifier
{
    NSManagedObjectContext * mainContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    return [self favouriteWithEntityName:entityName identifier:identifier context:mainContext];
}

@end
