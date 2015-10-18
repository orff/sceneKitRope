//
//  MHRope.m
//  SceneKitRope
//
//  Created by Michael Hill on 4/12/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.
//

#import "MHRope.h"

@implementation MHRope

{
    SCNMaterial *_ringTexture;
    NSMutableArray *_ropeRings;
}

//distance besteen each ring
static CGFloat const RINGS_DISTANCE_DEFAULT = 0.0;

static int const RING_COUNT_DEFAULT = 20;

static CGFloat const RING_FRICTION_DEFAULT = 0;
static CGFloat const RING_RESTITUTION_DEFAULT = 0;
static CGFloat const RING_MASS_DEFAULT = 20.0;


-(instancetype)initWithMaterial:(SCNMaterial *)ringTexture andRingSegmentSize:(SCNVector3)ringSegmentSize
{
    if(self = [super init]) {
        _ringTexture = ringTexture;
        
        //apply defaults
        _startRingPosition = SCNVector3Zero;
        _ringSegmentSize = ringSegmentSize;
        _ringsDistance = RINGS_DISTANCE_DEFAULT;
        _ringCount = RING_COUNT_DEFAULT;
        
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
    ring.geometry.firstMaterial = _ringTexture;
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
        
        [scene.physicsWorld addBehavior:joint];
    }
}

-(void)clampRingPositions
{
    for(int i = 1; i < _ropeRings.count; i++) {
        SCNNode *ring1 = (SCNNode *)_ropeRings[i - 1];
        SCNNode *ring2 = (SCNNode *)_ropeRings[i];
        
        SCNVector3 origPos = [ring1 presentationNode].position;
        SCNVector3 newPos = [ring2 presentationNode].position;
        
        float dist = sqrt((newPos.x - origPos.x) * (newPos.x - origPos.x) + (newPos.y - origPos.y) * (newPos.y - origPos.y) +(newPos.z - origPos.z) * (newPos.z - origPos.z)); //fastest
        
        SCNVector3 midPt = SCNVector3Make(
                                          (newPos.x + origPos.x)/2,
                                          (newPos.y + origPos.y)/2,
                                          (newPos.z + origPos.z)/2);
        
        if (dist>1.0) ring2.position = midPt;
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
