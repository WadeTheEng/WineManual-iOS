//
//  TableHeaderView.m
//  WineHound
//
//  Created by Mark Turner on 09/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "TableHeaderView.h"
#import "PCGradientView.h"

#import "UIFont+Edmondsans.h"

@implementation TableHeaderView {
    CGFloat _galleryContainerYOffset;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
        
        UICollectionViewFlowLayout * collectionViewLayout = [UICollectionViewFlowLayout new];
        [collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        [collectionView setBackgroundColor:[UIColor clearColor]];
        [collectionView registerClass:[WHGalleryCell class] forCellWithReuseIdentifier:[WHGalleryCell reuseIdentifier]];
        [collectionView setPagingEnabled:YES];
        [self addSubview:collectionView];
        [self setClipsToBounds:YES];
        
        PCGradientView * gradientView = [PCGradientView new];
        [gradientView setUserInteractionEnabled:NO];
        [gradientView setColors:@[[UIColor colorWithWhite:0.0 alpha:0.5],
                                  [UIColor colorWithWhite:0.0 alpha:0.0],
                                  [UIColor colorWithWhite:0.0 alpha:0.5]]];
        
        UILabel * titleLabel = [UILabel new];
        [titleLabel setText:@"Yering Station"];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont fontWithName:@"Edmondsans-Regular" size:18.0]];
        [titleLabel setNumberOfLines:0];
        [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [gradientView addSubview:titleLabel];
        [self addSubview:gradientView];
        
        UIButton * favouriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [favouriteButton setImage:[UIImage imageNamed:@"winery_favorite_icon"]          forState:UIControlStateNormal];
        [favouriteButton setImage:[UIImage imageNamed:@"winery_favorite_icon_selected"] forState:UIControlStateHighlighted];
        [favouriteButton setImage:[UIImage imageNamed:@"winery_favorite_icon_selected"] forState:UIControlStateSelected];
        [self addSubview:favouriteButton];
        
        UILabel * imageIndicatorLabel = [UILabel new];
        [imageIndicatorLabel setTextColor:[UIColor whiteColor]];
        [imageIndicatorLabel setFont:[UIFont fontWithName:@"Edmondsans-Regular" size:12.0]];
        [imageIndicatorLabel setTextAlignment:NSTextAlignmentRight];
        [gradientView addSubview:imageIndicatorLabel];
        
        UIButton * weatherIndicatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [weatherIndicatorButton setTitleEdgeInsets:(UIEdgeInsets){.left = 2.0, .right = -2.0}];
        [weatherIndicatorButton.titleLabel setFont:[UIFont edmondsansMediumOfSize:15.0]];
        [weatherIndicatorButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [weatherIndicatorButton setUserInteractionEnabled:NO];
        [self addSubview:weatherIndicatorButton];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:weatherIndicatorButton
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:+10.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:weatherIndicatorButton
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-12.0]];
        
        _galleryCollectionView = collectionView;
        _titleLabel            = titleLabel;
        _gradientView          = gradientView;
        _favouriteButton       = favouriteButton;
        _imageIndicatorLabel   = imageIndicatorLabel;
        _weatherInfoButton     = weatherIndicatorButton;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([[_galleryCollectionView superview] isEqual:self]) {
        
        CGFloat threshold = 0.5*CGRectGetHeight(self.bounds);
        CGFloat yScroll   = 0.0;
        if (_galleryContainerYOffset < 0) {
            yScroll = 0;
        } else {
            yScroll = MIN(1.0, _galleryContainerYOffset/CGRectGetHeight(self.bounds))*threshold;
        }
        
        if ([[_galleryCollectionView superview] isEqual:self]) {
            CGRect galleryContainerViewFrame = [_galleryCollectionView frame];
            galleryContainerViewFrame.origin.y = yScroll;
            galleryContainerViewFrame.size.width  = CGRectGetWidth(self.bounds);
            galleryContainerViewFrame.size.height = CGRectGetHeight(self.bounds);
            [_galleryCollectionView setFrame:galleryContainerViewFrame];
        }
    }

    CGRect titleLabeLrect = [_titleLabel textRectForBounds:(CGRect){.0,.0,{self.bounds.size.width - 50.0,self.bounds.size.height}} limitedToNumberOfLines:0];
    [_titleLabel            setFrame:(CGRect){10.0, CGRectGetHeight(self.bounds) - (titleLabeLrect.size.height + 5.0), titleLabeLrect.size}];
    [_gradientView          setFrame:(CGRect){.0,.0,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)}];
    [_favouriteButton       setFrame:(CGRect){CGRectGetWidth(self.bounds) - 45.0,CGRectGetHeight(self.bounds) - 39.0,44.0,44.0}];

    CGSize imageIndicatorSize = {50.0,18.0};
    if (self.imageIndicatorPosition == 0) {
        [_imageIndicatorLabel setFrame:(CGRect){CGRectGetWidth(self.bounds) - 55.0,4,imageIndicatorSize}];
    } else {
        [_imageIndicatorLabel setFrame:(CGRect){4,4,{50.0,18.0}}];
    }
}

- (void)setOffset:(CGFloat)yOffset
{
    _galleryContainerYOffset = yOffset;
    [self setNeedsLayout];
}

- (void)setPageNumber:(NSInteger)pageNumber
{
    NSInteger numberOfItems = [_galleryCollectionView numberOfItemsInSection:0];
    [self.imageIndicatorLabel setText:[NSString stringWithFormat:@"%li of %li",(long)pageNumber,(long)numberOfItems]];
    [self.imageIndicatorLabel setHidden:!(numberOfItems > 1)];
}

- (void)reload
{
    [self.galleryCollectionView reloadData];
    [self setPageNumber:1];
}

- (void)setImageIndicatorPosition:(NSInteger)imageIndicatorPosition
{
    _imageIndicatorPosition = imageIndicatorPosition;
    if (_imageIndicatorPosition == 0) {
        [_imageIndicatorLabel setTextAlignment:NSTextAlignmentRight];
    } else {
        [_imageIndicatorLabel setTextAlignment:NSTextAlignmentLeft];
    }
}

@end

////

@interface WHGalleryCell ()
@property (nonatomic,weak) UIActivityIndicatorView * activityIndicator;
@end

@implementation WHGalleryCell

+ (NSString *)reuseIdentifier
{
    return @"WHGalleryCell";
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView * imageView = [UIImageView new];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:imageView];
        
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator setHidesWhenStopped:YES];
        [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.contentView insertSubview:activityIndicator aboveSubview:imageView];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:imageView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:imageView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]];
        _activityIndicator = activityIndicator;
        _imageView         = imageView;
    }
    return _imageView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setFrame:(CGRect){.0,.0,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)}];
}

- (void)downloadImage:(NSURL *)imageURL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self.imageView setImage:nil];
    [_activityIndicator startAnimating];
    
    __weak typeof(self) blockSelf = self;
    [self.imageView setImageWithURLRequest:request
                            placeholderImage:nil
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         [blockSelf.activityIndicator stopAnimating];
                                         [blockSelf.imageView setImage:image];
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                         [blockSelf.activityIndicator stopAnimating];
                                     }];
}

@end
