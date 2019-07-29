//
//  UIImage+Resizable.m
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "UIImage+Resizable.h"

@implementation UIImage (Resizable)

+ (UIImage *)resizableImageWithImage:(UIImage *)image
{
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(floorf(image.size.height*0.5),
                                                               floorf(image.size.width *0.5),
                                                               floorf(image.size.height*0.5),
                                                               floorf(image.size.width *0.5))];
}

+ (UIImage *)resizableImageNamed:(NSString *)name
{
    UIImage * image = [self imageNamed:name];
    return [self resizableImageWithImage:image];
}

@end
