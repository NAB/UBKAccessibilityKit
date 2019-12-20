/*
 File: UIButton+UBKAccessibility.m
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

#import "UIButton+UBKAccessibility.h"

#import "UIFont+HelperMethods.h"

#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityValidation.h"

@implementation UIButton (UBKAccessibility)

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
            
            contrastScore = [UBKAccessibilityValidation getViewContrastRatio:self.titleLabel?self.titleLabel.textColor:self.tintColor backgroundColor:bgColour];
            ColourContrastRating contrastRating = [UBKAccessibilityValidation getColourContrastRatingForText:contrastScore withTextSize:self.titleLabel.font.pointSize withBoldFont:[self.titleLabel.font ubk_isFontBold]];
            if (!self.titleLabel)
            {
                contrastRating = [UBKAccessibilityValidation getColourContrastRatingForNonText:contrastScore];
            }
            BOOL contrastWarning = false;
            
            if (self.titleLabel.text.length > 0)
            {
                if (contrastRating == ColourContrastRatingFail)
                {
                    contrastWarning = true;
                }
            }
            else
            {
                //Need to check the buttonType, if it's custom use the tint colour.
                if ((self.buttonType != UIButtonTypeCustom) && (contrastRating == ColourContrastRatingFail))
                {
                    contrastWarning = true;
                }
                else
                {
                    contrastRating = ColourContrastRatingNA;
                }
            }
            
            UBKAccessibilityProperty *textColourProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_TextColour withColour:self.titleLabel?self.titleLabel.textColor:self.tintColor withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                [self ubk_setColour:updatedColour];
            }];
            textColourProperty.warningType =UBKAccessibilityWarningTypeColourContrast;
            textColourProperty.displayWarning = self.titleLabel.text.length > 0 ? contrastWarning : false;
            [accessibilitySection addProperty:textColourProperty];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_NormalStateColour withColour:[self titleColorForState:UIControlStateNormal] withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                [self setTitleColor:updatedColour forState:UIControlStateNormal];
            }]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_HighlightedStateColour withColour:[self titleColorForState:UIControlStateHighlighted] withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                [self setTitleColor:updatedColour forState:UIControlStateHighlighted];
            }]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_DisabledStateColour withColour:[self titleColorForState:UIControlStateDisabled] withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                [self setTitleColor:updatedColour forState:UIControlStateDisabled];
            }]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_SelectedStateColour withColour:[self titleColorForState:UIControlStateSelected] withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                [self setTitleColor:updatedColour forState:UIControlStateSelected];
            }]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_TintColour withColour:self.tintColor withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
                self.tintColor = updatedColour;
            }]];
            
            if (contrastRating == ColourContrastRatingNA)
            {
                [accessibilitySection removePropertyWithDisplayTitle:kUBKAccessibilityAttributeTitle_W3CContrastRatio];
            }
            else
            {
                UBKAccessibilityProperty *contrastProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_W3CContrastRatio withValue:[NSString stringWithFormat:@"%0.2f", contrastScore] withForegroundColour:self.titleLabel.textColor withBackgroundColour:bgColour withAlternateTitle:kUBKAccessibilityAttributeTitle_TextBackgroundColour withContrastScore:[UBKAccessibilityValidation getW3CRatingForColourContrast:contrastRating] showContrastWarning:contrastWarning];
                contrastProperty.warningType = UBKAccessibilityWarningTypeColourContrastBackground;
                contrastProperty.warningLevel = UBKAccessibilityWarningLevelHigh;
                [accessibilitySection addProperty:contrastProperty];
            }
        }
        else if (accessibilitySection.sectionType == SectionDisplayTypeTypography)
        {
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Font withValue:self.titleLabel.font.familyName]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_FontBold withValue:[self.titleLabel.font ubk_isFontBold]?@"Yes":@"No"]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_FontSize withValue:[NSString stringWithFormat:@"%0.2f", self.titleLabel.font.pointSize]]];
        }
        else if (accessibilitySection.sectionType == SectionDisplayTypeAccessibilityAttributes)
        {
            [accessibilitySection configureAccessibilityProperties:self];
            UBKAccessibilityProperty *dynamicTextProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_DynamicTextSupported withValue:self.titleLabel.adjustsFontForContentSizeCategory?@"Yes":@"No" withWarningType:UBKAccessibilityWarningTypeDynamicTextSize];
            dynamicTextProperty.displayWarning = !self.titleLabel.adjustsFontForContentSizeCategory;
            [accessibilitySection addProperty:dynamicTextProperty];
        }
        else if (accessibilitySection.sectionType == SectionDisplayTypeComponentAttributes)
        {
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Enabled withValue:self.isEnabled?@"Yes":@"No"]];
            [accessibilitySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Text withValue:self.titleLabel.text]];
        }
    }
    
    NSArray *warningsArray = [UBKAccessibilityValidation checkAccessibilityWarningForButton:self withContrast:contrastScore];
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

- (void)ubk_setColour:(UIColor *)colour
{
    [super ubk_setColour:colour];
    self.titleLabel.textColor = colour;
    
    if (self.currentAttributedTitle)
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.currentAttributedTitle];
        [attributedString addAttribute:NSForegroundColorAttributeName value:colour range:NSMakeRange(0, attributedString.length)];
        [self setAttributedTitle:attributedString forState:UIControlStateNormal];
    }
}

- (NSString *)ubk_classIconName
{
    return @"icon_button";
}

@end
