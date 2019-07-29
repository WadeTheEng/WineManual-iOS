//
//  WHRegionViewCell.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "WHRegionViewCell.h"
#import "WHRegionMO.h"
#import "WHPhotographMO.h"

#import "PCGradientView.h"
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

@interface WHRegionViewCell ()
@property (nonatomic,weak) UIImageView             * regionImageView;
@property (nonatomic,weak) UIActivityIndicatorView * activityIndicatorView;
@end
@implementation WHRegionViewCell

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_regionNameLabel     setFont:[UIFont edmondsansRegularOfSize:_regionNameLabel.font.pointSize]];
    [_regionDistanceLabel setFont:[UIFont edmondsansRegularOfSize:_regionDistanceLabel.font.pointSize]];
    
    [_regionNameLabel     setTextColor:[UIColor whiteColor]];
    [_regionDistanceLabel setTextColor:[UIColor whiteColor]];
    
    [_regionImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [_gradientView setColors:@[[UIColor colorWithWhite:0.0 alpha:0.0],[UIColor colorWithWhite:0.0 alpha:0.75]]];
    [_gradientView setLocations:@[@(0.4),@(1.0)]];
    
    [self setRegion:nil];
    
    UIView * selectedOverlayView = [UIView new];
    [selectedOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
    [selectedOverlayView setHidden:YES];
    [selectedOverlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:selectedOverlayView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selectedOverlayView]|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(selectedOverlayView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectedOverlayView]-7-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(selectedOverlayView)]];
    _selectedOverlayView = selectedOverlayView;
    
    //
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView insertSubview:activityIndicator aboveSubview:self.regionImageView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.regionImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.regionImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    [self setActivityIndicatorView:activityIndicator];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setRegion:nil];
}

+ (CGFloat)cellHeight
{
    return 100.0;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}


- (void)setRegion:(WHRegionMO *)region
{
    _region = region;
    
    [_regionNameLabel     setText:[region name]];
    [_regionDistanceLabel setText:nil];

    if (_region == nil) {
        [_regionImageView setImage:nil];
    } else {
        WHPhotographMO * photograph = [_region.photographs firstObject];
        if (photograph == nil) {
            [_regionImageView setImage:[UIImage imageNamed:@"region_placeholder"]];
        } else {
            NSMutableURLRequest * imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageThumbURL]];
            [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            __weak typeof(self) blockSelf = self;
            [self.activityIndicatorView startAnimating];
            [self.regionImageView setImage:nil];
            [self.regionImageView setImageWithURLRequest:imageRequest
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     if (image != nil && request == nil) {
                                                         //Returned with cached image & should already be decoded.
                                                         [blockSelf.activityIndicatorView stopAnimating];
                                                         [blockSelf.regionImageView setImage:image];
                                                     } else {
                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                             UIGraphicsBeginImageContext(CGSizeMake(1,1));
                                                             CGContextRef context = UIGraphicsGetCurrentContext();
                                                             CGContextDrawImage(context, (CGRect){0,0,1,1}, [image CGImage]);
                                                             UIGraphicsEndImageContext();
                                                             
                                                             if ([imageRequest isEqual:request]) {
                                                                 dispatch_sync(dispatch_get_main_queue(), ^{
                                                                     [blockSelf.activityIndicatorView stopAnimating];
                                                                     [blockSelf.regionImageView setImage:image];
                                                                 });
                                                             }
                                                         });
                                                     }
                                                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                     if ([imageRequest isEqual:request]) {
                                                         [blockSelf.activityIndicatorView stopAnimating];
                                                         [blockSelf.regionImageView setImage:nil];
                                                     }
                                                 }];
        }
    }
}

- (void)setDistance:(CLLocationDistance)distance
{
    //distance in meters.
    _distance = distance;
    CGFloat kilometer = (_distance/1000.0);
    if (kilometer > 1.0) {
        [_regionDistanceLabel setText:[NSString stringWithFormat:@"%.0f km",kilometer]];
    } else {
        [_regionDistanceLabel setText:[NSString stringWithFormat:@"%.2f km",kilometer]];
    }
}

- (void)setDistanceLabelHidden:(BOOL)hidden
{
    [_regionDistanceLabel setHidden:hidden];
}

#pragma mark UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [_selectedOverlayView setHidden:!selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [_selectedOverlayView setHidden:!highlighted];
}

#pragma mark

/*
- (NSNumberFormatter *)distanceNumberFormatter
{
    NSNumberFormatter * numberFormatter = nil;
    
    if (_publicDistanceNumberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@"0.## km"];
        _publicDistanceNumberFormatter = numberFormatter;
    } else {
        numberFormatter = _publicDistanceNumberFormatter;
    }
    
    _distanceNumberFormatter = numberFormatter;
    numberFormatter = nil;
    
    return _distanceNumberFormatter;
}

- (void)dealloc
{
    _distanceNumberFormatter = nil;
}
 */

@end
