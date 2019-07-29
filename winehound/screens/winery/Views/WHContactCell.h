//
//  WHContactCell.h
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class    GMSMapView,WHWineryMO,WHRegionMO,WHEventMO;
@protocol WHContactCellDelegate;

@interface WHContactCell : UITableViewCell {
    __weak WHRegionMO * _region;
}

@property (nonatomic,weak) UILabel  * addressLabel;
@property (nonatomic,weak) UIButton * drivingDirectionsButton;
@property (nonatomic,weak) UILabel  * phoneLabel;
@property (nonatomic,weak) UIButton * phoneButton;
@property (nonatomic,weak) UILabel  * emailLabel;
@property (nonatomic,weak) UIButton * emailButton;
@property (nonatomic,weak) UILabel  * websiteLabel;
@property (nonatomic,weak) UIButton * websiteButton;

@property (weak, nonatomic) IBOutlet GMSMapView         *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;

@property (nonatomic,weak) id <WHContactCellDelegate> delegate;

@property (nonatomic,weak) WHWineryMO * winery;
@property (nonatomic,weak) WHRegionMO * region;
@property (nonatomic,weak) WHEventMO  * event;

@property (nonatomic,weak,readonly) UIImage * wineryMarker;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeightForRegionObject:(WHRegionMO *)region;
+ (CGFloat)cellHeightForWineryObject:(WHWineryMO *)winery;
+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event;

@end

@protocol WHContactCellDelegate <NSObject>
- (void)contactCell:(WHContactCell *)contactCell didTapDrivingDirectionsButton:(UIButton *)button;
- (void)contactCell:(WHContactCell *)contactCell didTapPhoneButton:(UIButton *)button;
- (void)contactCell:(WHContactCell *)contactCell didTapEmailButton:(UIButton *)button;
- (void)contactCell:(WHContactCell *)contactCell didTapWebsiteButton:(UIButton *)button;
- (void)contactCell:(WHContactCell *)contactCell didTapMapView:(GMSMapView *)mapView;
@end