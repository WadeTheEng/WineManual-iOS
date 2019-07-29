//
//  WHPanoramaMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHPhotographMO, WHWineryMO;

@interface WHPanoramaMO : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * wineryId;
@property (nonatomic, retain) WHPhotographMO *photograph;
@property (nonatomic, retain) WHWineryMO *winery;

@end
