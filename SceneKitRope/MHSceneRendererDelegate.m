//
//  MHSceneRendererDelegate.m
//  SceneKitRope
//
//  Created by alayouni on 6/19/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.
//

#import "MHSceneRendererDelegate.h"

@implementation MHSceneRendererDelegate
{
    __weak MHRope *_rope;
    
    __weak SCNNode *_branch;
}

-(instancetype)initWithRope:(MHRope *)rope branch:(SCNNode *)branch
{
    if(self =[super init]) {
        _rope = rope;
        _branch = branch;
    }
    return self;
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time
{
    [_rope clampRingPositions];
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer didSimulatePhysicsAtTime:(NSTimeInterval)time
{
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer updateAtTime:(NSTimeInterval)time
{
    
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time
{
    
}

@end
