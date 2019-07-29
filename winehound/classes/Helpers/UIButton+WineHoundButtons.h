//
//  UIButton+WineHoundButtons.h
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (WineHoundButtons)
- (void)setupBurgundyButtonWithBorderWidth:(CGFloat)border cornerRadius:(CGFloat)cornerRadius;
- (void)setupButtonWithColour:(UIColor *)color borderWidth:(CGFloat)border cornerRadius:(CGFloat)cornerRadius;
@end
