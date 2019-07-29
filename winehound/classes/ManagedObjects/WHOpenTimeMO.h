//
//  WHOpenTimeMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHRestaurantMO, WHWineryMO;

@interface WHOpenTimeMO : NSManagedObject

@property (nonatomic, retain) NSDate * closeTime;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * openTime;
@property (nonatomic, retain) NSSet *restaurants;
@property (nonatomic, retain) NSSet *wineries;
@end

@interface WHOpenTimeMO (CoreDataGeneratedAccessors)

- (void)addRestaurantsObject:(WHRestaurantMO *)value;
- (void)removeRestaurantsObject:(WHRestaurantMO *)value;
- (void)addRestaurants:(NSSet *)values;
- (void)removeRestaurants:(NSSet *)values;

- (void)addWineriesObject:(WHWineryMO *)value;
- (void)removeWineriesObject:(WHWineryMO *)value;
- (void)addWineries:(NSSet *)values;
- (void)removeWineries:(NSSet *)values;

@end
