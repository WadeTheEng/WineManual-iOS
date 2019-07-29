//
//  WHWineryMO.h
//  WineHound
//
//  Created by Mark Turner on 30/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHAmenityMO, WHEventMO, WHOpenTimeMO, WHPanoramaMO, WHPhotographMO, WHRegionMO, WHRestaurantMO, WHWineClubMO, WHWineMO, WHWineRangeMO;

@interface WHWineryMO : NSManagedObject

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * allowPushNotifications;
@property (nonatomic, retain) NSString * cellarDoorDescription;
@property (nonatomic, retain) NSNumber * countryId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSNumber * hasPanoramas;
@property (nonatomic, retain) NSNumber * hasRestaurants;
@property (nonatomic, retain) NSNumber * hasWineClubs;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * instagram;
@property (nonatomic, retain) NSDate * lastPushDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * logoURL;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * notificationRadius;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * presence;
@property (nonatomic, retain) id regionIds;
@property (nonatomic, retain) NSString * stateIds;
@property (nonatomic, retain) NSNumber * tier;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSNumber * wineryId;
@property (nonatomic, retain) NSNumber * zoomLevel;
@property (nonatomic, retain) NSString * notificationMessage;
@property (nonatomic, retain) NSOrderedSet *amenities;
@property (nonatomic, retain) NSSet *cellarDoorOpenTimes;
@property (nonatomic, retain) NSOrderedSet *cellarDoorPanoramas;
@property (nonatomic, retain) NSOrderedSet *cellarDoorPhotographs;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSOrderedSet *photographs;
@property (nonatomic, retain) NSSet *ranges;
@property (nonatomic, retain) NSSet *regions;
@property (nonatomic, retain) NSSet *restaurants;
@property (nonatomic, retain) NSOrderedSet *wineClubs;
@property (nonatomic, retain) NSOrderedSet *wines;
@end

@interface WHWineryMO (CoreDataGeneratedAccessors)

- (void)insertObject:(WHAmenityMO *)value inAmenitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAmenitiesAtIndex:(NSUInteger)idx;
- (void)insertAmenities:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAmenitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAmenitiesAtIndex:(NSUInteger)idx withObject:(WHAmenityMO *)value;
- (void)replaceAmenitiesAtIndexes:(NSIndexSet *)indexes withAmenities:(NSArray *)values;
- (void)addAmenitiesObject:(WHAmenityMO *)value;
- (void)removeAmenitiesObject:(WHAmenityMO *)value;
- (void)addAmenities:(NSOrderedSet *)values;
- (void)removeAmenities:(NSOrderedSet *)values;
- (void)addCellarDoorOpenTimesObject:(WHOpenTimeMO *)value;
- (void)removeCellarDoorOpenTimesObject:(WHOpenTimeMO *)value;
- (void)addCellarDoorOpenTimes:(NSSet *)values;
- (void)removeCellarDoorOpenTimes:(NSSet *)values;

- (void)insertObject:(WHPanoramaMO *)value inCellarDoorPanoramasAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCellarDoorPanoramasAtIndex:(NSUInteger)idx;
- (void)insertCellarDoorPanoramas:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCellarDoorPanoramasAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCellarDoorPanoramasAtIndex:(NSUInteger)idx withObject:(WHPanoramaMO *)value;
- (void)replaceCellarDoorPanoramasAtIndexes:(NSIndexSet *)indexes withCellarDoorPanoramas:(NSArray *)values;
- (void)addCellarDoorPanoramasObject:(WHPanoramaMO *)value;
- (void)removeCellarDoorPanoramasObject:(WHPanoramaMO *)value;
- (void)addCellarDoorPanoramas:(NSOrderedSet *)values;
- (void)removeCellarDoorPanoramas:(NSOrderedSet *)values;
- (void)insertObject:(WHPhotographMO *)value inCellarDoorPhotographsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCellarDoorPhotographsAtIndex:(NSUInteger)idx;
- (void)insertCellarDoorPhotographs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCellarDoorPhotographsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCellarDoorPhotographsAtIndex:(NSUInteger)idx withObject:(WHPhotographMO *)value;
- (void)replaceCellarDoorPhotographsAtIndexes:(NSIndexSet *)indexes withCellarDoorPhotographs:(NSArray *)values;
- (void)addCellarDoorPhotographsObject:(WHPhotographMO *)value;
- (void)removeCellarDoorPhotographsObject:(WHPhotographMO *)value;
- (void)addCellarDoorPhotographs:(NSOrderedSet *)values;
- (void)removeCellarDoorPhotographs:(NSOrderedSet *)values;
- (void)addEventsObject:(WHEventMO *)value;
- (void)removeEventsObject:(WHEventMO *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)insertObject:(WHPhotographMO *)value inPhotographsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotographsAtIndex:(NSUInteger)idx;
- (void)insertPhotographs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotographsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotographsAtIndex:(NSUInteger)idx withObject:(WHPhotographMO *)value;
- (void)replacePhotographsAtIndexes:(NSIndexSet *)indexes withPhotographs:(NSArray *)values;
- (void)addPhotographsObject:(WHPhotographMO *)value;
- (void)removePhotographsObject:(WHPhotographMO *)value;
- (void)addPhotographs:(NSOrderedSet *)values;
- (void)removePhotographs:(NSOrderedSet *)values;
- (void)addRangesObject:(WHWineRangeMO *)value;
- (void)removeRangesObject:(WHWineRangeMO *)value;
- (void)addRanges:(NSSet *)values;
- (void)removeRanges:(NSSet *)values;

- (void)addRegionsObject:(WHRegionMO *)value;
- (void)removeRegionsObject:(WHRegionMO *)value;
- (void)addRegions:(NSSet *)values;
- (void)removeRegions:(NSSet *)values;

- (void)addRestaurantsObject:(WHRestaurantMO *)value;
- (void)removeRestaurantsObject:(WHRestaurantMO *)value;
- (void)addRestaurants:(NSSet *)values;
- (void)removeRestaurants:(NSSet *)values;

- (void)insertObject:(WHWineClubMO *)value inWineClubsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWineClubsAtIndex:(NSUInteger)idx;
- (void)insertWineClubs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWineClubsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWineClubsAtIndex:(NSUInteger)idx withObject:(WHWineClubMO *)value;
- (void)replaceWineClubsAtIndexes:(NSIndexSet *)indexes withWineClubs:(NSArray *)values;
- (void)addWineClubsObject:(WHWineClubMO *)value;
- (void)removeWineClubsObject:(WHWineClubMO *)value;
- (void)addWineClubs:(NSOrderedSet *)values;
- (void)removeWineClubs:(NSOrderedSet *)values;
- (void)insertObject:(WHWineMO *)value inWinesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWinesAtIndex:(NSUInteger)idx;
- (void)insertWines:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWinesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWinesAtIndex:(NSUInteger)idx withObject:(WHWineMO *)value;
- (void)replaceWinesAtIndexes:(NSIndexSet *)indexes withWines:(NSArray *)values;
- (void)addWinesObject:(WHWineMO *)value;
- (void)removeWinesObject:(WHWineMO *)value;
- (void)addWines:(NSOrderedSet *)values;
- (void)removeWines:(NSOrderedSet *)values;
@end
