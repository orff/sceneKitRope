//
//  MHRope.h
//  SceneKitRope
//
//  Created by Michael Hill on 4/12/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.

//#import <SpriteKit/SpriteKit.h>
#import <SceneKit/SceneKit.h>

@interface MHRope : NSObject

@property(nonatomic, readonly) NSArray *ropeRings;
@property(nonatomic) SCNVector3 ringSegmentSize;

@property(nonatomic) int ringCount;

@property(nonatomic) CGFloat ringScale;

@property(nonatomic) CGFloat ringsDistance;

@property(nonatomic) CGFloat jointsFrictionTorque;

@property(nonatomic) CGFloat ringsZPosition;

@property(nonatomic) SCNVector3 startRingPosition;

@property(nonatomic) CGFloat ringFriction;

@property(nonatomic) CGFloat ringRestitution;

@property(nonatomic) CGFloat ringMass;


@property(nonatomic) BOOL shouldEnableJointsAngleLimits;

@property(nonatomic) CGFloat jointsLowerAngleLimit;

@property(nonatomic) CGFloat jointsUpperAngleLimit;



-(instancetype)initWithMaterial:(SCNMaterial *)ringTexture andRingSegmentSize:(SCNVector3)ringSegmentSize;

-(void)buildRopeWithScene:(SCNScene *)scene;

-(SCNNode *)startRing;

-(SCNNode *)lastRing;

@end
