/*
 File: UBKAccessibilityValidation.m
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

#import "UBKAccessibilityValidation.h"
//Categories
#import "UIColor+HelperMethods.h"
#import "UIFont+HelperMethods.h"
//Classes
#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityProperty.h"
#import "UBKAccessibilityManager.h"

NSInteger const ColourContrastAARating = 3.5;
NSInteger const ColourContrastAAARating = 3.5;

@implementation UBKAccessibilityValidation

//Validation
//Contrast of foreground colour and background colour
//Minimum touch points when user interfaction enabled.
//Accessibility enabled and no trait, no label, no hint.

#pragma mark - Base Accessibility Validation Methods

+ (BOOL)hasMinimumSizeWarning:(UIView *)view
{
    if (((view.frame.size.width < 44) || (view.frame.size.height < 44)) && view.userInteractionEnabled == true)
    {
        return true;
    }
    return false;
}

+ (NSString *)getMinimumSizeWarningTitle:(UIView *)view
{
    if ([UBKAccessibilityValidation hasMinimumSizeWarning:view])
    {
        return @"Less than 44 x 44";
    }
    return @"No";
}

+ (BOOL)hasAccessibilityTraitWarning:(UIView *)view
{
    if (view.isAccessibilityElement)
    {
        if (view.accessibilityTraits & UIAccessibilityTraitNone)
        {
            return true;
        }
    }
    return false;
}

+ (BOOL)hasAccessibilityLabelWarning:(UIView *)view
{
    if (view.isAccessibilityElement)
    {
        if (@available(iOS 11.0, *)) {
            if ((view.accessibilityLabel.length > 0) || (view.accessibilityAttributedLabel.length > 0))
            {
                return false;
            }
        } else {
            // Fallback on earlier versions
            if (view.accessibilityLabel.length > 0)
            {
                return false;
            }
        }
        return true;
    }
    return false;
}

+ (BOOL)hasAccessibilityHintWarning:(UIView *)view
{
    if (view.isAccessibilityElement)
    {
        if (@available(iOS 11.0, *)) {
            if ((view.accessibilityHint.length > 0) || (view.accessibilityAttributedHint.length > 0))
            {
                return false;
            }
        } else {
            // Fallback on earlier versions
            if (view.accessibilityHint.length > 0)
            {
                return false;
            }
        }
        return true;
    }
    return false;
}

+ (BOOL)hasAccessibilityWarningForMissingFlag:(UIView *)view
{
    /*
//   TODO: Add back in when iOS supports checking the isAccessibilityElement boolean. At the moment value is unpredictable and returns false positive results in the inspector. See ReadMe file for more information.
    if ((view.userInteractionEnabled) && (!view.isAccessibilityElement))
    {
        return true;
    }
     */
    return false;
}

+ (BOOL)hasColourMatchWarning:(UIColor *)colour
{
    if (colour)
    {
        if ([UBKAccessibilityManager sharedInstance].isValidatingColours)
        {
            for (UBKAccessibilityProperty *property in [UBKAccessibilityManager sharedInstance].accessibilityColours.defaultColoursArray)
            {
                if (property.displayColour == colour)
                {
                    return false;
                }
            }
            return true;
        }
    }
    return false;
}

+ (NSString *)getWarningTitleForWarningType:(UBKAccessibilityWarningType)warningType
{
    NSString *warningTitle = @"UNKNOWN WARNING!";
    switch (warningType)
    {
        case UBKAccessibilityWarningTypeTrait:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_Trait;
            break;
        }
        case UBKAccessibilityWarningTypeLabel:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_Label;
            break;
        }
        case UBKAccessibilityWarningTypeHint:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_Hint;
            break;
        }
        case UBKAccessibilityWarningTypeValue:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_Value;
            break;
        }
        case UBKAccessibilityWarningTypeDisabled:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled;
            break;
        }
        case UBKAccessibilityWarningTypeMissingLabel:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_LabelNotSet;
            break;
        }
        case UBKAccessibilityWarningTypeDynamicTextSize:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_DynamicTextSize;
            break;
        }
        case UBKAccessibilityWarningTypeColourContrast:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_ColourContrast;
            break;
        }
        case UBKAccessibilityWarningTypeColourContrastBackground:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_BackgroundColourContrast;
            break;
        }
        case UBKAccessibilityWarningTypeWrongColour:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_WrongColour;
            break;
        }
        case UBKAccessibilityWarningTypeMinimumSize:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Warning_MinimumSize;
            break;
        }
    }
    return warningTitle;
}

