/*
 File: UBKAccessibilityProperty.h
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

NS_ASSUME_NONNULL_BEGIN

typedef void (^AccessibilityPropertySelectorActionCompletionBlock)(id _Nullable selector);
typedef void (^AccessibilityPropertyColourUpdateCompletionBlock)(UIColor *updatedColour);

typedef enum : NSUInteger {
    PropertyDisplayTypeTitleValue,
    PropertyDisplayTypeColour,
    PropertyDisplayTypeImage,
    PropertyDisplayTypeContrast,
    PropertyDisplayTypeAction
} PropertyDisplayType;

//Each UBKAccessibilityProperty is a row in the inspector details view controller.
@interface UBKAccessibilityProperty : NSObject

@property (nonatomic) BOOL canUpdateUI;
@property (nonatomic) AccessibilityPropertyColourUpdateCompletionBlock colourUpdateCompletionBlock;
@property (nonatomic) AccessibilityPropertySelectorActionCompletionBlock actionUpdateCompletionBlock;
@property (nonatomic) PropertyDisplayType displayType;
@property (nonatomic) NSString *displayTitle;
@property (nonatomic) NSString *displayValue;
@property (nonatomic) UIColor *displayColour;
@property (nonatomic) UIColor *displayAlternateColour;
@property (nonatomic) NSString *displayContrastScore;
@property (nonatomic) NSString *displayAlternateTitle;
@property (nonatomic) BOOL displayWarning;
@property (nonatomic) UITableViewCellAccessoryType cellAccessoryType;
@property (nonatomic) UBKAccessibilityWarningLevel warningLevel;
@property (nonatomic) UBKAccessibilityWarningType warningType;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTitle:(NSString *)title withValue:(NSString *)value;
- (instancetype)initWithTitle:(NSString *)title withValue:(nonnull NSString *)value withForegroundColour:(nonnull UIColor *)foregroundColour withBackgroundColour:(nonnull UIColor *)backgroundColour withAlternateTitle:(NSString *)alternateTitle withContrastScore:(NSString *)contrastScore showContrastWarning:(BOOL)showWarning;

- (instancetype)initWithTitle:(NSString *)title withColour:(UIColor *)colour;
- (instancetype)initWithTitle:(NSString *)title withColour:(UIColor *)colour withColourUpdateCompletionBlock:( AccessibilityPropertyColourUpdateCompletionBlock)completionBlock;

- (instancetype)initWithTitle:(NSString *)title withValue:(NSString *)value withWarningType:(UBKAccessibilityWarningType)warningType;
- (instancetype)initWithTitle:(NSString *)title withValue:(NSString *)value withActionCompletionBlock:(AccessibilityPropertySelectorActionCompletionBlock)completionBlock;

- (id)mutableCopyWithZone:(NSZone *)zone;

@end

NS_ASSUME_NONNULL_END
