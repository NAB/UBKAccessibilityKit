/*
 File: UBKAccessibilityShapeLayer.h
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

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class UIColor;

//Class is added to a ui element to show it has a warning or that it is selected.
@interface UBKAccessibilityShapeLayer : CAShapeLayer
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithLayer:(id)layer NS_UNAVAILABLE;
- (instancetype)initWithSize:(CGSize)size withColour:(UIColor *)colour;
- (void)startAnimating;
@end

NS_ASSUME_NONNULL_END
