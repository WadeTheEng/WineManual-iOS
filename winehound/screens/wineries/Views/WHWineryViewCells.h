//
//  WHWineryViewCells.h
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>
#import <SWTableViewCell/SWTableViewCell.h>

@class WHWineryMO;
@interface WHWineryNormalViewCell : SWTableViewCell
{
    @public
    __weak IBOutlet UILabel *_wineryNameLabel;
    __weak IBOutlet UILabel *_wineryDistanceLabel;
    __weak IBOutlet UICollectionView *_listingsCollectionView;

    __weak UIView * _selectedOverlayView;
}
@property (nonatomic,weak)   WHWineryMO * winery;
@property (nonatomic,assign) CLLocationDistance distance;

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;

- (void)displaySwipeButtons:(BOOL)display;
- (void)setDistanceLabelHidden:(BOOL)hidden;

@end

////

@class PCGradientView;
@interface WHWineryPremiumViewCell : WHWineryNormalViewCell
{
    __weak IBOutlet UIImageView      *_wineryImageView;
    __weak IBOutlet PCGradientView   *_gradientView;
}
@end