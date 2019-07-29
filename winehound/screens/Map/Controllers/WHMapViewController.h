//
//  WHMapViewController.h
//  WineHound
//
//  Created by Mark Turner on 30/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Provides the ability to display a full screen GMSMapView with a marker location & icon. 
 * Current implementation will being zoom at 7.0 & zoom to 13.0 after a second delay of view appearing.
 */

@class GMSMapView;
@interface WHMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (nonatomic) CLLocationCoordinate2D markerLocation;
@property (nonatomic) UIImage * markerIcon;

@end
