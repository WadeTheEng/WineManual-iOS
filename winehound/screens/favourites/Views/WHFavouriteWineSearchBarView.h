//
//  WHFavouriteWineSearchBarView.h
//  WineHound
//
//  Created by Mark Turner on 27/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHSearchBarView.h"

@interface WHFavouriteWineSearchBarView : WHSearchBarView

@property (weak, nonatomic) UIButton           *filterButton;
@property (weak, nonatomic) NSLayoutConstraint *filterButtonTrailingConstraint;

@end
