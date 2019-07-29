//
//  WHMapIconManager.h
//  WineHound
//
//  Created by Mark Turner on 11/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFImageRequestOperation,WHWineryMO;

@interface WHMapIconManager : NSObject

- (AFImageRequestOperation *)logoOperationWithWinery:(WHWineryMO *)winery
                                        withCallback:(void(^)(UIImage * wineryIcon))callback;

@end
