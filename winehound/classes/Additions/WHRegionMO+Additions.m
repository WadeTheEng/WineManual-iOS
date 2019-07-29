//
//  WHRegionMO+Additions.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHRegionMO+Additions.h"
#import <objc/runtime.h>

static char kWHRegionLocationKey;

@implementation WHRegionMO (Additions)
@dynamic location;

#pragma mark
#pragma mark Location

- (CLLocation *)location
{
    CLLocation * location = (CLLocation *)objc_getAssociatedObject(self, &kWHRegionLocationKey);
    if (location == nil) {
        location = [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
        [self setLocation:location];
    }
    return location;
}

- (void)setLocation:(CLLocation *)location
{
    objc_setAssociatedObject(self, &kWHRegionLocationKey, location, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTurnIntoFault
{
    [self setLocation:nil];
}

@end
