/*
 File: UBKAccessibilityValidation.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UBKAccessibilityConstants.h"

@class UBKAccessibilitySection;

typedef enum : NSUInteger {
    ColourContrastRatingNA,
    ColourContrastRatingFail,
    ColourContrastRatingAA,
    ColourContrastRatingAALarge,
    ColourContrastRatingAAA,
    ColourContrastRatingAAALarge,
} ColourContrastRating;

//The main validation class for determing if warnings should be shown for a ui element
@interface UBKAccessibilityValidation : NSObject

//Get the title for when the view has a minimum size warning
+ (NSString *)getMinimumSizeWarningTitle:(UIView *)view;

+ (NSString *)getW3CRatingForColourContrast:(ColourContrastRating)rating;

//Non text UI elements colour contrast rating
+ (NSString *)getTitleColourContrastRatingForNonText:(CGFloat)contrast;
+ (ColourContrastRating)getColourContrastRatingForNonText:(CGFloat)contrast;

//Text UI elements colour contrast rating
+ (NSString *)getTitleColourContrastRatingForText:(CGFloat)contrast withTextSize:(double)textSize withBoldFont:(BOOL)boldFont;
+ (ColourContrastRating)getColourContrastRatingForText:(CGFloat)contrast withTextSize:(double)textSize withBoldFont:(BOOL)boldFont;

+ (CGFloat)getViewContrastRatio:(UIColor *)foregroundColour backgroundColor:(UIColor *)backgroundColour;

//Check if has minimum size warning
+ (BOOL)hasMinimumSizeWarning:(UIView *)view;

//Check if has accessibility trait warning
+ (BOOL)hasAccessibilityTraitWarning:(UIView *)view;

//Check if the accessibility label has a warning
+ (BOOL)hasAccessibilityLabelWarning:(UIView *)view;

//Check if the accessbility hint has a warning;
+ (BOOL)hasAccessibilityHintWarning:(UIView *)view;

//Check if the UI element is interactive but is missing the accessibiliy flag
+ (BOOL)hasAccessibilityWarningForMissingFlag:(UIView *)view;

//Checks colours used against matching text colours.
+ (BOOL)hasColourMatchWarning:(UIColor *)colour;

//Setup any warning properties for the UI object.
+ (UBKAccessibilitySection *)configureWarningSection:(UBKAccessibilitySection *)warningsSection withWarnings:(NSArray<NSNumber *> *)warningsArray;

//Base Accessibility Warning Validation
//Does all checks to see if has any accessibility warnings
+ (NSArray *)checkBaseAccessibilityWarnings:(UIView *)view;

//UIButton Validation
//Check if the button has a warning
+ (NSArray *)checkAccessibilityWarningForButton:(UIButton *)button withContrast:(double)contrast;

//UILabel Validation
//Check if the label has a warning
+ (NSArray *)checkAccessibilityWarningForLabel:(UILabel *)label withContrast:(double)contrast;

//UISwitch Validation
//Check if the switch has a warning
+ (NSArray *)checkAccessibilityWarningForSwitch:(UISwitch *)switchObject;

//ImageView Validation
//Check if an image label has not been set, accessibility is using the default image name and if the contrast on a template image is set correctly.
+ (NSArray *)checkAccessibilityWarningForImageView:(UIImageView *)imageView withContrast:(double)contrast;

//UITextfield Validation
//Check if the textfield has a warning
+ (NSArray *)checkAccessibilityWarningForTextfield:(UITextField *)textfield withContrast:(double)contrast;

//UITextView
//Check if the textview has a warning
+ (NSArray *)checkAccessibilityWarningForTextView:(UITextView *)textView withContrast:(double)contrast;

//UISlider
//Check if the textview has a warning
+ (NSArray *)checkAccessibilityWarningForSlider:(UISlider *)slider;

//Get the warning level for a warning type
+ (UBKAccessibilityWarningLevel)getWarningLevelForWarningType:(UBKAccessibilityWarningType)warningType;

//Get the display title for a warning type
+ (NSString *)getWarningTitleForWarningType:(UBKAccessibilityWarningType)warningType;

@end
