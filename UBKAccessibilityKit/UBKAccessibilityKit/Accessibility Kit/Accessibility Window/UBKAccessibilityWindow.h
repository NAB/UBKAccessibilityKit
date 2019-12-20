/*
 File: UBKAccessibilityWindow.h
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

@class UBKAccessibilityButton;

@interface UBKAccessibilityWindow : UIWindow

///TODO: fix this
//Enable/Disable the accessibility inspector. Setting this to false will disable the custom UIWindow
@property (nonatomic) BOOL enableInspector;

//Accessibility button shown on screen, button shows warnings and has an active and inactive state.
@property (nonatomic) UBKAccessibilityButton *inspectorButton;

//Configures the screenshot service, screenshot service is only available in iOS 13+ and provides an Accessibility Report when a screenshot is taken.
- (void)configureScreenshotService;

@end

