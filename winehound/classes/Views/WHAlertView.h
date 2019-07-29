//
//  WHAlertView.h
//  WineHound
//
//  Created by Mark Turner on 16/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHAlertView : UIView

+ (instancetype)presentView:(UIView *)view animated:(BOOL)animated;
- (void)dismiss;

+ (WHAlertView *)currentAlertView;

@end
