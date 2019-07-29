//
//  WHRootViewController.m
//  WineHound
//
//  Created by Mark Turner on 04/03/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHRootViewController.h"
#import "WHSideMenuViewController.h"

#import "UITabBarController+Rotation.h"
#import "UINavigationController+Rotation.h"
#import "UIFont+Edmondsans.h"

#import <PCDefaults/PCDOperationTracker.h>

@interface MMDrawerController ()
@property (nonatomic, strong) UIView * centerContainerView;
-(BOOL)isPointContainedWithinNavigationRect:(CGPoint)point;
-(UIView*)childControllerContainerView;
@end

@implementation WHRootViewController

#pragma mark

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UIViewController * leftDrawer   = [[UIStoryboard storyboardWithName:@"SideMenu" bundle:[NSBundle mainBundle]] instantiateInitialViewController];;
        UINavigationController * regionsNC    = [[UIStoryboard storyboardWithName:@"Regions"    bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        UINavigationController * wineriesNC   = [[UIStoryboard storyboardWithName:@"Wineries"   bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        UINavigationController * eventsNC     = [[UIStoryboard storyboardWithName:@"EventsCalendar" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        UINavigationController * favouritesNC = [[UIStoryboard storyboardWithName:@"Favourites" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        
        [regionsNC    setTitle:@"Regions"];
        [wineriesNC   setTitle:@"Wineries"];
        [eventsNC     setTitle:@"Events"];
        [favouritesNC setTitle:@"Favourites"];
        
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont edmondsansRegularOfSize:11.0]}
                                                 forState:UIControlStateNormal];

        [regionsNC    setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Regions"
                                                                  image:[UIImage imageNamed:@"tab_icon_regions_inactive"]
                                                          selectedImage:[UIImage imageNamed:@"tab_icon_regions_active"]]];
        [wineriesNC   setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Wineries"
                                                                  image:[UIImage imageNamed:@"tab_icon_wineries_inactive"]
                                                          selectedImage:[UIImage imageNamed:@"tab_icon_wineries_active"]]];
        [eventsNC     setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Events"
                                                                  image:[UIImage imageNamed:@"tab_icon_events_inactive"]
                                                          selectedImage:[UIImage imageNamed:@"tab_icon_events_active"]]];
        [favouritesNC setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Favourites"
                                                                  image:[UIImage imageNamed:@"tab_icon_favorites_inactive"]
                                                          selectedImage:[UIImage imageNamed:@"tab_icon_favorites_active"]]];
        
        /*
        [regionsNC registerWithOperationTracker];
        [wineriesNC registerWithOperationTracker];
        [eventsNC registerWithOperationTracker];
        [favouritesNC registerWithOperationTracker];
         */
        
        UITabBarController * tarBarController = [[UITabBarController alloc] init];
        [tarBarController setViewControllers:@[regionsNC,wineriesNC,eventsNC,favouritesNC]];
        
        __weak WHSideMenuViewController * sideMenuVC = (WHSideMenuViewController*)leftDrawer;
        
        [self setCenterViewController:tarBarController];
        [self setLeftDrawerViewController:leftDrawer];
        [self setRightDrawerViewController:nil];

        [self setOpenDrawerGestureModeMask:(MMOpenDrawerGestureModePanningNavigationBar|MMOpenDrawerGestureModeBezelPanningCenterView)];
        [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        [self setMaximumLeftDrawerWidth:215.0];
        [self setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
            [sideMenuVC setWineHoundLogoOffset:percentVisible];
        }];
    }
    return self;
}

#pragma mark 

- (BOOL)shouldAutorotate
{
    return [self.centerViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.centerViewController supportedInterfaceOrientations];
}

#pragma mark MMDrawerController overide

-(void)updateShadowForCenterView
{
    UIView * centerView = self.centerContainerView;
    if(self.showsShadow){
        centerView.layer.masksToBounds = NO;
        centerView.layer.shadowRadius  = 0.0;
        centerView.layer.shadowOpacity = 0.3;
        
        /** In the event this gets called a lot, we won't update the shadowPath
         unless it needs to be updated (like during rotation) */
        if (centerView.layer.shadowPath == NULL) {
            centerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.centerContainerView.bounds, -10.0, -10.0)] CGPath];
        }
        else{
            CGRect currentPath = CGPathGetPathBoundingBox(centerView.layer.shadowPath);
            if (CGRectEqualToRect(currentPath, centerView.bounds) == NO){
                centerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.centerContainerView.bounds, -10.0, -10.0)] CGPath];
            }
        }
    }
    else if (centerView.layer.shadowPath != NULL) {
        centerView.layer.shadowRadius = 0.f;
        centerView.layer.shadowOpacity = 0.f;
        centerView.layer.shadowPath = NULL;
        centerView.layer.masksToBounds = YES;
    }
}

-(BOOL)isPointContainedWithinNavigationRect:(CGPoint)point
{
    CGRect navigationBarRect = CGRectNull;
    CGRect tabBarRect        = CGRectNull;
    
    if([self.centerViewController isKindOfClass:[UINavigationController class]]){
        UINavigationBar * navBar = [(UINavigationController*)self.centerViewController navigationBar];
        navigationBarRect = [navBar convertRect:navBar.bounds toView:self.childControllerContainerView];
        navigationBarRect = CGRectIntersection(navigationBarRect,self.childControllerContainerView.bounds);
    }
    if([self.centerViewController isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabBarController = (UITabBarController *)self.centerViewController;

        UITabBar * tabBar = tabBarController.tabBar;
        tabBarRect = [tabBar convertRect:tabBar.bounds toView:self.childControllerContainerView];
        tabBarRect = CGRectIntersection(tabBarRect,self.childControllerContainerView.bounds);
        
        if([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]){
            UINavigationBar * navBar = [(UINavigationController*)tabBarController.selectedViewController navigationBar];
            navigationBarRect = [navBar convertRect:navBar.bounds toView:self.childControllerContainerView];
            navigationBarRect = CGRectIntersection(navigationBarRect,self.childControllerContainerView.bounds);
        }
    }
    return CGRectContainsPoint(navigationBarRect,point) || CGRectContainsPoint(tabBarRect,point);
}

@end
