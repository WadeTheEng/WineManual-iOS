//
//  PCGalleryView.h
//  WineHound
//
//  Created by Mark Turner on 13/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AFImageRequestOperation;
@interface PCGalleryView : UIView <UIScrollViewDelegate>

@property (nonatomic,readonly,weak) UIScrollView * scrollView;

@property (nonatomic,weak) AFImageRequestOperation * imageRequestOperation;

@property (nonatomic) BOOL hideProgress;

- (void)prepareForReuse;
- (void)setImage:(UIImage *)image;

@end