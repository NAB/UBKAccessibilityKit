/*
 File: CALayer+HelperMethods.m
 Project: UBKAccessibilityKit
 Version: 1.0
 
 Copyright 2019 UBank - a division of National Australia Bank Limited
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "CALayer+HelperMethods.h"
#import "UBKAccessibilityShapeLayer.h"

@implementation CALayer (HelperMethods)

- (void)ubk_showLayerBoxWithColour:(UIColor *)colour
{
    BOOL hasShapeLayer = false;
    
    for (CALayer *layer in self.sublayers)
    {
        if ([layer isKindOfClass:[UBKAccessibilityShapeLayer class]])
        {
            hasShapeLayer = true;
            break;
        }
    }
    
    if (!hasShapeLayer)
    {
        UBKAccessibilityShapeLayer *shapeLayer = [[UBKAccessibilityShapeLayer alloc]initWithSize:self.bounds.size withColour:colour];
        [self addSublayer:shapeLayer];
    }
}

- (void)ubk_hideLayerBox
{
    NSMutableArray *removeLayers = [[NSMutableArray alloc]init];
    
    for (CALayer *layer in self.sublayers)
    {
        if ([layer isKindOfClass:[UBKAccessibilityShapeLayer class]])
        {
            [removeLayers addObject:layer];
        }
    }
    
    for (CALayer *layer in removeLayers)
    {
        [layer removeFromSuperlayer];
    }
}


@end
