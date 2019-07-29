//
//  WHEventMO.h
//  WineHound
//
//  Created by Mark Turner on 30/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHEventMO, WHPhotographMO, WHRegionMO, WHWineryMO;

@interface WHEventMO : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * createdAt;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) id eventIds;
@property (nonatomic, retain) NSNumber * eventLength;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parentEventId;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * priceDescription;
@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) id regionIds;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * stateIds;
@property (nonatomic, retain) NSNumber * tradeEvent;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSNumber * wineryId;
@property (nonatomic, retain) id wineryIds;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSOrderedSet *events;
@property (nonatomic, retain) WHEventMO *featuredEvent;
@property (nonatomic, retain) NSOrderedSet *photographs;
@property (nonatomic, retain) NSSet *regions;
@property (nonatomic, retain) NSSet *wineries;
@end

@interface WHEventMO (CoreDataGeneratedAccessors)

- (void)insertObject:(WHEventMO *)value inEventsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEventsAtIndex:(NSUInteger)idx;
- (void)insertEvents:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEventsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEventsAtIndex:(NSUInteger)idx withObject:(WHEventMO *)value;
- (void)replaceEventsAtIndexes:(NSIndexSet *)indexes withEvents:(NSArray *)values;
- (void)addEventsObject:(WHEventMO *)value;
- (void)removeEventsObject:(WHEventMO *)value;
- (void)addEvents:(NSOrderedSet *)values;
- (void)removeEvents:(NSOrderedSet *)values;
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
- (void)addRegionsObject:(WHRegionMO *)value;
- (void)removeRegionsObject:(WHRegionMO *)value;
- (void)addRegions:(NSSet *)values;
- (void)removeRegions:(NSSet *)values;

- (void)addWineriesObject:(WHWineryMO *)value;
- (void)removeWineriesObject:(WHWineryMO *)value;
- (void)addWineries:(NSSet *)values;
- (void)removeWineries:(NSSet *)values;

@end
