/*
 File: UBKAccessibilityHighlightAction.h
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

NS_ASSUME_NONNULL_BEGIN

//Custom class of UIAccessibilityCustomAction, adds in the property for actionTag.
//Class is used for each element cell in the UBKAccessibilityElementsTableViewController.
//When initalized the class actionTag is set to the row index. This allows the selector to
//find the correct ui element from an array when the action is performed.

@interface UBKAccessibilityHighlightAction : UIAccessibilityCustomAction
@property (nonatomic) NSInteger actionTag;
@end

NS_ASSUME_NONNULL_END
