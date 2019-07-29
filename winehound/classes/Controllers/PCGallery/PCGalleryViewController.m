//
//  PCGalleryViewController.m
//  WineHound
//
//  Created by Mark Turner on 12/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <AFNetworking/AFImageRequestOperation.h>

#import "PCGalleryViewController.h"
#import "PCGalleryView.h"
#import "PCPhoto.h"
#import "NSCache+UIImage.h"

#define PADDING                 0
#define PAGE_INDEX_TAG_OFFSET   1000
#define PAGE_INDEX(page)        ([(page) tag] - PAGE_INDEX_TAG_OFFSET)

@interface PCGalleryViewController () <UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    NSUInteger _photoCount;

	NSMutableSet * _visiblePages, * _recycledPages;
    
    NSCache * _imageCache;
    
    NSOperationQueue * _imageRequestOperationQueue;
}
@property (nonatomic,weak) UIScrollView * pagingScrollView;
@property (nonatomic,readonly,weak) UIButton * closeButton;
@end

@implementation PCGalleryViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)dealloc
{
    [_imageRequestOperationQueue cancelAllOperations];
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];

    /*
     not nessasary
     [_imageCache removeAllObjects];
     */
}

- (void)_setup
{
    _photoCount = NSNotFound;
    _currentPageIndex = 0;

    _visiblePages  = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];
}

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];

    UIScrollView * scrollView = [UIScrollView new];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setDelegate:self];
    [scrollView setPagingEnabled:YES];
    
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setContentSize:[self contentSizeForPagingScrollView]];

    [self.view addSubview:scrollView];

    _pagingScrollView = scrollView;
    
    UIPanGestureRecognizer * panGesture = [UIPanGestureRecognizer new];
    [panGesture setDelegate:self];
    [panGesture addTarget:self action:@selector(_panGesture:)];
    [self.view addGestureRecognizer:panGesture];

    UITapGestureRecognizer * tapGesture = [UITapGestureRecognizer new];
    [tapGesture addTarget:self action:@selector(_tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UIImage * closeIcon = [UIImage imageNamed:@"alert_close_icon"];
    UIButton * closeButton = [[UIButton alloc] initWithFrame:(CGRect){.0, .0, closeIcon.size}];
    [closeButton setImage:closeIcon forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(_closeButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [closeButton setAlpha:0.0];
    [self.view addSubview:closeButton];
    _closeButton = closeButton;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-20.0]];

    [self reloadData];

    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_imageRequestOperationQueue cancelAllOperations];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
	// Remember index
	NSUInteger indexPriorToLayout = _currentPageIndex;
    
    [_pagingScrollView setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    
	// Recalculate contentSize based on current orientation
	_pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (PCGalleryView * page in _visiblePages) {
        NSUInteger index = PAGE_INDEX(page);
		page.frame = [self frameForPageAtIndex:index];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	[self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
	// Reset
	_currentPageIndex = indexPriorToLayout;
}

#pragma mark 

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.closeButton setHidden:YES];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark

- (UIView *)containerView
{
    return _pagingScrollView;
}

- (NSCache *)imageCache
{
    if (_imageCache == nil) {
        NSCache * imageCache = [UIImageView af_sharedImageCache];
        _imageCache = imageCache;
    }
    return _imageCache;
}

- (NSOperationQueue *)imageRequestOperationQueue
{
    if (_imageRequestOperationQueue == nil) {
        NSOperationQueue * imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        _imageRequestOperationQueue = imageRequestOperationQueue;
    }
    return _imageRequestOperationQueue;
}

- (void)setFetchFullSize:(BOOL)fetchFullSize
{
    _fetchFullSize = fetchFullSize;
    
    PCGalleryView * page = [self pageDisplayedAtIndex:_currentPageIndex];
    [self configurePage:page forIndex:_currentPageIndex];
}

- (void)reloadData
{
    [_imageRequestOperationQueue cancelAllOperations];
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    
    // Remove everything
    while (_pagingScrollView.subviews.count) {
        [[_pagingScrollView.subviews lastObject] removeFromSuperview];
    }
    
    // Update current page index
    _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    
    // Update
    [self performLayout];
    
    // Layout
    [self.view setNeedsLayout];
    
}

- (void)performLayout
{
	// Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // Content offset
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
}

#pragma mark - Paging

- (void)tilePages
{
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = _pagingScrollView.bounds;
	int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = (int)[self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = (int)[self numberOfPhotos] - 1;
	
	// Recycle no longer needed pages
    NSInteger pageIndex;
	for (PCGalleryView * page in _visiblePages) {
        pageIndex = PAGE_INDEX(page);
		if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
			[_recycledPages addObject:page];
            [page prepareForReuse];
			[page removeFromSuperview];
		}
	}
	[_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
			PCGalleryView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[PCGalleryView alloc] initWithFrame:CGRectZero];
			}
			[self configurePage:page forIndex:index];
			[_visiblePages addObject:page];
			[_pagingScrollView addSubview:page];
		}
	}
}

