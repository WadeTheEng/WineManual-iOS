//
//  WHOnboardingViewController.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHOnboardingViewController.h"
#import "UIFont+Edmondsans.h"

#import "WHOnboardingCardView.h"

@interface WHOnboardingViewController () <UIScrollViewDelegate>
{
    __weak IBOutlet UIImageView   *_backgroundImageView;
    __weak IBOutlet UIButton      *_startButton;
    __weak IBOutlet UIPageControl *_pageControl;
    __weak IBOutlet NSLayoutConstraint *_topLayoutContraint;
    
    UIDynamicAnimator * _dynamicAnimator;
    UIPushBehavior    * _userDragBehavior;
}
@end

@implementation WHOnboardingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_startButton.titleLabel setFont:[UIFont edmondsansBoldOfSize:17.0]];
    [_startButton.layer setCornerRadius:2.0];
    [_startButton.layer setMasksToBounds:YES];
    [_startButton addTarget:self action:@selector(_startButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    [effectX setMinimumRelativeValue:@(-25.0)];
    [effectX setMaximumRelativeValue:@(25.0)];
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    [effectY setMinimumRelativeValue:@(-25.0)];
    [effectY setMaximumRelativeValue:@(25.0)];
    
    [_backgroundImageView addMotionEffect:effectX];
    [_backgroundImageView addMotionEffect:effectY];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    [_pageControl setUserInteractionEnabled:NO];

    UITapGestureRecognizer * tapGesture = [UITapGestureRecognizer new];
    [tapGesture addTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];

    [self reload];
    
/*
    UIDynamicBehavior *behavior = [[UIDynamicBehavior alloc] init];

    UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:firstCard attachedToAnchor:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))];
    [attachment setFrequency:8.0];
    [attachment setDamping:0.9];
    [attachment setLength:0.0];
    [behavior addChildBehavior:attachment];

    UIDynamicAnimator * dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [dynamicAnimator addBehavior:behavior];

    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGesture:)];
    [firstCard addGestureRecognizer:gesture];
    
    _dynamicAnimator = dynamicAnimator;
 */
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (([UIScreen mainScreen].bounds.size.height > 480.0) == NO) {
        [_topLayoutContraint setConstant:20.0];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateBackgroundOffset];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, CGRectGetHeight(self.scrollView.bounds))];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark 
#pragma mark

- (void)reload
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //
    
    NSString * onboardingDataPath = [[NSBundle mainBundle] pathForResource:@"WHOnboardingData" ofType:@"plist"];
    NSArray * onboardingDataArray = [NSArray arrayWithContentsOfFile:onboardingDataPath];
    
    for (NSDictionary * cardDict in onboardingDataArray) {
        NSString * title    = cardDict[@"title"];
        NSString * detail   = cardDict[@"detail"];
        UIImage * iconImage = [UIImage imageNamed:cardDict[@"image_name"]];
        
        NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHOnboardingCard" owner:nil options:nil];
        WHOnboardingCardView * cardView = [views firstObject];
        [cardView setTitle:title
                    detail:detail
                      icon:iconImage];
        
        CGSize cardSize = cardView.frame.size;
        NSInteger index = [onboardingDataArray indexOfObject:cardDict];

        CGPoint origin = CGPointZero;
        origin.x = ((CGFloat)(index)*CGRectGetWidth(self.scrollView.bounds)) + ((CGRectGetWidth(self.scrollView.bounds) - cardSize.width) * 0.5);
        origin.y = ([UIScreen mainScreen].bounds.size.height > 480.0)?35.0:10.0;
        
        [cardView setFrame:(CGRect){origin,cardSize}];
        [self.scrollView addSubview:cardView];
    }

    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * onboardingDataArray.count, CGRectGetHeight(self.scrollView.frame))];
    [_pageControl setNumberOfPages:onboardingDataArray.count];
}

#pragma mark 

/*
- (void)_panGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if(_userDragBehavior) {
                [_dynamicAnimator removeBehavior:_userDragBehavior];
            }
             _userDragBehavior = [[UIPushBehavior alloc] initWithItems:@[recognizer.view] mode:UIPushBehaviorModeContinuous];
            [_dynamicAnimator addBehavior:_userDragBehavior];
        }
        case UIGestureRecognizerStateChanged:
            _userDragBehavior.pushDirection = CGVectorMake([recognizer translationInView:self.view].x, [recognizer translationInView:self.view].y);
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [_dynamicAnimator removeBehavior:_userDragBehavior];
            _userDragBehavior = nil;
            
        }
            break;
        default:
            break;
    }
}
 */

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture
{
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.bounds), self.scrollView.contentOffset.y);
    if (newOffset.x < self.scrollView.contentSize.width) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.bounds), self.scrollView.contentOffset.y) animated:YES];
    }
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float fractionalPage = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    NSInteger page = lround(fractionalPage);
    [_pageControl setCurrentPage:page];
    [self updateBackgroundOffset];
}

- (void)updateBackgroundOffset
{
    CGFloat ratio = (_backgroundImageView.frame.size.width/self.scrollView.contentSize.width);
    CGFloat off   = (self.scrollView.contentOffset.x*ratio)*0.5;
    [_backgroundImageView setTransform:CGAffineTransformMakeTranslation(-off+100.0f, 0)];
}

#pragma mark Actions

- (void)_startButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(onboardingViewController:didTapStartButton:)]) {
        [self.delegate onboardingViewController:self didTapStartButton:button];
    }
}

@end
