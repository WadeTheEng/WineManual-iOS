//
//  WHWineriesListViewController.h
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHListViewController.h"
#import "WHWineryMO+Mapping.h"

@interface WHWineriesListViewController : WHListViewController

@property (nonatomic) NSNumber * regionId; //Filter wineries by region.

@property (nonatomic,assign) WHWineryType fetchWineryType;

@end