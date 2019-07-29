//
//  WHWineRangeMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHWineMO, WHWineryMO;

@interface WHWineRangeMO : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * rangeDescription;
@property (nonatomic, retain) NSNumber * rangeId;
@property (nonatomic, retain) NSSet *wineries;
@property (nonatomic, retain) NSSet *wines;
@end

@interface WHWineRangeMO (CoreDataGeneratedAccessors)

- (void)addWineriesObject:(WHWineryMO *)value;
- (void)removeWineriesObject:(WHWineryMO *)value;
- (void)addWineries:(NSSet *)values;
- (void)removeWineries:(NSSet *)values;

- (void)addWinesObject:(WHWineMO *)value;
- (void)removeWinesObject:(WHWineMO *)value;
- (void)addWines:(NSSet *)values;
- (void)removeWines:(NSSet *)values;

@end
