//
//  WHWebViewController.m
//  WineHound
//
//  Created by Mark Turner on 30/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHWebViewController.h"
#import "UIColor+WineHoundColors.h"

@interface WHWebViewController () <UIWebViewDelegate>
{
    __weak IBOutlet UIWebView *_webView;
    __weak UIActivityIndicatorView * _activityIndicatorView;
    
    BOOL _previousNavigatonBarVisibleState;
    BOOL _previousToolbarVisibleState;
}
@end

@implementation WHWebViewController

#pragma mark 

+ (WHWebViewController *)webViewControllerWithUrl:(NSURL *)url
{
    WHWebViewController * wvc = [WHWebViewController new];
    [wvc setUrl:url];
    return wvc;
}

+ (WHWebViewController *)webViewControllerWithUrlString:(NSString *)urlString
{
    NSURL * url = nil;
    if ([urlString hasPrefix:@"http"]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:urlString]];
    }
    return [self webViewControllerWithUrl:url];
}

#pragma mark
#pragma mark View Lifecycle

- (void)loadView
{
    UIWebView * webView = [[UIWebView alloc] init];
    [self setView:webView];
    _webView = webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setTintColor:[UIColor wh_burgundy]];
    
    [_webView setScalesPageToFit:YES];
    [_webView setDelegate:self];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setHidesWhenStopped:YES];

    UIBarButtonItem * activityIndicatorItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    UIBarButtonItem * backButtonItem        = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"web_back_button"] style:UIBarButtonItemStyleBordered    target:self action:@selector(_backButtonAction:)];
    UIBarButtonItem * forwardButtonItem     = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"web_forward_button"] style:UIBarButtonItemStyleBordered target:self action:@selector(_forwardButtonAction:)];
    UIBarButtonItem * flexibleSpace         = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * fixedSpace            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    UIBarButtonItem * closeButtonItem       = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(_closeButtonAction:)];
    
    [fixedSpace setWidth:30.0];
    
    [self setToolbarItems:@[backButtonItem,fixedSpace,forwardButtonItem,flexibleSpace,activityIndicatorItem,closeButtonItem]];

    _activityIndicatorView = activityView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _previousNavigatonBarVisibleState = self.navigationController.navigationBarHidden;
    _previousToolbarVisibleState      = self.navigationController.toolbarHidden;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:NO        animated:YES];
    
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:self.url];
    [_webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:_previousNavigatonBarVisibleState animated:YES];
    [self.navigationController setToolbarHidden:_previousToolbarVisibleState            animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark 
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%s - %@", __func__,error);
}

- (IBAction)_backButtonAction:(id)sender
{
    [_webView goBack];
}

- (IBAction)_forwardButtonAction:(id)sender
{
    [_webView goForward];
}

- (void)_closeButtonAction:(UIBarButtonItem *)sender
{
    if (self.presentingViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
