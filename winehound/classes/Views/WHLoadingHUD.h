//
//  WHLoadingHUD.h
//  WineHound
//
//  Created by Mark Turner on 11/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PCDefaults/PCDCollectionManager.h>

@interface WHLoadingHUD : UIView <PCDLoadingHUDViewProtocol>
+ (void)show;
+ (void)dismiss;
@end

/*
 Value in which Windows with lower level be seeked below.
 */
extern const UIWindowLevel WHLoadingHUDMaxWindowLevel;
