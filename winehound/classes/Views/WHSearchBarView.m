//
//  WHSearchBarView.m
//  WineHound
//
//  Created by Mark Turner on 18/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHSearchBarView.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@implementation WHSearchBarView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UITextField * searchTextField = [UITextField new];
        UIImageView * searchIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_search_icon"]];
        [searchIconImageView setFrame:CGRectMake(.0, .0, 30.0, CGRectGetHeight(searchIconImageView.frame))];
        [searchIconImageView setContentMode:UIViewContentModeLeft];
        
        [searchTextField setLeftView:searchIconImageView];
        [searchTextField setLeftViewMode:UITextFieldViewModeAlways];
        [searchTextField setBackgroundColor:[UIColor whiteColor]];
        [searchTextField setFont:[UIFont edmondsansRegularOfSize:18.0]];
        [searchTextField setPlaceholder:@"Search"];
        [searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [searchTextField setReturnKeyType:UIReturnKeySearch];
        [self addSubview:searchTextField];
        _searchTextField = searchTextField;
        
        //
        
        UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(.0, .0, 55.0, 21.0)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont edmondsansMediumOfSize:18.0]];
        [cancelButton setTitleColor:[UIColor wh_grey] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self addSubview:cancelButton];
        _cancelButton = cancelButton;
        
        //Setup constaints
        
        [searchTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSLayoutConstraint *searchTextFieldLeadingConstraint =
        [NSLayoutConstraint constraintWithItem:searchTextField
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0];
        
        NSLayoutConstraint * searchTextFieldTrailingConstraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:searchTextField
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0];
        
        [self addConstraint:searchTextFieldLeadingConstraint];
        [self addConstraint:searchTextFieldTrailingConstraint];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:searchTextField
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:10.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:searchTextField
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:10.0]];
        _searchTextFieldLeadingConstraint  = searchTextFieldLeadingConstraint;
        _searchTextFieldTrailingConstraint = searchTextFieldTrailingConstraint;
        
        //
        
        [cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cancelButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cb(==60)]" options:0 metrics:nil views:@{@"cb":cancelButton}]];
        [cancelButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cb(==40)]" options:0 metrics:nil views:@{@"cb":cancelButton}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        NSLayoutConstraint * cancelButtonTrailingConstraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:cancelButton
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0];
        [self addConstraint:cancelButtonTrailingConstraint];
        _cancelButtonTrailingConstraint = cancelButtonTrailingConstraint;
        
        //
        
        UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView setHidesWhenStopped:YES];
        [activityIndicatorView setColor:[UIColor colorWithWhite:0.2 alpha:0.2]];
        [self addSubview:activityIndicatorView];
        [activityIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicatorView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicatorView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        _activityIndicatorView = activityIndicatorView;
        
        
        //Setup constraint constants.
        [self setSearchBarExpanded:NO animationDuration:0];
    }
    return self;
}

- (void)setSearchBarExpanded:(BOOL)expanded;
{
    [self setSearchBarExpanded:expanded animationDuration:0.2];
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
                             [self.cancelButtonTrailingConstraint    setConstant:10.0];
                         } else {
                             [self.searchTextFieldLeadingConstraint  setConstant:120.0];
                             [self.searchTextFieldTrailingConstraint setConstant:40.0];
                             [self.cancelButtonTrailingConstraint    setConstant:-10.0-CGRectGetWidth(self.cancelButton.frame)];
                         }
                         [self layoutIfNeeded];
                     } completion:nil];
}

- (void)cancel
{
    [self.searchTextField resignFirstResponder];
    [self.searchTextField setText:nil];
}

@end
