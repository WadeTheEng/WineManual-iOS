//
//  WHShareManager.h
//  WineHound
//
//  Created by Mark Turner on 31/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHShareProtocol.h"

@interface WHShareManager : NSObject

- (void)presentShareAlertWithObject:(id <WHShareProtocol>)obj;

@end
