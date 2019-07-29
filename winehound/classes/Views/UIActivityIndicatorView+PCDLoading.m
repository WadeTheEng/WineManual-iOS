//
//  UIActivityIndicatorView+PCDLoading.m
//  WineHound
//
//  Created by Mark Turner on 23/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

static UIActivityIndicatorView __weak * activityIndicatorView;

#import "UIActivityIndicatorView+PCDLoading.h"

@implementation UIActivityIndicatorView (PCDLoading)

+ (void)setCurrentActivityIndicatorView:(UIActivityIndicatorView *)view
{
    activityIndicatorView = view;
}

#pragma mark PCDLoadingHUDViewProtocol

+ (void)show
{
    [activityIndicatorView startAnimating];
}

+ (void)showError:(NSError *)error
{
    [activityIndicatorView stopAnimating];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    [activityIndicatorView stopAnimating];
}

+ (void)dismiss
{
    [activityIndicatorView stopAnimating];
}

@end