+ (UBKAccessibilityWarningLevel)getWarningLevelForWarningType:(UBKAccessibilityWarningType)warningType
{
    UBKAccessibilityWarningLevel warningLevel = UBKAccessibilityWarningLevelLow;
    switch (warningType)
    {
        case UBKAccessibilityWarningTypeTrait:
        {
            warningLevel = UBKAccessibilityWarningLevelMedium;
            break;
        }
        case UBKAccessibilityWarningTypeLabel:
        {
            warningLevel = UBKAccessibilityWarningLevelHigh;
            break;
        }
        case UBKAccessibilityWarningTypeHint:
        {
            warningLevel = UBKAccessibilityWarningLevelLow;
            break;
        }
        case UBKAccessibilityWarningTypeValue:
        {
            warningLevel = UBKAccessibilityWarningLevelMedium;
            break;
        }
        case UBKAccessibilityWarningTypeDisabled:
        {
            warningLevel = UBKAccessibilityWarningLevelMedium;
            break;
        }
        case UBKAccessibilityWarningTypeMissingLabel:
        {
            warningLevel = UBKAccessibilityWarningLevelHigh;
            break;
        }
        case UBKAccessibilityWarningTypeDynamicTextSize:
        {
            warningLevel = UBKAccessibilityWarningLevelMedium;
            break;
        }
        case UBKAccessibilityWarningTypeColourContrast:
        {
            warningLevel = UBKAccessibilityWarningLevelHigh;
            break;
        }
        case UBKAccessibilityWarningTypeColourContrastBackground:
        {
            warningLevel = UBKAccessibilityWarningLevelHigh;
            break;
        }
        case UBKAccessibilityWarningTypeWrongColour:
        {
            warningLevel = UBKAccessibilityWarningLevelHigh;
            break;
        }
        case UBKAccessibilityWarningTypeMinimumSize:
        {
            warningLevel = UBKAccessibilityWarningLevelHigh;
            break;
        }
    }
    return warningLevel;
}

+ (UBKAccessibilitySection *)configureWarningSection:(UBKAccessibilitySection *)warningsSection withWarnings:(NSArray<NSNumber *> *)warningsArray
{
    for (NSNumber *warningTypeNumber in warningsArray)
    {
        UBKAccessibilityWarningType warningType = [warningTypeNumber integerValue];
        NSString *warningTitle = [self getWarningTitleForWarningType:warningType];
        UBKAccessibilityWarningLevel warningLevel = [self getWarningLevelForWarningType:warningType];
        
        UBKAccessibilityProperty *accessibilityProperty = [[UBKAccessibilityProperty alloc]initWithTitle:warningTitle withValue:@""];
        accessibilityProperty.displayWarning = true;
        accessibilityProperty.cellAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        accessibilityProperty.warningLevel = warningLevel;
        accessibilityProperty.warningType = warningType;
        [warningsSection addProperty:accessibilityProperty];
    }
    
    return warningsSection;
}

+ (NSArray *)checkBaseAccessibilityWarnings:(UIView *)view
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]init];
    if ([UBKAccessibilityValidation hasAccessibilityTraitWarning:view])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeTrait)];
    }
    if ([UBKAccessibilityValidation hasAccessibilityLabelWarning:view])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeLabel)];
    }
    if ([UBKAccessibilityValidation hasAccessibilityHintWarning:view])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeHint)];
    }
    if ([UBKAccessibilityValidation hasAccessibilityWarningForMissingFlag:view])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeDisabled)];
    }
    return warningsArray;
}

#pragma mark - UILabel Validation

+ (NSArray *)checkAccessibilityWarningForLabel:(UILabel *)label withContrast:(double)contrast
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]initWithArray:[self checkBaseAccessibilityWarnings:label]];
    double textSize = label.font.pointSize;
    BOOL boldFont = [label.font ubk_isFontBold];
    UIColor *colour = label.textColor;

    if ([UBKAccessibilityValidation getColourContrastRatingForText:contrast withTextSize:textSize withBoldFont:boldFont] == ColourContrastRatingFail)
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeColourContrast)];
    }
    if ([UBKAccessibilityValidation hasColourMatchWarning:colour])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeWrongColour)];
    }
    if ((!label.adjustsFontForContentSizeCategory) && (!label.hidden) && (label.text.length > 0))
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeDynamicTextSize)];
    }
    return warningsArray;
}

