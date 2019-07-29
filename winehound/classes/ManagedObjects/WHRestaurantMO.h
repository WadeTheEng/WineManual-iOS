//
//  WHRestaurantMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHOpenTimeMO, WHPhotographMO, WHWineryMO;

@interface WHRestaurantMO : NSManagedObject

@property (nonatomic, retain) NSString * menuPdf;
@property (nonatomic, retain) NSString * restaurantDescription;
@property (nonatomic, retain) NSNumber * restaurantId;
@property (nonatomic, retain) NSString * restaurantName;
@property (nonatomic, retain) NSNumber * wineryId;
@property (nonatomic, retain) NSSet *openTimes;
@property (nonatomic, retain) NSOrderedSet *photographs;
@property (nonatomic, retain) WHWineryMO *winery;
@end

@interface WHRestaurantMO (CoreDataGeneratedAccessors)

- (void)addOpenTimesObject:(WHOpenTimeMO *)value;
- (void)removeOpenTimesObject:(WHOpenTimeMO *)value;
- (void)addOpenTimes:(NSSet *)values;
- (void)removeOpenTimes:(NSSet *)values;

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
@end
