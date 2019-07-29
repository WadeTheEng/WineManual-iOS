//
//  WHPhotographCell.m
//  WineHound
//
//  Created by Mark Turner on 28/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

@interface WHPhotographCellProgressView : UIView
@property (assign, nonatomic) CGFloat progress;
@end

@implementation WHPhotographCellProgressView

- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress) {
        _progress = (progress < 0.) ? 0. : (progress > 1.) ? 1. : progress;
        if (progress > 0. && progress < 1.) {
            [self setNeedsDisplay];
        }
    }
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width  = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    CGFloat outerRadius = MIN(width, height) / 2. * 0.7;;
    CGFloat innerRadius = MIN(width, height) / 2. * 0.6;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGContextScaleCTM(context, 1., -1.);
    CGContextSetRGBFillColor(context, 0., 0., 0., 0.5);
    
    CGMutablePathRef path0 = CGPathCreateMutable();
    CGPathAddArc(path0, NULL, 0., 0., outerRadius, M_PI, 0., YES);
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
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);

        CGFloat angle = 360 - (360. * _progress);
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);

        CGMutablePathRef path2 = CGPathCreateMutable();
        CGPathMoveToPoint(path2, &transform, innerRadius, 0.);

        CGPathAddArc(path2, &transform, 0., 0., innerRadius, 0., angle / 180. * M_PI, YES);
        CGPathAddLineToPoint(path2, &transform, 0., 0.);
        CGPathAddLineToPoint(path2, &transform, innerRadius, 0.);

        CGContextAddPath(context, path2);
        CGContextFillPath(context);
        CGPathRelease(path2);
    }
}


@end


#import "WHPhotographCell.h"
#import "WHPhotographMO.h"

@interface WHPhotographCell ()
{
    __weak IBOutlet NSLayoutConstraint *_topLayoutConstraint;
    __weak IBOutlet NSLayoutConstraint *_bottomLayoutConstraint;
    __weak IBOutlet NSLayoutConstraint *_leftLayoutConstraint;
    __weak IBOutlet NSLayoutConstraint *_rightLayoutConstraint;

    __weak IBOutlet UIActivityIndicatorView * _activityIndicatorView;
}
@property (weak, nonatomic) IBOutlet UIImageView * panoramaImageView;
@property (weak, nonatomic) IBOutlet UIControl   * overlayControlView;
@property (weak, nonatomic) WHPhotographCellProgressView * progressView;
@end

@implementation WHPhotographCell
@synthesize activityIndicatorView = _activityIndicatorView;

#pragma mark

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:[self reuseIdentifier] bundle:[NSBundle mainBundle]];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    [_topLayoutConstraint    setConstant:contentInsets.top];
    [_bottomLayoutConstraint setConstant:contentInsets.bottom];
    [_leftLayoutConstraint   setConstant:contentInsets.left];
    [_rightLayoutConstraint  setConstant:contentInsets.right];
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.activityIndicatorView setHidesWhenStopped:YES];
    
    [self.overlayControlView addTarget:self action:@selector(overlayControlViewTouchDown:)      forControlEvents:UIControlEventTouchDown];
    [self.overlayControlView addTarget:self action:@selector(overlayControlViewTouchUpInside:)  forControlEvents:UIControlEventTouchUpInside];
    [self.overlayControlView addTarget:self action:@selector(overlayControlViewTouchUp:)        forControlEvents:UIControlEventTouchUpOutside];
    [self.overlayControlView addTarget:self action:@selector(overlayControlViewTouchUp:)        forControlEvents:UIControlEventTouchCancel];
    [self.overlayControlView setBackgroundColor:[UIColor clearColor]];

    [self.panoramaImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.panoramaImageView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.2]];
    [self.panoramaImageView setClipsToBounds:YES];
    
    WHPhotographCellProgressView * progressView = [WHPhotographCellProgressView new];
    [progressView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:progressView];

    [progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [progressView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pv(==60)]" options:0 metrics:nil views:@{@"pv":progressView}]];
    [progressView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pv(==60)]" options:0 metrics:nil views:@{@"pv":progressView}]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:progressView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:progressView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    [progressView setHidden:YES];

    [self setDownloadProgress:0.4];
    
    _progressView = progressView;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setPhotograph:nil];
}

- (void)setDownloadProgress:(CGFloat)downloadProgress
{
    [self.progressView setHidden:!(downloadProgress>0.0)];
    [self.progressView setProgress:downloadProgress];
}

- (void)setPhotograph:(WHPhotographMO *)photograph
{
    _photograph = photograph;
    
    if (photograph != nil) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageThumbURL]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        __weak typeof (self) weakSelf = self;
        
        [weakSelf.activityIndicatorView startAnimating];
        [self.panoramaImageView setImageWithURLRequest:request
                                      placeholderImage:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   [weakSelf.activityIndicatorView stopAnimating];
                                                   [weakSelf.panoramaImageView setImage:image];
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   [weakSelf.activityIndicatorView stopAnimating];
                                                   [weakSelf.panoramaImageView setImage:nil];
                                               }];
    }
}

#pragma mark 
#pragma mark Actions

- (void)overlayControlViewTouchDown:(UIControl *)control
{
    [self.overlayControlView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.4]];
}

- (void)overlayControlViewTouchUpInside:(UIControl *)control
{
    [self.overlayControlView setBackgroundColor:[UIColor clearColor]];
    
    if ([self.delegate respondsToSelector:@selector(photographCellDidTouchUpInside:)]) {
        [self.delegate photographCellDidTouchUpInside:self];
    }
}

- (void)overlayControlViewTouchUp:(UIControl *)control
{
    [self.overlayControlView setBackgroundColor:[UIColor clearColor]];
}

@end
