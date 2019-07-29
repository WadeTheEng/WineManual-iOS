//
//  WHSideMenuViewController.h
//  WineHound
//
//  Created by Mark Turner on 26/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHSideMenuViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)setWineHoundLogoOffset:(CGFloat)offset;//Value between 0.0 - 1.0

@end
