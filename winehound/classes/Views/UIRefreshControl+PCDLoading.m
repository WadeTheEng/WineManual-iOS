//
//  UIRefreshControl+PCDLoading.m
//  WineHound
//
//  Created by Mark Turner on 23/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "UIRefreshControl+PCDLoading.h"

static UIRefreshControl __weak * refreshControlView;

@implementation UIRefreshControl (PCDLoading)

+ (void)setCurrentRefreshControl:(UIRefreshControl *)view;
{
    refreshControlView = view;
}

#pragma mark PCDLoadingHUDViewProtocol

+ (void)show
{
    [refreshControlView beginRefreshing];
}

+ (void)showError:(NSError *)error
{
    if (refreshControlView.isRefreshing)
        [refreshControlView endRefreshing];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    if (refreshControlView.isRefreshing)
        [refreshControlView endRefreshing];
}

+ (void)dismiss
{
    if (refreshControlView.isRefreshing) {
        [refreshControlView endRefreshing];
    }
}

@end
