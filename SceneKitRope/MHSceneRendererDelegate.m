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
}

-(instancetype)initWithRope:(MHRope *)rope;
{
    if(self =[super init]) {
        _rope = rope;
    }
    return self;
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time
{
    [_rope adjustRingsPositions];
}

@end
