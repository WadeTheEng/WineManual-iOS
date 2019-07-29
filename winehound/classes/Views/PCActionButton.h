//
//  PCActionButton.h
//  WineHound
//
//  Created by Mark Turner on 07/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCActionButtonDelegate;
@interface PCActionButton : UIButton
@property (nonatomic,weak) id identifier;
@property (nonatomic,weak) id <PCActionButtonDelegate> actionDelegate;

- (void)call:(id)sender;
- (void)sms:(id)sender;
- (void)email:(id)sender;
- (void)website:(id)sender;

@end

@protocol PCActionButtonDelegate <NSObject>
- (BOOL)actionButton:(PCActionButton *)button canPerformAction:(SEL)action;
- (void)actionButton:(PCActionButton *)button performAction:(SEL)action;
@end