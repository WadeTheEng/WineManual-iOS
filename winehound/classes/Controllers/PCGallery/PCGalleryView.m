//
//  PCGalleryView.m
//  WineHound
//
//  Created by Mark Turner on 13/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "PCGalleryView.h"
#import "UIColor+WineHoundColors.h"

@interface PCLoadingWheel : UIView
@property (nonatomic) CGFloat progress;
@end

@implementation PCLoadingWheel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Draw background
    CGFloat lineWidth = 5.f;
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = lineWidth;
    processBackgroundPath.lineCapStyle = kCGLineCapRound;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - lineWidth)/2;
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [[[UIColor wh_grey] colorWithAlphaComponent:0.7] set];
    [processBackgroundPath stroke];
    
    // Draw progress
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    processPath.lineCapStyle = kCGLineCapRound;
    processPath.lineWidth = lineWidth;
    endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [[UIColor wh_beige] set];
    [processPath stroke];
}

@end

////

@interface PCGalleryView ()
@property (nonatomic,weak) UIImageView    * imageView;
@property (nonatomic,weak) PCLoadingWheel * loadingWheel;
@end

@implementation PCGalleryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        UIScrollView * scrollView = [UIScrollView new];
        [scrollView setDelegate:self];
        [scrollView setZoomScale:1.0];
        [scrollView setMinimumZoomScale:1.0];
        [scrollView setMaximumZoomScale:2.0];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        
        UIImageView * imageView = [UIImageView new];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [scrollView addSubview:imageView];
        
        [self addSubview:scrollView];
        
        /*
        UIActivityIndicatorView * activityIndicator = [UIActivityIndicatorView new];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        [activityIndicator setHidesWhenStopped:YES];
        [self addSubview:activityIndicator];
         */

        UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [scrollView addGestureRecognizer:doubleTapGesture];
        
        _scrollView = scrollView;
        _imageView  = imageView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_scrollView setFrame:CGRectMake(.0, .0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    
    UIImage * image = _imageView.image;
    if (image != nil) {
        CGFloat ratio   = CGRectGetWidth(_scrollView.bounds)/image.size.width;
        CGFloat height  = image.size.height*ratio;
        CGFloat yOrigin = 0.5*(CGRectGetHeight(_scrollView.bounds) - height);
        [_imageView  setFrame:CGRectMake(.0, yOrigin, CGRectGetWidth(_scrollView.bounds), height)];
    } else {
        [_imageView  setFrame:CGRectMake(.0, .0, CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds))];
    }
    
    CGSize loadingWheelSize = CGSizeMake(30.0, 30.0);
    [_loadingWheel setFrame:(CGRect){
        (CGRectGetWidth(self.bounds)-loadingWheelSize.width)*0.5,
        (CGRectGetHeight(self.bounds)-loadingWheelSize.height)*0.5,
        loadingWheelSize}];
}

- (void)prepareForReuse
{
    [_imageView setImage:nil];
    [_scrollView setZoomScale:1.0];
    [_loadingWheel setProgress:0.0];

    [self.imageRequestOperation setDownloadProgressBlock:nil];
    [self setImageRequestOperation:nil];
}

- (void)setImage:(UIImage *)image
{
    [_imageView setImage:image];
    [self setNeedsLayout];
}

- (void)setHideProgress:(BOOL)hideProgress
{
    _hideProgress = hideProgress;
    [_loadingWheel setHidden:_hideProgress];
}

- (void)setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation
{
    _imageRequestOperation = imageRequestOperation;

    [self.loadingWheel setProgress:0.0];
    
    __weak typeof(self) blockSelf = self;
    [_imageRequestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [blockSelf.loadingWheel setProgress:((float)totalBytesRead/(float)totalBytesExpectedToRead)];
    }];
}

- (PCLoadingWheel *)loadingWheel
{
    if (_loadingWheel == nil) {
        PCLoadingWheel * loadingWheel = [PCLoadingWheel new];
        [self addSubview:loadingWheel];
        _loadingWheel = loadingWheel;
    }
    return _loadingWheel;
}

#pragma mark 
#pragma mark

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGesture
{
    if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    else
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    [_imageView setCenter:CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                      scrollView.contentSize.height * 0.5 + offsetY)];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSLog(@"%s - %@", __func__,scrollView);
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    NSLog(@"%s", __func__);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"%s", __func__);
}

@end