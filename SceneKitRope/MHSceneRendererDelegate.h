//
//  MHSceneRendererDelegate.h
//  SceneKitRope
//
//  Created by alayouni on 6/19/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "MHRope.h"

@interface MHSceneRendererDelegate: NSObject<SCNSceneRendererDelegate>

-(instancetype)initWithRope:(MHRope *)rope;

@end
