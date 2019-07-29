//
//  UIRefreshControl+PCDLoading.h
//  WineHound
//
//  Created by Mark Turner on 23/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PCDefaults/PCDCollectionManager.h>

@interface UIRefreshControl (PCDLoading) <PCDLoadingHUDViewProtocol>

+ (void)setCurrentRefreshControl:(UIRefreshControl *)view;

@end
