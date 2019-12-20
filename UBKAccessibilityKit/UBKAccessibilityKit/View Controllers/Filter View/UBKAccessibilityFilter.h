/*
 File: UBKAccessibilityFilter.h
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
#import "UBKAccessibilityConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class NSArray;
@class UIView;

//Used to filter all objects on screen and determine if they should or should not be visible in the inspector elements views.
@interface UBKAccessibilityFilter : NSObject
+ (NSString *)warningNameForWarningType:(UBKAccessibilityWarningType)warningType;
+ (NSString *)warningNameForWarningLevel:(UBKAccessibilityWarningLevel)warningLevel;
+ (NSString *)objectClassNameForObjectClassNames:(UBKAccessibilityObjectClass)objectClass;

@property (nonatomic) NSMutableArray *filteredObjects;

@property (nonatomic) NSMutableArray *warningLevels;
- (void)toggleWarningLevelToWarningLevels:(UBKAccessibilityWarningLevel)warning;

@property (nonatomic) NSMutableArray *warningTypesAvailable;
@property (nonatomic) NSMutableArray *warningTypesSelected;
- (void)toggleSelectedWarningType:(UBKAccessibilityWarningType)warning;
- (void)configureWarningTypesForWarningLevels;

@property (nonatomic) NSMutableArray *objectClassNames;
- (void)toggleObjectClassToObjectClassNames:(UBKAccessibilityObjectClass)className;

- (void)resetFilter;
- (void)applyFilter;
- (NSInteger)filterCount;
@end

NS_ASSUME_NONNULL_END
