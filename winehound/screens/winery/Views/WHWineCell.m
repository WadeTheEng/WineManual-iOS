//
//  WHWineCell.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"
#import "NSAttributedString+HTML.h"
#import "WHHelpers.h"

#import "WHWineCell.h"
#import "WHWineMO+Mapping.h"
#import "WHWineryMO+Additions.h"
#import "WHPhotographMO.h"
#import "WHFavouriteMO+Additions.h"

@implementation WHWineCell

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

#pragma mark

+ (CGFloat)cellHeight
{
    return 170.0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.titleLabel       setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [self.descriptionLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];

    [self.titleLabel       setTextColor:[UIColor wh_grey]];
    [self.descriptionLabel setTextColor:[UIColor wh_grey]];
    [self.descriptionLabel setLineBreakMode:NSLineBreakByTruncatingTail];

    [self.bottleImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.bottleImageView setBackgroundColor:[UIColor clearColor]];
    
    [self.favouriteButton addTarget:self
                             action:@selector(_favouriteWineButtonTouchedUpInside:)
                   forControlEvents:UIControlEventTouchUpInside];

    //

    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView insertSubview:activityIndicator aboveSubview:self.bottleImageView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.bottleImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.bottleImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    [self setActivityIndicatorView:activityIndicator];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setWine:nil];
}

- (void)setWine:(WHWineMO *)wine
{
    _wine = wine;
    /*
    NSRange stringRange = {0, MIN([wine.wineDescription length], 160)};
    NSString * shortString = [wine.wineDescription substringWithRange:stringRange];
    if ([wine.wineDescription length] > stringRange.length) {
        shortString = [shortString stringByAppendingString:@"..."];
    }
     */

    NSRange range = {.0,.0};
    NSString * wineDescription = [wine.wineDescription copy];
    if (wineDescription.length > 0) {
        while ((range = [wineDescription rangeOfString:@"<[^>]+>\\s*" options:NSRegularExpressionSearch]).location != NSNotFound)
            wineDescription = [wineDescription stringByReplacingCharactersInRange:range withString:@""];
        wineDescription = [wineDescription stringByReplacingOccurrencesOfString:@"&amp;" withString:@" "];
        wineDescription = [wineDescription stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        wineDescription = TruncatedString(wineDescription, 200);
    }
    
    [self.titleLabel setText:wine.name];
    [self.descriptionLabel setText:wineDescription];
    
    WHWineryMO * winery = [wine.wineries anyObject]; //Wines can only belong to one Winery
    [self.favouriteButton setHidden:(winery.tierValue < WHWineryTierBronze)];

    if (winery.tierValue >= WHWineryTierBronze) {
        WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHWineMO entityName]
                                                                identifier:wine.wineId];
        [_favouriteButton setSelected:favourite!=nil];
    }
    
    if (_wine.photographs.count > 0) {
        WHPhotographMO * photograph = [_wine.photographs firstObject];
        
        NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageWineThumbURL]];
        [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        __weak typeof(self) blockSelf = self;
        [self.activityIndicatorView startAnimating];
        [self.bottleImageView setImageWithURLRequest:imageRequest
                                    placeholderImage:[UIImage imageNamed:@"wine_placeholder"]
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 if (image != nil && request == nil) {
                                                     //Returned with cached image & should already be decoded.
                                                     [blockSelf.activityIndicatorView stopAnimating];
                                                     [blockSelf.bottleImageView setImage:image];
                                                 } else {
                                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                         UIGraphicsBeginImageContext(CGSizeMake(1,1));
                                                         CGContextRef context = UIGraphicsGetCurrentContext();
                                                         CGContextDrawImage(context, (CGRect){0,0,1,1}, [image CGImage]);
                                                         UIGraphicsEndImageContext();
                                                         if ([imageRequest isEqual:request]) {
                                                             dispatch_sync(dispatch_get_main_queue(), ^{
                                                                 [blockSelf.activityIndicatorView stopAnimating];
                                                                 [blockSelf.bottleImageView setImage:image];
                                                             });
                                                         }
                                                     });
                                                 }
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 if ([imageRequest isEqual:request]) {
                                                     [blockSelf.activityIndicatorView stopAnimating];
                                                     [blockSelf.bottleImageView setImage:[UIImage imageNamed:@"wine_placeholder"]];
                                                 }
                                             }];
    } else {
        [self.bottleImageView setImage:[UIImage imageNamed:@"wine_placeholder"]];
    }
}

#pragma mark Actions

- (void)_favouriteWineButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(wineCell:didTapFavouriteButton:)]) {
        [self.delegate wineCell:self didTapFavouriteButton:button];
    }
}

@end
