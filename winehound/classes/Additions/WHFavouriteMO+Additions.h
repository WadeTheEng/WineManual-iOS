//
//  WHFavouriteMO+Additions.h
//  WineHound
//
//  Created by Mark Turner on 10/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHFavouriteMO.h"

@interface WHFavouriteMO (Additions)
+ (BOOL)favouriteEntityName:(NSString *)entityName identifier:(NSNumber *)identifier;
+ (WHFavouriteMO *)favouriteWithEntityName:(NSString *)entityName identifier:(NSNumber *)identifier;
@end
