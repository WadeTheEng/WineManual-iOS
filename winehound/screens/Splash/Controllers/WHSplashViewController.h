//
//  WHSplashViewController.h
//  WineHound
//
//  Created by Mark Turner on 04/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHSplashViewController : UIViewController
- (void)startAnimation;
- (void)startAnimationWithCompletionBlock:(void(^)())completion;
- (void)stopAnimation;
@end
