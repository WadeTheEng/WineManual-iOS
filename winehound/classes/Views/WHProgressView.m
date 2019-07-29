//
//  WHProgressView.m
//  WineHound
//
//  Created by Mark Turner on 31/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHProgressView.h"

static dispatch_once_t   _oncePredicate;
static WHProgressView *  _sharedProgressView;

@interface WHProgressView ()

@property (nonatomic, strong) UIControl *overlayView;

@property (assign, nonatomic) CGFloat animationProgress;

@property (assign, nonatomic) CGFloat innerRadiusRatio;
@property (assign, nonatomic) CGFloat outerRadiusRatio;

@end

@implementation WHProgressView

#pragma mark

+ (WHProgressView*)sharedView
{
    dispatch_once(&_oncePredicate, ^{
        WHProgressView * progressHUD = nil;
        progressHUD = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _sharedProgressView = progressHUD;
    });
    return _sharedProgressView;
}

- (UIControl *)overlayView
{
    if(_overlayView == nil) {
        UIControl * overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [overlayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
        [overlayView addTarget:self action:@selector(_overlayViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
        [overlayView setUserInteractionEnabled:NO];
        _overlayView = overlayView;
    }
    return _overlayView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setUserInteractionEnabled:NO];
        [self setOpaque:NO];
        
        self.progress = 0.;
        self.outerRadiusRatio = 0.7;
        self.innerRadiusRatio = 0.6;
        self.animationProgress = 0.;
    }
    return self;
}

#pragma mark

+ (void)show
{
    [[self sharedView] show];
}

- (void)show
{
    if(!self.overlayView.superview){
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.overlayView];
    }
    
    if(!self.superview) {
        [self.overlayView addSubview:self];
    }
}

+ (void)dismiss
{
    [[self sharedView].overlayView removeFromSuperview];
    [[self sharedView] removeFromSuperview];
}

#pragma mark


- (void)_overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent *)event
{
    NSLog(@"%s", __func__);
}


#pragma mark

+ (void)setProgress:(CGFloat)progress
{
    [[self sharedView] setProgress:progress];
}


- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress) {
        _progress = (progress < 0.) ? 0. : (progress > 1.) ? 1. : progress;
        if (progress > 0. && progress < 1.) {
            [self setNeedsDisplay];
        }
    }
}

- (CGFloat)innerRadius
{
    CGFloat width = 120.0;//CGRectGetWidth(self.squareView.bounds);
    CGFloat height = 120.0;//CGRectGetHeight(self.squareView.bounds);
    CGFloat radius = MIN(width, height) / 2. * self.innerRadiusRatio;
    return radius;
}

- (CGFloat)outerRadius
{
    CGFloat width = 120.0;//CGRectGetWidth(self.squareView.bounds);
    CGFloat height = 120.0;//CGRectGetHeight(self.squareView.bounds);
    CGFloat radius = MIN(width, height) / 2. * self.outerRadiusRatio;
    return radius;
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = 120.0;//CGRectGetWidth(self.squareView.bounds);
    CGFloat height = 120.0;//CGRectGetHeight(self.squareView.bounds);

    CGFloat outerRadius = [self outerRadius];
    CGFloat innerRadius = [self innerRadius];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGContextScaleCTM(context, 1., -1.);
    CGContextSetRGBFillColor(context, 0., 0., 0., 0.5);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.5].CGColor);

    CGMutablePathRef path0 = CGPathCreateMutable();
    CGPathMoveToPoint(path0, NULL, width / 2., 0.);
    CGPathAddLineToPoint(path0, NULL, width / 2., height / 2.);
    CGPathAddLineToPoint(path0, NULL, -width / 2., height / 2.);
    CGPathAddLineToPoint(path0, NULL, -width / 2., 0.);
    CGPathAddLineToPoint(path0, NULL, (cosf(M_PI) * outerRadius), 0.);
    CGPathAddArc(path0, NULL, 0., 0., outerRadius, M_PI, 0., 1.);
    CGPathAddLineToPoint(path0, NULL, width / 2., 0.);
    CGPathCloseSubpath(path0);
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGAffineTransform rotation = CGAffineTransformMakeScale(1., -1.);
    CGPathAddPath(path1, &rotation, path0);
    
    CGContextAddPath(context, path0);
    CGContextFillPath(context);
    CGPathRelease(path0);
    
    CGContextAddPath(context, path1);
    CGContextFillPath(context);
    CGPathRelease(path1);
    
    if (_progress < 1.) {
        CGFloat angle = 360. - (360. * _progress);
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        CGMutablePathRef path2 = CGPathCreateMutable();
        CGPathMoveToPoint(path2, &transform, innerRadius, 0.);
        CGPathAddArc(path2, &transform, 0., 0., innerRadius, 0., angle / 180. * M_PI, 0.);
        CGPathAddLineToPoint(path2, &transform, 0., 0.);
        CGPathAddLineToPoint(path2, &transform, innerRadius, 0.);
        CGContextAddPath(context, path2);
        CGContextFillPath(context);
        CGPathRelease(path2);
    }
}

@end
