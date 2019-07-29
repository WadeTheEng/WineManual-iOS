//
//  WHWineriesScheduledLocationManager.h
//  WineHound
//
//  Created by Mark Turner on 11/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kWHUserDefaultsPushEnabled;

extern NSString * const kWHNotificationAlertActionKey;
extern NSString * const kWHNotificationAlertActionOpenWinery;
extern NSString * const kWHNotificationWineryIDKey;

@interface WHWineriesScheduledLocationManager : NSObject
- (void)startUpdates;
@end
