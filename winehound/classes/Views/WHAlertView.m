//
//  WHAlertView.m
//  WineHound
//
//  Created by Mark Turner on 16/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

@interface WHNoRotateVC : UIViewController

@end

@implementation WHNoRotateVC

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

#import "WHAlertView.h"
#import "UIImage+ImageEffects.h"

static WHAlertView __weak * _currentAlertView;

@implementation WHAlertView {
    UIWindow __weak   * _previousKeyWindow;
    UIWindow __strong * _alertWindow;
    
    UIView __weak * _backgroundView;
    UIView __weak * _presentingView;
    
    UIDynamicAnimator * _dynamicAnimator;
    UIAttachmentBehavior * _spring;
}

+ (WHAlertView *)alertView
{
    if (_currentAlertView.superview == nil) {
        WHAlertView * alertView = [WHAlertView new];
        _currentAlertView = alertView;
    }
    return _currentAlertView;
}

+ (WHAlertView *)currentAlertView
{
    return _currentAlertView;
}

#pragma mark

- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self == nil) return nil;
    
    _previousKeyWindow = [[UIApplication sharedApplication] keyWindow];

    //Capture preview window & apply blue
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    [_previousKeyWindow.rootViewController.view drawViewHierarchyInRect:self.frame afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyBlurWithRadius:1.75
                                                             tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]
                                                 saturationDeltaFactor:1.0
                                                             maskImage:nil];
    UIGraphicsEndImageContext();
    
    
    UIImageView * backgroundView = [UIImageView new];
    [backgroundView setFrame:self.bounds];
    [backgroundView setImage:blurredSnapshotImage];
    [self addSubview:backgroundView];

    _backgroundView = backgroundView;
    
    UIImage * closeIcon = [UIImage imageNamed:@"alert_close_icon"];
    UIButton * closeButton = [[UIButton alloc] initWithFrame:(CGRect){.0, .0, closeIcon.size}];
    [closeButton setImage:closeIcon forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(_closeButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom  multiplier:1.0 constant:-60.0]];

    UISwipeGestureRecognizer * swipeGesture = [UISwipeGestureRecognizer new];
    [swipeGesture addTarget:self action:@selector(_swipeDownGestureAction:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeGesture setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:swipeGesture];
    
    UIWindow * alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [alertWindow setWindowLevel:_previousKeyWindow.windowLevel+1.0];
    [alertWindow setBackgroundColor:[UIColor clearColor]];
    [alertWindow setRootViewController:[WHNoRotateVC new]];
    [alertWindow.rootViewController.view addSubview:self];
    [alertWindow makeKeyAndVisible];
    
    _alertWindow = alertWindow;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_positionAlertView:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_positionAlertView:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)_closeButtonTouchedUpInside:(UIButton *)button
{
    [self dismissByClosing:YES];
}

- (void)_swipeDownGestureAction:(UISwipeGestureRecognizer *)gesture
{
    [self dismissByClosing:YES];
}

#pragma mark

+ (instancetype)presentView:(UIView *)view animated:(BOOL)animated;
{
    WHAlertView * alertView = [self alertView];
    if (alertView->_presentingView != nil) {
        NSLog(@"Already presenting view");
        return nil;
    }
    
    CGRect alertViewBounds = [alertView bounds];

    [view setCenter:CGPointMake(CGRectGetMidX(alertViewBounds),CGRectGetMaxY(alertViewBounds)+(CGRectGetHeight(view.bounds)*0.5))];
    [alertView addSubview:view];
    alertView->_presentingView = view;
    
    [alertView->_backgroundView setAlpha:0.0];

    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    [effectX setMinimumRelativeValue:@(-15.0)];
    [effectX setMaximumRelativeValue:@(15.0)];
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    [effectY setMinimumRelativeValue:@(-10.0)];
    [effectY setMaximumRelativeValue:@(10.0)];

    [view addMotionEffect:effectX];
    [view addMotionEffect:effectY];
    
    [UIView animateWithDuration:0.4f
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:2.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [view setCenter:CGPointMake(CGRectGetMidX(alertViewBounds), CGRectGetMidY(alertViewBounds))];
                         [alertView->_backgroundView setAlpha:1.0];
                     } completion:nil];
    
    /*
    
    UIDynamicAnimator * dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:alertView];
    alertView->_dynamicAnimator = dynamicAnimator;
    
    UIAttachmentBehavior * spring = [[UIAttachmentBehavior alloc] initWithItem:view
                                                              attachedToAnchor:CGPointMake(CGRectGetMidX(alertViewBounds), CGRectGetMidY(alertViewBounds))];
    [spring setFrequency:2.0];
    [spring setDamping:0.6];
    [spring setLength:0.0];
    
    [dynamicAnimator addBehavior:spring];
    alertView->_spring = spring;
    
    */
        
    return alertView;
}

+ (UIView *)presentingView
{
    WHAlertView * alertView = [self alertView];
    return alertView->_presentingView;
}


- (void)dismiss
{
    [self dismissByClosing:NO];
}

- (void)dismissByClosing:(BOOL)closing
{
    void(^animationComplete)(BOOL finished) = ^(BOOL finished) {
        if (finished == YES) {
            _alertWindow = nil;
            
            [_presentingView removeFromSuperview];
            [_previousKeyWindow makeKeyWindow];
        }
    };
    
    if (closing == NO) {
        [UIView animateKeyframesWithDuration:0.3f
                                       delay:0
                                     options:0
                                  animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.3 animations:^{
                [_presentingView setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
                [_presentingView setAlpha:0.0];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                [_backgroundView setAlpha:0.0];
            }];
        } completion:animationComplete];
    } else {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [_presentingView setCenter:CGPointMake(CGRectGetMidX(self.bounds), 1000.0)];
                             [_backgroundView setAlpha:0.0];
                         } completion:animationComplete];
    }
}

/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_spring setAnchorPoint:CGPointMake(CGRectGetMidX(self.bounds), 1000.0)];

    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismiss];
    });
}
*/

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
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
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
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions
                     animations:^{
                         [_presentingView setCenter:CGPointMake(CGRectGetWidth(screenBounds)*0.5, CGRectGetHeight(screenBounds)*0.5)];
                     }
                     completion:NULL];
}


@end
