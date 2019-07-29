//
//  WHFavouriteWineCell.m
//  WineHound
//
//  Created by Mark Turner on 10/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "WHFavouriteWineCell.h"
#import "WHWineMO.h"
#import "WHPhotographMO.h"

#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"
#import "NSAttributedString+HTML.h"

@interface WHFavouriteWineCell ()
@property (nonatomic,weak) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic,weak) UIImageView             * wineImageView;
@end
@implementation WHFavouriteWineCell

#pragma mark 
#pragma mark

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

#pragma mark

+ (CGFloat)cellHeight
{
    return 100.0;
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_wineTitleLabel       setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [_wineDescriptionLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    
    [_wineTitleLabel       setTextColor:[UIColor wh_grey]];
    [_wineDescriptionLabel setTextColor:[UIColor wh_grey]];

    UIButton * shareButton = [UIButton new];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton setBackgroundColor:[UIColor wh_grey]];
    [shareButton.titleLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];

    UIButton * deleteButton = [UIButton new];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
    [deleteButton.titleLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    
    [self setRightUtilityButtonStyle:SWUtilityButtonStyleVertical];
    [self setRightUtilityButtons:@[shareButton,deleteButton]];
    
    [_wineImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    //
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView insertSubview:activityIndicator aboveSubview:self.wineImageView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.wineImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.wineImageView
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

#pragma mark
#pragma mark

- (void)setWine:(WHWineMO *)wine
{
    _wine = wine;
    
    [_wineTitleLabel setText:_wine.name];

    NSRange range = {.0,.0};
    NSString * wineDescription = [wine.wineDescription copy];
    if (wineDescription.length > 0) {
        while ((range = [wineDescription rangeOfString:@"<[^>]+>\\s*" options:NSRegularExpressionSearch]).location != NSNotFound)
            wineDescription = [wineDescription stringByReplacingCharactersInRange:range withString:@""];
        wineDescription = [wineDescription stringByReplacingOccurrencesOfString:@"&amp;" withString:@" "];
        wineDescription = [wineDescription stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];

        NSRange stringRange = {0, MIN([wineDescription length], 100)};
        NSString * shortString = [wineDescription substringWithRange:stringRange];
        if ([wineDescription length] > stringRange.length) {
            shortString = [shortString stringByAppendingString:@"..."];
        }
        wineDescription = shortString;
    }
    [_wineDescriptionLabel setText:wineDescription];
    
    if (_wine.photographs.count > 0) {
        WHPhotographMO * photograph = [_wine.photographs firstObject];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageWineThumbURL]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        __weak typeof(self) blockSelf = self;
        [self.activityIndicatorView startAnimating];
        [self.wineImageView setImageWithURLRequest:request
                                  placeholderImage:[UIImage imageNamed:@"wine_placeholder"]
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               [blockSelf.activityIndicatorView stopAnimating];
                                               [blockSelf.wineImageView setImage:image];
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               [blockSelf.activityIndicatorView stopAnimating];
                                               [blockSelf.wineImageView setImage:[UIImage imageNamed:@"wine_placeholder"]];
                                           }];
    }
}

@end
