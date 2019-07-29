//
//  UIImage+Resizable.h
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resizable)
+ (UIImage *)resizableImageNamed:(NSString *)name;
+ (UIImage *)resizableImageWithImage:(UIImage *)image;
@end