#pragma mark - UIButton Validation

+ (NSArray *)checkAccessibilityWarningForButton:(UIButton *)button withContrast:(double)contrast
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]initWithArray:[self checkBaseAccessibilityWarnings:button]];
    UIColor *colour = button.titleLabel.textColor;

    if ([UBKAccessibilityValidation hasMinimumSizeWarning:button])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeMinimumSize)];
    }
    if (button.titleLabel.text.length > 0)
    {
        double textSize = button.titleLabel.font.pointSize;
        BOOL boldFont = [button.titleLabel.font ubk_isFontBold];

        if ([UBKAccessibilityValidation getColourContrastRatingForText:contrast withTextSize:textSize withBoldFont:boldFont] == ColourContrastRatingFail)
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeColourContrast)];
        }
        if (!button.titleLabel.adjustsFontForContentSizeCategory)
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeDynamicTextSize)];
        }
    }
    if ([UBKAccessibilityValidation hasColourMatchWarning:colour])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeWrongColour)];
    }
    return warningsArray;
}

#pragma mark - UISwitch Validation

+ (NSArray *)checkAccessibilityWarningForSwitch:(UISwitch *)switchObject
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]initWithArray:[self checkBaseAccessibilityWarnings:switchObject]];

    if (switchObject.isAccessibilityElement)
    {
        if (([switchObject.accessibilityIdentifier isEqualToString:switchObject.accessibilityLabel]) || (switchObject.accessibilityLabel == nil) || ([switchObject.accessibilityLabel isEqualToString:@""]))
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeMissingLabel)];
        }
        if (switchObject.accessibilityValue == nil || switchObject.accessibilityValue.length == 0)
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeValue)];
        }
    }
    if ([UBKAccessibilityValidation hasMinimumSizeWarning:switchObject])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeMinimumSize)];
    }
    return warningsArray;
}

#pragma mark - UIImageView Validation

+ (NSArray *)checkAccessibilityWarningForImageView:(UIImageView *)imageView withContrast:(double)contrast
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]initWithArray:[self checkBaseAccessibilityWarnings:imageView]];

    if (imageView.isAccessibilityElement)
    {
        if (([imageView.accessibilityIdentifier isEqualToString:imageView.accessibilityLabel]) || (imageView.accessibilityLabel == nil) || ([imageView.accessibilityLabel isEqualToString:@""]))
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeMissingLabel)];
        }
    }
    if (imageView.image.renderingMode == UIImageRenderingModeAlwaysTemplate)
    {
        if ([UBKAccessibilityValidation getColourContrastRatingForNonText:contrast] == ColourContrastRatingFail)
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeColourContrast)];
        }
    }
    return warningsArray;
}

#pragma mark - UITextfield Validation

+ (NSArray *)checkAccessibilityWarningForTextfield:(UITextField *)textfield withContrast:(double)contrast
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]initWithArray:[self checkBaseAccessibilityWarnings:textfield]];
    double textSize = textfield.font.pointSize;
    BOOL boldFont = [textfield.font ubk_isFontBold];
    UIColor *colour = textfield.textColor;

    if ([UBKAccessibilityValidation hasMinimumSizeWarning:textfield])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeMinimumSize)];
    }
    if ([UBKAccessibilityValidation getColourContrastRatingForText:contrast withTextSize:textSize withBoldFont:boldFont] == ColourContrastRatingFail)
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeColourContrast)];
    }
    if ([UBKAccessibilityValidation hasColourMatchWarning:colour])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeWrongColour)];
    }
    if (!textfield.adjustsFontForContentSizeCategory)
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeDynamicTextSize)];
    }
    return warningsArray;
}

#pragma mark - UITextView Validation

