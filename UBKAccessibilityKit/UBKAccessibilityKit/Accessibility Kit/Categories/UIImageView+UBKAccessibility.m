/*
 File: UIImageView+UBKAccessibility.m
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

#import "UIImageView+UBKAccessibility.h"

#import "UIFont+HelperMethods.h"

#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityValidation.h"

@implementation UIImageView (UBKAccessibility)

- (nonnull NSArray<UBKAccessibilitySection *> *)ubk_accessibilityDetails
{
    double contrastScore = 0;
    NSArray *items = [super ubk_accessibilityDetails];
    for (UBKAccessibilitySection *accessibilitySection in items)
    {
        if (accessibilitySection.sectionType == SectionDisplayTypeColour)
        {
            if (self.image.renderingMode == UIImageRenderingModeAlwaysTemplate)
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
                contrastScore = [UBKAccessibilityValidation getViewContrastRatio:self.tintColor backgroundColor:bgColour];
                ColourContrastRating contrastRating = [UBKAccessibilityValidation getColourContrastRatingForNonText:contrastScore];
                BOOL contrastWarning = false;
                if (contrastRating == ColourContrastRatingFail)
                {
                    contrastWarning = true;
                }
                
                [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_TintColour withColour:self.tintColor withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                    self.tintColor = updatedColour;
                }]];
                
                UBKAccessibilityProperty *contrastProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_W3CContrastRatio withValue:[NSString stringWithFormat:@"%0.2f", contrastScore] withForegroundColour:self.tintColor withBackgroundColour:bgColour withAlternateTitle:kUBKAccessibilityAttributeTitle_TextBackgroundColour withContrastScore:[UBKAccessibilityValidation getW3CRatingForColourContrast:contrastRating] showContrastWarning:contrastWarning];
                contrastProperty.warningLevel = UBKAccessibilityWarningLevelHigh;
                [accessibilitySection addProperty:contrastProperty];
            }
            else
            {
                [accessibilitySection removePropertyWithDisplayTitle:kUBKAccessibilityAttributeTitle_W3CContrastRatio];
            }
        }
    }
    
    NSMutableArray *itemsTmp = [[NSMutableArray alloc]initWithArray:items];
    NSArray *warningsArray = [UBKAccessibilityValidation checkAccessibilityWarningForImageView:self withContrast:contrastScore];
    if (warningsArray.count > 0)
    {
        //UI element has a warning. Check which warning should be showed.
        UBKAccessibilitySection *warningsSection = [[UBKAccessibilitySection alloc]initWithHeader:kUBKAccessibilityAttributeTitle_Warning_Header type:SectionDisplayTypeWarnings];
        
        //Add any validation warning properties.
        warningsSection = [UBKAccessibilityValidation configureWarningSection:warningsSection withWarnings:warningsArray];
        
        //Add in warnings to section
        if (warningsSection.items.count > 0)
        {
            [itemsTmp insertObject:warningsSection atIndex:0];
        }
    }
    
    itemsTmp = [UBKAccessibilitySection removeSectionIn:itemsTmp matching:SectionDisplayTypeTypography];
    return itemsTmp;
}

- (NSString *)ubk_classIconName
{
    return @"icon_image";
}

@end
