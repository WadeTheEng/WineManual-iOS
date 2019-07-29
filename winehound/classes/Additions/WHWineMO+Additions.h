//
//  WHWineMO+Additions.h
//  WineHound
//
//  Created by Mark Turner on 10/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHWineMO.h"
#import "WHShareProtocol.h"

@interface WHWineMO (Additions) <WHShareProtocol>
/*
 Returns a formatted string with the locale identifier 'au_AU'
 */
- (NSString *)costString;
@end
