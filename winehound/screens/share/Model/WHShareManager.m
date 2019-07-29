//
//  WHShareManager.m
//  WineHound
//
//  Created by Mark Turner on 31/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

#import "WHShareManager.h"
#import "WHShareView.h"
#import "WHAlertView.h"

#import "WHWineryMO.h"
#import "WHEventMO.h"

@interface WHShareManager () <WHShareAlertDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    WHAlertView __weak * _alertView;
    
    id <WHShareProtocol> __weak _shareObject;
}
@end

@implementation WHShareManager

#pragma mark

- (void)presentShareAlertWithObject:(id <WHShareProtocol>)obj
{
    _shareObject = obj;
    
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHShareView" owner:nil options:nil];
    
    WHShareView * shareWineryView = [views firstObject];
    [shareWineryView setDelegate:self];
    [shareWineryView setTitle:obj.shareTitle];
    [shareWineryView setObject:obj];
    
    [WHAlertView presentView:shareWineryView animated:YES];
}

#pragma mark WHShareWineryAlertDelegate

- (void)shareView:(WHShareView *)view didTapFacebookButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:[view.object facebookShareString]];
        [controller setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    
                    if ([view.object respondsToSelector:@selector(trackProperties)]) {
                        [[Mixpanel sharedInstance] track:@"Shared with Facebook"
                                              properties:[(NSObject <WHShareProtocol> *)view.object trackProperties]];
                    }
                    
                    [[WHAlertView currentAlertView] dismiss];

                    break;
                    
                default:
                    break;
            }
        }];
        
        [[view.window rootViewController] presentViewController:controller animated:YES completion:nil];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Facebook unavailabe"
                                    message:@"You need to sign into Facebook on your device in order to share."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)shareView:(WHShareView *)view didTapTwitterButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[view.object twitterShareString]];
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessfull");
                    
                    [[Mixpanel sharedInstance] track:@"Shared with Twitter"
                                          properties:[(NSObject <WHShareProtocol> *)view.object trackProperties]];

                    [[WHAlertView currentAlertView] dismiss];

                    break;
                    
                default:
                    break;
            }        }];
        
        [[view.window rootViewController] presentViewController:tweetSheet animated:YES completion:nil];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Facebook unavailabe"
                                    message:@"You need to sign into Twitter on your device in order to share."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)shareView:(WHShareView *)view didTapEmailButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    MFMailComposeViewController *emailViewController = [[MFMailComposeViewController alloc] init];
    if (emailViewController) {

        if ([view.object respondsToSelector:@selector(emailSubject)]) {
            [emailViewController setSubject:[view.object emailSubject]];
        } else {
            [emailViewController setSubject:@"Check out Winehound"];
        }
        if ([view.object respondsToSelector:@selector(emailBody)]) {
            [emailViewController setMessageBody:[view.object emailBody] isHTML:YES];
        }
        
        [emailViewController setMailComposeDelegate:self];
        
        [[view.window rootViewController] presentViewController:emailViewController animated:YES completion:nil];
    }
}

- (void)shareView:(WHShareView *)view didTapSMSButton:(UIButton *)button
{
    if(![MFMessageComposeViewController canSendText]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Your device doesn't support SMS!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController setMessageComposeDelegate:self];
    [messageController setBody:[view.object smsShareString]];

    [[view.window rootViewController] presentViewController:messageController animated:YES completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result) {
        case MFMailComposeResultFailed:
        case MFMailComposeResultCancelled:
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSent:
            [[Mixpanel sharedInstance] track:@"Shared with Email"
                                  properties:[_shareObject trackProperties]];
        case MFMailComposeResultSaved:
            [controller dismissViewControllerAnimated:YES completion:^{
                [[WHAlertView currentAlertView] dismiss];
            }];
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultFailed:
        case MessageComposeResultCancelled:
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultSent:
            [[Mixpanel sharedInstance] track:@"Shared via SMS"
                                  properties:[_shareObject trackProperties]];
            [controller dismissViewControllerAnimated:YES completion:^{
                [[WHAlertView currentAlertView] dismiss];
            }];
            break;
            break;
            
        default:
            break;
    }
}

@end
