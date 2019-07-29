//
//  WHMapIconManager.m
//  WineHound
//
//  Created by Mark Turner on 11/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHMapIconManager.h"

@interface WHImageCache : NSCache
- (UIImage *)cachedImageForURL:(NSURL *)url;
- (void)cacheImage:(UIImage *)image
            forURL:(NSURL *)url;
@end

@implementation WHImageCache

- (UIImage *)cachedImageForURL:(NSURL *)url
{
	return [self objectForKey:[url absoluteString]];
}

- (void)cacheImage:(UIImage *)image
            forURL:(NSURL *)url
{
    if (image && url) {
        [self setObject:image forKey:[url absoluteString]];
    }
}
@end

/////

#import <AFNetworking/AFNetworking.h>
#import "WHWineryMO.h"

@interface WHMapIconManager ()
@property (nonatomic) WHImageCache * wineriesLogoCache;
@property (nonatomic) dispatch_queue_t imageSuccessQueue;
@property (nonatomic) NSOperationQueue * logoOperationQueue;
@end

@implementation WHMapIconManager

- (NSOperationQueue *)logoOperationQueue
{
    if (_logoOperationQueue == nil) {
        NSOperationQueue * logoOperationQueue = [[NSOperationQueue alloc] init];
        [logoOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        _logoOperationQueue = logoOperationQueue;
    }
    return _logoOperationQueue;
}

- (dispatch_queue_t)imageSuccessQueue
{
    if (_imageSuccessQueue == nil) {
        dispatch_queue_t imageSuccessQueue = dispatch_queue_create("au.net.winehound.mapiconimageprocessqueue", NULL);
        _imageSuccessQueue = imageSuccessQueue;
    }
    return _imageSuccessQueue;
}

- (WHImageCache *)wineriesLogoCache
{
    if (_wineriesLogoCache == nil) {
        WHImageCache * imageCache = [WHImageCache new];
        _wineriesLogoCache = imageCache;
    }
    return _wineriesLogoCache;
}

- (BOOL)isDownloadingURL:(NSURL *)url
{
    for (NSOperation * operation in _logoOperationQueue.operations) {
        if ([operation isKindOfClass:[AFURLConnectionOperation class]]) {
            AFURLConnectionOperation * urlOperation = (AFURLConnectionOperation*)operation;
            if ([urlOperation.request.URL isEqual:url]) {
                break;
                return YES;
            }
        }
    }
    return NO;
}

- (AFImageRequestOperation *)logoOperationWithWinery:(WHWineryMO *)winery withCallback:(void(^)(UIImage * wineryIcon))callback;
{
    NSURL * logoURL = [NSURL URLWithString:winery.logoURL];
    UIImage * cachedImage = [self.wineriesLogoCache cachedImageForURL:logoURL];
    if (cachedImage != nil) {
        if (callback != nil) {
            callback(cachedImage);
        }
    } else {
        if ([self isDownloadingURL:logoURL] == NO) {
            NSMutableURLRequest * logoRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:winery.logoURL]];
            [logoRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];

            /*
             NSCachedURLResponse *cachedImage = [[NSURLCache sharedURLCache] cachedResponseForRequest:logoRequest];
             if (cachedImage != nil && [[cachedImage data] length] > 0) {
             NSLog(@"cachedImage: %@",cachedImage);
             }
             */

            __weak typeof (self) weakSelf = self;
            
            AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:logoRequest];
            [requestOperation setAllowsInvalidSSLCertificate:YES];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                UIImage * wineryLogo = [(AFImageRequestOperation*)operation responseImage];
                if (wineryLogo != nil) {

                    CGSize circleSize = CGSizeMake(44.0, 44.0);

                    UIImage * goldPin = [UIImage imageNamed:@"map_gold_blank_pin"];

                    UIGraphicsBeginImageContextWithOptions(goldPin.size, NO, 0.0);
                    CGContextRef context = UIGraphicsGetCurrentContext();

                    [goldPin drawAtPoint:CGPointMake(0,0)];

                    CGContextAddArc(context, goldPin.size.width*0.5, 0.5+(goldPin.size.width*0.5), 0.5+(circleSize.width*0.5), 0, M_PI*2.0, YES);
                    CGContextClip(context);

                    CGFloat logoHeight = circleSize.height*(wineryLogo.size.height/wineryLogo.size.width);
                    [wineryLogo drawInRect:(CGRect){4.0,4.0+(0.5*(circleSize.height-logoHeight)),circleSize.width,logoHeight} blendMode:kCGBlendModeNormal alpha:1.0];

                    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();

                    UIGraphicsEndImageContext();

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.wineriesLogoCache cacheImage:result forURL:logoURL];

                        if (callback != nil) {
                            callback(result);
                        }
                    });
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback != nil) {
                        callback(nil);
                    }
                });
            }];
            
            [requestOperation setSuccessCallbackQueue:self.imageSuccessQueue];
            [self.logoOperationQueue addOperation:requestOperation];
            
            return requestOperation;
        }
    }
    return nil;
}


@end
