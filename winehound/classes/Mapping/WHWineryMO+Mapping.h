//
//  WHWineryMO+Mapping.h
//  WineHound
//
//  Created by Mark Turner on 04/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWineryMO.h"
#import <PCDefaults/PCDObjectProtocol.h>

typedef NS_ENUM(NSInteger, WHWineryTier) {
    WHWineryTierGoldPlus = 0,
    WHWineryTierGold     = 1,
    WHWineryTierSilver   = 2,
    WHWineryTierBronze   = 3,
    WHWineryTierBasic    = 4,
};

typedef NS_ENUM(NSInteger, WHWineryType) {
    WHWineryTypeWinery  = 1,
    WHWineryTypeBrewery = 2,
    WHWineryTypeCidery  = 3,
};

@interface WHWineryMO (Mapping) <PCDObjectProtocol>
@property (nonatomic,readonly) WHWineryTier tierValue;
@end