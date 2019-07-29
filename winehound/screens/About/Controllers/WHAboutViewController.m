//
//  WHAboutViewController.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>

#import "WHAboutViewController.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "UIViewController+Appearance.h"
#import "WHLoadingHUD.h"
#import "WHDetailViewController.h"
#import "WHWebViewController.h"
#import "PCActionButton.h"

@interface WHAboutViewController () <PCActionButtonDelegate,MFMailComposeViewControllerDelegate>

@end

@implementation WHAboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setWinehoundTitleView];
    
    [WHLoadingHUD dismiss];
    
    [self.aboutLabel setFont:[UIFont edmondsansRegularOfSize:17.0]];
    [self.aboutLabel setTextColor:[UIColor wh_grey]];
    
    NSMutableAttributedString * aboutString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"kAboutScreenAboutDescription", nil)];
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:4.0];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [aboutString setAttributes:@{NSFontAttributeName: [UIFont edmondsansRegularOfSize:17.0],
                                 NSForegroundColorAttributeName:[UIColor wh_grey],
                                 NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, aboutString.length)];

    NSAttributedString * termsString =
    [[NSAttributedString alloc] initWithString:@"Terms of Use"
                                    attributes:@{NSFontAttributeName: [UIFont edmondsansMediumOfSize:15.0],
                                                 NSForegroundColorAttributeName:[UIColor wh_burgundy],
                                                 NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];
    NSAttributedString * privacyString =
    [[NSAttributedString alloc] initWithString:@"Privacy Policy"
                                    attributes:@{NSFontAttributeName: [UIFont edmondsansMediumOfSize:15],
                                                 NSForegroundColorAttributeName:[UIColor wh_burgundy],
                                                 NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];
    
    NSString * bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    [self.aboutLabel    setAttributedText:aboutString];;
    [self.termsButton   setAttributedTitle:termsString forState:UIControlStateNormal];
    [self.privacyButton setAttributedTitle:privacyString forState:UIControlStateNormal];

    [self.versionLabel setText:[NSString stringWithFormat:@"Version %@",bundleVersion]];
    [self.versionLabel setFont:[UIFont edmondsansRegularOfSize:12.0]];
    
    [self.termsButton      addTarget:self action:@selector(_termsButtonTouchedUpInside:)   forControlEvents:UIControlEventTouchUpInside];
    [self.privacyButton    addTarget:self action:@selector(_privacyButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_papercloudTapGesture:)];
    [self.papercloudImageView setUserInteractionEnabled:YES];
    [self.papercloudImageView addGestureRecognizer:tapGesture];

    [self.contactLabel setFont:[UIFont edmondsansRegularOfSize:16.0]];
    [self.contactLabel setTextColor:[UIColor wh_grey]];

    [self.contactButton.titleLabel setFont:[UIFont edmondsansRegularOfSize:16.0]];
    [self.contactButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [self.contactButton addTarget:self action:@selector(_contactButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactButton setActionDelegate:self];
    [self.contactButton setIdentifier:@"email"];
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


#pragma mark actions

- (void)_termsButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    NSString * termsHTMLFilePath = [[NSBundle mainBundle] pathForResource:@"WineHound_Application_Terms_of_Us" ofType:@"html"];
    NSString * htmlFile = [NSString stringWithContentsOfFile:termsHTMLFilePath encoding:NSUTF8StringEncoding error:NULL];

    WHTextViewController * textViewController = [WHTextViewController new];
    [textViewController setTitle:@"Terms of Use" text:htmlFile];
    [self.navigationController pushViewController:textViewController animated:YES];
}

- (void)_privacyButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);

    NSString * privacyHTMLFilePath = [[NSBundle mainBundle] pathForResource:@"WineHound_Application_Privacy_Policy" ofType:@"html"];
    NSString * htmlFile = [NSString stringWithContentsOfFile:privacyHTMLFilePath encoding:NSUTF8StringEncoding error:NULL];
    
    WHTextViewController * textViewController = [WHTextViewController new];
    [textViewController setTitle:@"Privacy Policy" text:htmlFile];
    [self.navigationController pushViewController:textViewController animated:YES];
}

- (void)_papercloudTapGesture:(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"%s", __func__);
    NSURL * papercloudURL = [NSURL URLWithString:@"http://papercloud.com.au/"];
    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:papercloudURL];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)_contactButtonTouchedUpInside:(PCActionButton *)button
{
    NSLog(@"%s", __func__);
    [self _displayMenuControllerInButton:button];
}

#pragma mark

- (void)_displayMenuControllerInButton:(PCActionButton *)actionButton
{
    UIMenuItem * emailMenuItem  = [[UIMenuItem alloc] initWithTitle:@"Email" action:@selector(email:)];
    CGRect requiredSize = [actionButton.titleLabel.text boundingRectWithSize:actionButton.frame.size
                                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                  attributes:@{NSFontAttributeName:actionButton.titleLabel.font}
                                                                     context:nil];
    
    [actionButton becomeFirstResponder];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:@[emailMenuItem]];
    [menuController setTargetRect:(CGRect) {.origin = actionButton.frame.origin, .size = requiredSize.size} inView:actionButton.superview];
    [menuController setMenuVisible:YES animated:YES];
    [menuController setMenuItems:nil];
}

#pragma mark

- (BOOL)actionButton:(PCActionButton *)button canPerformAction:(SEL)action
{
    NSLog(@"%s", __func__);
    return
    (action == @selector(copy:)) ||
    (action == @selector(email:) && [button.identifier isEqualToString:@"email"]);
}

- (void)actionButton:(PCActionButton *)button performAction:(SEL)action
{
    NSLog(@"%s", __func__);
    
    if ([button.identifier isEqualToString:@"email"]) {
        MFMailComposeViewController *emailViewController = [[MFMailComposeViewController alloc] init];
        if (emailViewController != nil) {
            [emailViewController setMailComposeDelegate:(id)self];
            [emailViewController setToRecipients:@[@"simon@winehound.net.au"]];
            [self presentViewController:emailViewController animated:YES completion:nil];
        }
    }
}

#pragma mark
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
