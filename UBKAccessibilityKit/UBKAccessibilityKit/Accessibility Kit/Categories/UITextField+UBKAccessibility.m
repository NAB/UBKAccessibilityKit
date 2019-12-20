/*
 File: UITextField+UBKAccessibility.m
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

#import "UITextField+UBKAccessibility.h"

#import "UIFont+HelperMethods.h"

#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityValidation.h"

@implementation UITextField (UBKAccessibility)

- (nonnull NSArray<UBKAccessibilitySection *> *)ubk_accessibilityDetails
{
    double contrastScore = 0;
    NSArray *items = [super ubk_accessibilityDetails];
    for (UBKAccessibilitySection *accessibilitySection in items)
    {
        if (accessibilitySection.sectionType == SectionDisplayTypeColour)
        {
            //Refactor this loop, make it better, its used twice.
            UIColor *bgColour = self.backgroundColor;
            for (UBKAccessibilityProperty *accessibilityProperty in accessibilitySection.items)
            {
                if ([accessibilityProperty.displayTitle isEqualToString:kUBKAccessibilityAttributeTitle_BackgroundColour])
                {
                    bgColour = accessibilityProperty.displayColour;
                    break;
                }
            }
            
            contrastScore = [UBKAccessibilityValidation getViewContrastRatio:self.textColor backgroundColor:bgColour];
            ColourContrastRating contrastRating = [UBKAccessibilityValidation getColourContrastRatingForText:contrastScore withTextSize:self.font.pointSize withBoldFont:[self.font ubk_isFontBold]];
            BOOL contrastWarning = false;
            if (contrastRating == ColourContrastRatingFail)
            {
                contrastWarning = true;
            }
            
            UBKAccessibilityProperty *textColourProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_TextColour withColour:self.textColor withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                self.textColor = updatedColour;
            }];
            textColourProperty.warningType = UBKAccessibilityWarningTypeColourContrast;
            textColourProperty.displayWarning = contrastWarning;
            [accessibilitySection addProperty:textColourProperty];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_TintColour withColour:self.tintColor withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                self.tintColor = updatedColour;
            }]];
            
            UBKAccessibilityProperty *contrastRatioProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_W3CContrastRatio withValue:[NSString stringWithFormat:@"%0.2f", contrastScore] withForegroundColour:self.textColor withBackgroundColour:bgColour withAlternateTitle:kUBKAccessibilityAttributeTitle_TextBackgroundColour withContrastScore:[UBKAccessibilityValidation getW3CRatingForColourContrast:contrastRating] showContrastWarning:contrastWarning];
            contrastRatioProperty.warningLevel = UBKAccessibilityWarningLevelHigh;
            textColourProperty.warningType = UBKAccessibilityWarningTypeColourContrast;
            contrastRatioProperty.displayWarning = contrastWarning;
            [accessibilitySection addProperty:contrastRatioProperty];
        }
        else if (accessibilitySection.sectionType == SectionDisplayTypeTypography)
        {
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Font withValue:self.font.familyName]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_FontBold withValue:[self.font ubk_isFontBold]?@"Yes":@"No"]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_FontSize withValue:[NSString stringWithFormat:@"%0.2f", self.font.pointSize]]];
        }
        else if (accessibilitySection.sectionType == SectionDisplayTypeAccessibilityAttributes)
        {
            [accessibilitySection configureAccessibilityProperties:self];
            UBKAccessibilityProperty *dynamicTextProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_DynamicTextSupported withValue:self.adjustsFontForContentSizeCategory?@"Yes":@"No" withWarningType:UBKAccessibilityWarningTypeDynamicTextSize];
            dynamicTextProperty.displayWarning = !self.adjustsFontForContentSizeCategory;
            [accessibilitySection addProperty:dynamicTextProperty];
        }
    }
    
    NSArray *warningsArray = [UBKAccessibilityValidation checkAccessibilityWarningForTextfield:self withContrast:contrastScore];
    if (warningsArray.count > 0)
    {
        //UI element has a warning. Check which warning should be showed.
        NSMutableArray *itemsTmp = [[NSMutableArray alloc]initWithArray:items];
        UBKAccessibilitySection *warningsSection = [[UBKAccessibilitySection alloc]initWithHeader:kUBKAccessibilityAttributeTitle_Warning_Header type:SectionDisplayTypeWarnings];
        
        //Add any validation warning properties.
        warningsSection = [UBKAccessibilityValidation configureWarningSection:warningsSection withWarnings:warningsArray];
        
        //Add in warnings to section
        if (warningsSection.items.count > 0)
        {
            [itemsTmp insertObject:warningsSection atIndex:0];
            items = itemsTmp;
        }
    }
    
    return items;
}

- (void)ubk_setColour:(nonnull UIColor *)colour
{
    self.textColor = colour;
}

- (NSString *)ubk_classIconName
{
    return @"icon_textfield";
}

@end
