//
//  RKRelationshipMapping+ReplaceAssignment.m
//  WineHound
//
//  Created by Mark Turner on 04/03/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "RKRelationshipMapping+ReplaceAssignment.h"

@implementation RKRelationshipMapping (ReplaceAssignment)

+ (instancetype)relationshipMappingFromKeyPath:(NSString *)sourceKeyPath toKeyPath:(NSString *)destinationKeyPath withMapping:(RKMapping *)mapping assignmentPolicy:(RKAssignmentPolicy)policy
{
    RKRelationshipMapping * relationshipMapping = [self relationshipMappingFromKeyPath:sourceKeyPath toKeyPath:destinationKeyPath withMapping:mapping];
    [relationshipMapping setAssignmentPolicy:policy];
    return relationshipMapping;
}

@end
