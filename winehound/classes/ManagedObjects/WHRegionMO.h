//
//  WHRegionMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHEventMO, WHPhotographMO, WHStateMO, WHWineryMO;

@interface WHRegionMO : NSManagedObject

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSNumber * countryId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * hasBreweries;
@property (nonatomic, retain) NSNumber * hasCideries;
@property (nonatomic, retain) NSNumber * hasWineries;
@property (nonatomic, retain) NSString * instagram;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pdfURL;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) NSString * regionZone;
@property (nonatomic, retain) NSNumber * stateId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * websiteUrl;
@property (nonatomic, retain) NSNumber * zoomLevel;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSOrderedSet *photographs;
@property (nonatomic, retain) WHStateMO *state;
@property (nonatomic, retain) NSSet *wineries;
@end

@interface WHRegionMO (CoreDataGeneratedAccessors)

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
- (void)addWineriesObject:(WHWineryMO *)value;
- (void)removeWineriesObject:(WHWineryMO *)value;
- (void)addWineries:(NSSet *)values;
- (void)removeWineries:(NSSet *)values;

@end
