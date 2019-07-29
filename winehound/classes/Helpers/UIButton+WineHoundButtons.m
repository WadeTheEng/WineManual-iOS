//
//  UIButton+WineHoundButtons.m
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "UIButton+WineHoundButtons.h"
#import "UIImage+Resizable.h"
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

UIImage * imageFromCALayer(CALayer * layer) {
    UIGraphicsBeginImageContextWithOptions([layer frame].size, NO, [UIScreen mainScreen].scale);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

@implementation UIButton (WineHoundButtons)

- (void)setupBurgundyButtonWithBorderWidth:(CGFloat)border cornerRadius:(CGFloat)cornerRadius
{
    [self setupButtonWithColour:[UIColor wh_burgundy] borderWidth:border cornerRadius:cornerRadius];
}

- (void)setupButtonWithColour:(UIColor *)color borderWidth:(CGFloat)border cornerRadius:(CGFloat)cornerRadius
{
    CALayer * backgroundImageLayer = [CALayer new];
    [backgroundImageLayer setFrame:CGRectMake(.0, .0, 10.0, 10.0)];
    [backgroundImageLayer setBackgroundColor:[UIColor whiteColor].CGColor];
    [backgroundImageLayer setBorderColor:color.CGColor];
    [backgroundImageLayer setBorderWidth:border];
    [backgroundImageLayer setCornerRadius:cornerRadius];
    
    [self setBackgroundImage:[UIImage resizableImageWithImage:imageFromCALayer(backgroundImageLayer)]
                    forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(.0, 14.0, .0, .0)];
    
}

@end
