//
//  PCPhoto.h
//  WineHound
//
//  Created by Mark Turner on 13/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCPhoto <NSObject>
@required
- (NSURL *)photoURL;
@optional
- (UIImage *)image;
- (NSURL *)thumbURL;
@end

@interface PCPhoto : NSObject <PCPhoto>
@property (nonatomic,strong) UIImage * image;
@property (nonatomic,strong) NSURL   * photoURL;
@property (nonatomic,strong) NSURL   * thumbURL;
@end