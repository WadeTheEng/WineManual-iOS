//
//  WHWebViewController.h
//  WineHound
//
//  Created by Mark Turner on 30/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHWebViewController : UIViewController

@property (nonatomic) NSURL * url;

+ (WHWebViewController *)webViewControllerWithUrl:(NSURL *)url;
+ (WHWebViewController *)webViewControllerWithUrlString:(NSString *)urlString;

@end
