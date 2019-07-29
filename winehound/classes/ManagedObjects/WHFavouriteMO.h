//
//  WHFavouriteMO.h
//  WineHound
//
//  Created by Mark Turner on 24/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WHFavouriteMO : NSManagedObject

@property (nonatomic, retain) NSString * favouriteEntityName;
@property (nonatomic, retain) NSNumber * favouriteId;

@end
