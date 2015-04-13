//
//  MHRope.m
//  SceneKitRope
//
//  Created by Michael Hill on 4/12/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.
//

#import "ALRope.h"

@implementation ALRope

{
    SCNMaterial *_ringTexture;
    NSMutableArray *_ropeRings;
}

//distance besteen each ring
static CGFloat const RINGS_DISTANCE_DEFAULT = 0.0;

static CGFloat const JOINTS_FRICTION_TORQUE_DEFAULT = 0;

static CGFloat const RING_SCALE_DEFAULT = 1;

static int const RING_COUNT_DEFAULT = 20;

static CGFloat const RINGS_Z_POSITION_DEFAULT = 1;

static BOOL const SHOULD_ENABLE_JOINTS_ANGLE_LIMITS_DEFAULT = NO;

static CGFloat const JOINT_LOWER_ANGLE_LIMIT_DEFAULT = -M_PI / 3;

static CGFloat const JOINT_UPPER_ANGLE_LIMIT_DEFAULT = M_PI / 3;

static CGFloat const RING_FRICTION_DEFAULT = 0;

static CGFloat const RING_RESTITUTION_DEFAULT = 0;

static CGFloat const RING_MASS_DEFAULT = -1;


-(instancetype)initWithMaterial:(SCNMaterial *)ringTexture andRingSegmentSize:(SCNVector3)ringSegmentSize
{
    if(self = [super init]) {
        _ringTexture = ringTexture;
        
        //apply defaults
        _startRingPosition = SCNVector3Zero;
        _ringSegmentSize = ringSegmentSize;
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
        position = SCNVector3Make(lastRing.position.x, lastRing.position.y - _ringSegmentSize.y - _ringsDistance, 0);
        lastRing = [self addRopeRingWithPosition:position underScene:scene];
    }
    
    [self addJointsWithScene:scene];
}

-(SCNNode *)addRopeRingWithPosition:(SCNVector3)position underScene:(SCNScene *)scene
{
    SCNBox *box = [SCNBox boxWithWidth:_ringSegmentSize.x height:_ringSegmentSize.y length:_ringSegmentSize.z chamferRadius:0.1];
    SCNNode *ring = [SCNNode nodeWithGeometry:box];
    ring.castsShadow = YES;
    ring.geometry.firstMaterial = _ringTexture;
    
    //ring.xScale = ring.yScale = _ringScale;
    ring.position = position;
    ring.physicsBody = [SCNPhysicsBody dynamicBody];
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
        
        SCNPhysicsBallSocketJoint *joint = [SCNPhysicsBallSocketJoint jointWithBodyA:nodeA.physicsBody anchorA:SCNVector3Make(0.0, -_ringSegmentSize.y/2 - _ringsDistance, 0) bodyB:nodeB.physicsBody anchorB:SCNVector3Make(0, _ringSegmentSize.y/2 + _ringsDistance, 0)];
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

-(SCNNode *)startRing
{
    return _ropeRings[0];
}

-(SCNNode *)lastRing
{
    return [_ropeRings lastObject];
}

@end
