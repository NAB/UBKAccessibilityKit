/*
 File: UBKAccessibilityProperty.m
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

#import "UBKAccessibilityProperty.h"
#import "UIColor+HelperMethods.h"
#import "UBKAccessibilityValidation.h"

@interface UBKAccessibilityProperty ()

@end

@implementation UBKAccessibilityProperty

#pragma init methods

- (instancetype)init
{
    if (self = [super init])
    {
        self.cellAccessoryType = UITableViewCellAccessoryNone;
        self.warningLevel = UBKAccessibilityWarningLevelPass;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title withValue:(NSString *)value
{
    if (self = [super init])
    {
        self.displayType = PropertyDisplayTypeTitleValue;
        self.displayTitle = title;
        self.displayValue = value;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title withValue:(NSString *)value withWarningType:(UBKAccessibilityWarningType)warningType
{
    if (self = [super init])
    {
        self.displayType = PropertyDisplayTypeTitleValue;
        self.displayTitle = title;
        self.displayValue = value;
        self.warningType = warningType;
        self.warningLevel = [UBKAccessibilityValidation getWarningLevelForWarningType:warningType];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title withColour:(UIColor *)colour
{
    if (self = [super init])
    {
        self.displayType = PropertyDisplayTypeColour;
        self.displayTitle = title;
        self.displayColour = colour;
        self.canUpdateUI = true;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title withColour:(UIColor *)colour withColourUpdateCompletionBlock:(nonnull AccessibilityPropertyColourUpdateCompletionBlock)completionBlock
{
    if (self = [super init])
    {
        self.displayType = PropertyDisplayTypeColour;
        self.displayTitle = title;
        self.displayColour = colour;
        self.colourUpdateCompletionBlock = completionBlock;
        self.canUpdateUI = true;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title withValue:(NSString *)value withActionCompletionBlock:(nonnull AccessibilityPropertySelectorActionCompletionBlock)completionBlock
{
    if (self = [super init])
    {
        self.displayType = PropertyDisplayTypeAction;
        self.displayTitle = title;
        self.displayValue = value;
        self.actionUpdateCompletionBlock = completionBlock;
        self.canUpdateUI = true;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title withValue:(nonnull NSString *)value withForegroundColour:(nonnull UIColor *)foregroundColour withBackgroundColour:(nonnull UIColor *)backgroundColour withAlternateTitle:(NSString *)alternateTitle withContrastScore:(NSString *)contrastScore showContrastWarning:(BOOL)showWarning
{
    if (self = [super init])
    {
        self.displayType = PropertyDisplayTypeContrast;
        self.displayTitle = title;
        self.displayValue = value;
        self.displayColour = foregroundColour;
        self.displayAlternateColour = backgroundColour;
        self.displayAlternateTitle = alternateTitle;
        self.displayContrastScore = contrastScore;
        self.displayWarning = showWarning;
    }
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    UBKAccessibilityProperty *property = [[UBKAccessibilityProperty alloc]initWithTitle:self.displayTitle withValue:self.displayValue];
    property.cellAccessoryType = self.cellAccessoryType;
    property.displayType = self.displayType;
    property.displayColour = self.displayColour;
    property.displayAlternateColour = self.displayAlternateColour;
    property.displayAlternateTitle = self.displayAlternateTitle;
    property.displayContrastScore = self.displayContrastScore;
    property.displayWarning = self.displayWarning;
    return property;
}

- (void)setWarningType:(UBKAccessibilityWarningType)warningType
{
    _warningType = warningType;
    _warningLevel = [UBKAccessibilityValidation getWarningLevelForWarningType:warningType];
}

#pragma mark - Display Values

- (NSString *)displayValue
{
    NSString *returnValueString = _displayValue;
    if (self.displayType == PropertyDisplayTypeColour)
    {
        returnValueString = [self.displayColour ubk_hexStringFromColour];
    }
    return [self validateValue:returnValueString];
}

#pragma mark - Validation

- (NSString *)validateValue:(NSString *)value
{
    if (value)
    {
        return value;
    }
    return @"";
}

@end
