/*
 File: UIColor+HelperMethods.h
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

#import <UIKit/UIKit.h>

@interface UIColor (HelperMethods)
- (NSString *)ubk_hexStringFromColour;
- (NSString *)ubk_rgbStringFromColour;
- (double)ubk_contrastRatio:(UIColor *)other;
- (UIColor *)ubk_lighterColour;
- (UIColor *)ubk_darkerColour;
- (UIColor *)ubk_analagousColour:(CGFloat)value;

+ (UIColor *)ubk_findBetterContrastColour:(UIColor *)forground backgroundColour:(UIColor *)background previousContrast:(double)previousContrast;
+ (UIColor *)ubk_colourFromHexString:(NSString *)hexString;

+ (UIColor *)ubk_warningLevelHighForegroundColour;
+ (UIColor *)ubk_warningLevelHighBackgroundColour;
+ (UIColor *)ubk_warningLevelMediumForegroundColour;
+ (UIColor *)ubk_warningLevelMediumBackgroundColour;
+ (UIColor *)ubk_warningLevelLowForegroundColour;
+ (UIColor *)ubk_warningLevelLowBackgroundColour;
+ (UIColor *)ubk_warningLevelPassBackgroundColour;
@end
