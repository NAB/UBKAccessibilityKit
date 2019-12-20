/*
 File: UBKAccessibilityManager.h
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
#import "UBKAccessibilityColours.h"

@class UBKAccessibilityWindow, UBKAccessibilityInspectorViewController, UBKNavigationController, UBKAccessibilityInspectorContainerView, UBKAccessibilityProperty, UBKAccessibilityValidColour, UBKAccessibilityFilter;

@interface UBKAccessibilityManager : NSObject

+ (UBKAccessibilityManager *)sharedInstance;

@property (nonatomic, weak) UBKAccessibilityWindow *window;
@property (nonatomic) UBKNavigationController *navigationViewController;
@property (nonatomic) UBKAccessibilityInspectorContainerView *inspectorContainerView;

//All ui elements are passed through the Accessibility filter to either show or hide it while navigating the accessibility inspector.
@property (nonatomic) UBKAccessibilityFilter *accessibilityFilter;

//Colours
//isValidating colours is used to show a warning for colours not matching in the AccessibilityColours array.
@property (nonatomic) BOOL isValidatingColours; // default off, set to true if
//If isValidatingColours is true and colours exist in the accessibilityColours array but none of the colours used match a warning will be shown for that colour.
@property (nonatomic) UBKAccessibilityColours *accessibilityColours; //array of UIColours

//Array of views that are currently being "selected" used for the layers hierarchy
@property (nonatomic) NSMutableArray *currentTouchedElements;

//Array of views that are a first class citizens for touches. Views added to this array are checked when touches occur
@property (nonatomic) NSMutableSet <UIView *> *accessibilityViews;

@property (nonatomic) BOOL alertOnScreenAllowTouchEvents;
@property (nonatomic) BOOL allowNormalTouchEvents;
@property (nonatomic) BOOL isShowingHighlightedUI;
@property (nonatomic) BOOL isShowingTouchAnimations;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)showInspector:(BOOL)popViewController;
- (void)hideInspector;

//Pass in the view that was selected.
- (void)checkHitTest:(UIView *)view withTouches:(UITouch *)touch;

//Reloads all the UI elements on the elements in the UBKAccessibilityElementsTableViewController.
- (void)configureAllUIElments;
- (UBKAccessibilityWarningLevel)showWarningLevelForView;

//Reset all outlines
- (void)removeAllOutlines;

@end
