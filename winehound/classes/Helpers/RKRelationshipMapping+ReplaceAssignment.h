//
//  RKRelationshipMapping+ReplaceAssignment.h
//  WineHound
//
//  Created by Mark Turner on 04/03/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "RKRelationshipMapping.h"

@interface RKRelationshipMapping (ReplaceAssignment)

+ (instancetype)relationshipMappingFromKeyPath:(NSString *)sourceKeyPath toKeyPath:(NSString *)destinationKeyPath withMapping:(RKMapping *)mapping assignmentPolicy:(RKAssignmentPolicy)policy;

@end
