//
//  WHRestaurantCell.m
//  WineHound
//
//  Created by Mark Turner on 20/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHRestaurantCell.h"
#import "WHRestaurantMO+Additions.h"

#import "UIButton+WineHoundButtons.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

#import "NSAttributedString+HTML.h"
#import "NSAttributedString+OpenHours.h"

@interface WHRestaurantCell () <UITextViewDelegate>
{
    __weak IBOutlet UITextView *_descriptionTextView;
    __weak IBOutlet UIButton   *_viewMenuButton;
}
@end

@implementation WHRestaurantCell


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

+ (CGFloat)cellHeightForRestaurantObject:(WHRestaurantMO *)restaurant
{
    NSMutableAttributedString * descriptionMutableString = [[NSMutableAttributedString alloc] init];
    [descriptionMutableString appendAttributedString:[NSAttributedString wh_attributedStringWithHTMLString:restaurant.restaurantDescription]];
    [descriptionMutableString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    [descriptionMutableString appendAttributedString:[NSAttributedString openHoursAttributedStringWithObject:restaurant]];
    CGRect requiredRect = [descriptionMutableString boundingRectWithSize:(CGSize){300.0, CGFLOAT_MAX}
                                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                 context:nil];

    CGFloat cellHeight = ceilf(10.0 + requiredRect.size.height + 50.0);
    //if (restaurant.menuPdf.length > 0)
    cellHeight += 44.0;

    return cellHeight < 114.0 ? 115.0 : cellHeight;
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_descriptionTextView setTextContainerInset:UIEdgeInsetsMake(.0, -5, 0, 0)];
    [_descriptionTextView setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [_descriptionTextView setTextColor:[UIColor wh_grey]];
    [_descriptionTextView setScrollEnabled:NO];
    [_descriptionTextView setSelectable:YES];
    [_descriptionTextView setEditable:NO];
    [_descriptionTextView setDelegate:self];
    [_descriptionTextView setDataDetectorTypes:UIDataDetectorTypeAll];
    
    [_viewMenuButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
    [_viewMenuButton setBackgroundColor:[UIColor whiteColor]];
    [_viewMenuButton addTarget:self action:@selector(_viewMenuButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_viewMenuButton setImage:[UIImage imageNamed:@"restaurant_menu_icon"] forState:UIControlStateNormal];
}

- (void)setRestaurant:(WHRestaurantMO *)restaurant
{
    _restaurant = restaurant;
    
    if (_restaurant != nil) {
        NSMutableAttributedString * descriptionMutableString = [[NSMutableAttributedString alloc] init];
        [descriptionMutableString appendAttributedString:[NSAttributedString wh_attributedStringWithHTMLString:restaurant.restaurantDescription]];
        [descriptionMutableString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        [descriptionMutableString appendAttributedString:[NSAttributedString openHoursAttributedStringWithObject:restaurant]];
        [_descriptionTextView setAttributedText:descriptionMutableString];
    } else {
        [_descriptionTextView setText:nil];
    }
    
    [_viewMenuButton setHidden:!(_restaurant.menuPdf.length>0)];
}

- (void)_viewMenuButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(restaurantCell:didTapViewMenuButton:)]) {
        [self.delegate restaurantCell:self didTapViewMenuButton:button];
    }
}

#pragma mark
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"%s", __func__);
    if ([self.delegate respondsToSelector:@selector(restaurantCell:didTapURL:)]) {
        [self.delegate restaurantCell:self didTapURL:URL];
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
