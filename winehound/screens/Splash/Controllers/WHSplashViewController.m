//
//  WHSplashViewController.m
//  WineHound
//
//  Created by Mark Turner on 04/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHSplashViewController.h"

@interface WHSplashViewController ()
@property (nonatomic,weak) UIImageView * animationImageView;
@end

@implementation WHSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage * animatedSequence = [UIImage animatedImageNamed:@"winehound_splash_animation_" duration:0.7];
        NSArray * reversedSequence = [[animatedSequence.images reverseObjectEnumerator] allObjects];
        NSArray * animationImages = [animatedSequence.images arrayByAddingObjectsFromArray:reversedSequence];
        
        UIImageView * animationImageView = [[UIImageView alloc] init];
        [animationImageView setAnimationImages:animationImages];
        [animationImageView setAnimationDuration:1.4];
        [animationImageView setContentMode:UIViewContentModeCenter];
        [animationImageView setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:240.0/255.0 blue:235.0/255.0 alpha:1.0]];
    
        [self.view addSubview:animationImageView];

        _animationImageView = animationImageView;
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.animationImageView setFrame:CGRectMake(.0, .0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark 

- (void)startAnimationWithCompletionBlock:(void(^)())completion
{
    if (completion != nil) {
        double delayInSeconds = 1.1;//self.animationImageView.animationDuration;
        [UIView animateWithDuration:0.2
                              delay:delayInSeconds
                            options:0 
                         animations:^{
            [self.view setAlpha:0.0];
        } completion:^(BOOL finished) {
            if (finished) {
                completion();
            }
        }];
    }
    [self.animationImageView startAnimating];
}

- (void)startAnimation
{
    [self.animationImageView startAnimating];
}

- (void)stopAnimation
{
    [self.animationImageView stopAnimating];
}

@end
