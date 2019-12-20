/*
 File: UBKAccessibilityVisibleWarningView.m
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

#import "UBKAccessibilityVisibleWarningView.h"
#import "UIColor+HelperMethods.h"
#import "UIView+UBKAccessibility.h"

@implementation UBKAccessibilityVisibleWarningView

- (instancetype)initWithFrame:(CGRect)frame withWarning:(UBKAccessibilityWarningLevel)warningLevel
{
    if (self = [super initWithFrame:frame])
    {
        [self updateAppearanceWithWarning:warningLevel];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)updateAppearanceWithWarning:(UBKAccessibilityWarningLevel)warningLevel
{
    switch (warningLevel)
    {
        case UBKAccessibilityWarningLevelHigh:
        {
            [self ubk_setHighlightedItemAppearanceColour:[UIColor ubk_warningLevelHighBackgroundColour]];
            break;
        }
        case UBKAccessibilityWarningLevelMedium:
        {
            [self ubk_setHighlightedItemAppearanceColour:[UIColor ubk_warningLevelMediumBackgroundColour]];
            break;
        }
        case UBKAccessibilityWarningLevelLow:
        {
            [self ubk_setHighlightedItemAppearanceColour:[UIColor ubk_warningLevelLowBackgroundColour]];
            break;
        }
        case UBKAccessibilityWarningLevelPass:
        {
            [self removeFromSuperview];
            [self ubk_setDeselectedItemAppearance];
            break;
        }
    }
}

@end
