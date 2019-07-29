//
// Created by David Lawson on 18/03/2014.
// Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocation (AltDistance)

- (CLLocationDistance)altDistanceFromLocation:(const CLLocation *)location;

@end