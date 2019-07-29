//
//  WHFilterBarView.h
//  WineHound
//
//  Created by Mark Turner on 02/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHSearchBarView.h"

@interface WHFilterBarView : WHSearchBarView

@property (weak, nonatomic) UIButton           *filterButton;
@property (weak, nonatomic) UISegmentedControl *segmentedControl;

@property (weak, nonatomic) NSLayoutConstraint *segmentedControlLeadingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *filterButtonTrailingConstraint;

@end