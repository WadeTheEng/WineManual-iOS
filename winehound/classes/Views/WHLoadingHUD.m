//
//  WHLoadingHUD.m
//  WineHound
//
//  Created by Mark Turner on 11/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHLoadingHUD.h"

@interface WHOverlayView : UIControl @end
@implementation WHOverlayView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [WHLoadingHUD dismiss];
    return nil;
}
@end

#pragma mark
#pragma mark

const UIWindowLevel WHLoadingHUDMaxWindowLevel = 100.0;

@interface WHLoadingHUD ()
{
    UIImageView * _maskImageView;
}
@property (nonatomic, strong) UIControl *overlayView;
@end

static dispatch_once_t _once;
static WHLoadingHUD *  _sharedView;

@implementation WHLoadingHUD

#pragma mark 

+ (WHLoadingHUD*)sharedView
{
    dispatch_once(&_once, ^{
        WHLoadingHUD * loadingHud = nil;
        loadingHud = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _sharedView = loadingHud;
    });
    return _sharedView;
}

- (UIControl *)overlayView
{
    if(_overlayView == nil) {
        WHOverlayView * overlayView = [[WHOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [overlayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
        [overlayView addTarget:self action:@selector(_overlayViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
        [overlayView setUserInteractionEnabled:YES];
        _overlayView = overlayView;
    }
    return _overlayView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setUserInteractionEnabled:NO];

        UIView * square = [UIView new];
        [square setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        [square.layer setCornerRadius:10.0];
        [square.layer setMasksToBounds:YES];
        [self addSubview:square];
        
        UIImage * image = [UIImage imageNamed:@"loading_wine_mask"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0) resizingMode:UIImageResizingModeStretch];
        
        UIImageView * maskIV = [UIImageView new];
        [maskIV setImage:image];
        [maskIV setFrame:CGRectMake(0.0,0.0,120.0,120.0)];
        [maskIV setContentMode:UIViewContentModeCenter];
        [square.layer setMask:maskIV.layer];
        _maskImageView = maskIV;
        
        [square setTranslatesAutoresizingMaskIntoConstraints:NO];
        [square addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[square(120)]"
                                                                       options:NSLayoutFormatAlignAllCenterY
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(square)]];
        [square addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[square(120)]"
                                                                       options:NSLayoutFormatAlignAllCenterX
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(square)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:square
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:square
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.x" type: UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        [effectX setMinimumRelativeValue:@(-20.0)];
        [effectX setMaximumRelativeValue:@(20.0)];

        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.y" type: UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        [effectY setMinimumRelativeValue:@(-20.0)];
        [effectY setMaximumRelativeValue:@(20.0)];

        [square addMotionEffect:effectX];
        [square addMotionEffect:effectY];

        [self _registerKeyboardNotifications];
    }
    return self;
}

- (void)dealloc
{
    [self _unregisterKeyboardNotifications];
}

#pragma mark

+ (void)show
{
    [[self sharedView] show];
}

- (void)show
{
    if(!self.overlayView.superview) {
        UIWindow * mainWindow = nil;
        for (UIWindow * window in [UIApplication sharedApplication].windows) {
            if (window.windowLevel <= WHLoadingHUDMaxWindowLevel) {
                if (mainWindow != nil) {
                    NSLog(@"Investigate - multiple windows with Normal level");
                } else if ([window isMemberOfClass:[UIWindow class]]) {
                    mainWindow = window;
                }
            }
        }
        [mainWindow addSubview:self.overlayView];
    }
    
    if(!self.superview) {
        [self.overlayView addSubview:self];
        [self startAnimating];
    }
}

+ (void)showError:(NSError *)error
{
    NSLog(@"%s - %@", __func__,error);
    [self showErrorWithStatus:error.localizedDescription];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    NSLog(@"%s - %@", __func__,string);
    [self dismiss];
}

+ (void)dismiss
{
    [[self sharedView].overlayView removeFromSuperview];
    [[self sharedView] removeFromSuperview];
}

#pragma mark 

- (void)startAnimating
{
    CAAnimation * animation = [_maskImageView.layer animationForKey:@"transform"];
    if (animation != nil) {
        return;
    }
    
    CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
    
    [theAnimation setValues:@[ [NSValue valueWithCATransform3D:CATransform3DRotate(_maskImageView.layer.transform, M_PI*0.0, 0, 0, 1)],
                               [NSValue valueWithCATransform3D:CATransform3DRotate(_maskImageView.layer.transform, M_PI*0.5, 0, 0, 1)],
                               [NSValue valueWithCATransform3D:CATransform3DRotate(_maskImageView.layer.transform, M_PI*1.0, 0, 0, 1)]]];
    
    [theAnimation setKeyTimes:@[ [NSNumber numberWithFloat:0.0],
                                 [NSNumber numberWithFloat:0.5],
                                 [NSNumber numberWithFloat:1.0]]];
    
    [theAnimation setTimingFunctions:@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]]];
    
    [theAnimation setCumulative:YES];
    [theAnimation setDuration:1.0];
    [theAnimation setRepeatCount:CGFLOAT_MAX];
    [theAnimation setRemovedOnCompletion:YES];
    
    [_maskImageView.layer addAnimation:theAnimation forKey:@"transform"];
}

#pragma mark


- (void)_overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent *)event
{
    NSLog(@"%s", __func__);
}

#pragma mark

- (void)_registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_positionAlertView:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_positionAlertView:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)_unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (CGFloat)_visibleKeyboardHeight
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

- (void)_positionAlertView:(NSNotification *)notification
{
    NSLog(@"%s", __func__);
    
    CGFloat keyboardHeight = 0;
    NSTimeInterval         animationDuration = 0.0;
    UIViewAnimationOptions animationOptions  = 0;
    
    if(notification != nil) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration    = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        animationOptions = animationCurve << 16;
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            keyboardHeight = keyboardFrame.size.height;
        } else
            keyboardHeight = 0;
        
    } else {
        keyboardHeight = [self _visibleKeyboardHeight];
    }
    animationOptions = animationOptions|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionLayoutSubviews;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    screenBounds.size.height -= keyboardHeight;
    
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions
                     animations:^{
                         [self setFrame:screenBounds];
                         [self layoutIfNeeded];
                     }
                     completion:NULL];
}

@end
