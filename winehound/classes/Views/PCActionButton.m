//
//  PCActionButton.m
//  WineHound
//
//  Created by Mark Turner on 07/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "PCActionButton.h"

@implementation PCActionButton

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    /*
    return
    (action == @selector(copy:) && self.canCopy)   ||
    (action == @selector(call:) && self.canCall)   ||
    (action == @selector(sms:) && self.canSMS)     ||
    (action == @selector(email:) && self.canEmail) ||
    (action == @selector(website:) && self.canWebsite);
     */

    if ([self.actionDelegate respondsToSelector:@selector(actionButton:canPerformAction:)]) {
        return [self.actionDelegate actionButton:self canPerformAction:action];
    }
    return NO;
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.titleLabel.text];
}

- (void)call:(id)sender
{
    NSLog(@"%s", __func__);
    if ([self.actionDelegate respondsToSelector:@selector(actionButton:performAction:)]) {
        [self.actionDelegate actionButton:self performAction:_cmd];
    }
}

- (void)sms:(id)sender
{
    NSLog(@"%s", __func__);
    if ([self.actionDelegate respondsToSelector:@selector(actionButton:performAction:)]) {
        [self.actionDelegate actionButton:self performAction:_cmd];
    }
}

- (void)email:(id)sender
{
    NSLog(@"%s", __func__);
    if ([self.actionDelegate respondsToSelector:@selector(actionButton:performAction:)]) {
        [self.actionDelegate actionButton:self performAction:_cmd];
    }
}

- (void)website:(id)sender
{
    NSLog(@"%s", __func__);
    if ([self.actionDelegate respondsToSelector:@selector(actionButton:performAction:)]) {
        [self.actionDelegate actionButton:self performAction:_cmd];
    }
}

@end