//
//  WHMapCalloutView.m
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHMapCalloutView.h"
#import "UIImage+Resizable.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "NSString+ReformatTel.h"

#import "WHWineryMO+Mapping.h"
#import "WHFavouriteMO+Additions.h"
#import "WHAmenityMO+Mapping.h"
#import "WHAmenityMO+Additions.h"

#import "PCActionButton.h"

NSString * const WHCalloutFavouriteBackgroundImageName[] = {
    [WHWineryTierBasic]     = @"map_callout_basic_favourite_background",
    [WHWineryTierBronze]    = @"map_callout_bronze_favourite_background",
    [WHWineryTierSilver]    = @"map_callout_silver_favourite_background",
    [WHWineryTierGold]      = @"map_callout_gold_favourite_background",
    [WHWineryTierGoldPlus]  = @"map_callout_gold_favourite_background",
};

typedef NS_ENUM(NSInteger, WHMapCalloutType) {
    WHMapCalloutTypeStandard = 0,
    WHMapCalloutTypePremium,
    WHMapCalloutTypeBreweryCidery,
};

@interface WHMapCalloutView () <UICollectionViewDataSource,PCActionButtonDelegate>
{
    CAShapeLayer * _backgroundLayer;
    WHMapCalloutType _type;
}
@end

@implementation WHMapCalloutView
@synthesize favouriteButton = _favouriteButton;

