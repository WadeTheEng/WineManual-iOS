//
//  WHWineDescriptionCell.m
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWineDescriptionCell.h"
#import "WHWineMO+Mapping.h"
#import "WHFavouriteMO+Additions.h"

#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"
#import "NSAttributedString+HTML.h"
#import "WHHelpers.h"

@interface WHWineDescriptionCell () <UITextViewDelegate>
@end

@implementation WHWineDescriptionCell

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_wineTitleLabel setFont:[UIFont edmondsansBoldOfSize:15.0]];
    [_wineTitleLabel setTextColor:[UIColor wh_burgundy]];
    
    [_wineDescriptionTextView setFont:[UIFont edmondsansRegularOfSize:13.0]];
    [_wineDescriptionTextView setTextColor:[UIColor wh_grey]];
    [_wineDescriptionTextView setTextContainerInset:UIEdgeInsetsMake(.0, -5, 0, 0)];
    [_wineDescriptionTextView setScrollEnabled:NO];
    [_wineDescriptionTextView setSelectable:YES];
    [_wineDescriptionTextView setEditable:NO];
    [_wineDescriptionTextView setDelegate:self];
    
    [_favouriteButton addTarget:self
                         action:@selector(_favouriteButtonTouchedUpInside:)
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

+ (CGFloat)cellHeightForWineObject:(WHWineMO *)wine
{
    if (wine == nil) {
        return 50.0;
    }
    
    const CGFloat kTopHeight = 8.0;
    const CGFloat kSpacing   = 10.0;
    const CGFloat kPadding   = 10.0;
    
    CGRect requiredTitleBoundingBox = [wine.name boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:15.0]}
                                                              context:nil];
    
    NSAttributedString * attributedString = [NSAttributedString wh_attributedStringWithHTMLString:wine.wineDescription];
    CGRect requiredDescriptionBoundingBox = [attributedString boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             context:nil];
    
    return ceilf((kTopHeight+kSpacing+kPadding)+requiredTitleBoundingBox.size.height + requiredDescriptionBoundingBox.size.height);
}

#pragma mark

- (void)setWine:(WHWineMO *)wine
{
    _wine = wine;

    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHWineMO entityName] identifier:self.wine.wineId];

    [_wineTitleLabel       setText:_wine.name];
    [_favouriteButton setSelected:favourite!=nil];
    
    if (_wine.wineDescription.length > 0) {
        NSAttributedString * attributedString = [NSAttributedString wh_attributedStringWithHTMLString:_wine.wineDescription];
        [_wineDescriptionTextView setAttributedText:attributedString];
    } else {
        [_wineDescriptionTextView setText:nil];
    }
}

#pragma mark
#pragma mark Actions

- (void)_favouriteButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);

    if (self.delegate && [self.delegate respondsToSelector:@selector(wineDescriptionCell:didTapFavouriteButton:)]) {
        [self.delegate wineDescriptionCell:self didTapFavouriteButton:button];
    }
}

#pragma mark
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([self.delegate respondsToSelector:@selector(wineDescriptionCell:didTapURL:)]) {
        [self.delegate wineDescriptionCell:self didTapURL:URL];
        return NO;
    } else {
        return YES;
    }
}

@end
