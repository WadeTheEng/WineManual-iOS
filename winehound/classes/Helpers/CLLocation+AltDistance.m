//
// Created by David Lawson on 18/03/2014.
// Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "CLLocation+AltDistance.h"


@implementation CLLocation (AltDistance)

- (CLLocationDistance)altDistanceFromLocation:(const CLLocation *)location
{
    double earth = 6371.0;
    double from_lat = self.coordinate.latitude;
    double from_lng = self.coordinate.longitude;
    double to_lat = location.coordinate.latitude;
    double to_lng = location.coordinate.longitude;

    return earth * 2 * asin(sqrt(pow(sin((to_lat - from_lat) * M_PI / 180 / 2), 2) + cos(to_lat * M_PI / 180) * cos(from_lat * M_PI / 180) * pow(sin((to_lng - from_lng) * M_PI / 180 / 2), 2)));
}

@end