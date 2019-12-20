/*
 File: UISwitch+UBKAccessibility.m
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

#import "UISwitch+UBKAccessibility.h"

#import "UIFont+HelperMethods.h"

#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityValidation.h"

@implementation UISwitch (UBKAccessibility)

- (nonnull NSArray<UBKAccessibilitySection *> *)ubk_accessibilityDetails
{
    NSArray *items = [super ubk_accessibilityDetails];
    NSMutableArray *itemsTmp = [[NSMutableArray alloc]initWithArray:items];
    
    NSArray *warningsArray = [UBKAccessibilityValidation checkAccessibilityWarningForSwitch:self];
    if (warningsArray.count > 0)
    {
        //UI element has a warning. Check which warning should be showed.
        UBKAccessibilitySection *warningsSection = [[UBKAccessibilitySection alloc]initWithHeader:kUBKAccessibilityAttributeTitle_Warning_Header type:SectionDisplayTypeWarnings];
        
        //Add any validation warning properties.
        warningsSection = [UBKAccessibilityValidation configureWarningSection:warningsSection withWarnings:warningsArray];
        
        //Add in warnings to section
        if (warningsSection.items.count > 0)
        {
            [itemsTmp insertObject:warningsSection atIndex:0];
        }
    }
    
    itemsTmp = [UBKAccessibilitySection removeSectionIn:itemsTmp matching:SectionDisplayTypeTypography];
    return itemsTmp;
}

- (NSString *)ubk_classIconName
{
    return @"icon_switch";
}

@end
