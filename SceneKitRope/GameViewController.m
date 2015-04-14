//
//  GameViewController.m
//  RopeSwing
//
//  Created by Michael Hill on 4/9/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.
//

#import "GameViewController.h"
#import "MHRope.h"

@implementation GameViewController {
    __weak SCNNode *_branch;
    
    BOOL _branchIsMoving;
    
    MHRope *_rope;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SETTINGS
    float handleHeight = 1.5;
    
    SCNVector3 ringSegmentSize = SCNVector3Make(0.2, 0.4, 0.2);
    SCNVector3 backgroundSize = SCNVector3Make(10.0, 10.0, 2.0);
    bool useSpotlight = NO;
#if (TARGET_IPHONE_SIMULATOR)
    useSpotlight = NO;
#endif
    
    // create a new scene
    SCNScene *scene = [SCNScene scene];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    if (useSpotlight) {
        lightNode.light.color = [SKColor colorWithWhite:0.2 alpha:1.0];
    } else {
        lightNode.light.color = [SKColor colorWithWhite:0.6 alpha:1.0];
    }
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor grayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    if (useSpotlight) {
        SCNNode *spotLightNode = [SCNNode node];
        spotLightNode.light = [SCNLight light];
        spotLightNode.light.type = SCNLightTypeSpot;
        spotLightNode.light.castsShadow = YES;
        spotLightNode.light.color = [UIColor colorWithWhite:0.5 alpha:1.0];
        spotLightNode.position = SCNVector3Make(0, 10, 15);
        spotLightNode.eulerAngles = SCNVector3Make(0,0 ,  M_2_PI/2);
        spotLightNode.light.spotInnerAngle = 0;
        spotLightNode.light.spotOuterAngle = 75;
        spotLightNode.light.shadowColor = [SKColor blackColor];
        
        [scene.rootNode addChildNode:spotLightNode];
    }
    
    //add floor
    SCNNode *floorNode = [SCNNode node];
    floorNode.position = SCNVector3Make(0, -backgroundSize.y/2, 0);
    floorNode.name = @"floor";
    
    SCNFloor *floor = [SCNFloor floor];
    floorNode.geometry = floor;
    floorNode.physicsBody = [SCNPhysicsBody kinematicBody];
    [scene.rootNode addChildNode:floorNode];
    
    /////////
    
    //add background?
    SCNNode *bgBox = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:backgroundSize.x height:backgroundSize.y length:backgroundSize.z chamferRadius:0]];
    bgBox.name = @"bgBox";
    bgBox.physicsBody = [SCNPhysicsBody kinematicBody];
    
    bgBox.position = SCNVector3Make(0, 2.0, -3.0);
    [[scene rootNode] addChildNode:bgBox];
    
    // add the branch at the top
    SCNNode *branch = [SCNNode nodeWithGeometry:[SCNCylinder cylinderWithRadius:0.3 height:handleHeight]];
    branch.name = @"branch";
    branch.geometry.firstMaterial.diffuse.contents = [SKColor redColor];
    branch.physicsBody = [SCNPhysicsBody staticBody];
    //branch.eulerAngles = SCNVector3Make(0, 0, M_PI_2);
    
    branch.position = SCNVector3Make(0, 4.0, 0);
    [[scene rootNode] addChildNode:branch];
    
    //create the rope
    SCNMaterial *ropeMaterial = [SCNMaterial material];
    ropeMaterial.diffuse.contents = [SKColor grayColor];
    ropeMaterial.reflective.contents = @"chrome.jpg";
    ropeMaterial.reflective.intensity = 0.65;
    ropeMaterial.specular.contents = [SKColor colorWithWhite:0.9 alpha:1.0];
    ropeMaterial.shininess = 1.0;
    _rope = [[MHRope alloc] initWithMaterial:ropeMaterial andRingSegmentSize:ringSegmentSize];
    
    //
    //    //configure rope params if needed
    //    //    _rope.ringCount = ...;//default is 30
    //    //    _rope.ringScale = ...;//default is 1
    //    //    _rope.ringsDistance = ...;//default is 0
    //    //    _rope.ringRestitution = ...;//default is 0
    //    //    _rope.ringMass = ...;//ignored unless mass > 0; default -1
    //
    
    //params used
    _rope.ringsDistance = 0.025;
    _rope.ringFriction = 0.5;
    _rope.ringMass = 5.0;
    
    _rope.startRingPosition = SCNVector3Make(branch.position.x, branch.position.y - handleHeight/2 - ringSegmentSize.y/2, branch.position.z);
    [_rope buildRopeWithScene:scene];
    
    //attach rope to branch
    SCNNode *startRing = [_rope startRing];
    
    SCNPhysicsBallSocketJoint *joint = [SCNPhysicsBallSocketJoint jointWithBodyA:branch.physicsBody anchorA:SCNVector3Make(0.0, -handleHeight/2, 0) bodyB:startRing.physicsBody anchorB:SCNVector3Make(0, ringSegmentSize.y/2 +  _rope.ringsDistance, 0)];
    [scene.physicsWorld addBehavior:joint];
    
    ///////////
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    scnView.scene.physicsWorld.speed = 2.5;
    
    // allows the user to manipulate the camera
    //scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    //scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [gestureRecognizers addObject:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [gestureRecognizers addObject:panGesture];
    
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
    
}

-(SCNHitTestResult *)dragPlaneResult:(NSArray *)hitResults {
    //finds the first backWall node inside of hitTest results
    
    for (SCNHitTestResult *result in hitResults) {
        if ([result.node.name isEqualToString:@"bgBox"]) {
            return result;
            break;
        }
        //NSLog(@"hitName: %@", result.node.name);
    }
    
    return nil;
}

- (void) handlePan:(UIGestureRecognizer*)gestureRecognize {
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    SCNHitTestResult *dragPlaneResult = [self dragPlaneResult:hitResults];
    
    //only allow dragging around on background box
    if(dragPlaneResult){
        SCNNode *branch = [[[(SCNView *)self.view scene] rootNode] childNodeWithName:@"branch" recursively:NO];
        if (branch) {
            branch.position = SCNVector3Make(dragPlaneResult.worldCoordinates.x, dragPlaneResult.worldCoordinates.y, 0);
        }
    }
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        if (![result.node.name isEqualToString:@"floor"]) {
            // get its material
            SCNMaterial *material = result.node.geometry.firstMaterial;
            
            // highlight it
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            // on completion - unhighlight
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.5];
                
                material.emission.contents = [UIColor blackColor];
                
                [SCNTransaction commit];
            }];
            
            material.emission.contents = [UIColor redColor];
            
            [SCNTransaction commit];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
