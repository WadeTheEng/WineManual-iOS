//
//  WHWineryMO+Additions.h
//  WineHound
//
//  Created by Mark Turner on 06/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <PCDefaults/PCDCollectionManager+Proximity.h>

#import "WHWineryMO+Mapping.h"
#import "WHShareProtocol.h"
#import "NSAttributedString+OpenHours.h"

static NSString * const WHWineryMarkerImageName[] = {
    [WHWineryTierGoldPlus] = @"map_gold_pin",
    [WHWineryTierGold]     = @"map_gold_pin",
    [WHWineryTierSilver]   = @"map_silver_pin",
    [WHWineryTierBronze]   = @"map_bronze_pin",
    [WHWineryTierBasic]    = @"map_basic_pin",
};

@class CLLocation;
@interface WHWineryMO (Additions) <ProximitySortable,WHShareProtocol,WHOpenHoursProtocol>
@property (nonatomic,readonly) CLLocation * location;
- (BOOL)isPremium;
- (BOOL)isGold;
@end
