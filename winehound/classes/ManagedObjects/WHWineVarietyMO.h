//
//  WHWineVarietyMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHWineMO;

@interface WHWineVarietyMO : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * varietyId;
@property (nonatomic, retain) NSSet *wines;
@end

@interface WHWineVarietyMO (CoreDataGeneratedAccessors)

- (void)addWinesObject:(WHWineMO *)value;
- (void)removeWinesObject:(WHWineMO *)value;
- (void)addWines:(NSSet *)values;
- (void)removeWines:(NSSet *)values;

@end
