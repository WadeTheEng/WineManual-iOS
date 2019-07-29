//
//  WHRestaurantMO+Additions.m
//  WineHound
//
//  Created by Mark Turner on 21/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHRestaurantMO+Additions.h"
#import "WHWineryMO.h"

@implementation WHRestaurantMO (Additions)

#pragma mark WHOpenHoursProtocol

- (NSSet *)openHoursSet
{
    return [self openTimes];
}

- (NSString *)phoneNumber
{
    return [self.winery phoneNumber];
}

@end
