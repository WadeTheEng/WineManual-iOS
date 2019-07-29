//
//  WHStateMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHRegionMO;

@interface WHStateMO : NSManagedObject

@property (nonatomic, retain) NSNumber * countryId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * primaryKey;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *regions;
@end

@interface WHStateMO (CoreDataGeneratedAccessors)

- (void)addRegionsObject:(WHRegionMO *)value;
- (void)removeRegionsObject:(WHRegionMO *)value;
- (void)addRegions:(NSSet *)values;
- (void)removeRegions:(NSSet *)values;

@end
