//
//  WHWineClubMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHPhotographMO, WHWineryMO;

@interface WHWineClubMO : NSManagedObject

@property (nonatomic, retain) NSString * clubDescription;
@property (nonatomic, retain) NSNumber * clubIdentifier;
@property (nonatomic, retain) NSString * clubName;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSNumber * wineryId;
@property (nonatomic, retain) NSSet *clubWineries;
@property (nonatomic, retain) NSOrderedSet *photographs;
@end

@interface WHWineClubMO (CoreDataGeneratedAccessors)

- (void)addClubWineriesObject:(WHWineryMO *)value;
- (void)removeClubWineriesObject:(WHWineryMO *)value;
- (void)addClubWineries:(NSSet *)values;
- (void)removeClubWineries:(NSSet *)values;

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
