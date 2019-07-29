//
//  WHContactCell.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <GoogleMaps/GMSMapView.h>
#import <GoogleMaps/GMSCameraPosition.h>
#import <GoogleMaps/GMSMarker.h>

#import "WHContactCell.h"
#import "WHWineryMO+Mapping.h"
#import "WHWineryMO+Additions.h"
#import "WHRegionMO.h"
#import "WHEventMO.h"
#import "WHMapIconManager.h"
#import "PCActionButton.h"

#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"
#import "NSString+ReformatTel.h"

const CGFloat kMapViewHeight = 180.0f;
const CGFloat kYLabelSpacing = 20.0;
const CGFloat kLabelHeight   = 20.0;

@interface WHContactCell () <PCActionButtonDelegate>

@property (nonatomic) WHMapIconManager * mapIconManager;

@end

@implementation WHContactCell

#pragma mark

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:[self reuseIdentifier] bundle:[NSBundle mainBundle]];
}

- (WHMapIconManager *)mapIconManager
{
    if (_mapIconManager == nil) {
        WHMapIconManager * mapIconManager = [WHMapIconManager new];
        _mapIconManager = mapIconManager;
    }
    return _mapIconManager;
}

#pragma mark

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setWinery:nil];
}

+ (CGFloat)cellHeightForRegionObject:(WHRegionMO *)region
{
    CGRect requiredPhone = [region.phoneNumber
                            boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                            attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:14.0]}
                            context:nil];
    CGRect requiredEmail = [region.email
                            boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                            attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:14.0]}
                            context:nil];

    CGFloat cellHeight = (kMapViewHeight + kYLabelSpacing);
    
    cellHeight += kLabelHeight;//Driving directions
    cellHeight += kYLabelSpacing;
    
    if (region.phoneNumber.length > 0) {
        cellHeight += ceilf(requiredPhone.size.height);
        cellHeight += kYLabelSpacing;
    }
    if (region.email.length > 0) {
        cellHeight += ceilf(requiredEmail.size.height);
        cellHeight += kYLabelSpacing;
    }
    if (region.websiteUrl.length > 0) {
        cellHeight += [self.class requiredSizeForWebsiteString:region.websiteUrl].height;
        cellHeight += kYLabelSpacing;
    }
    
    cellHeight += 20.0;//bit of padding

    return cellHeight;
}

+ (CGFloat)cellHeightForWineryObject:(WHWineryMO *)winery
{
    CGRect requiredBoundingBox = [winery.address
                                  boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName: [UIFont edmondsansRegularOfSize:14.0]}
                                  context:nil];
    
    CGFloat cellHeight = 0.0;
    cellHeight += kMapViewHeight;
    cellHeight += kYLabelSpacing;
    cellHeight += requiredBoundingBox.size.height;
    cellHeight += kYLabelSpacing;
    cellHeight += kLabelHeight;//Driving directions
    cellHeight += kYLabelSpacing;

    if (winery.phoneNumber.length > 0) {
        cellHeight += kLabelHeight;//Phone
        cellHeight += kYLabelSpacing;
    }
    if (winery.tierValue < WHWineryTierBasic) {
        if (winery.email.length > 0) {
            cellHeight += kLabelHeight; //Email
            cellHeight += kYLabelSpacing;
        }
        if (winery.website.length > 0) {
            cellHeight += [self.class requiredSizeForWebsiteString:winery.website].height;
            cellHeight += kYLabelSpacing;
        }
    }
    
    cellHeight += 20.0;//bit of padding
    
    return cellHeight;
}

+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event
{
    CGRect requiredAddress = [event.address
                              boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                              attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:14.0]}
                              context:nil];
    CGRect requiredWebsite = [event.website
                              boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                              attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:14.0]}
                              context:nil];
    CGRect requiredPhone   = [event.phoneNumber
                              boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                              attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:14.0]}
                              context:nil];
    
    CGFloat cellHeight = .0;//(kMapViewHeight + kYLabelSpacing);
    
    cellHeight += kLabelHeight;//Driving directions
    cellHeight += kYLabelSpacing;

    if (event.address.length > 0) {
        cellHeight += ceilf(requiredAddress.size.height);
        cellHeight += kYLabelSpacing;
    }
    if (event.website.length > 0) {
        cellHeight += ceilf(requiredWebsite.size.height);
        cellHeight += kYLabelSpacing;
    }
    if (event.phoneNumber.length > 0) {
        cellHeight += ceilf(requiredPhone.size.height);
        cellHeight += kYLabelSpacing;
    }
    
    cellHeight += 20.0;//bit of padding
    
    return cellHeight;
}

