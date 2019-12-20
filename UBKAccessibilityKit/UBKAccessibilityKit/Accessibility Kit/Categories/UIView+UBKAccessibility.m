/*
 File: UIView+UBKAccessibility.m
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

#import "UIView+UBKAccessibility.h"

//Categories
#import "UIColor+HelperMethods.h"
#import "UIFont+HelperMethods.h"
#import "UIView+HelperMethods.h"
#import "CALayer+HelperMethods.h"

#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityValidation.h"

@implementation UIView (UBKAccessibility)

#pragma mark - UBKAccessibilityProtocol

- (NSArray<UBKAccessibilitySection *> *)ubk_accessibilityDetails
{
    UIColor *bgColour = [self ubk_findBackgroundColour:self];
    NSMutableArray *sectionsArray = [[NSMutableArray alloc]init];
    
    UBKAccessibilitySection *accessibilityAttributesSection = [[UBKAccessibilitySection alloc]initWithHeader:kUBKAccessibilityAttributeTitle_AccessibilityAttributes type:SectionDisplayTypeAccessibilityAttributes];
    
    [accessibilityAttributesSection configureAccessibilityProperties:self];
    [sectionsArray addObject:accessibilityAttributesSection];
    
    //Configure Colours Section
    UBKAccessibilitySection *attributesSection = [[UBKAccessibilitySection alloc]initWithHeader:kUBKAccessibilityAttributeTitle_Attributes type:SectionDisplayTypeComponentAttributes];
    [attributesSection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_ClassName withValue:NSStringFromClass([self class])]];
    [attributesSection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Frame withValue:[self ubk_formattedRect:self.frame]]];
    [attributesSection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_UserInteractionEnabled withValue:self.userInteractionEnabled?@"Yes":@"No"]];
    if (self.userInteractionEnabled)
    {
        UBKAccessibilityProperty *minimumSizeProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_MinimumSizeWarning withValue:[UBKAccessibilityValidation getMinimumSizeWarningTitle:self] withWarningType:UBKAccessibilityWarningTypeMinimumSize];
        minimumSizeProperty.displayWarning = [UBKAccessibilityValidation hasMinimumSizeWarning:self];
        [attributesSection addProperty:minimumSizeProperty];
    }
    [sectionsArray addObject:attributesSection];
    
    CGFloat contrastScore = [UBKAccessibilityValidation getViewContrastRatio:self.tintColor backgroundColor:bgColour];
    ColourContrastRating contrastRating = [UBKAccessibilityValidation getColourContrastRatingForNonText:contrastScore];
    BOOL contrastWarning = false;
    if (contrastRating == ColourContrastRatingFail)
    {
        contrastWarning = true;
    }
    
    UBKAccessibilitySection *coloursSection = [[UBKAccessibilitySection alloc]initWithHeader:kUBKAccessibilityAttributeTitle_Colours type:SectionDisplayTypeColour];
    if (([self respondsToSelector:@selector(font)]) || ([self respondsToSelector:@selector(textLabel)]) || ([self isKindOfClass:[UIImageView class]]))
    {
        UBKAccessibilityProperty *contrastProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_W3CContrastRatio withValue:[NSString stringWithFormat:@"%0.2f", contrastScore] withForegroundColour:self.tintColor withBackgroundColour:bgColour withAlternateTitle:kUBKAccessibilityAttributeTitle_TintBackgroundColour withContrastScore:[UBKAccessibilityValidation getW3CRatingForColourContrast:contrastRating] showContrastWarning:contrastWarning];
        contrastProperty.warningLevel = UBKAccessibilityWarningLevelHigh;
        [coloursSection addProperty:contrastProperty];
    }
    [coloursSection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_BackgroundColour withColour:bgColour withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
        self.backgroundColor = updatedColour;
    }]];
    
    [coloursSection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_TintColour withColour:self.tintColor withColourUpdateCompletionBlock:^(UIColor * _Nonnull updatedColour) {
        self.tintColor = updatedColour;
    }]];
    [sectionsArray addObject:coloursSection];
    
    if (([self respondsToSelector:@selector(font)]) || ([self respondsToSelector:@selector(textLabel)]))
    {
        UBKAccessibilitySection *typographySection = [[UBKAccessibilitySection alloc]initWithHeader:kUBKAccessibilityAttributeTitle_Typography type:SectionDisplayTypeTypography];
        [typographySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Font withValue:@""]];
        [typographySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_FontBold withValue:@""]];
        [typographySection addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_FontSize withValue:@""]];
        [sectionsArray addObject:typographySection];
    }
    return sectionsArray;
}

- (void)ubk_setColour:(UIColor *)colour
{
    self.tintColor = colour;
}

- (void)ubk_setHighlightedItemAppearanceColour:(UIColor *)colour
{
    [self.layer ubk_showLayerBoxWithColour:colour];
}

- (void)ubk_setSelectedItemAppearanceColour:(UIColor *)colour
{
    [self.layer ubk_showLayerBoxWithColour:colour];
}

- (void)ubk_setDeselectedItemAppearance
{
    [self.layer ubk_hideLayerBox];
}

- (NSString *)ubk_classIconName
{
    return @"ubk_icon_view";
}

@end
