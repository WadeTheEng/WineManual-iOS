//
//  NSCache+UIImage.h
//  WineHound
//
//  Created by Mark Turner on 14/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface NSCache (AFNetworkingImageCache)
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

@interface UIImageView (AFNetworkingImageCache)
+ (NSCache *)af_sharedImageCache;
@end