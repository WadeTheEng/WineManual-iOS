//
//  WHWineViewController.h
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHWineViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSNumber * wineryId;
@property (nonatomic) NSNumber * selectedWineId;
@property (nonatomic) NSNumber * rangeId;

@end
