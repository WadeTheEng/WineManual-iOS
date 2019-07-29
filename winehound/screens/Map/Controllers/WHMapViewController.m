//
//  WHMapViewController.m
//  WineHound
//
//  Created by Mark Turner on 30/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

#import "WHMapViewController.h"

@interface WHMapViewController ()

@end

@implementation WHMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Map"];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:self.markerLocation];
    [marker setAppearAnimation:kGMSMarkerAnimationNone];
    [marker setIcon:self.markerIcon];
    [marker setMap:self.mapView];
    
    [self.mapView setCamera:[GMSCameraPosition cameraWithTarget:self.markerLocation zoom:7.0]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:self.markerLocation zoom:13.0]];
    });
}

@end
