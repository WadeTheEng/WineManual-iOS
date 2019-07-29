//
//  WHEventCell.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "WHEventCell.h"
#import "WHEventMO+Additions.h"
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

#import "WHPhotographMO+Mapping.h"

static NSDateFormatter __weak * _publicDateFormatter;

@implementation WHEventCell {
    __weak UIActivityIndicatorView * _activityIndicator;

    NSDateFormatter * _dateFormatter;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.titleLabel  setFont:[UIFont edmondsansBoldOfSize:12.0]];
    [self.detailLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [self.locationLabel setFont:[UIFont edmondsansRegularOfSize:11.0]];
    
    [self.titleLabel setTextColor:[UIColor wh_burgundy]];
    
    [self.imageView setClipsToBounds:YES];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.titleLabel    setAdjustsFontSizeToFitWidth:YES];
    [self.titleLabel    setMinimumScaleFactor:0.5];
    [self.titleLabel    setNumberOfLines:2];
    [self.detailLabel   setAdjustsFontSizeToFitWidth:YES];
    [self.detailLabel   setMinimumScaleFactor:0.5];
    [self.locationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.locationLabel setMinimumScaleFactor:0.5];
    [self.locationLabel setNumberOfLines:2];
    
    [self setBackgroundView:[UIView new]];
    [self setSelectedBackgroundView:[UIView new]];
    
    [self.backgroundView         setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:230.0/255.0 blue:235.0/255.0 alpha:1.0]];
    [self.selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:142.0/255.0 green:130.0/255.0 blue:135.0/255.0 alpha:1.0]];
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView insertSubview:activityIndicator aboveSubview:self.imageView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.imageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.imageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    _activityIndicator = activityIndicator;
}

- (void)dealloc
{
    _dateFormatter = nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setEvent:nil];
}

- (void)setEvent:(WHEventMO *)event
{
    _event = event;
    
    [self.titleLabel  setText:_event.name];
    [self.detailLabel setText:_event.shortDatePeriodString];

    [self.locationLabel setText:_event.locationName];
    [self.locationLabel setHidden:_event.parentEventId == nil];
    
    if (_event == nil) {
        [self.imageView setImage:nil];
    } else {
        WHPhotographMO * firstPhotograph = [_event.photographs firstObject];
        if (firstPhotograph.imageThumbURL == nil) {
            [self.imageView setImage:[UIImage imageNamed:@"winery_event_cells_placeholder"]];
        } else {
            __weak typeof(self) blockSelf = self;
            
            NSMutableURLRequest * imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:firstPhotograph.imageThumbURL]];
            [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            [_activityIndicator startAnimating];
            [self.imageView setImage:nil];
            [self.imageView setImageWithURLRequest:imageRequest
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               if (image != nil && request == nil) {
                                                   //Returned with cached image & should already be decoded.
                                                   [_activityIndicator stopAnimating];
                                                   [blockSelf.imageView setImage:image];
                                               } else if ([imageRequest isEqual:request]) {
                                                   [_activityIndicator stopAnimating];
                                                   [blockSelf.imageView setImage:image];
                                               }
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               if ([imageRequest isEqual:request]) {
                                                   [_activityIndicator stopAnimating];
                                                   [blockSelf.imageView setImage:[UIImage imageNamed:@"winery_event_cells_placeholder"]];
                                               }
                                           }];
        }
    }
}

/*
- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        NSDateFormatter * df = _publicDateFormatter;
        if (_publicDateFormatter == nil) {
            df = [NSDateFormatter new];
            [df setFormatterBehavior:NSDateFormatterBehavior10_4];
            [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"]];
            [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [df setDateFormat:@"d MMM"];

            _publicDateFormatter = df;
        }
        _dateFormatter = df;
    }
    return _dateFormatter;
}
*/

@end
