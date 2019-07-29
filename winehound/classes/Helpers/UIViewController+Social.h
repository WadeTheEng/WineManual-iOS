//
//  UIViewController+Social.h
//  WineHound
//
//  Created by Mark Turner on 02/07/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Social)

- (void)openTwitterAppOrPresentWebviewWithHandle:(NSString *)tiwtterHandle;
- (void)openInstagramAppOrPresentWebviewWithHandle:(NSString *)instagramHandle;
- (void)openFacebookAppOrPresentWebviewWithHandle:(NSString *)facebookURLString;

@end
