/*
 File: UBKColourPickerTableViewController.h
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
#import "UBKAccessibilityProperty.h"

NS_ASSUME_NONNULL_BEGIN

//View controller contains a tableview, shows a list of colours and contrast values. Is used to update the selected ui element colour for foreground or background colours.
@interface UBKColourPickerTableViewController : UIViewController
//Object represents the foreground colour for the selected ui element, if its a label the text colour is passed in, if its a view it will be the tint colour etc.
//If the property has an AccessibilityPropertyColourUpdateCompletionBlock block it will call that on selecting a colour from the views tableview. This should update the foreground colour.
@property (nonatomic) UBKAccessibilityProperty *accessibilityProperty;

//Object represents the background colour for the selected ui element, if its a view it will be the background colour.
//If the property has an AccessibilityPropertyColourUpdateCompletionBlock block it will call that on selecting a colour from the views tableview. This should update the background colour.
@property (nonatomic) UBKAccessibilityProperty *accessibilityBackground;

//The actual ui element that has been selected.
@property (nonatomic) UIView *selectedElement;

//This is set to true if updaing the selected ui elements background colour.
@property (nonatomic) BOOL changingBackgroundColour;
@end

NS_ASSUME_NONNULL_END
