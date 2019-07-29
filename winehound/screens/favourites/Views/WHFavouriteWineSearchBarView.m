//
//  WHFavouriteWineSearchBarView.m
//  WineHound
//
//  Created by Mark Turner on 27/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHFavouriteWineSearchBarView.h"

@implementation WHFavouriteWineSearchBarView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        UIButton * filterButton = [UIButton new];
        [filterButton setFrame:CGRectMake(0, 0, 10, 10)];
        [filterButton setImage:[UIImage imageNamed:@"filter_button"]      forState:UIControlStateNormal];
        [filterButton setImage:[UIImage imageNamed:@"filter_button_high"] forState:UIControlStateHighlighted];
        [filterButton setImage:[UIImage imageNamed:@"filter_button_high"] forState:UIControlStateSelected];
        [self addSubview:filterButton];
        _filterButton = filterButton;
        
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
                             [self.filterButtonTrailingConstraint    setConstant:-CGRectGetWidth(self.filterButton.frame)];
                             [self.cancelButtonTrailingConstraint    setConstant:10.0];
                         } else {
                             [self.searchTextFieldLeadingConstraint  setConstant:120.0];
                             [self.searchTextFieldTrailingConstraint setConstant:40.0];
                             [self.filterButtonTrailingConstraint    setConstant:0.0];
                             [self.cancelButtonTrailingConstraint    setConstant:-10.0-CGRectGetWidth(self.cancelButton.frame)];
                         }
                         [self layoutIfNeeded];
                     } completion:nil];
}

@end
