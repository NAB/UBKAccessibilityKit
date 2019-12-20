/*
 File: UBKAccessibilityInspectorGutterContainerView.h
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

@protocol UBKAccessibilityInspectorGutterViewDelegate;

typedef enum : NSUInteger {
    GutterPositionNone,
    GutterPositionTop,
    GutterPositionLeft,
    GutterPositionRight,
    GutterPositionBottom
} GutterPosition;

NS_ASSUME_NONNULL_BEGIN

//Class is used by the UBKAccessibilityInspectorContainerView.
//Holds the top, left, right and bottom views shown when the inspector is dragged.

@interface UBKAccessibilityInspectorGutterContainerView : UIView

//Gutter container delete, used when the user has dropped the inspector into a gutter view (top, left, right and bottom).
@property (nonatomic, weak) id <UBKAccessibilityInspectorGutterViewDelegate> delegate;

//Setup each gutter view (top, left, right and bottom).
- (void)initalizeGutterViews;

//Hide all gutter views (top, left, right and bottom).
- (void)hideAllGutterViews;

//Change the appearance of the gutter under the drag touch point.
- (void)highlightGutterUnderTouchPoint:(CGPoint)touchPoint;

//Touch did end, pass the last touch point. If true, delegate method is called
- (void)checkInspectorDropTouchPoint:(CGPoint)touchPoint;
@end

NS_ASSUME_NONNULL_END

@protocol UBKAccessibilityInspectorGutterViewDelegate <NSObject>

- (void)didDropInspectorInGutter:(GutterPosition)gutterPosition;

@end
