//
//  WHEventCalendarViewCell.m
//  WineHound
//
//  Created by Mark Turner on 21/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WHEventCalendarViewCell.h"
#import "UIFont+Edmondsans.h"

@interface WHEventCalendarViewCell ()
{
    BOOL _indicatorVisible;
}
@property (nonatomic, weak) UILabel     *dayLabel;
@property (nonatomic, weak) UIView      *todayView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@end

@implementation WHEventCalendarViewCell

#pragma mark 
#pragma mark

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel * dayLabel = [[UILabel alloc] init];
        [dayLabel setTextAlignment:NSTextAlignmentCenter];
        [dayLabel setTextColor:[UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0]];
        [dayLabel setFont:[UIFont edmondsansRegularOfSize:12.0]];
        [dayLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:dayLabel];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:dayLabel
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterX
                                         multiplier:1.0
                                         constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:dayLabel
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterY
                                         multiplier:1.0
                                         constant:1.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:dayLabel
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0
                                         constant:28.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:dayLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0
                                         constant:28.0]];
        
        UIImageView * imageView = [UIImageView new];
        [imageView setContentMode:UIViewContentModeCenter];
        [self.contentView addSubview:imageView];
        
        UIImageView * indicatorImageView = [UIImageView new];
        [indicatorImageView setContentMode:UIViewContentModeCenter];
        [indicatorImageView setImage:[UIImage imageNamed:@"calendar_cell_indicator"]];
        [indicatorImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:indicatorImageView];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:indicatorImageView
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterX
                                         multiplier:1.0
                                         constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:indicatorImageView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                         constant:-3.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:indicatorImageView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0
                                         constant:6.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:indicatorImageView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0
                                         constant:6.0]];
        
        _indicatorImageView = indicatorImageView;
        _imageView = imageView;
        _dayLabel = dayLabel;
        _isToday  = NO;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_todayView != nil) {
        [self.contentView bringSubviewToFront:_todayView];
    }
    
    [self.contentView bringSubviewToFront:self.imageView];
    [self.contentView bringSubviewToFront:self.indicatorImageView];
    [self.contentView bringSubviewToFront:self.dayLabel];
    
    [self.imageView setFrame:CGRectMake(1.0, 0, CGRectGetWidth(self.contentView.bounds)-1, 26.0)];
}

- (UIView *)todayView
{
    if (_todayView == nil) {
        UIView * todayView = [UIView new];
        [todayView setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:240.0/255.0 blue:235.0/255.0 alpha:1.0]];
        [todayView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [todayView.layer setCornerRadius:4.0];
        [todayView.layer setMasksToBounds:YES];
        [self.contentView addSubview:todayView];
        
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:todayView
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterX
                                         multiplier:1.0
                                         constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:todayView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterY
                                         multiplier:1.0
                                         constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:todayView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0
                                         constant:28.0]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:todayView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0
                                         constant:28.0]];
        
        _todayView = todayView;
    }
    return _todayView;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [self.class reuseIdentifier];
}

#pragma mark - Prepare for Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _isToday = NO;
    _indicatorVisible = NO;

    [_indicatorImageView setHidden:YES];
    [_todayView setHidden:YES];
    [_dayLabel setText:@""];
}

- (void)setDayNumber:(NSString *)dayNumber
{
    [self.dayLabel setText:dayNumber];
}

- (void)setIsToday:(BOOL)isToday
{
    _isToday = isToday;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    if (_isToday == YES) {
        [self.todayView setHidden:NO];
        [self setNeedsLayout];
    } else {
        //Today view is lazy load.
        [_todayView setHidden:YES];
    }
    [CATransaction commit];
}

- (void)setIndicatorVisible:(BOOL)visible
{
    _indicatorVisible = visible;
    
    [self.indicatorImageView setHidden:!_indicatorVisible];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    if (selected == YES) {
        [self.dayLabel setTextColor:[UIColor whiteColor]];
        [self.dayLabel setFont:[UIFont edmondsansMediumOfSize:11.0]];
        [self.imageView setImage:[UIImage imageNamed:@"calendar_cell_selected_icon"]];
    } else {
        [self.dayLabel setTextColor:[UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0]];
        [self.dayLabel setFont:[UIFont edmondsansRegularOfSize:12.0]];
        [self.imageView setImage:nil];
    }
    
    [_indicatorImageView setHidden:!_indicatorVisible];
}

@end
