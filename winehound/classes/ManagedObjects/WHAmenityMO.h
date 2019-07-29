//
//  WHAmenityMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHWineryMO;

@interface WHAmenityMO : NSManagedObject

@property (nonatomic, retain) NSNumber * amenityId;
@property (nonatomic, retain) NSString * iconIdentifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *wineries;
@end

@interface WHAmenityMO (CoreDataGeneratedAccessors)

- (void)addWineriesObject:(WHWineryMO *)value;
- (void)removeWineriesObject:(WHWineryMO *)value;
- (void)addWineries:(NSSet *)values;
- (void)removeWineries:(NSSet *)values;

@end
