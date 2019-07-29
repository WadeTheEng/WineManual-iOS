//
//  UIFont+Edmondsans.m
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "UIFont+Edmondsans.h"

@implementation UIFont (Edmondsans)

+ (UIFont *)edmondsansMediumOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Edmondsans-Medium" size:fontSize];
}

+ (UIFont *)edmondsansBoldOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Edmondsans-Bold" size:fontSize];
}

+ (UIFont *)edmondsansRegularOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Edmondsans-Regular" size:fontSize];
}

@end
