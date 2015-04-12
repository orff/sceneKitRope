//
//  GameViewController.m
//  RopeSwing
//
//  Created by Michael Hill on 4/9/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.
//

#import "GameViewController.h"
#import "ALRope.h"

@implementation GameViewController {
    __weak SCNNode *_branch;
    
    BOOL _branchIsMoving;
    
    ALRope *_rope;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create a new scene
    SCNScene *scene = [SCNScene scene];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zNear = 1.0;
    cameraNode.camera.zFar = 400.0;
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor grayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    /////////
    
    //add background?
    SCNNode *bgBox = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:10 height:10 length:2 chamferRadius:0]];
    bgBox.name = @"bgBox";
    bgBox.position = SCNVector3Make(0, 0, -2.0);
    [[scene rootNode] addChildNode:bgBox];
    
    // add the branch at the top
    SCNNode *branch = [SCNNode nodeWithGeometry:[SCNCylinder cylinderWithRadius:0.2 height:2.0]];
    branch.name = @"branch";
    branch.geometry.firstMaterial.diffuse.contents = [SKColor redColor];
    branch.physicsBody = [SCNPhysicsBody kinematicBody];
    //branch.eulerAngles = SCNVector3Make(0, 0, M_PI_2);
    
    branch.position = SCNVector3Make(0, 4.0, 0);
    [[scene rootNode] addChildNode:branch];
    
//    SCNNode *branch2 = [SCNNode nodeWithGeometry:[SCNCylinder cylinderWithRadius:0.2 height:2.0]];
//    branch2.geometry.firstMaterial.diffuse.contents = [SKColor blueColor];
//    branch2.physicsBody = [SCNPhysicsBody dynamicBody];
//    //branch2.eulerAngles = SCNVector3Make(0, 0, M_PI_2);
//    
//    branch2.position = SCNVector3Make(0, 2.0, 0);
//    [[scene rootNode] addChildNode:branch2];
//    
//    SCNPhysicsBallSocketJoint *joint = [SCNPhysicsBallSocketJoint jointWithBodyA:branch.physicsBody anchorA:SCNVector3Make(0.0, -1.1, 0) bodyB:branch2.physicsBody anchorB:SCNVector3Make(0, 1.1, 0)];
//    [scene.physicsWorld addBehavior:joint];
    
    //create the rope
        SCNMaterial *ropeMaterial = [SCNMaterial material];
        _rope = [[ALRope alloc] initWithMaterial:ropeMaterial];
    //
    //
    //    //configure rope params if needed
    //    //    _rope.ringCount = ...;//default is 30
    //    //    _rope.ringScale = ...;//default is 1
    //    //    _rope.ringsDistance = ...;//default is 0
    //    //    _rope.jointsFrictionTorque = ...;//default is 0
    //    //    _rope.ringsZPosition = ...;//default is 1
    //    //    _rope.ringFriction = ...;//default is 0
    //    //    _rope.ringRestitution = ...;//default is 0
    //    //    _rope.ringMass = ...;//ignored unless mass > 0; default -1
    //    //    _rope.shouldEnableJointsAngleLimits = ...;//default is NO
    //    //    _rope.jointsLowerAngleLimit = ...;//default is -M_PI/3
    //    //    _rope.jointsUpperAngleLimit = ...;//default is M_PI/3
    //
        _rope.startRingPosition = SCNVector3Make(branch.position.x, branch.position.y - 2.0, branch.position.z);
        [_rope buildRopeWithScene:scene];
    
    //attach rope to branch
    SCNNode *startRing = [_rope startRing];
    
    SCNPhysicsBallSocketJoint *joint = [SCNPhysicsBallSocketJoint jointWithBodyA:branch.physicsBody anchorA:SCNVector3Make(0.0, -1.1, 0) bodyB:startRing.physicsBody anchorB:SCNVector3Make(0, 1.1, 0)];
    [scene.physicsWorld addBehavior:joint];
    
//    SCNVector3 jointAnchor = SCNVector3Make(startRing.position.x, startRing.position.y + 1.0 / 2, 0);
//    
//    SCNPhysicsHingeJoint *joint = [SCNPhysicsHingeJoint jointWithBodyA:branch.physicsBody axisA:SCNVector3Make(0, 1.0, 0) anchorA:jointAnchor bodyB:startRing.physicsBody axisB:SCNVector3Make(0, 0, 0) anchorB:SCNVector3Make(0, 0, 0)];
//    
//    [scene.physicsWorld addBehavior:joint];
    
    ///////////
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    //scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor grayColor];
    
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [gestureRecognizers addObject:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [gestureRecognizers addObject:panGesture];
    
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
    
}

- (void) handlePan:(UIGestureRecognizer*)gestureRecognize {
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    //if (gestureRecognize.state == UIGestureRecognizerStateChanged) {
        // check that we clicked on at least one object
        if([hitResults count] > 0){
            SCNHitTestResult *result = [hitResults objectAtIndex:0];
            
            //only allow dragging around on background box
            if ([result.node.name isEqualToString:@"bgBox"]) {
                SCNNode *branch = [[[(SCNView *)self.view scene] rootNode] childNodeWithName:@"branch" recursively:NO];
                if (branch) {
                    branch.position = SCNVector3Make(result.worldCoordinates.x, result.worldCoordinates.y, 0);
                }
            }
        }
    //}
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
