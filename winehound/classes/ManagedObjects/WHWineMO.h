//
//  WHWineMO.h
//  WineHound
//
//  Created by Mark Turner on 30/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHPhotographMO, WHWineRangeMO, WHWineVarietyMO, WHWineryMO;

@interface WHWineMO : NSManagedObject

@property (nonatomic, retain) NSString * alcoholContent;
@property (nonatomic, retain) NSString * aroma;
@property (nonatomic, retain) NSString * closure;
@property (nonatomic, retain) NSString * colour;
@property (nonatomic, retain) NSString * cost;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * dateBottled;
@property (nonatomic, retain) NSString * displayVariety;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * palate;
@property (nonatomic, retain) NSString * pdfUrl;
@property (nonatomic, retain) NSString * ph;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * vineyard;
@property (nonatomic, retain) NSString * vintage;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * wineDescription;
@property (nonatomic, retain) NSNumber * wineId;
@property (nonatomic, retain) NSString * winemakers;
@property (nonatomic, retain) NSNumber * wineRangeId;
@property (nonatomic, retain) NSNumber * wineryId;
@property (nonatomic, retain) NSString * wineTypeName;
@property (nonatomic, retain) NSNumber * winerySortPosition;
@property (nonatomic, retain) NSNumber * wineRangeSortPosition;
@property (nonatomic, retain) NSOrderedSet *photographs;
@property (nonatomic, retain) NSSet *ranges;
@property (nonatomic, retain) NSSet *varieties;
@property (nonatomic, retain) NSSet *wineries;
@end

@interface WHWineMO (CoreDataGeneratedAccessors)

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

- (void)addVarietiesObject:(WHWineVarietyMO *)value;
- (void)removeVarietiesObject:(WHWineVarietyMO *)value;
- (void)addVarieties:(NSSet *)values;
- (void)removeVarieties:(NSSet *)values;

- (void)addWineriesObject:(WHWineryMO *)value;
- (void)removeWineriesObject:(WHWineryMO *)value;
- (void)addWineries:(NSSet *)values;
- (void)removeWineries:(NSSet *)values;

@end