+ (id)new
{
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHMapCalloutView" owner:nil options:nil];
    return [views lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundColor:[UIColor clearColor]];

    [_titleLabel    setFont:[UIFont edmondsansRegularOfSize:_titleLabel.font.pointSize]];
    [_distanceLabel setFont:[UIFont edmondsansRegularOfSize:_distanceLabel.font.pointSize]];

    [_distanceLabel setTextColor:[UIColor wh_grey]];
    [_titleLabel    setTextColor:[UIColor wh_grey]];
    [_distanceLabel setHighlightedTextColor:[UIColor blackColor]];
    [_titleLabel    setHighlightedTextColor:[UIColor blackColor]];
    
    [_phLabel setTextColor:[UIColor wh_grey]];
    [_phLabel setFont:[UIFont edmondsansRegularOfSize:15.0]];

    [_phoneNumberButton setActionDelegate:self];
    [_phoneNumberButton setTitle:nil forState:UIControlStateNormal];
    [_phoneNumberButton.titleLabel setFont:[UIFont edmondsansMediumOfSize:15.0]];
    [_phoneNumberButton setTitleColor:[UIColor wh_grey] forState:UIControlStateNormal];
    [_phoneNumberButton addTarget:self
                           action:@selector(_phoneNumberButtonTouchedUpInside:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [_drivingDirectionButton setTitle:@"Driving Directions" forState:UIControlStateNormal];
    [_drivingDirectionButton.titleLabel setFont:[UIFont edmondsansMediumOfSize:15.0]];
    [_drivingDirectionButton setTitleColor:[UIColor wh_grey] forState:UIControlStateNormal];
    [_drivingDirectionButton addTarget:self
                                action:@selector(_drivingDirectionsButtonTouchedUpInside:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [_backgroundImageView               setImage:[UIImage resizableImageNamed:@"map_callout_background"]];
    [_backgroundImageView    setHighlightedImage:[UIImage resizableImageNamed:@"map_callout_background_high"]];
    [_backgroundTipImageView            setImage:[UIImage imageNamed:@"map_callout_tip"]];
    [_backgroundTipImageView setHighlightedImage:[UIImage imageNamed:@"map_callout_tip_high"]];
    
    [_accesoryImageView setImage:[UIImage imageNamed:@"map_callout_accessory"]];

    [_favouriteButton setTintColor:[UIColor whiteColor]];
    [_favouriteButton setImage:[UIImage imageNamed:@"map_callout_favourite"]      forState:UIControlStateNormal];
    [_favouriteButton setImage:[UIImage imageNamed:@"map_callout_favourite_high"] forState:UIControlStateHighlighted];
    [_favouriteButton setImage:[UIImage imageNamed:@"map_callout_favourite_high"] forState:UIControlStateSelected];
    [_favouriteButton addTarget:self action:@selector(_favouriteButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [_amenitiesCollectionView setBackgroundColor:[UIColor clearColor]];
    [_amenitiesCollectionView setUserInteractionEnabled:NO];
    [_amenitiesCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    [self addTarget:self action:@selector(_touchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setWinery:nil];
}

- (void)setType:(WHMapCalloutType)type
{
    _type = type;
    
    CGRect requiredTitleBoundingBox =
    [self.winery.name    boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                      options:0
                                   attributes:@{NSFontAttributeName:_titleLabel.font}
                                      context:nil];
    CGRect requiredPhoneNumberBoundingBox =
    [self.winery.phoneNumber boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                          options:0
                                       attributes:@{NSFontAttributeName:_phoneNumberButton.titleLabel.font}
                                          context:nil];
    CGRect requiredDistanceBoundingBox =
    [_distanceLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                      options:0
                                   attributes:@{NSFontAttributeName:_distanceLabel.font}
                                      context:nil];

    //Love da magic numbers.
    
    CGFloat requiredWidth = MAX(MIN(100.0+requiredTitleBoundingBox.size.width, 300.0),150.0);
    requiredWidth = MAX(requiredWidth, requiredDistanceBoundingBox.size.width);
    requiredWidth = MAX(requiredWidth, requiredPhoneNumberBoundingBox.size.width);
    requiredWidth = requiredWidth<200.0?200.0:requiredWidth;
    
    CGSize requiredSize = {requiredWidth,.0};
    
    switch (type) {
            case WHMapCalloutTypeStandard:
            requiredSize.height = 65.0;
            break;
            case WHMapCalloutTypePremium:
            requiredSize.height = 90.0;
            break;
            case WHMapCalloutTypeBreweryCidery:
            requiredSize.height = 97.0;
            requiredWidth = requiredWidth<220.0?220.0:requiredWidth;
            break;
        default:
            break;
    }
    
    _requiredSize = requiredSize;
    
    [self setFrame:(CGRect){self.frame.origin, requiredSize}];
}

- (void)setWinery:(WHWineryMO *)winery
{
    _winery = winery;

    NSString * distanceString = nil;
    if ([self.delegate respondsToSelector:@selector(distanceStringForMapCalloutView:)]) {
        distanceString = [self.delegate distanceStringForMapCalloutView:self];
    }
    
    [_titleLabel      setText:_winery.name];
    [_distanceLabel   setText:distanceString];
    
    if (winery.type.intValue == WHWineryTypeCidery || winery.type.intValue == WHWineryTypeBrewery) {
        [self setType:WHMapCalloutTypeBreweryCidery];

        if (winery.phoneNumber.length > 0) {
            [_phoneNumberButton setTitle:winery.phoneNumber forState:UIControlStateNormal];
            [_phoneNumberButton setUserInteractionEnabled:YES];

            NSURL * telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",winery.phoneNumber.escaped]];
            if ([[UIApplication sharedApplication] canOpenURL:telURL]) {
                [_phoneNumberButton setIdentifier:@"Phone"];
            } else {
                [_phoneNumberButton setIdentifier:nil];
            }
        } else {
            [_phoneNumberButton setTitle:@"No Number" forState:UIControlStateNormal];
            [_phoneNumberButton setUserInteractionEnabled:NO];
            [_phoneNumberButton setIdentifier:nil];
        }

        [_amenitiesCollectionView setDataSource:nil];
        [_amenitiesCollectionView setHidden:YES];
        [_phoneNumberButton setHidden:NO];
        [_phLabel setHidden:NO];
        [_drivingDirectionButton setHidden:NO];
        [_accesoryImageView setHidden:YES];
        
        [_favouriteButton setUserInteractionEnabled:NO];
        [_favouriteButton setBackgroundImage:[UIImage resizableImageNamed:@"map_callout_cidery_brewery_background"]
                                    forState:UIControlStateNormal];
        
        if (winery.type.intValue == WHWineryTypeCidery) {
            [_favouriteButton setImage:[UIImage imageNamed:@"map_callout_cidery_favourite_icon"]
                              forState:UIControlStateNormal];
        } else if (winery.type.intValue == WHWineryTypeBrewery) {
            [_favouriteButton setImage:[UIImage imageNamed:@"map_callout_brewery_favourite_icon"]
                              forState:UIControlStateNormal];
        }
    } else {
        [self setType:_winery.tierValue > WHWineryTierSilver ? WHMapCalloutTypeStandard : WHMapCalloutTypePremium];

        [_amenitiesCollectionView setDataSource:self];
        [_amenitiesCollectionView reloadData];
        [_amenitiesCollectionView setHidden:(_winery.tierValue > WHWineryTierSilver)];

        [_phoneNumberButton setHidden:YES];
        [_phLabel setHidden:YES];
        [_drivingDirectionButton setHidden:YES];
        [_accesoryImageView setHidden:NO];

        WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHWineryMO entityName] identifier:self.winery.wineryId];
        [_favouriteButton setUserInteractionEnabled:YES];
        [_favouriteButton setImage:[UIImage imageNamed:@"map_callout_favourite"]
                          forState:UIControlStateNormal];
        [_favouriteButton setSelected:favourite!=nil];
        [_favouriteButton setBackgroundImage:[UIImage resizableImageNamed:WHCalloutFavouriteBackgroundImageName[_winery.tierValue]]
                                    forState:UIControlStateNormal];
    }
    [self setNeedsLayout];
}

- (void)setDistance:(NSString *)string
{
    [_distanceLabel setText:string];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
//    if (CGSizeEqualToSize(_backgroundLayer.frame.size, self.frame.size) == NO) {
//        [_backgroundLayer removeFromSuperlayer];
//        
//        CGFloat minx = 0.0, maxx = CGRectGetWidth(self.frame);
//        CGFloat miny = 0.0, maxy = CGRectGetHeight(self.frame);
//        CGFloat midx = maxx * 0.5;
//        
//        CGFloat radius = 8.5;
//        CGFloat hfb    = 13.0; //height from bottom
//        
//        UIBezierPath *backgroundShapePath = [UIBezierPath bezierPath];
//        [backgroundShapePath moveToPoint:CGPointMake(maxx, (maxy - hfb) - radius)];
//        [backgroundShapePath addLineToPoint:CGPointMake(maxx, miny + radius)];
//        [backgroundShapePath addQuadCurveToPoint:CGPointMake(maxx - radius, miny)
//                                    controlPoint:CGPointMake(maxx, miny)];
//        [backgroundShapePath addLineToPoint:CGPointMake(minx + radius, miny)];
//        [backgroundShapePath addQuadCurveToPoint:CGPointMake(minx, miny + radius)
//                                    controlPoint:CGPointMake(minx, miny)];
//        [backgroundShapePath addLineToPoint:CGPointMake(minx, (maxy - hfb) - radius)];
//        [backgroundShapePath addQuadCurveToPoint:CGPointMake(minx + radius, (maxy - hfb))
//                                    controlPoint:CGPointMake(minx, (maxy - hfb))];
//        //Tip
//        /*
//        [backgroundShapePath addCurveToPoint:CGPointMake(midx - 14.0, maxy - hfb) controlPoint1:CGPointMake(midx - 0.0, maxy - hfb) controlPoint2:CGPointMake(midx - 20.0, maxy - hfb)];
//         */
//        [backgroundShapePath addLineToPoint:CGPointMake(midx - 14.0, maxy - hfb)];
//        [backgroundShapePath addLineToPoint:CGPointMake(midx, maxy)];
//        [backgroundShapePath addLineToPoint:CGPointMake(midx + 14.0, maxy - hfb)];
//        
//        [backgroundShapePath addLineToPoint:CGPointMake(maxx - radius, maxy - hfb)];
//        [backgroundShapePath addQuadCurveToPoint:CGPointMake(maxx, (maxy - hfb) - radius) controlPoint:CGPointMake(maxx, maxy - hfb)];
//        [backgroundShapePath closePath];
//        
//        CAShapeLayer * backgroundLayer = [CAShapeLayer layer];
//        [backgroundLayer setFrame:CGRectMake(.0f, .0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
//        [backgroundLayer setPath:[backgroundShapePath CGPath]];
//        [backgroundLayer setLineWidth:0.5];
//        [backgroundLayer setFillColor:[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]];
//        [backgroundLayer setStrokeColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
//        [self.layer insertSublayer:backgroundLayer atIndex:0];
//        
//        _backgroundLayer = backgroundLayer;
//    }
}

#pragma mark 

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (self.winery.type.intValue == WHWineryTypeWinery) {
        [_backgroundTipImageView setHighlighted:highlighted];
        [_backgroundImageView    setHighlighted:highlighted];
        [_titleLabel             setHighlighted:highlighted];
        [_distanceLabel          setHighlighted:highlighted];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        if (highlighted == YES) {
            [_backgroundLayer setFillColor:[[UIColor colorWithRed:242.0/255.0 green:240.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor]];
        } else {
            [_backgroundLayer setFillColor:[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]];
        }
        [CATransaction commit];
    }
}

#pragma mark
#pragma mark Actions

- (void)_favouriteButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapCalloutView:didTapFavouriteButton:)]) {
        [self.delegate mapCalloutView:self didTapFavouriteButton:button];
    }
}

- (void)_phoneNumberButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    UIMenuItem * callMenuItem = [[UIMenuItem alloc] initWithTitle:@"Call" action:@selector(call:)];
    CGRect requiredSize = [button.titleLabel.text boundingRectWithSize:button.frame.size
                                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                            attributes:@{NSFontAttributeName:button.titleLabel.font}
                                                               context:nil];
    
    [button becomeFirstResponder];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:@[callMenuItem]];
    [menuController setTargetRect:(CGRect) {.origin = button.frame.origin, .size = requiredSize.size} inView:button.superview];
    [menuController setMenuVisible:YES animated:YES];
    [menuController setMenuItems:nil];
}

