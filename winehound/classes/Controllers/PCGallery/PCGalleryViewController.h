//
//  PCGalleryViewController.h
//  WineHound
//
//  Created by Mark Turner on 12/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCGalleryViewControllerDataSource;
@protocol PCGalleryViewControllerDelegate;

@class PCPhoto;
@interface PCGalleryViewController : UIViewController
@property (nonatomic,weak) id <PCGalleryViewControllerDataSource> dataSource;
@property (nonatomic,weak) id <PCGalleryViewControllerDelegate>   delegate;

@property (nonatomic,readonly) UIView * containerView;
@property (nonatomic) NSUInteger currentPageIndex;
@property (nonatomic) BOOL fetchFullSize;

- (void)reloadData;
@end

@protocol PCGalleryViewControllerDataSource <NSObject>
- (NSUInteger)numberOfPhotosInGallery:(PCGalleryViewController *)gallery;
- (PCPhoto *)gallery:(PCGalleryViewController *)gallery photoAtIndex:(NSUInteger)index;
@end

@protocol PCGalleryViewControllerDelegate <NSObject>
- (void)galleryDidDimiss:(PCGalleryViewController *)gallery;
@end