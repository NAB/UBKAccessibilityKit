/*
 File: UBKBadgeLayer.m
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

#import "UBKBadgeLayer.h"
#import "UIColor+HelperMethods.h"

@interface UBKBadgeLayer ()
//Text layer shown on the badge.
@property (nonatomic) CATextLayer *textLayer;
@end

@implementation UBKBadgeLayer

- (instancetype)init
{
    if (self = [super init])
    {
        //Magic numbers to set the size of the label and font.
        UIFont *font = [UIFont boldSystemFontOfSize:17];
        CGFloat width = 20;
        CGFloat height = 20;
        
        //The text layer is a sublayer of the badge layer. The text layer was added so padding could be added around the text.
        self.textLayer = [[CATextLayer alloc] init];
        self.textLayer.frame = CGRectMake(30, -5, width, height); //tempLabel.frame;
        self.textLayer.alignmentMode = kCAAlignmentCenter;
        CFTypeRef fontRef = CFBridgingRetain(font);
        self.textLayer.font = fontRef;
        self.textLayer.fontSize = font.pointSize;
        self.textLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.textLayer.contentsScale = [UIScreen mainScreen].scale;
        self.textLayer.needsDisplayOnBoundsChange = YES;
        [self addSublayer:self.textLayer];
        
        self.contentsScale = [UIScreen mainScreen].scale;
        self.cornerRadius = height / 2;
        
        CFRelease(fontRef);
    }
    return self;
}

- (void)configureWarningTextLayerAppearance
{
    self.textLayer.string = @"!";
    self.textLayer.foregroundColor = [UIColor colorWithRed:0.978 green:0.924 blue:0.916 alpha:1.000].CGColor;
    self.backgroundColor = [UIColor ubk_warningLevelHighBackgroundColour].CGColor;
}

- (void)configureUnknownWarningTextLayerAppearance
{
    self.textLayer.string = @"?";
    self.textLayer.foregroundColor = [UIColor colorWithRed:0.978 green:0.924 blue:0.916 alpha:1.000].CGColor;
    self.backgroundColor = [UIColor ubk_warningLevelMediumBackgroundColour].CGColor;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    //Update the text layer so that it is padded.
    CGFloat gutter = 2;
    self.textLayer.frame = CGRectMake(gutter, gutter, self.frame.size.width - (gutter * 2), self.frame.size.height - (gutter * 2));
    self.cornerRadius = self.frame.size.height / 2;
}

//Animate the badge on screen
- (void)showBadgeAnimation
{
    [self animateBadge:0.0 withToValue:1.0 hasDelegate:false];
}

//Animate the badge off screen
- (void)hideBadgeAnimation
{
    [self removeAnimationForKey:@"animateBadgeLayer"];
    [self animateBadge:1.0 withToValue:0.0 hasDelegate:true];
}

- (void)animateBadge:(CGFloat)fromValue withToValue:(CGFloat)toValue hasDelegate:(BOOL)delegate
{
    //Checks if already animated before trying to animate again. Prevents multiple animations on the same screen.
    if (![self animationForKey:@"animateBadgeLayer"])
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.3f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:fromValue];
        animation.toValue = [NSNumber numberWithFloat:toValue];
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        if (delegate)
        {
            animation.delegate = self;
        }
        [self addAnimation:animation forKey:@"animateBadgeLayer"];
    }
}

#pragma mark - CAAnimationDelegate

//Delegate method should only be called when animating the badge off screen.
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //Animation was stopped, reset the badge layer so that it can be animated on screen in the future.
    [self removeFromSuperlayer];
    [self removeAnimationForKey:@"animateBadgeLayer"];
}

@end
