//
//  UITabBarController+Rotation.m
//  WineHound
//
//  Created by Mark Turner on 03/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "UITabBarController+Rotation.h"

@implementation UITabBarController (Rotation)

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

@end
