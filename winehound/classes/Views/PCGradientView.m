//
//  PCGradientView.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "PCGradientView.h"

@implementation PCGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (void)setColors:(NSArray *)array
{
    CAGradientLayer * gradientLayer = (CAGradientLayer*)self.layer;
    NSMutableArray * mutableColorsArray = [NSMutableArray arrayWithCapacity:array.count];
    for (UIColor * color in array) {
        [mutableColorsArray addObject:(id)color.CGColor];
    }
    [gradientLayer setColors:mutableColorsArray];
}

- (void)setLocations:(NSArray *)locationsArray
{
    CAGradientLayer * gradientLayer = (CAGradientLayer*)self.layer;
    [gradientLayer setLocations:locationsArray];
}

@end
