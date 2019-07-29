//
//  UIViewController+Social.m
//  WineHound
//
//  Created by Mark Turner on 02/07/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "UIViewController+Social.h"
#import "WHWebViewController.h"

@implementation UIViewController (Social)

- (void)openTwitterAppOrPresentWebviewWithHandle:(NSString *)tiwtterHandle
{
    NSString * twitterURLString = [NSString stringWithFormat:@"twitter://user?screen_name=%@",tiwtterHandle];
    NSURL * twitterURL = [NSURL URLWithString:twitterURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        NSString * twitterURLString = [NSString stringWithFormat:@"http://twitter.com/%@",tiwtterHandle];
        NSURL * url = [NSURL URLWithString:twitterURLString];
        WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:url];
        [self.navigationController pushViewController:wvc animated:YES];
    }
    
}

- (void)openInstagramAppOrPresentWebviewWithHandle:(NSString *)instagramHandle
{
    NSString * instagramURLString = [NSString stringWithFormat:@"instagram://user?username=%@",instagramHandle];
    NSURL * instagramURL = [NSURL URLWithString:instagramURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://instagram.com/%@",instagramHandle]];
        WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:instagramURL];
        [self.navigationController pushViewController:wvc animated:YES];
    }
}

- (void)openFacebookAppOrPresentWebviewWithHandle:(NSString *)facebookURLString
{
    NSArray * urlArray = [[facebookURLString lastPathComponent] componentsSeparatedByString:@"?"];
    NSString * facebookHandle = [urlArray firstObject];

    //Issue of usl is as follows: facebook.com/919wines/apage
    
    NSString * facebookUrlSchemeString = [NSString stringWithFormat:@"fb://profile/%@",facebookHandle];
    NSURL * facebookURL = [NSURL URLWithString:facebookUrlSchemeString];
    
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        facebookURL = [NSURL URLWithString:facebookURLString];
        WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:facebookURL];
        [self.navigationController pushViewController:wvc animated:YES];
    }
}


@end
