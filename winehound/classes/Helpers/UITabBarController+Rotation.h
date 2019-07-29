//
//  UITabBarController+Rotation.h
//  WineHound
//
//  Created by Mark Turner on 03/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Rotation)
-(BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
@end
