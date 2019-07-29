//
//  WHMapCalloutView.h
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

@protocol WHMapCalloutViewDelegate;
@class WHWineryMO,PCActionButton;

@interface WHMapCalloutView : UIControl
{
    @private
    __weak IBOutlet UILabel          *_titleLabel;
    __weak IBOutlet UILabel          *_distanceLabel;
    
    __weak IBOutlet UIButton         *_favouriteButton;
    __weak IBOutlet UIImageView      *_backgroundImageView;
    __weak IBOutlet UIImageView      *_backgroundTipImageView;
    __weak IBOutlet UIImageView      *_accesoryImageView;
    __weak IBOutlet UICollectionView *_amenitiesCollectionView;

    __weak IBOutlet UILabel          *_phLabel;
    __weak IBOutlet PCActionButton   *_phoneNumberButton;
    __weak IBOutlet UIButton         *_drivingDirectionButton;
}

@property (weak,nonatomic) UIButton * favouriteButton;

@property (nonatomic) CGSize requiredSize;

@property (nonatomic) CLLocationCoordinate2D markerPosition;

@property (nonatomic,strong) WHWineryMO * winery;

@property (nonatomic,weak) id <WHMapCalloutViewDelegate> delegate;

- (void)setDistance:(NSString *)string;

@end

//

@protocol WHMapCalloutViewDelegate <NSObject>
- (void)mapCalloutView:(WHMapCalloutView *)view didTapFavouriteButton:(UIButton *)button;
- (void)mapCalloutView:(WHMapCalloutView *)view didTapTelephoneButton:(UIButton *)button;
- (void)mapCalloutView:(WHMapCalloutView *)view didTapDrivingDirectionsButton:(UIButton *)button;
- (void)mapCalloutViewDidTapView:(WHMapCalloutView *)view;
- (NSString *)distanceStringForMapCalloutView:(WHMapCalloutView *)view;
@end