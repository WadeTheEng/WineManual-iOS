//
//  WHRegionMO+Additions.h
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHRegionMO.h"
#import <PCDefaults/PCDCollectionManager+Proximity.h>

@interface WHRegionMO (Additions) <ProximitySortable>
@property (nonatomic,readonly) CLLocation * location;
@end
