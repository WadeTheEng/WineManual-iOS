//
//  WHWineriesMapViewController.h
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GMSMapView;
@class PCDCollectionManager;

typedef NS_OPTIONS(NSUInteger, WHWineryMapType) {
    WHWineryMapTypeWinery  = 1 << 0,
    WHWineryMapTypeBrewery = 1 << 1,
    WHWineryMapTypeCidery  = 1 << 2,
    WHWineryMapTypeAll     = WHWineryMapTypeWinery  |
                             WHWineryMapTypeBrewery |
                             WHWineryMapTypeCidery,
};

@interface WHWineriesMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic,assign) WHWineryMapType fetchWineryTypes;

@property (nonatomic) NSNumber * regionId; //Filter wineries by region.
@property (nonatomic) NSNumber * displayCalloutForWineryId;
@property (nonatomic) UIEdgeInsets contentEdgeInsets;

- (void)setMapInteractionEnabled:(BOOL)enabled;

@end