- (void)_drivingDirectionsButtonTouchedUpInside:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapCalloutView:didTapDrivingDirectionsButton:)]) {
        [self.delegate mapCalloutView:self didTapDrivingDirectionsButton:button];
    }
}

- (void)_touchedUpInside:(UIControl *)control
{
    NSLog(@"%s", __func__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapCalloutViewDidTapView:)]) {
        [self.delegate mapCalloutViewDidTapView:self];
    }
}


#pragma mark PCActionButtonDelegate

- (BOOL)actionButton:(PCActionButton *)button canPerformAction:(SEL)action
{
    NSLog(@"%s", __func__);
    return
    (action == @selector(copy:)) ||
    (action == @selector(call:) && [button.identifier isEqual:@"Phone"]);
}

- (void)actionButton:(PCActionButton *)button performAction:(SEL)action
{
    NSLog(@"%s", __func__);
    
    if ([button.identifier isEqual:@"Phone"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mapCalloutView:didTapTelephoneButton:)]) {
            [self.delegate mapCalloutView:self didTapTelephoneButton:button];
        }
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.winery.amenities count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    const NSInteger kImageViewTag = 111;
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UIImageView * iv = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
    
    if (iv == nil) {
        iv = [UIImageView new];
        [iv setTag:kImageViewTag];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        [iv setFrame:CGRectMake(.0, .0, CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame))];
        [iv setTintColor:[UIColor wh_grey]];
        [cell.contentView addSubview:iv];
    }

    WHAmenityMO * amenityObject = [self.winery.amenities objectAtIndex:indexPath.row];
    [iv setImage:[amenityObject icon]];
    return cell;
}

@end

