//
//  WHAmenityMO+Additions.m
//  WineHound
//
//  Created by Mark Turner on 10/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHAmenityMO+Additions.h"

NSInteger  const WHAmenityIconCount = 25;
NSString * const WHAmenityImageNames[] = {
    [0]  = @"",
    [1]  = @"",
    [2]  = @"",
    [3]  = @"amenity_coffee",
    [4]  = @"amenity_concert",
    [5]  = @"amenity_conferences",
    [6]  = @"amenity_craft-local",
    [7]  = @"amenity_gallery",
    [8]  = @"amenity_tastings",
    [9]  = @"amenity_restaurant-cafe",
    [10] = @"amenity_tour",
    [11] = @"amenity_picnic",
    [12] = @"amenity_accomodation",
    [13] = @"amenity_historical-buildings",
    [14] = @"amenity_cheese",
    [15] = @"",
    [16] = @"amenity_playground",
    [17] = @"amenity_antipasto",
    [18] = @"amenity_disabled",
    [19] = @"amenity_bikes",
    [20] = @"amenity_bar",
    [21] = @"amenity_antipasto",
    [22] = @"amenity_vineyardtours",
    [23] = @"amenity_antipasto",
    [24] = @"amenity_tastings",
    [25] = @"amenity_bbq"
};

@implementation WHAmenityMO (Additions)

- (UIImage *)icon
{
    int amenityId = self.amenityId.intValue;
    if (amenityId > WHAmenityIconCount) {
        return nil;
    }
    return [[UIImage imageNamed:WHAmenityImageNames[amenityId]]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
