/*
 File: UBKAccessibilityProtocol.h
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

@class UBKAccessibilitySection;

NS_ASSUME_NONNULL_BEGIN

@protocol UBKAccessibilityProtocol <NSObject>

//The accessibility details array is the back bone for validations and displaying information about the ui element.
- (NSArray <UBKAccessibilitySection *> *)ubk_accessibilityDetails;

//Used to set the foreground colour for the ui element, eg if a label the text colour or a view is the tint colour. Override this method in your custom class.
- (void)ubk_setColour:(UIColor *)colour;

//When showing all warnings on screen the highlighted item appearance colour method is used.
- (void)ubk_setHighlightedItemAppearanceColour:(UIColor *)colour;

//When the ui element is selected this method is used. This method is called when the view is tapped on screen. By default an outline layer (UBKAccessibilityShapeLayer) is added to the view.
- (void)ubk_setSelectedItemAppearanceColour:(UIColor *)colour;

//When the view is deselected this method is called. This removes an outline layer (UBKAccessibilityShapeLayer).
- (void)ubk_setDeselectedItemAppearance;

//Used to return the class name icon shown on the ui elements list view controller.
- (NSString *)ubk_classIconName;
@end

NS_ASSUME_NONNULL_END
