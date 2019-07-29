//
//  WHProgressView.h
//  WineHound
//
//  Created by Mark Turner on 31/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHProgressView : UIView
@property (assign, nonatomic) CGFloat progress;
+ (void)show;
+ (void)setProgress:(CGFloat)progress;
+ (void)dismiss;
@end
