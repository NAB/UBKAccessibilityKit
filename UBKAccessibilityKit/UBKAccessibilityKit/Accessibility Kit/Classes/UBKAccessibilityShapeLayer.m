/*
 File: UBKAccessibilityShapeLayer.m
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

#import "UBKAccessibilityShapeLayer.h"
#import <UIKit/UIKit.h>

@implementation UBKAccessibilityShapeLayer

- (instancetype)initWithSize:(CGSize)size withColour:(UIColor *)colour
{
    if (self = [super init])
    {
        CGFloat buffer = 0;
        if (UIAccessibilityIsReduceMotionEnabled())
        {
            buffer = 5;
        }
        self.frame = CGRectMake(-buffer, -buffer, size.width + (2 * buffer), size.height + (2 * buffer));
        self.borderColor = colour.CGColor;
        self.borderWidth = 2;
        self.cornerRadius = 5;
        [self startAnimating];
    }
    return self;
}

- (void)startAnimating
{
    if (!UIAccessibilityIsReduceMotionEnabled())
    {
        [self animateToScale:1.05];
    }
}

- (void)animateToScale:(CGFloat)scaleVal
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    scale.duration = 0.1f;
    CATransform3D tr = CATransform3DIdentity;
    tr = CATransform3DScale(tr, scaleVal, scaleVal, 1);
    scale.toValue = [NSValue valueWithCATransform3D:tr];
    scale.removedOnCompletion = false;
    scale.repeatCount = 2;
    scale.autoreverses = true;
    [self addAnimation:scale forKey:@"animate"];
}

@end
