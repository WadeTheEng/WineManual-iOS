//
//  WHWinerySectionHeaderView.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWinerySectionHeaderView.h"

#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

@implementation WHWinerySectionHeaderView

#pragma mark - 

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    [self setBackgroundView:[UIView new]];
    [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];

    UIImageView * sectionImageView = [UIImageView new];
    [sectionImageView setContentMode:UIViewContentModeCenter];
    [self.contentView addSubview:sectionImageView];

    UIImageView * sectionAccesoryView = [UIImageView new];
    [sectionAccesoryView setContentMode:UIViewContentModeCenter];
    [sectionAccesoryView setImage:[UIImage imageNamed:@"winery_section_accessory"]];
    [self.contentView addSubview:sectionAccesoryView];

    UILabel * sectionTitleLabel = [UILabel new];
    [sectionTitleLabel setFont:[UIFont edmondsansMediumOfSize:18]];
    [sectionTitleLabel setTextColor:[UIColor wh_burgundy]];
    [self.contentView addSubview:sectionTitleLabel];

    UILabel * sectionDetailLabel = [UILabel new];
    [sectionDetailLabel setFont:[UIFont edmondsansRegularOfSize:16.0]];
    [sectionDetailLabel setTextColor:[UIColor wh_grey]];
    [sectionDetailLabel setTextAlignment:NSTextAlignmentRight];
    [sectionDetailLabel setNumberOfLines:0];
    [sectionDetailLabel setMinimumScaleFactor:0.2];
    [sectionDetailLabel setAdjustsFontSizeToFitWidth:YES];
    [self.contentView addSubview:sectionDetailLabel];

    UITapGestureRecognizer * tapGesture = [UITapGestureRecognizer new];
    [tapGesture addTarget:self action:@selector(_tapGesture:)];
    [self addGestureRecognizer:tapGesture];

    _sectionImageView    = sectionImageView;
    _sectionAccesoryView = sectionAccesoryView;
    _sectionTitleLabel   = sectionTitleLabel;
    _sectionDetailLabel  = sectionDetailLabel;
    _titleLabelLeftInset = 45.0;

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /*
     Deliberately not using auto layout constraints in this class.
     */
    
    CGRect textRect = [_sectionTitleLabel textRectForBounds:self.bounds limitedToNumberOfLines:0];
    CGFloat maxDetailX = self.titleLabelLeftInset + textRect.size.width;
    if (maxDetailX < 100.0) {
        maxDetailX = 100.0;
    }
    CGFloat detailWidth = (CGRectGetWidth(self.contentView.bounds) - 40.0) - maxDetailX;
    
    [_sectionTitleLabel   setFrame:(CGRect){self.titleLabelLeftInset,0,textRect.size.width,CGRectGetHeight(self.contentView.bounds)}];
    [_sectionDetailLabel  setFrame:(CGRect){maxDetailX,0,detailWidth,CGRectGetHeight(self.contentView.bounds)}];
    [_sectionImageView    setFrame:(CGRect){10,self.contentView.center.y - 15.0,30,30}];
    [_sectionAccesoryView setFrame:(CGRect){CGRectGetWidth(self.contentView.bounds)-30.0,self.contentView.center.y - 10.0,20,20}];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.sectionTitleLabel   setText:nil];
    [self.sectionDetailLabel  setText:nil];
    [self.sectionImageView    setImage:nil];
    [self.sectionAccesoryView setTransform:CGAffineTransformIdentity];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (CGFloat)viewHeight
{
    return 55.0;
}

#pragma mark - 

- (void)setExpanded:(BOOL)expanded animationDuration:(NSTimeInterval)animationDuration
{
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.sectionAccesoryView setTransform:CGAffineTransformMakeRotation(expanded?(M_PI-0.01):0)];
    } completion:nil];
}

#pragma mark - Actions

- (void)_tapGesture:(UITapGestureRecognizer *)tapGesture
{
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(didSelectTableViewHeaderSection:)]) {
        [self.delegate didSelectTableViewHeaderSection:self];
    }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.contentView setBackgroundColor:[[UIColor wh_grey] colorWithAlphaComponent:0.2]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
}

@end
