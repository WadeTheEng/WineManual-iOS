//
//  WHCalendarHeaderView.h
//  WineHound
//
//  Created by Mark Turner on 21/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHCalendarHeaderView : UICollectionReusableView

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *daysLabels;
@property (weak, nonatomic) IBOutlet UIView *containerView;

+ (NSString *)reuseIdentifier;

@end
