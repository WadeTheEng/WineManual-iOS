//
//  WHPanoramaViewController.m
//  WineHound
//
//  Created by Mark Turner on 25/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

#import "WHPanoramaViewController.h"

#import "PanoramaView.h"
#import "Sphere.h"

@interface WHPanoramaViewController () <GLKViewDelegate>

@property (weak, nonatomic) GLKView   * glkView;
@property (nonatomic) CMMotionManager * motionManager;

@property (strong, nonatomic) EAGLContext     * context;
@property (strong, nonatomic) GLKTextureInfo  * cubemap;
@property (strong, nonatomic) GLKSkyboxEffect * skyboxEffect;

@end

@implementation WHPanoramaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"Cellar Door 360°"];

    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (context == nil) {
        NSLog(@"Failed to create ES context");
    }
    
    PanoramaView * panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self.pathToPanoramaTexture != nil) {
        [panoramaView setTexture:self.pathToPanoramaTexture];
    } else {
        [panoramaView setTexture:@"park_2048.jpg"];
    }
    [panoramaView setOrientToDevice:YES];  // YES: use accel/gyro. NO: use touch pan gesture
    [panoramaView setPinchZoom:YES];  // pinch to change field of view
    [panoramaView setDelegate:self];
    [panoramaView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:panoramaView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[panoramaView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(panoramaView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[panoramaView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(panoramaView)]];


    _glkView = panoramaView;
    _context = context;

    [self setupGL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self establishMotionManager];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self shutDownMotionManager];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    [self setContext:nil];
}

#pragma mark Actions

- (void)_tapGesture:(UITapGestureRecognizer *)tapGesture
{
    BOOL isHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark
#pragma mark

- (void)shutDownMotionManager
{
    [self.motionManager stopDeviceMotionUpdates];
    _motionManager = nil;
}

- (void)establishMotionManager
{
    if (_motionManager != nil) [self shutDownMotionManager];
    
    // Establish the motion manager
    CMMotionManager * motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable) {
        __weak typeof (self) weakSelf = self;
        [motionManager setDeviceMotionUpdateInterval:1.0/45.0];
        //CMAttitudeReferenceFrameXTrueNorthZVertical
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                           toQueue:[NSOperationQueue currentQueue]
                                                       withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                           [weakSelf update];
                                                       }];
    }
    _motionManager = motionManager;
}

#pragma mark
#pragma mark

- (void)setupGL
{
    /*
    [EAGLContext setCurrentContext:self.context];
    
    NSError * error = nil;
    NSString * cubemapPath = [[NSBundle mainBundle] pathForResource:@"cubemap" ofType:@"jpg"];
    GLKTextureInfo * cubemap = [GLKTextureLoader cubeMapWithContentsOfFile:cubemapPath
                                                                   options:@{GLKTextureLoaderOriginBottomLeft: @(YES)}
                                                                     error:&error];
    GLKSkyboxEffect * skyboxEffect = [[GLKSkyboxEffect alloc] init];
    [skyboxEffect.textureCubeMap setName:cubemap.name];
    
    _cubemap      = cubemap;
    _skyboxEffect = skyboxEffect;
     */
}

#pragma mark 
#pragma mark 

- (void)update
{
    /*
    CGFloat aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    CMRotationMatrix rM = [self.motionManager.deviceMotion.attitude rotationMatrix];
    GLKMatrix4 modelViewMatrix = GLKMatrix4Make(rM.m11, rM.m21, rM.m31, 0.0f,
                                                rM.m12, rM.m22, rM.m32, 0.0f,
                                                rM.m13, rM.m23, rM.m33, 0.0f,
                                                0.0f,   0.0f,   0.0f,   1.0f);
    
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, M_PI/2.0, 1.0f, 0.0f, 0.0f);
    
    [self.skyboxEffect.transform setProjectionMatrix:projectionMatrix];
    [self.skyboxEffect.transform setModelviewMatrix:modelViewMatrix];
    
     */
    [self.glkView display];
}

#pragma mark GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [(PanoramaView*)self.glkView execute];
    /*
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.skyboxEffect prepareToDraw];
    [self.skyboxEffect draw];
     */
}

@end