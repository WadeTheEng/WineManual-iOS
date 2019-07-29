//
//  NSManagedObject+Additions.m
//  WineHound
//
//  Created by Mark Turner on 15/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (Additions)

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)ctx
{
    if ([self respondsToSelector:@selector(entityName)]) {
        NSString * entityName = [self performSelector:@selector(entityName)];
        return [NSEntityDescription entityForName:entityName inManagedObjectContext:ctx];
    }
    return nil;
}

@end
