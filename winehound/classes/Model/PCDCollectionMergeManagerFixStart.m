//
//  PCDCollectionMergeManagerFixStart.m
//  WineHound
//
//  Created by Mark Turner on 30/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "PCDCollectionMergeManagerFixStart.h"

@implementation PCDCollectionMergeManagerFixStart

- (void)loadAtIndex:(NSInteger)index
{
    if (index == 0) {
        [(NSMutableDictionary *)self.filterParameters setObject:@(YES) forKey:@"start"];
    } else {
        [(NSMutableDictionary *)self.filterParameters removeObjectForKey:@"start"];
    }
    [super loadAtIndex:index];
}

@end
