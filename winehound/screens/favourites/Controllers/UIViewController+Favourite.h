//
//  UIViewController+Favourite.h
//  WineHound
//
//  Created by Mark Turner on 25/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 MT NOTE - Not currently being used. 
 */

@interface UIViewController (Favourite)

/*
 Returns YES if a favourite already exists for the entity name & identifier
*/
- (BOOL)displayFavouriteAlertForEntity:(NSString *)entityName
                        withIdentifier:(NSNumber *)identifier
                     mailingIdentifier:(NSString *)mailingIdentifier;

@end
