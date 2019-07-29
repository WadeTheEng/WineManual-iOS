//
//  WHAboutViewController.h
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCActionButton;
@interface WHAboutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel     * aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel     * versionLabel;
@property (weak, nonatomic) IBOutlet UIButton    * termsButton;
@property (weak, nonatomic) IBOutlet UIButton    * privacyButton;
@property (weak, nonatomic) IBOutlet UIImageView * papercloudImageView;
@property (weak, nonatomic) IBOutlet UILabel        * contactLabel;
@property (weak, nonatomic) IBOutlet PCActionButton * contactButton;
@end
