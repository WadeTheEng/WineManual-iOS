//
//  PCFileDownloadManager.h
//  WineHound
//
//  Created by Mark Turner on 27/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFileDownloadManager : NSObject

- (void)cancel;
- (void)downloadURL:(NSURL *)url
      progressBlock:(void(^)(CGFloat progress))progressBlock
         completion:(void(^)(NSString * filePath, NSError * error))completion;

@end
