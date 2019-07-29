//
//  WHOnboardingViewController.h
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHOnboardingViewControllerDelegate;
@interface WHOnboardingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) id <WHOnboardingViewControllerDelegate> delegate;
- (void)reload;
@end

@protocol WHOnboardingViewControllerDelegate <NSObject>
- (void)onboardingViewController:(WHOnboardingViewController *)vc didTapStartButton:(UIButton *)button;
@end
