/*
 File: UBKAccessibilityTouchAnimations.m
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

#import "UBKAccessibilityTouchAnimations.h"
#import "UBKAccessibilityTouchView.h"

@interface UBKAccessibilityTouchAnimations ()
@property (nonatomic, weak) UIView *view;
@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) BOOL isDrawing;
@end

@implementation UBKAccessibilityTouchAnimations

- (instancetype)initWithView:(UIView *)view
{
    if (self = [super init])
    {
        self.view = view;
    }
    return self;
}

//Handle touch or swipe on screen when animations are enabled.
- (void)touchDidHappen:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        switch ([touch phase])
        {
            case UITouchPhaseBegan:
            {
                CGPoint pointTmp = [touch locationInView:self.view];
                self.previousPoint = pointTmp;
                [self addTouchEvent:touch];
                break;
            }
            case UITouchPhaseEnded:
            {
                if (self.isDrawing)
                {
                    [self addTouchEvent:touch];
                }
                self.isDrawing = false;
                break;
            }
            case UITouchPhaseMoved:
            {
                [self moveTouchEvent:touch];
                break;
            }
            case UITouchPhaseCancelled:
            case UITouchPhaseStationary:
            {
                break;
            }
        }
    }
}

//Adds the single touch point
- (void)addTouchEvent:(UITouch *)touch
{
    CGFloat size = 44;
    CGPoint pointTmp = [touch locationInView:self.view];
    pointTmp = CGPointMake(pointTmp.x - (size/2), pointTmp.y - (size/2));
    
    __block UBKAccessibilityTouchView *addTouchView = [[UBKAccessibilityTouchView alloc]initWithFrame:CGRectMake(pointTmp.x, pointTmp.y, size, size)];
    [self.view addSubview:addTouchView];

    //Add animations
    CAAnimationGroup *group = [self addAnimationsWithScale:true];
    [addTouchView.layer addAnimation:group forKey:@"touchEventAnimation"];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4 repeats:0 block:^(NSTimer * _Nonnull timer) {
        [addTouchView removeFromSuperview];
    }];
}

//Used to draw the swipe on screen
- (void)moveTouchEvent:(UITouch *)touch
{
    CGFloat size = 4;
    CGPoint pointTmp = [touch locationInView:self.view];
    pointTmp = CGPointMake(pointTmp.x - (size/2), pointTmp.y - (size/2));
    CGPoint oldPoint = CGPointMake(self.previousPoint.x - (size/2), self.previousPoint.y - (size/2));
    
    if (((floor(oldPoint.x) == floor(pointTmp.x)) && (floor(oldPoint.y) == floor(pointTmp.y))) && (self.isDrawing == false))
    {
        return;
    }
    self.isDrawing = true;
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    [path moveToPoint:self.previousPoint];
    [path addLineToPoint:pointTmp];
    
    __block CAShapeLayer *shapeLayer = [[CAShapeLayer alloc]init];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
    shapeLayer.lineWidth = size;
    [self.view.layer addSublayer:shapeLayer];

    //Add animations
    CAAnimationGroup *group = [self addAnimationsWithScale:false];
    [shapeLayer addAnimation:group forKey:@"touchEventAnimation"];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4 repeats:0 block:^(NSTimer * _Nonnull timer) {
        [shapeLayer removeFromSuperlayer];
    }];
    
    self.previousPoint = pointTmp;
}

- (CAAnimationGroup *)addAnimationsWithScale:(BOOL)addScale
{
    NSMutableArray *animationArray = [[NSMutableArray alloc]init];

    //Scale
    if (addScale)
    {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0.6];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1.4];
        [animationArray addObject:scaleAnimation];
    }
    
    //Fade out
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithDouble:1.0];
    fadeAnimation.toValue = [NSNumber numberWithDouble:0.0];
    [animationArray addObject:fadeAnimation];
    
    //Animation group
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.3;
    group.removedOnCompletion = false;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.animations = animationArray;
    return group;
}

@end
