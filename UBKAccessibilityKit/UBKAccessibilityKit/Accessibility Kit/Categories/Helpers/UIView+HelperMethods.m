/*
 File: UIView+HelperMethods.m
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

#import "UIView+HelperMethods.h"
#import "UBKAccessibilityVisibleWarningView.h"

@implementation UIView (HelperMethods)

- (UIImage *)ubk_createImage
{
    UIGraphicsBeginImageContext(self.frame.size);

    //this gets the graphic context
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];

    //now get the image from the context
    UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return bezierImage;
}

- (UIColor *)ubk_findBackgroundColour:(UIView *)view
{
    UIColor *bgColour = view.backgroundColor;
    if ([view isKindOfClass:[UITabBar class]])
    {
        UITabBar *tabbar = (UITabBar *)view;
        if (tabbar.barTintColor != nil)
        {
            return tabbar.barTintColor;
        }
    }
    if (((bgColour != nil) & (bgColour != [UIColor clearColor])) || (view == nil))
    {
        return bgColour;
    }
    return [self ubk_findBackgroundColour:view.superview];
}

- (NSString *)ubk_formattedAccessibilityTraitString
{
    if (self.accessibilityTraits & UIAccessibilityTraitNone)
    {
        return @"None";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitButton)
    {
        return @"Button";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitLink)
    {
        return @"Link";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitHeader)
    {
        return @"Header";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitSearchField)
    {
        return @"SearchField";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitImage)
    {
        return @"Image";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitSelected)
    {
        return @"Selected";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitPlaysSound)
    {
        return @"Play Sound";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitKeyboardKey)
    {
        return @"Keyboard Key";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitStaticText)
    {
        return @"Static Text";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitSummaryElement)
    {
        return @"Summary Element";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitNotEnabled)
    {
        return @"Not Enabled";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitUpdatesFrequently)
    {
        return @"Updates Frequently";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitStartsMediaSession)
    {
        return @"Starts Media Session";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitAdjustable)
    {
        return @"Adjustable";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitAllowsDirectInteraction)
    {
        return @"Allows Direct Interaction";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitCausesPageTurn)
    {
        return @"Causes Page Turn";
    }
    else if (self.accessibilityTraits & UIAccessibilityTraitTabBar)
    {
        return @"Tab Bar";
    }
    
    return @"";
}

- (NSString *)ubk_formattedRect:(CGRect)frame
{
    return [NSString stringWithFormat:@"Coordinates: x: %0.2f, y: %0.2f, \nSize: width: %0.2f, height: %0.2f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
}

- (void)ubk_addSelectionOutline:(NSInteger)warningLevel
{
    UBKAccessibilityVisibleWarningView *warningView = nil;

    //Check if the current UI element already has a warning view. If it does then return it.
    for (UIView *subElement in self.subviews)
    {
        if ([subElement isKindOfClass:[UBKAccessibilityVisibleWarningView class]])
        {
            warningView = (UBKAccessibilityVisibleWarningView *)subElement;
        }
    }

    //If no warning view create it.
    if (warningView == nil)
    {
        warningView = [[UBKAccessibilityVisibleWarningView alloc]initWithFrame:self.bounds withWarning:warningLevel];
        [self addSubview:warningView];
    }
    else
    {
        //The UI element has a warning view, update the appearance of it incase the user has changed the colours.
        [warningView updateAppearanceWithWarning:warningLevel];
    }
}

- (void)ubk_removeSelectionOutline
{
    //Not conducting active highlighting so remove any warning view found.
    for (UIView *subElement in self.subviews)
    {
        if ([subElement isKindOfClass:[UBKAccessibilityVisibleWarningView class]])
        {
            [subElement removeFromSuperview];
        }
    }
}

@end
