//
//  WHFilterBarView.m
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHFilterBarView.h"

#import "UIColor+WineHoundColors.h"
#import "UIImage+Resizable.h"
#import "UIFont+Edmondsans.h"

@implementation WHFilterBarView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        UISegmentedControl * segmentedControl = [UISegmentedControl new];
        [segmentedControl setFrame:CGRectMake(0, 0, 10, 10)];
        [segmentedControl setTintColor:[UIColor wh_grey]];
        [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"winery_filter_location_icon"] atIndex:0 animated:NO];
        [segmentedControl insertSegmentWithTitle:@"A-Z" atIndex:1 animated:NO];
        [segmentedControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont edmondsansMediumOfSize:14.0],
                                                   NSForegroundColorAttributeName:[UIColor wh_grey] }
                                        forState:UIControlStateNormal];
        [self addSubview:segmentedControl];
        _segmentedControl = segmentedControl;
        
        //
        
        UIButton * filterButton = [UIButton new];
        [filterButton setFrame:CGRectMake(0, 0, 10, 10)];
        [filterButton setImage:[UIImage imageNamed:@"filter_button"]      forState:UIControlStateNormal];
        [filterButton setImage:[UIImage imageNamed:@"filter_button_high"] forState:UIControlStateHighlighted];
        [filterButton setImage:[UIImage imageNamed:@"filter_button_high"] forState:UIControlStateSelected];
        [self addSubview:filterButton];
        _filterButton = filterButton;

        //Setup constaints
        
        [segmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
        [segmentedControl addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sc(==100)]" options:0 metrics:nil views:@{@"sc":segmentedControl}]];
        [segmentedControl addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sc(==30)]"  options:0 metrics:nil views:@{@"sc":segmentedControl}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        NSLayoutConstraint *segmentedControlLeadingConstraint =
        [NSLayoutConstraint constraintWithItem:segmentedControl
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:10.0];
        [self addConstraint:segmentedControlLeadingConstraint];
        _segmentedControlLeadingConstraint = segmentedControlLeadingConstraint;
        

        //
        
        [filterButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [filterButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[fb(==44)]" options:0 metrics:nil views:@{@"fb":filterButton}]];
        [filterButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[fb(==44)]" options:0 metrics:nil views:@{@"fb":filterButton}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:filterButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        NSLayoutConstraint * filterButtonTrailingConstraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:filterButton
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0];
        [self addConstraint:filterButtonTrailingConstraint];
        _filterButtonTrailingConstraint = filterButtonTrailingConstraint;

        //Setup constraint constants.
        [self setSearchBarExpanded:NO animationDuration:0];
    }
    return self;
}

- (void)setSearchBarExpanded:(BOOL)expanded animationDuration:(NSTimeInterval)animationDuration
{
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:0
                     animations:^{
                         if (expanded == YES) {
                             [self setBackgroundColor:[UIColor whiteColor]];
                         } else {
                             [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
                         }
                         
                         if (expanded == YES) {
                             [self.searchTextFieldLeadingConstraint  setConstant:10.0];
                             [self.searchTextFieldTrailingConstraint setConstant:75.0];
                             [self.segmentedControlLeadingConstraint setConstant:-CGRectGetWidth(self.segmentedControl.frame)];
                             [self.filterButtonTrailingConstraint    setConstant:-CGRectGetWidth(self.filterButton.frame)];
                             [self.cancelButtonTrailingConstraint    setConstant:10.0];
                         } else {
                             [self.searchTextFieldLeadingConstraint  setConstant:120.0];
                             [self.searchTextFieldTrailingConstraint setConstant:40.0];
                             [self.segmentedControlLeadingConstraint setConstant:10.0];
                             [self.filterButtonTrailingConstraint    setConstant:0.0];
                             [self.cancelButtonTrailingConstraint    setConstant:-10.0-CGRectGetWidth(self.cancelButton.frame)];
                         }
                         [self layoutIfNeeded];
                     } completion:nil];
}

@end

