/*
 File: UBKAccessibilityColours.h
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

@class UBKAccessibilityValidColour, UBKAccessibilityProperty;

NS_ASSUME_NONNULL_BEGIN

@interface UBKAccessibilityColours : NSObject

//Default colours are added into this array.
@property (nonatomic) NSMutableArray<UBKAccessibilityProperty *> *defaultColoursArray;

//Suggested colours, colours are added to this if the colour contrast levels fail for the selected ui element.
@property (nonatomic) NSMutableArray<UBKAccessibilityProperty *> *suggestedColoursArray;

/*  Default colours */
// Replaces default colours with user defined colours
- (void)replaceDefaultColours:(NSArray <UBKAccessibilityValidColour *> *)colourArray;

//Add single colour to colours array, checks if colour is already in array before adding, validates against colour
- (void)addDefaultColour:(UIColor *)colour withTitle:(NSString *)title;

//Remove a colour from the colours array
- (void)removeDefaultColour:(UBKAccessibilityProperty *)colourProperty;

/*  Suggested colours */
//Suggested Colours, used when the colour contrast fails for the ui element.
- (void)addSuggestedColour:(UIColor *)colour withTitle:(NSString *)title;

//Remove single suggested colour from suggestedColoursArray
- (void)removeSuggestedColour:(UBKAccessibilityProperty *)colourProperty;

//Removes all suggested colours from the suggestedColoursArray
- (void)removeAllSuggestedColours;

@end

NS_ASSUME_NONNULL_END