#pragma mark

- (NSUInteger)numberOfPhotos
{
    if (_photoCount == NSNotFound) {
        if ([self.dataSource respondsToSelector:@selector(numberOfPhotosInGallery:)]) {
            _photoCount = [self.dataSource numberOfPhotosInGallery:self];
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (id<PCPhoto>)photoAtIndex:(NSUInteger)index
{
    id <PCPhoto> photo = nil;
    if ([self.dataSource respondsToSelector:@selector(gallery:photoAtIndex:)]) {
        photo = [self.dataSource gallery:self photoAtIndex:index];
    }
    return photo;
}

#pragma mark

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
    CGRect bounds    = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}


- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index
{
	CGFloat pageWidth = _pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGSize)contentSizeForPagingScrollView
{
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    CGSize size = CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
    return size;
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    
    [self.pagingScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.pagingScrollView.bounds) * (float)currentPageIndex, 0.0) animated:NO];
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
	for (PCGalleryView * page in _visiblePages)
		if (PAGE_INDEX(page) == index) return YES;
	return NO;
}

- (PCGalleryView *)pageDisplayedAtIndex:(NSUInteger)index
{
	PCGalleryView *thePage = nil;
	for (PCGalleryView *page in _visiblePages) {
		if (PAGE_INDEX(page) == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

#pragma mark

- (void)configurePage:(PCGalleryView *)page forIndex:(NSUInteger)index
{
    [page setFrame:[self frameForPageAtIndex:index]];
    [page setTag:(PAGE_INDEX_TAG_OFFSET + index)];

    [page setHideProgress:NO];

    PCPhoto * photo = [self photoAtIndex:index];
    
    NSMutableURLRequest * thumbURLRequest = [NSMutableURLRequest requestWithURL:photo.thumbURL];
    [thumbURLRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    UIImage *cachedThumbImage = [self.imageCache cachedImageForRequest:thumbURLRequest];
    if (cachedThumbImage != nil) {
        [page setImage:cachedThumbImage];
        if (self.fetchFullSize == NO) {
            [page setHideProgress:YES];
        }
    }

    //
    
    NSURL * url = nil;
    if (self.fetchFullSize == YES) {
        url = photo.photoURL;
    } else if (cachedThumbImage == nil) {
        url = photo.thumbURL;
    }
    
    if (url != nil) {
        NSMutableURLRequest * imageURLRequest = [NSMutableURLRequest requestWithURL:url];
        [imageURLRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        AFImageRequestOperation * existingOperation = [self imageRequestOperationForRequest:imageURLRequest];
        if (existingOperation != nil) {
            [page setImageRequestOperation:existingOperation];
            return;
        }

        UIImage *cachedImage = [self.imageCache cachedImageForRequest:imageURLRequest];
        if (cachedImage != nil) {
            [page setImage:cachedImage];
            [page setHideProgress:YES];
        } else {
            __weak typeof(self) blockSelf = self;
            AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:imageURLRequest];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                PCGalleryView * visiblePage = [blockSelf pageDisplayedAtIndex:index];
                if ([visiblePage.imageRequestOperation.request isEqual:[operation request]]) {
                    
                    [blockSelf.imageCache cacheImage:responseObject forRequest:operation.request];
                    
                    [visiblePage setImage:responseObject];
                    [visiblePage setHideProgress:YES];
                } else {
                    NSLog(@"Page image request is not equal to response");
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Image download failure: %@",error);
                if (operation.isCancelled == NO) {
                    [page setHideProgress:YES];
                }
            }];
            
            [page setHideProgress:NO];
            [page setImageRequestOperation:requestOperation];
            
            [self.imageRequestOperationQueue addOperation:requestOperation];
        }
    }
}

- (AFImageRequestOperation *)imageRequestOperationForRequest:(NSURLRequest *)request
{
    AFImageRequestOperation * imageRequestOperation = nil;
    for (NSOperation *operation in [self.imageRequestOperationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        
        BOOL hasMatchingMethod = [@"GET" isEqualToString:[[(AFHTTPRequestOperation *)operation request] HTTPMethod]];
        BOOL hasMatchingPath = [[[[(AFHTTPRequestOperation *)operation request] URL] path] isEqual:request.URL.path];
        
        if (hasMatchingMethod && hasMatchingPath) {
            if ([operation isKindOfClass:[AFImageRequestOperation class]]) {
                imageRequestOperation = (AFImageRequestOperation*)operation;
            }
        }
    }
    return imageRequestOperation;
}

- (PCGalleryView *)dequeueRecycledPage
{
	PCGalleryView *page = [_recycledPages anyObject];
	if (page != nil) {
		[_recycledPages removeObject:page];
	}
	return page;
}

- (void)didStartViewingPageAtIndex:(NSUInteger)index
{
    [self loadAdjacentPhotosIfNecessary:index];
}

- (void)loadAdjacentPhotosIfNecessary:(NSUInteger)index
{
    // If page is current page then initiate loading of previous and next pages
    if (_currentPageIndex == index) {
        if (index > 0) {
            PCGalleryView * page = [self pageDisplayedAtIndex:index-1];
            [self configurePage:page forIndex:index-1];
        }
        if (index < [self numberOfPhotos] - 1) {
            PCGalleryView * page = [self pageDisplayedAtIndex:index+1];
            [self configurePage:page forIndex:index+1];
        }
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Checks
//	if (!_viewIsActive || _performingLayout || _rotating) return;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = _pagingScrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > [self numberOfPhotos] - 1) index = (int)[self numberOfPhotos] - 1;
	NSUInteger previousCurrentPage = _currentPageIndex;
	_currentPageIndex = index;
	if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
}

#pragma mark Actions

- (void)_panGesture:(UIPanGestureRecognizer *)panGesture
{
    PCGalleryView * page = [self pageDisplayedAtIndex:_currentPageIndex];
    //Return early if zoom is not 100%
    if (page.scrollView.zoomScale != 1.0)
        return;
 
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait)
        return;
    
    CGPoint translation = [panGesture translationInView:self.view];
    CGRect viewFrame = _pagingScrollView.frame;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            viewFrame.origin.y += translation.y;
            
            float alpha = 1.0-(fabsf(viewFrame.origin.y)/100.0);
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:alpha]];
                [_pagingScrollView setFrame:viewFrame];
            } completion:nil];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        default:
        {
            if (fabsf(viewFrame.origin.y) > 40.0) {
                if ([self.delegate respondsToSelector:@selector(galleryDidDimiss:)]) {
                    [self.closeButton setAlpha:0.0];
                    [self.delegate galleryDidDimiss:self];
                }
            } else {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionLayoutSubviews
                                 animations:^{
                                     [self.view setBackgroundColor:[UIColor blackColor]];
                                     [_pagingScrollView setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
                                     [_pagingScrollView layoutIfNeeded];
                                 } completion:nil];
            }
        }
            break;
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)_tapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait)
        return;

    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        [self.closeButton setAlpha:self.closeButton.alpha>0.0?0.0:1.0];
    } completion:nil];
}

- (void)_closeButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(galleryDidDimiss:)]) {
        [self.closeButton setAlpha:0.0];
        [self.delegate galleryDidDimiss:self];
    }
}

#pragma mark
#pragma mark

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    NSLog(@"gestureRecognizer: %@ otherGestureRecognizer: %@",gestureRecognizer,otherGestureRecognizer);
//    
//    
//    return YES;
//}

@end

/*
#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation PCImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request
{
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
	return [self objectForKey:AFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFImageCacheKeyFromURLRequest(request)];
    }
}

@end
*/