+ (NSArray *)checkAccessibilityWarningForTextView:(UITextView *)textView withContrast:(double)contrast
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]initWithArray:[self checkBaseAccessibilityWarnings:textView]];
    double textSize = textView.font.pointSize;
    BOOL boldFont = [textView.font ubk_isFontBold];
    UIColor *colour = textView.textColor;

    if ([UBKAccessibilityValidation hasMinimumSizeWarning:textView])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeMinimumSize)];
    }
    if ([UBKAccessibilityValidation getColourContrastRatingForText:contrast withTextSize:textSize withBoldFont:boldFont] == ColourContrastRatingFail)
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeColourContrast)];
    }
    if ([UBKAccessibilityValidation hasColourMatchWarning:colour])
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeWrongColour)];
    }
    if (!textView.adjustsFontForContentSizeCategory)
    {
        [warningsArray addObject:@(UBKAccessibilityWarningTypeDynamicTextSize)];
    }
    return warningsArray;
}

#pragma mark - UISlider Validation

+ (NSArray *)checkAccessibilityWarningForSlider:(UISlider *)slider
{
    NSMutableArray *warningsArray = [[NSMutableArray alloc]initWithArray:[self checkBaseAccessibilityWarnings:slider]];
    
    if (slider.isAccessibilityElement)
    {
        if (([slider.accessibilityIdentifier isEqualToString:slider.accessibilityLabel]) || (slider.accessibilityLabel == nil) || ([slider.accessibilityLabel isEqualToString:@""]))
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeMissingLabel)];
        }
        if (slider.accessibilityValue == nil || slider.accessibilityValue.length == 0)
        {
            [warningsArray addObject:@(UBKAccessibilityWarningTypeValue)];
        }
    }
    if ([UBKAccessibilityValidation hasMinimumSizeWarning:slider])
    {
           [warningsArray addObject:@(UBKAccessibilityWarningTypeMinimumSize)];
    }
    return warningsArray;
}

#pragma mark - Base Colour Validation Methods

+ (NSString *)getW3CRatingForColourContrast:(ColourContrastRating)rating
{
    switch (rating)
    {
        case ColourContrastRatingAAA:
        {
            return @"AAA";
        }
        case ColourContrastRatingAAALarge:
        {
            return @"AAA Large";
        }
        case ColourContrastRatingAA:
        {
            return @"AA";
        }
        case ColourContrastRatingAALarge:
        {
            return @"AA Large";
        }
        case ColourContrastRatingFail:
        {
            return @"Fail";
        }
        case ColourContrastRatingNA:
        {
            return @"";
        }
    }
}

+ (NSString *)getTitleColourContrastRatingForNonText:(CGFloat)contrast
{
    ColourContrastRating rating = [self getColourContrastRatingForNonText:contrast];
    return [self getW3CRatingForColourContrast:rating];
}

+ (ColourContrastRating)getColourContrastRatingForNonText:(CGFloat)contrast
{
    if (contrast >= 4.5)
    {
        return ColourContrastRatingAAA;
    }
    else if (contrast >= 3.0)
    {
        return ColourContrastRatingAA;
    }
    return ColourContrastRatingFail; // <= 2.9
}

+ (NSString *)getTitleColourContrastRatingForText:(CGFloat)contrast withTextSize:(double)textSize withBoldFont:(BOOL)boldFont
{
    ColourContrastRating rating = [self getColourContrastRatingForText:contrast withTextSize:textSize withBoldFont:boldFont];
    return [self getW3CRatingForColourContrast:rating];
}

+ (ColourContrastRating)getColourContrastRatingForText:(CGFloat)contrast withTextSize:(double)textSize withBoldFont:(BOOL)boldFont
{
    //Large text has a differet ratio to smaller text
    //https://www.w3.org/TR/WCAG20-TECHS/G18.html
    if (contrast == 0 && textSize == 0)
    {
        return ColourContrastRatingNA;
    }
    if (((textSize >= 18.66) && (boldFont)) || (textSize >= 24))
    {
        if (contrast >= 4.5)
        {
            return ColourContrastRatingAAALarge;
        }
        else if (contrast >= 3.0)
        {
            return ColourContrastRatingAALarge;
        }
    }
    else
    {
        if (contrast >= 7.0)
        {
            return ColourContrastRatingAAA;
        }
        else if (contrast >= 4.5)
        {
            return ColourContrastRatingAA;
        }
    }
    return ColourContrastRatingFail;
}

+ (CGFloat)getViewContrastRatio:(UIColor *)foregroundColour backgroundColor:(UIColor *)backgroundColour
{
    CGFloat contrast = 0;
    if ((foregroundColour) && (backgroundColour))
    {
        contrast = [foregroundColour ubk_contrastRatio:backgroundColour];
    }
    return contrast;
}

@end
