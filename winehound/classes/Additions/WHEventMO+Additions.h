//
//  WHEventMO+Additions.h
//  WineHound
//
//  Created by Mark Turner on 23/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <PCDefaults/PCDCollectionManager+Proximity.h>

#import "WHEventMO.h"
#import "WHShareProtocol.h"

@interface WHEventMO (Additions) <ProximitySortable,WHShareProtocol>

@property (nonatomic,readonly) CLLocation * location;
@property (nonatomic,readonly) BOOL isFeatured;

@property (nonatomic,assign) NSDateFormatter * sharedDateFormatter; //the dateformatter used by datePeriodString getter.
@property (nonatomic,readonly) NSString * datePeriodString;
@property (nonatomic,readonly) NSString * shortDatePeriodString;

@end
