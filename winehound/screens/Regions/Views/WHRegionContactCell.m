//
//  WHRegionContactCell.m
//  WineHound
//
//  Created by Mark Turner on 20/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHRegionContactCell.h"
#import "WHRegionMO.h"

@implementation WHRegionContactCell {
    __weak UIControl * _mapTapControl;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.mapContainerView bringSubviewToFront:_mapContainerView];
    
    if (self.mapContainerView.subviews.count > 0) {
        for (UIView * subview in self.mapContainerView.subviews) {
            [subview setFrame:(CGRect) {
                .origin = {.0,.0},
                .size = self.mapContainerView.bounds.size,
            }];
        }
    }
    [_mapTapControl setFrame:(CGRect){0, 0,_mapContainerView.frame.size}];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    //Will respond to 2 finger up.
    UIControl * mapTapControl = [UIControl new];
    [mapTapControl addTarget:self action:@selector(_mapTapControlTouchedUp:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:mapTapControl];
    _mapTapControl = mapTapControl;
}

- (void)setRegion:(WHRegionMO *)region
{
    _region = region;
    
    [self.addressLabel   setText:nil];
    [self.phoneButton   setTitle:_region.phoneNumber forState:UIControlStateNormal];
    [self.emailButton   setTitle:_region.email       forState:UIControlStateNormal];
    [self.websiteButton setTitle:_region.websiteUrl  forState:UIControlStateNormal];
    
    [self.phoneLabel    setHidden:(_region.phoneNumber.length == 0)];
    [self.phoneButton   setHidden:(_region.phoneNumber.length == 0)];
    [self.emailLabel    setHidden:(_region.email.length == 0)];
    [self.emailButton   setHidden:(_region.email.length == 0)];
    [self.websiteLabel  setHidden:(_region.websiteUrl.length == 0)];
    [self.websiteButton setHidden:(_region.websiteUrl.length == 0)];
    
    /*
    if (_region != nil) {
        CLLocationDegrees latitude  = (CLLocationDegrees)_region.latitude.doubleValue;
        CLLocationDegrees longitude = (CLLocationDegrees)_region.longitude.doubleValue;
        [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:14.0]];
        
        NSURL * telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",self.region.phoneNumber.escaped]];
        if ([[UIApplication sharedApplication] canOpenURL:telURL]) {
            [(PCActionButton *)self.phoneButton setIdentifier:@"Phone"];
        } else {
            [(PCActionButton *)self.phoneButton setIdentifier:nil];
        }
    }
     */
}

- (void)_mapTapControlTouchedUp:(UIControl *)mapTapControl
{
    NSLog(@"%s", __func__);
    
    if ([self.delegate respondsToSelector:@selector(contactCell:didTapMapView:)]) {
        [self.delegate contactCell:self didTapMapView:nil];
    }
}

@end
