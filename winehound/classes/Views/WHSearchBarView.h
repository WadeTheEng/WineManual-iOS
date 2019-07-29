//
//  WHSearchBarView.h
//  WineHound
//
//  Created by Mark Turner on 18/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHSearchBarViewProtocol <NSObject>
- (UITextField *)searchTextField;
- (UIButton *)cancelButton;
@end


@interface WHSearchBarView : UIView <WHSearchBarViewProtocol>

@property (weak, nonatomic) UITextField        *searchTextField;
@property (weak, nonatomic) UIButton           *cancelButton;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) NSLayoutConstraint *searchTextFieldLeadingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *searchTextFieldTrailingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *cancelButtonTrailingConstraint;

- (void)setSearchBarExpanded:(BOOL)expanded;
- (void)cancel;

@end