+ (CGSize)requiredSizeForWebsiteString:(NSString *)website
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    CGRect requiredBoundingBox = [website boundingRectWithSize:CGSizeMake(245.0, CGFLOAT_MAX)
                                                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                    attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:14.0],
                                                                 NSParagraphStyleAttributeName: paragraphStyle }
                                                       context:nil];
    return requiredBoundingBox.size;
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer * mapTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_mapTapGesture:)];
    [mapTapGesture setNumberOfTapsRequired:1];
    [mapTapGesture setNumberOfTouchesRequired:1];
    [self.mapView addGestureRecognizer:mapTapGesture];
    [self.mapView.settings setAllGesturesEnabled:NO];
    [self.mapView setMyLocationEnabled:YES];
    [self.mapView setPadding:UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)];
    
    [self.mapViewHeightConstraint setConstant:kMapViewHeight];
    
    UILabel * addressLabel = [UILabel new];
    [addressLabel setText:@"38 Melba Hwy Yarra Glen 3775\nVictoria, Australia"];
    [addressLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [addressLabel setTextColor:[UIColor wh_grey]];
    [addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [addressLabel setNumberOfLines:0];
    
    UIButton * drivingDirectionsButton = [PCActionButton buttonWithType:UIButtonTypeCustom];
    [drivingDirectionsButton setTitle:@"Driving Directions" forState:UIControlStateNormal];
    [drivingDirectionsButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [drivingDirectionsButton setTitleColor:[UIColor wh_grey] forState:UIControlStateHighlighted];
    [drivingDirectionsButton.titleLabel setFont:[UIFont fontWithName:@"Edmondsans-Bold" size:14.0]];
    [drivingDirectionsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [drivingDirectionsButton addTarget:self action:@selector(_drivingDirectionsTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    //Phone
    
    UILabel  * phoneLabel = [UILabel new];
    [phoneLabel setText:@"Phone: "];
    [phoneLabel setFont:[UIFont fontWithName:@"Edmondsans-Regular" size:14.0]];
    [phoneLabel setTextColor:[UIColor wh_grey]];
    
    PCActionButton * phoneButton = [PCActionButton buttonWithType:UIButtonTypeCustom];
    [phoneButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [phoneButton setTitleColor:[UIColor wh_grey] forState:UIControlStateHighlighted];
    [phoneButton.titleLabel setFont:[UIFont fontWithName:@"Edmondsans-Bold" size:14.0]];
    [phoneButton setTitle:@"+61 3 9730 0100" forState:UIControlStateNormal];
    [phoneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [phoneButton addTarget:self action:@selector(_phoneButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [phoneButton setActionDelegate:self];

    //Email
    
    UILabel  * emailLabel = [UILabel new];
    [emailLabel setText:@"Email: "];
    [emailLabel setFont:[UIFont fontWithName:@"Edmondsans-Regular" size:14.0]];
    [emailLabel setTextColor:[UIColor wh_grey]];

    PCActionButton * emailButton = [PCActionButton buttonWithType:UIButtonTypeCustom];
    [emailButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [emailButton setTitleColor:[UIColor wh_grey] forState:UIControlStateHighlighted];
    [emailButton.titleLabel setFont:[UIFont fontWithName:@"Edmondsans-Bold" size:14.0]];
    [emailButton setTitle:@"info@yering.com" forState:UIControlStateNormal];
    [emailButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [emailButton addTarget:self action:@selector(_emailButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [emailButton setActionDelegate:self];
    [emailButton setIdentifier:@"Email"];

    //Website
    
    UILabel  * websiteLabel = [UILabel new];
    [websiteLabel setText:@"Website: "];
    [websiteLabel setFont:[UIFont fontWithName:@"Edmondsans-Regular" size:14.0]];
    [websiteLabel setTextColor:[UIColor wh_grey]];
    
    PCActionButton * websiteButton = [PCActionButton buttonWithType:UIButtonTypeCustom];
    [websiteButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [websiteButton setTitleColor:[UIColor wh_grey] forState:UIControlStateHighlighted];
    [websiteButton.titleLabel setFont:[UIFont fontWithName:@"Edmondsans-Bold" size:14.0]];
    [websiteButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [websiteButton.titleLabel setNumberOfLines:0];
    [websiteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [websiteButton addTarget:self action:@selector(_websiteButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [websiteButton setActionDelegate:self];
    [websiteButton setIdentifier:@"Website"];
    
    //
    
    [self.contentView addSubview:addressLabel];
    [self.contentView addSubview:drivingDirectionsButton];
    [self.contentView addSubview:phoneLabel];
    [self.contentView addSubview:phoneButton];
    [self.contentView addSubview:emailLabel];
    [self.contentView addSubview:emailButton];
    [self.contentView addSubview:websiteLabel];
    [self.contentView addSubview:websiteButton];
    
    _addressLabel            = addressLabel;
    _drivingDirectionsButton = drivingDirectionsButton;
    _phoneLabel      		 = phoneLabel;
    _phoneButton     		 = phoneButton;
    _emailLabel      		 = emailLabel;
    _emailButton     		 = emailButton;
    _websiteLabel    		 = websiteLabel;
    _websiteButton   		 = websiteButton;
    
    [self setWinery:nil];
    
    //set constant of map height constraint.
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString * phone   = _winery != nil ? _winery.phoneNumber : nil;
    NSString * email   = _winery != nil && (_winery.tierValue < WHWineryTierBasic) ? _winery.email : nil;;
    NSString * website = _winery != nil && (_winery.tierValue < WHWineryTierBasic) ? _winery.website : nil;;

    if (_region != nil) {
        phone   = _winery.phoneNumber;
        email   = _region.email;
        website = _region.websiteUrl;
    }
    
    if (_event != nil) {
        phone   = _event.phoneNumber;
        website = _event.website;
    }
    
    CGFloat y = kYLabelSpacing + self.mapViewHeightConstraint.constant;
    CGSize addressLabelSize = [self.addressLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 20.0, CGFLOAT_MAX)];
    [self.addressLabel setFrame:(CGRect){10.0,y,addressLabelSize.width,addressLabelSize.height}];
        
    if (addressLabelSize.height > 0) {
        y += (addressLabelSize.height + kYLabelSpacing);
    }

    [self.drivingDirectionsButton setFrame:(CGRect){10.0,y,130.0,kLabelHeight}];
    
    y += (kLabelHeight + kYLabelSpacing);
    
    if (phone.length > 0) {
        [self.phoneLabel  setFrame:(CGRect){10.0,y, 45.0,kLabelHeight}];
        [self.phoneButton setFrame:(CGRect){55.0,y,255.0,kLabelHeight}];

        y += (kLabelHeight + kYLabelSpacing);
    }
    if (email.length > 0) {
        [self.emailLabel    setFrame:(CGRect){10.0,y, 40.0,kLabelHeight}];
        [self.emailButton   setFrame:(CGRect){50.0,y,260.0,kLabelHeight}];
        
        y += (kLabelHeight + kYLabelSpacing);
    }
    if (website.length > 0) {
        CGSize websiteSize = [self.class requiredSizeForWebsiteString:website];
        [self.websiteLabel  setFrame:(CGRect){10.0,y, 50.0,kLabelHeight}];
        [self.websiteButton setFrame:(CGRect){65.0,y,245.0,websiteSize.height}];
    }
}

#pragma mark

- (void)setWinery:(WHWineryMO *)winery
{
    _winery = winery;
    
    [self.addressLabel   setText:_winery.address];
    [self.phoneButton   setTitle:_winery.phoneNumber forState:UIControlStateNormal];
    [self.emailButton   setTitle:_winery.email       forState:UIControlStateNormal];
    [self.websiteButton setTitle:_winery.website     forState:UIControlStateNormal];
    
    [self.emailLabel    setHidden:((_winery.tierValue >= WHWineryTierBasic) || (_winery.email.length == 0))];
    [self.emailButton   setHidden:((_winery.tierValue >= WHWineryTierBasic) || (_winery.email.length == 0))];
    [self.websiteLabel  setHidden:((_winery.tierValue >= WHWineryTierBasic) || (_winery.website.length == 0))];
    [self.websiteButton setHidden:((_winery.tierValue >= WHWineryTierBasic) || (_winery.website.length == 0))];
    
    if (_winery != nil) {
        [self.mapView clear];

        CLLocationDegrees latitude  = (CLLocationDegrees)_winery.latitude.doubleValue;
        CLLocationDegrees longitude = (CLLocationDegrees)_winery.longitude.doubleValue;
        CGFloat mapZoom = 14.0;
        
        if (winery.zoomLevel != nil) {
            mapZoom = winery.zoomLevel.floatValue;
        }
        [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:mapZoom]];
        
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(latitude,longitude)];
        [marker setIcon:[UIImage imageNamed:WHWineryMarkerImageName[_winery.tierValue]]];
        [marker setMap:self.mapView];
        
        if (winery.tierValue <= WHWineryTierGold) {
            [self.mapIconManager logoOperationWithWinery:winery withCallback:^(UIImage *wineryIcon) {
                if (wineryIcon) {
                    [marker setIcon:wineryIcon];
                }
                _wineryMarker = wineryIcon;
            }];
        }
        
        NSURL * telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",_winery.phoneNumber.escaped]];
        if ([[UIApplication sharedApplication] canOpenURL:telURL]) {
            [(PCActionButton *)self.phoneButton setIdentifier:@"Phone"];
        } else {
            [(PCActionButton *)self.phoneButton setIdentifier:nil];
        }
    }
}

- (void)setEvent:(WHEventMO *)event
{
    _event = event;
    
    [self.mapView removeFromSuperview];
    [self.mapViewHeightConstraint setConstant:.0];
    
    [self.addressLabel  setText:event.address];
    [self.websiteButton setTitle:_event.website     forState:UIControlStateNormal];
    [self.phoneButton   setTitle:_event.phoneNumber forState:UIControlStateNormal];
    
    [self.phoneLabel    setHidden:(_event.phoneNumber.length == 0)];
    [self.phoneButton   setHidden:(_event.phoneNumber.length == 0)];
    [self.emailLabel    setHidden:YES];
    [self.emailButton   setHidden:YES];
    [self.websiteLabel  setHidden:(_event.website.length == 0)];
    [self.websiteButton setHidden:(_event.website.length == 0)];

    if (_event != nil) {
        NSURL * telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",_event.phoneNumber.escaped]];
        if ([[UIApplication sharedApplication] canOpenURL:telURL]) {
            [(PCActionButton *)self.phoneButton setIdentifier:@"Phone"];
        } else {
            [(PCActionButton *)self.phoneButton setIdentifier:nil];
        }
    }
    
    /*
    if (_event != nil) {
        CLLocationDegrees latitude  = (CLLocationDegrees)_event.latitude.doubleValue;
        CLLocationDegrees longitude = (CLLocationDegrees)_event.longitude.doubleValue;
        [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:14.0]];
    }
     */
}

#pragma mark
#pragma mark Actions

- (void)_drivingDirectionsTouchedUpInside:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contactCell:didTapDrivingDirectionsButton:)]) {
        [self.delegate contactCell:self didTapDrivingDirectionsButton:button];
    }
}

- (void)_phoneButtonTouchedUpInside:(UIButton *)button
{
    [self _displayMenuControllerInButton:(PCActionButton*)button];
}

- (void)_emailButtonTouchedUpInside:(UIButton *)button
{
    [self _displayMenuControllerInButton:(PCActionButton*)button];
}

- (void)_websiteButtonTouchedUpInside:(UIButton *)button
{
    [self _displayMenuControllerInButton:(PCActionButton*)button];
}

- (void)_mapTapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contactCell:didTapMapView:)]) {
        [self.delegate contactCell:self didTapMapView:self.mapView];
    }
}

#pragma mark 

- (void)_displayMenuControllerInButton:(PCActionButton *)actionButton
{
    UIMenuItem * callMenuItem    = [[UIMenuItem alloc] initWithTitle:@"Call" action:@selector(call:)];
    UIMenuItem * smsMenuItem     = [[UIMenuItem alloc] initWithTitle:@"SMS"  action:@selector(sms:)];
    UIMenuItem * emailMenuItem   = [[UIMenuItem alloc] initWithTitle:@"Email" action:@selector(email:)];
    UIMenuItem * browseMenuItem  = [[UIMenuItem alloc] initWithTitle:@"Open"  action:@selector(website:)];
    
    CGRect requiredSize = [actionButton.titleLabel.text boundingRectWithSize:actionButton.frame.size
                                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                  attributes:@{NSFontAttributeName:actionButton.titleLabel.font}
                                                                     context:nil];
    
    [actionButton becomeFirstResponder];

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:@[callMenuItem,smsMenuItem,emailMenuItem,browseMenuItem]];
    [menuController setTargetRect:(CGRect) {.origin = actionButton.frame.origin, .size = requiredSize.size} inView:actionButton.superview];
    [menuController setMenuVisible:YES animated:YES];
    [menuController setMenuItems:nil];
}

#pragma mark 

- (BOOL)actionButton:(PCActionButton *)button canPerformAction:(SEL)action
{
    NSLog(@"%s", __func__);
    return
    (action == @selector(copy:)) ||
    (action == @selector(call:) && [button.identifier isEqualToString:@"Phone"]) ||
    (action == @selector(email:) && [button.identifier isEqualToString:@"Email"]) ||
    (action == @selector(website:) && [button.identifier isEqualToString:@"Website"]);
}

- (void)actionButton:(PCActionButton *)button performAction:(SEL)action
{
    NSLog(@"%s", __func__);
    
    if ([button.identifier isEqualToString:@"Phone"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contactCell:didTapPhoneButton:)]) {
            [self.delegate contactCell:self didTapPhoneButton:button];
        }
    } else if ([button.identifier isEqualToString:@"Email"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contactCell:didTapEmailButton:)]) {
            [self.delegate contactCell:self didTapEmailButton:button];
        }
    } else if ([button.identifier isEqualToString:@"Website"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contactCell:didTapWebsiteButton:)]) {
            [self.delegate contactCell:self didTapWebsiteButton:button];
        }
    }
}

@end
