//
//  WHWineBuyShareButtonsCell.m
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWineBuyShareCell.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "UIButton+WineHoundButtons.h"

@implementation WHWineBuyShareCell {
    __weak IBOutlet NSLayoutConstraint *_shareWineLeadingConstraint;
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_buyOnlineButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
    [_shareWineButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
    
    [_buyOnlineButton addTarget:self
                         action:@selector(_buyOnlineButtonTouchedUpInside:)
               forControlEvents:UIControlEventTouchUpInside];
    [_shareWineButton addTarget:self
                         action:@selector(_shareWineButtonTouchedUpInside:)
               forControlEvents:UIControlEventTouchUpInside];
    
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
    return 48.0;
}

#pragma mark

- (void)setBuyOnlineVisible:(BOOL)buyOnlineVisible
{
    [_shareWineLeadingConstraint setConstant:buyOnlineVisible?170:10.0];
    [_buyOnlineButton setHidden:!buyOnlineVisible];
}

#pragma mark
#pragma mark Actions

- (void)_buyOnlineButtonTouchedUpInside:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wineBuyShareCell:didSelectBuyOnlineButton:)]) {
        [self.delegate wineBuyShareCell:self didSelectBuyOnlineButton:button];
    }
}

- (void)_shareWineButtonTouchedUpInside:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wineBuyShareCell:didSelectShareButton:)]) {
        [self.delegate wineBuyShareCell:self didSelectShareButton:button];
    }
}

@end
