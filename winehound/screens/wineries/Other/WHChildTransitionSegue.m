//
//  WHChildTransitionSegue.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHChildTransitionSegue.h"

@implementation WHChildTransitionSegue

- (void)perform
{
    UIViewController * mainVC = (UIViewController*)self.sourceViewController;
    if (mainVC.childViewControllers.count > 1) {
        NSLog(@"Error - Should only be one existing child view controller");
    }
    
    UIViewController * fromViewController = [mainVC.childViewControllers lastObject];
    UIViewController * toViewController   = self.destinationViewController;
    
    if (fromViewController == nil) {
        [mainVC addChildViewController:toViewController];
        [mainVC.view addSubview:toViewController.view];

        [toViewController didMoveToParentViewController:mainVC];
        
        if (self.completionBlock) {
            self.completionBlock();
        }
    } else {
        [mainVC addChildViewController:toViewController];
        
        [fromViewController willMoveToParentViewController:nil];
        
        [mainVC transitionFromViewController:fromViewController
                            toViewController:toViewController
                                    duration:0.25
                                     options:UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionTransitionCrossDissolve
                                  animations:nil
                                  completion:^(BOOL finished) {
                                      if (self.completionBlock) {
                                          self.completionBlock();
                                      }

                                      [fromViewController removeFromParentViewController];
                                      [toViewController didMoveToParentViewController:mainVC];
                                  }];
    }
}

@end
