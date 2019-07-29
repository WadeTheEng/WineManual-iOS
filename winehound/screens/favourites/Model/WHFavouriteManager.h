//
//  WHFavouriteManager.h
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHFavouriteManager : NSObject

+ (NSString *)email;
+ (void)setEmail:(NSString *)email;

+ (void)favouriteWineryId:(NSNumber *)wineryId withEmail:(NSString *)email callback:(void(^)(BOOL success,NSError *error))callback;

+ (void)favouriteKey:(NSString *)key
      withIdentifier:(NSNumber *)identifier
           withEmail:(NSString *)email
            callback:(void(^)(BOOL success,NSError *error))callback;

@end
