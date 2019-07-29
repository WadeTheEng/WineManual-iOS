//
//  WHPhotographMO.h
//  WineHound
//
//  Created by Mark Turner on 12/08/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHEventMO, WHPanoramaMO, WHRegionMO, WHRestaurantMO, WHWineClubMO, WHWineMO, WHWineryMO;

@interface WHPhotographMO : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSString * imageThumbURL;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * imageWineThumbURL;
@property (nonatomic, retain) NSNumber * photographId;
@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) NSNumber * subjectId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * wineId;
@property (nonatomic, retain) NSNumber * wineryId;
@property (nonatomic, retain) NSString * subjectType;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *cellarDoors;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) WHPanoramaMO *panorama;
@property (nonatomic, retain) NSSet *regions;
@property (nonatomic, retain) NSSet *restaurants;
@property (nonatomic, retain) NSSet *wineClubs;
@property (nonatomic, retain) NSSet *wineries;
@property (nonatomic, retain) NSSet *wines;
@end

@interface WHPhotographMO (CoreDataGeneratedAccessors)

- (void)addCellarDoorsObject:(WHWineryMO *)value;
- (void)removeCellarDoorsObject:(WHWineryMO *)value;
- (void)addCellarDoors:(NSSet *)values;
- (void)removeCellarDoors:(NSSet *)values;

- (void)addEventsObject:(WHEventMO *)value;
- (void)removeEventsObject:(WHEventMO *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addRegionsObject:(WHRegionMO *)value;
- (void)removeRegionsObject:(WHRegionMO *)value;
- (void)addRegions:(NSSet *)values;
- (void)removeRegions:(NSSet *)values;

- (void)addRestaurantsObject:(WHRestaurantMO *)value;
- (void)removeRestaurantsObject:(WHRestaurantMO *)value;
- (void)addRestaurants:(NSSet *)values;
- (void)removeRestaurants:(NSSet *)values;

- (void)addWineClubsObject:(WHWineClubMO *)value;
- (void)removeWineClubsObject:(WHWineClubMO *)value;
- (void)addWineClubs:(NSSet *)values;
- (void)removeWineClubs:(NSSet *)values;

- (void)addWineriesObject:(WHWineryMO *)value;
- (void)removeWineriesObject:(WHWineryMO *)value;
- (void)addWineries:(NSSet *)values;
- (void)removeWineries:(NSSet *)values;

- (void)addWinesObject:(WHWineMO *)value;
- (void)removeWinesObject:(WHWineMO *)value;
- (void)addWines:(NSSet *)values;
- (void)removeWines:(NSSet *)values;

@end
