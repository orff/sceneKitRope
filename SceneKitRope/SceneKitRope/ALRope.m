//
//  ALRope.m
//  RopeDemo
//
//  Created by alayouni on 1/18/15.
//  Copyright (c) 2015 com.alayouni. All rights reserved.
//

#import "ALRope.h"

@implementation ALRope

{
    SCNMaterial *_ringTexture;
    NSMutableArray *_ropeRings;
}

static CGFloat const RINGS_DISTANCE_DEFAULT = 0;

static CGFloat const JOINTS_FRICTION_TORQUE_DEFAULT = 0;

static CGFloat const RING_SCALE_DEFAULT = 1;

static int const RING_COUNT_DEFAULT = 10;

static CGFloat const RINGS_Z_POSITION_DEFAULT = 1;

static BOOL const SHOULD_ENABLE_JOINTS_ANGLE_LIMITS_DEFAULT = NO;

static CGFloat const JOINT_LOWER_ANGLE_LIMIT_DEFAULT = -M_PI / 3;

static CGFloat const JOINT_UPPER_ANGLE_LIMIT_DEFAULT = M_PI / 3;

static CGFloat const RING_FRICTION_DEFAULT = 0;

static CGFloat const RING_RESTITUTION_DEFAULT = 0;

static CGFloat const RING_MASS_DEFAULT = -1;


-(instancetype)initWithMaterial:(SCNMaterial *)ringTexture
{
    if(self = [super init]) {
        _ringTexture = ringTexture;
        
        //apply defaults
        _startRingPosition = SCNVector3Zero;
        _ringsDistance = RINGS_DISTANCE_DEFAULT;
        _jointsFrictionTorque = JOINTS_FRICTION_TORQUE_DEFAULT;
        _ringScale = RING_SCALE_DEFAULT;
        _ringCount = RING_COUNT_DEFAULT;
        _ringsZPosition = RINGS_Z_POSITION_DEFAULT;
        _shouldEnableJointsAngleLimits = SHOULD_ENABLE_JOINTS_ANGLE_LIMITS_DEFAULT;
        _jointsLowerAngleLimit = JOINT_LOWER_ANGLE_LIMIT_DEFAULT;
        _jointsUpperAngleLimit = JOINT_UPPER_ANGLE_LIMIT_DEFAULT;
        _ringFriction = RING_FRICTION_DEFAULT;
        _ringRestitution = RING_RESTITUTION_DEFAULT;
        _ringMass = RING_MASS_DEFAULT;
    }
    return self;
}


-(void)buildRopeWithScene:(SCNScene *)scene
{
    _ropeRings = [NSMutableArray new];
    SCNNode *firstRing = [self addRopeRingWithPosition:_startRingPosition underScene:scene];
    
    SCNNode *lastRing = firstRing;
    SCNVector3 position;
    for (int i = 1; i < _ringCount; i++) {
        float ringHeight = 1.0;
        position = SCNVector3Make(lastRing.position.x, lastRing.position.y - ringHeight - _ringsDistance, 0);
        lastRing = [self addRopeRingWithPosition:position underScene:scene];
    }
    
    [self addJointsWithScene:scene];
}

-(SCNNode *)addRopeRingWithPosition:(SCNVector3)position underScene:(SCNScene *)scene
{
    SCNBox *box = [SCNBox boxWithWidth:1.0 height:1.0 length:1.0 chamferRadius:0.1];
    SCNNode *ring = [SCNNode nodeWithGeometry:box];
    ring.geometry.firstMaterial = _ringTexture;
    
    //ring.xScale = ring.yScale = _ringScale;
    ring.position = position;
    ring.physicsBody = [SCNPhysicsBody dynamicBody];
//    ring.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ring.size.height / 2];
//    ring.physicsBody.allowsRotation = YES;
    ring.physicsBody.friction = _ringFriction;
    ring.physicsBody.restitution = _ringRestitution;
    if(_ringMass > 0) {
        ring.physicsBody.mass = _ringMass;
    }
    
    [[scene rootNode] addChildNode:ring];
    [_ropeRings addObject:ring];
    return ring;
}

-(void)addJointsWithScene:(SCNScene *)scene
{
    for (int i = 1; i < _ropeRings.count; i++) {
        SCNNode *nodeA = [_ropeRings objectAtIndex:i-1];
        SCNNode *nodeB = [_ropeRings objectAtIndex:i];
        
        SCNPhysicsBallSocketJoint *joint = [SCNPhysicsBallSocketJoint jointWithBodyA:nodeA.physicsBody anchorA:SCNVector3Make(0.0, -0.51, 0) bodyB:nodeB.physicsBody anchorB:SCNVector3Make(0, 0.51, 0)];
        [scene.physicsWorld addBehavior:joint];
        
//        SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody
//                                                               bodyB:nodeB.physicsBody
//                                                              anchor:CGPointMake(nodeA.position.x,
//                                                                                 nodeA.position.y - (nodeA.size.height + _ringsDistance) / 2)];
//        joint.frictionTorque = _jointsFrictionTorque;
//        joint.shouldEnableLimits = _shouldEnableJointsAngleLimits;
//        if(_shouldEnableJointsAngleLimits) {
//            joint.lowerAngleLimit = _jointsLowerAngleLimit;
//            joint.upperAngleLimit = _jointsUpperAngleLimit;
//        }
//        [scene.physicsWorld addJoint:joint];
        
        [scene.physicsWorld addBehavior:joint];
    }
}

//workaround for elastic effect should be called from didSimulatePhysics
-(void)adjustRingPositions
{
    //based on zRotations of all rings and the position of start ring adjust the rest of the rings positions starting from top to bottom
    for (int i = 1; i < _ropeRings.count; i++) {
        SCNNode *nodeA = [_ropeRings objectAtIndex:i-1];
        SCNNode *nodeB = [_ropeRings objectAtIndex:i];
        CGFloat thetaA = nodeA.rotation.y - M_PI / 2, // Y, NOT Z ?
        thetaB = nodeB.rotation.y + M_PI / 2,
        ringHeight = 1.0,
        jointRadius = (_ringsDistance + ringHeight) / 2,
        xJoint = jointRadius * cosf(thetaA) + nodeA.position.x,
        yJoint = jointRadius * sinf(thetaA) + nodeA.position.y,
        theta = thetaB - M_PI,
        xB = jointRadius * cosf(theta) + xJoint,
        yB = jointRadius * sinf(theta) + yJoint;
        
        nodeB.position = SCNVector3Make(xB, yB,0);
    }
}

-(SCNNode *)startRing
{
    return _ropeRings[0];
}

-(SCNNode *)lastRing
{
    return [_ropeRings lastObject];
}

@end
