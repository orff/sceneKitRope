//
//  ALRope.h
//  RopeDemo
//
//  Created by alayouni on 1/18/15.
//  Copyright (c) 2015 com.alayouni. All rights reserved.
//

//#import <SpriteKit/SpriteKit.h>
#import <SceneKit/SceneKit.h>

@interface ALRope : NSObject

@property(nonatomic, readonly) NSArray *ropeRings;

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



-(instancetype)initWithMaterial:(SCNMaterial *)ringTexture;

-(void)buildRopeWithScene:(SCNScene *)scene;

-(void)adjustRingPositions;

-(SCNNode *)startRing;

-(SCNNode *)lastRing;

@end
