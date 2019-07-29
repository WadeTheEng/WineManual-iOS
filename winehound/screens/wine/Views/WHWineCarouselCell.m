//
//  WHWineCarouselCell.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <iCarousel/iCarousel.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "NSCache+UIImage.h"

#import "WHWineCarouselCell.h"
#import "WHWineMO.h"
#import "WHPhotographMO.h"

@interface WHWineCarouselCell () <iCarouselDataSource,iCarouselDelegate>

@end

@implementation WHWineCarouselCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.carouselView setCurrentItemIndex:0];
    [self.carouselView setType:iCarouselTypeCustom];
    [self.carouselView setPerspective:-1.0f/150.0f];
}

- (void)reload
{
    [self.carouselView setDelegate:self];
    [self.carouselView setDataSource:self];
    [self.carouselView reloadData];
    [self.carouselView setScrollOffset:0.0];
}

- (void)scrollToWineAtIndex:(NSInteger)index animated:(BOOL)animated
{
    [self.carouselView scrollToItemAtIndex:index animated:animated];
}

- (void)_informDelegate
{
    if ([self.delegate respondsToSelector:@selector(cell:currentWineIndexDidChange:)]) {
        [self.delegate cell:self currentWineIndexDidChange:self.carouselView.currentItemIndex];
    }
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (CGFloat)cellHeight
{
    return 230.0;
}

#pragma mark
#pragma mark iCarouselDataSource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if ([self.dataSource respondsToSelector:@selector(numberOfWineObjectsInCell:)]) {
        return [self.dataSource numberOfWineObjectsInCell:self];
    }
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    WHWineMO * wine = nil;
    if ([self.dataSource respondsToSelector:@selector(cell:wineObjectAtIndex:)]) {
        wine = [self.dataSource cell:self wineObjectAtIndex:index];
    }
    
    UIImageView * wineBottleImageView = [UIImageView new];
    [wineBottleImageView setContentMode:UIViewContentModeScaleAspectFit];
    [wineBottleImageView setFrame:(CGRect){.size = {CGRectGetHeight(carousel.bounds) / 2.75, CGRectGetHeight(carousel.bounds)}}];
    [wineBottleImageView setBackgroundColor:[UIColor clearColor]];

    UIView * wineBottleView = [UIView new];
    [wineBottleView setFrame:CGRectMake(0, 0, CGRectGetWidth(wineBottleImageView.frame), CGRectGetHeight(wineBottleImageView.frame))];
    [wineBottleView addSubview:wineBottleImageView];

    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [wineBottleView insertSubview:activityIndicator aboveSubview:wineBottleImageView];
    [wineBottleView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:wineBottleImageView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0]];
    [wineBottleView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:wineBottleImageView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0]];
    
    if (wine.photographs.count <= 0) {
        [wineBottleImageView setImage:[UIImage imageNamed:@"wine_placeholder"]];
    } else {
        WHPhotographMO * photograph = [wine.photographs firstObject];

        NSMutableURLRequest * thumbRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageWineThumbURL]];
        UIImage * imageThumb = [[UIImageView af_sharedImageCache] cachedImageForRequest:thumbRequest];
        
        NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageThumbURL]];
        [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        __weak UIImageView             * weakWBIV = wineBottleImageView;
        __weak UIActivityIndicatorView * weakAI   = activityIndicator;
        
        [activityIndicator startAnimating];
        
        [wineBottleImageView setImageWithURLRequest:imageRequest
                                   placeholderImage:imageThumb!=nil?imageThumb:[UIImage imageNamed:@"wine_placeholder"]
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                if (image != nil && request == nil) {
                                                    //Returned with cached image & should already be decoded.
                                                    [weakAI stopAnimating];
                                                    [weakWBIV setImage:image];
                                                } else {
                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                        UIGraphicsBeginImageContext(CGSizeMake(1,1));
                                                        CGContextRef context = UIGraphicsGetCurrentContext();
                                                        CGContextDrawImage(context, (CGRect){0,0,1,1}, [image CGImage]);
                                                        UIGraphicsEndImageContext();
                                                        if ([imageRequest isEqual:request]) {
                                                            dispatch_sync(dispatch_get_main_queue(), ^{
                                                                [weakAI stopAnimating];
                                                                [weakWBIV setImage:image];
                                                            });
                                                        }
                                                    });
                                                }
                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                if ([imageRequest isEqual:request]) {
                                                    [weakAI stopAnimating];
                                                    if (imageThumb == nil) {
                                                        [weakWBIV setImage:[UIImage imageNamed:@"wine_placeholder"]];
                                                    } else {
                                                        [weakWBIV setImage:imageThumb];
                                                    }
                                                }
                                            }];
    }
    return wineBottleView;
}

#pragma mark iCarouselDelegate

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    CGFloat count   = carousel.numberOfItems + carousel.numberOfPlaceholders;
    CGFloat spacing = 1.2;
    CGFloat arc     = M_PI * 2.0f;
    CGFloat radius  = fmaxf(carousel.itemWidth * spacing / 2.0f, carousel.itemWidth * spacing / 2.0f / tanf(arc/2.0f/count));
    CGFloat angle   = offset / count * arc;

    CGFloat z = MAX(-50,(radius * cos(angle) - radius));
    
    return CATransform3DTranslate(transform, offset * carousel.itemWidth * spacing, 0.0f, z);
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate;
{
    if (!decelerate) {
        [self _informDelegate];
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
    [self _informDelegate];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    [self _informDelegate];
}

@end
