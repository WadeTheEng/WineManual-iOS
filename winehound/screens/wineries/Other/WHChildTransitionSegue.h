//
//  WHChildTransitionSegue.h
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHChildTransitionSegue : UIStoryboardSegue
@property (nonatomic, copy) void(^completionBlock)(void);;
@end
