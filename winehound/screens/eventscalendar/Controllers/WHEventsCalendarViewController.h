//
//  WHEventsCalendarViewController.h
//  WineHound
//
//  Created by Mark Turner on 22/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHCalendarViewController.h"

@interface WHEventsCalendarViewController : WHCalendarViewController

@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;

@property (nonatomic) BOOL displayTradeEvents;

@end
