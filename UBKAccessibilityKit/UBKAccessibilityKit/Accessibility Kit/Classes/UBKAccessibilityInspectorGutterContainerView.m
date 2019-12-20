/*
 File: UBKAccessibilityInspectorGutterContainerView.m
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

#import "UBKAccessibilityInspectorGutterContainerView.h"

@interface UBKAccessibilityInspectorGutterContainerView ()
@property (nonatomic) UIView *gutterTop;
@property (nonatomic) UIView *gutterLeft;
@property (nonatomic) UIView *gutterRight;
@property (nonatomic) UIView *gutterBottom;

@property (nonatomic) CGFloat viewHighlightAlpha;
@property (nonatomic) CGFloat viewUnhighlightAlpha;

@property (nonatomic) UIColor *viewHighlightColour;
@property (nonatomic) UIColor *viewUnhighlightColour;
@end

@implementation UBKAccessibilityInspectorGutterContainerView

- (instancetype)init
{
    if (self = [super init])
    {
        self.viewUnhighlightColour = [UIColor colorWithRed:0.000 green:0.518 blue:0.000 alpha:1.000];
        self.viewHighlightColour = [UIColor colorWithRed:0.000 green:0.686 blue:0.000 alpha:1.000];
        
        self.viewUnhighlightAlpha = 1.0;
        self.viewHighlightAlpha = 1.0;
    }
    return self;
}

- (GutterPosition)gutterBoundsCheck:(CGPoint)touchPoint
{
    if (CGRectContainsPoint(self.gutterTop.frame, touchPoint))
    {
        return GutterPositionTop;
    }
    else if (CGRectContainsPoint(self.gutterLeft.frame, touchPoint))
    {
        return GutterPositionLeft;
    }
    else if (CGRectContainsPoint(self.gutterRight.frame, touchPoint))
    {
        return GutterPositionRight;
    }
    else if (CGRectContainsPoint(self.gutterBottom.frame, touchPoint))
    {
        return GutterPositionBottom;
    }
    
    return GutterPositionNone;
}

//Change the appearance of the gutter when inspector dragged over it.
- (void)highLightGutter:(GutterPosition)gutterPosition
{
    self.gutterTop.alpha = self.viewUnhighlightAlpha;
    self.gutterLeft.alpha = self.viewUnhighlightAlpha;
    self.gutterRight.alpha = self.viewUnhighlightAlpha;
    self.gutterBottom.alpha = self.viewUnhighlightAlpha;

    self.gutterTop.backgroundColor = self.viewUnhighlightColour;
    self.gutterLeft.backgroundColor = self.viewUnhighlightColour;
    self.gutterRight.backgroundColor = self.viewUnhighlightColour;
    self.gutterBottom.backgroundColor = self.viewUnhighlightColour;

    switch (gutterPosition)
    {
        case GutterPositionTop:
        {
            self.gutterTop.backgroundColor = self.viewHighlightColour;
            self.gutterTop.alpha = self.viewHighlightAlpha;
            break;
        }
        case GutterPositionLeft:
        {
            self.gutterLeft.backgroundColor = self.viewHighlightColour;
            self.gutterLeft.alpha = self.viewHighlightAlpha;
            break;
        }
        case GutterPositionRight:
        {
            self.gutterRight.backgroundColor = self.viewHighlightColour;
            self.gutterRight.alpha = self.viewHighlightAlpha;
            break;
        }
        case GutterPositionBottom:
        {
            self.gutterBottom.backgroundColor = self.viewHighlightColour;;
            self.gutterBottom.alpha = self.viewHighlightAlpha;
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)hideAllGutterViews
{
    self.gutterTop.alpha = 0;
    self.gutterLeft.alpha = 0;
    self.gutterRight.alpha = 0;
    self.gutterBottom.alpha = 0;
}

- (void)initalizeGutterViews
{
    if (!self.gutterTop)
    {
        self.gutterTop = [self configureGutter];
        [self.gutterTop.topAnchor constraintEqualToAnchor:self.window.topAnchor].active = true;
        [self.gutterTop.leftAnchor constraintEqualToAnchor:self.window.leftAnchor constant:100].active = true;
        [self.gutterTop.rightAnchor constraintEqualToAnchor:self.window.rightAnchor constant:-100].active = true;
        [self.gutterTop.heightAnchor constraintEqualToConstant:100].active = true;
    }
    
    if (!self.gutterLeft)
    {
        self.gutterLeft = [self configureGutter];
        [self.gutterLeft.topAnchor constraintEqualToAnchor:self.window.topAnchor constant:100].active = true;
        [self.gutterLeft.leftAnchor constraintEqualToAnchor:self.window.leftAnchor].active = true;
        [self.gutterLeft.bottomAnchor constraintEqualToAnchor:self.window.bottomAnchor constant:-100].active = true;
        [self.gutterLeft.widthAnchor constraintEqualToConstant:100].active = true;
    }
    
    if (!self.gutterRight)
    {
        self.gutterRight = [self configureGutter];
        [self.gutterRight.topAnchor constraintEqualToAnchor:self.window.topAnchor constant:100].active = true;
        [self.gutterRight.rightAnchor constraintEqualToAnchor:self.window.rightAnchor].active = true;
        [self.gutterRight.bottomAnchor constraintEqualToAnchor:self.window.bottomAnchor constant:-100].active = true;
        [self.gutterRight.widthAnchor constraintEqualToConstant:100].active = true;
    }
    
    if (!self.gutterBottom)
    {
        self.gutterBottom = [self configureGutter];
        [self.gutterBottom.bottomAnchor constraintEqualToAnchor:self.window.bottomAnchor].active = true;
        [self.gutterBottom.leftAnchor constraintEqualToAnchor:self.window.leftAnchor constant:100].active = true;
        [self.gutterBottom.rightAnchor constraintEqualToAnchor:self.window.rightAnchor constant:-100].active = true;
        [self.gutterBottom.heightAnchor constraintEqualToConstant:100].active = true;
    }
    
    self.gutterTop.alpha = self.viewUnhighlightAlpha;
    self.gutterLeft.alpha = self.viewUnhighlightAlpha;
    self.gutterRight.alpha = self.viewUnhighlightAlpha;
    self.gutterBottom.alpha = self.viewUnhighlightAlpha;
}

//Highlights the gutter under the touch point.
- (void)highlightGutterUnderTouchPoint:(CGPoint)touchPoint
{
    [self highLightGutter:[self gutterBoundsCheck:touchPoint]];
}

//Checks which gutter the inspector was dropped into
- (void)checkInspectorDropTouchPoint:(CGPoint)touchPoint
{
    [self.delegate didDropInspectorInGutter:[self gutterBoundsCheck:touchPoint]];
}

#pragma mark - Convenience methods

- (UIView *)configureGutter
{
    UIView *gutter = [[UIView alloc]init];
    gutter.translatesAutoresizingMaskIntoConstraints = false;
    gutter.backgroundColor = self.viewUnhighlightColour;
    gutter.alpha = self.viewUnhighlightAlpha;
    gutter.layer.borderColor = [UIColor darkGrayColor].CGColor;
    gutter.layer.borderWidth = 8;
    gutter.layer.zPosition = 998;
    [self addSubview:gutter];

    UILabel *label = [[UILabel alloc]init];
    label.text = @"Drag inspector here...";
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = false;
    [gutter addSubview:label];
    [label.topAnchor constraintEqualToAnchor:gutter.topAnchor].active = true;
    [label.rightAnchor constraintEqualToAnchor:gutter.rightAnchor].active = true;
    [label.leftAnchor constraintEqualToAnchor:gutter.leftAnchor].active = true;
    [label.bottomAnchor constraintEqualToAnchor:gutter.bottomAnchor].active = true;
    
    return gutter;
}

@end
