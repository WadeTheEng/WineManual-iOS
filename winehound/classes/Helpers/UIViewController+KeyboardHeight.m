//
//  UIViewController+KeyboardHeight.m
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "UIViewController+KeyboardHeight.h"

@implementation UIViewController (KeyboardHeight)

- (CGFloat)visibleKeyboardHeight
{
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")])
            return possibleKeyboard.bounds.size.height;
    }
    
    return 0;
}


@end
