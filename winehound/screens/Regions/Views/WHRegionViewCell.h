//
//  WHRegionViewCell.h
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

@class WHRegionMO,PCGradientView;
@interface WHRegionViewCell : UITableViewCell
{
    __weak IBOutlet UILabel     *_regionNameLabel;
    __weak IBOutlet UILabel     *_regionDistanceLabel;
    __weak IBOutlet UIImageView *_regionImageView;
    __weak IBOutlet PCGradientView *_gradientView;
    
    __weak UIView * _selectedOverlayView;
}
@property (nonatomic,weak) WHRegionMO * region;
@property (nonatomic,assign) CLLocationDistance distance;
+ (CGFloat)cellHeight;
+ (NSString *)reuseIdentifier;
- (void)setDistanceLabelHidden:(BOOL)hidden;
@end
