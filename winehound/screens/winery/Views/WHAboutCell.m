//
//  WHAboutCell.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHAboutCell.h"
#import "WHWineryMO.h"
#import "WHRegionMO.h"
#import "WHEventMO.h"
#import "WHHelpers.h"

#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"
#import "NSAttributedString+HTML.h"

@interface WHAboutCell () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboutTextViewBottomConstraint;
@end

@implementation WHAboutCell

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

+ (CGFloat)cellHeightForAboutText:(NSString *)string truncated:(BOOL)truncated
{
    BOOL didTruncate = NO;

    NSAttributedString * attributedString = [NSAttributedString wh_attributedStringWithHTMLString:string];
    NSAttributedString * truncatedString = TruncatedAttributedString(attributedString, truncated ? 550.0 : [attributedString length], &didTruncate);

    CGRect requiredBoundingBox = [truncatedString boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                               context:nil];

    return ceilf(5.0 + requiredBoundingBox.size.height + (didTruncate ? 31.0 : 10.0));
}

+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event truncated:(BOOL)truncated
{
    CGFloat requiredHeight = .0f;
    requiredHeight += [self cellHeightForAboutText:event.eventDescription truncated:truncated];

    if (event.priceDescription.length > 0) {
        CGRect requiredPricingBoundingBox = [event.priceDescription boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                              attributes:@{NSFontAttributeName:[UIFont edmondsansRegularOfSize:14.0]}
                                                                                 context:nil];
        
        requiredHeight += 30.0;
        requiredHeight += ceilf(requiredPricingBoundingBox.size.height);
    }
    return requiredHeight;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.readMoreButton.titleLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [self.readMoreButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [self.readMoreButton addTarget:self action:@selector(_readMoreButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];

    [self.aboutTextView setTextContainerInset:UIEdgeInsetsMake(.0, -5, 0, 0)];
    [self.aboutTextView setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [self.aboutTextView setTextColor:[UIColor wh_grey]];
    [self.aboutTextView setScrollEnabled:NO];
    [self.aboutTextView setSelectable:YES];
    [self.aboutTextView setEditable:NO];
    [self.aboutTextView setDelegate:self];
    [self.aboutTextView setDataDetectorTypes:UIDataDetectorTypeAll];
}

- (void)setAboutText:(NSString *)string
{
    [self setAboutText:string truncated:YES];
}

- (void)setAboutText:(NSString *)string truncated:(BOOL)truncated
{
    BOOL didTruncate = NO;
    NSAttributedString * attributedString = [NSAttributedString wh_attributedStringWithHTMLString:string];
    NSAttributedString * truncatedString = TruncatedAttributedString(attributedString, truncated ? 550.0 : [attributedString length], &didTruncate);
    
    [self.readMoreButton setHidden:didTruncate == NO];
    [self.aboutTextViewBottomConstraint setConstant:didTruncate ? 31 : 10.0];
    [self.aboutTextView setAttributedText:truncatedString];
}

- (void)setEvent:(WHEventMO *)event
{
    [self setEvent:event truncated:YES];
}

- (void)setEvent:(WHEventMO *)event truncated:(BOOL)truncated
{
    _event = event;
    
    BOOL didTruncate = NO;
    NSMutableAttributedString * mutableAttributedString = [NSMutableAttributedString new];
    
    NSAttributedString * attributedDescriptionString = [NSAttributedString wh_attributedStringWithHTMLString:event.eventDescription];
    NSAttributedString * truncatedDescriptionString  = TruncatedAttributedString(attributedDescriptionString,
                                                                                 truncated ? 550.0 : [attributedDescriptionString length],
                                                                                 &didTruncate);
    [mutableAttributedString appendAttributedString:truncatedDescriptionString];
    
    if (event.priceDescription.length > 0) {
        [mutableAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [mutableAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:event.priceDescription
                                                                                        attributes:@{NSFontAttributeName:[UIFont edmondsansRegularOfSize:14.0],
                                                                                                     NSForegroundColorAttributeName:[UIColor wh_grey]}]];
        [mutableAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }

    [self.readMoreButton setHidden:didTruncate == NO];
    [self.aboutTextViewBottomConstraint setConstant:didTruncate ? 31 : 10.0];
    [self.aboutTextView setAttributedText:mutableAttributedString];
}

#pragma mark -

- (void)_readMoreButtonTouchedUpInside:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aboutCell:didTapReadMoreButton:)]) {
        [self.delegate aboutCell:self didTapReadMoreButton:button];
    }
}

#pragma mark
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"%s", __func__);
    if ([self.delegate respondsToSelector:@selector(aboutCell:didTapURL:)]) {
        [self.delegate aboutCell:self didTapURL:URL];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    NSLog(@"%s", __func__);
    return YES;
}

@end
