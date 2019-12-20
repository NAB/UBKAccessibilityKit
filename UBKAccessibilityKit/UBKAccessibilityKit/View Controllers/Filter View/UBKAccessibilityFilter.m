/*
 File: UBKAccessibilityFilter.m
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

#import "UBKAccessibilityFilter.h"
#import "UIView+UBKAccessibility.h"
#import "UBKAccessibilitySection.h"
#import "NSArray+HelperMethods.h"
#import "UBKAccessibilityConstants.h"

@import UIKit;

@implementation UBKAccessibilityFilter

- (instancetype)init
{
    if (self = [super init])
    {
        self.filteredObjects = [[NSMutableArray alloc]init];
        self.warningTypesAvailable = [[NSMutableArray alloc]init];
        self.warningTypesSelected = [[NSMutableArray alloc]init];
        self.warningLevels = [[NSMutableArray alloc]init];
        self.objectClassNames = [[NSMutableArray alloc]init];
        [self resetFilter];
    }
    return self;
}

- (void)resetFilter
{
    [self.warningTypesSelected removeAllObjects];
    [self.warningTypesAvailable removeAllObjects];
    [self.warningLevels removeAllObjects];
    [self.objectClassNames removeAllObjects];
    
    [self toggleWarningLevelToWarningLevels:UBKAccessibilityWarningLevelHigh];
    [self toggleWarningLevelToWarningLevels:UBKAccessibilityWarningLevelMedium];
    [self toggleWarningLevelToWarningLevels:UBKAccessibilityWarningLevelLow];
    
    [self configureWarningTypesForWarningLevels];
    
    ///TODO: add in filtering for object types
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUIButton];
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUIImageView];
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUILabel];
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUISlider];
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUISwitch];
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUITextfield];
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUITextView];
    [self toggleObjectClassToObjectClassNames:UBKAccessibilityObjectClassUIView];
}

- (void)configureWarningTypesForWarningLevels
{
    [self.warningTypesSelected removeAllObjects];
    [self.warningTypesAvailable removeAllObjects];

    for (NSString *warningTypes in self.warningLevels)
    {
        if ([warningTypes integerValue] == UBKAccessibilityWarningLevelHigh)
        {
            [self loadWarningsForHigh];
        }
        else if ([warningTypes integerValue] == UBKAccessibilityWarningLevelMedium)
        {
            [self loadWarningsForMedium];
        }
        else if ([warningTypes integerValue] == UBKAccessibilityWarningLevelLow)
        {
            [self loadWarningsForLow];
        }
    }
}

- (void)loadWarningsForHigh
{
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeLabel];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeMissingLabel];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeColourContrast];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeColourContrastBackground];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeWrongColour];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeMinimumSize];

    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeLabel withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeMissingLabel withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeColourContrast withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeColourContrastBackground withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeWrongColour withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeMinimumSize withArray:self.warningTypesAvailable];
    
    self.warningTypesAvailable = [[NSMutableArray alloc]initWithArray:[self.warningTypesAvailable sortedArrayUsingSelector: @selector(compare:)]];
}

- (void)loadWarningsForMedium
{
    //Updates the selected warning types, this shows a tick next to each cell in the available list.
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeTrait];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeValue];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeDisabled];
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeDynamicTextSize];

    //Update the available warning types, this displays all available for the medium warning type.
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeTrait withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeValue withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeDisabled withArray:self.warningTypesAvailable];
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeDynamicTextSize withArray:self.warningTypesAvailable];
    
    self.warningTypesAvailable = [[NSMutableArray alloc]initWithArray:[self.warningTypesAvailable sortedArrayUsingSelector: @selector(compare:)]];
}

//No low warnings are currently being used in the framework. This is available for future use.
- (void)loadWarningsForLow
{
    //Updates the selected warning types, this shows a tick next to each cell in the available list.
    [self toggleSelectedWarningType:UBKAccessibilityWarningTypeHint];

    //Update the available warning types, this displays all available for the medium warning type.
    [self toggleWarningTypeToWarningTypes:UBKAccessibilityWarningTypeHint withArray:self.warningTypesAvailable];
    
    self.warningTypesAvailable = [[NSMutableArray alloc]initWithArray:[self.warningTypesAvailable sortedArrayUsingSelector: @selector(compare:)]];
}

- (void)toggleWarningTypeToWarningTypes:(UBKAccessibilityWarningType)warning withArray:(NSMutableArray *)array
{
    NSNumber *warningNumber = [NSNumber numberWithInteger:warning];
    [self toggleNumber:warningNumber inArray:array];
}

- (void)toggleSelectedWarningType:(UBKAccessibilityWarningType)warning
{
    [self toggleWarningTypeToWarningTypes:warning withArray:self.warningTypesSelected];
}

- (void)toggleWarningLevelToWarningLevels:(UBKAccessibilityWarningLevel)warning
{
    NSNumber *warningNumber = [NSNumber numberWithInteger:warning];
    [self toggleNumber:warningNumber inArray:self.warningLevels];
}

- (void)toggleObjectClassToObjectClassNames:(UBKAccessibilityObjectClass)className
{
    NSNumber *objectClassNumber = [NSNumber numberWithInteger:className];
    [self toggleNumber:objectClassNumber inArray:self.objectClassNames];
}

#pragma mark - Helper methods

- (void)toggleNumber:(NSNumber *)number inArray:(NSMutableArray *)array
{
    if (![array containsObject: number])
    {
        [array addObject:number];
    }
    else
    {
        [array removeObject:number];
    }
}

+ (NSString *)warningNameForWarningType:(UBKAccessibilityWarningType)warningType
{
    NSString *warningString = @"UNKNOWN warning";
    switch (warningType)
    {
        case UBKAccessibilityWarningTypeMinimumSize:
        {
            warningString = @"Minimum size";
            break;
        }
        case UBKAccessibilityWarningTypeColourContrast:
        {
            warningString = @"Colour contrast - Foreground";
            break;
        }
        case UBKAccessibilityWarningTypeColourContrastBackground:
        {
            warningString = @"Colour contrast - Background";
            break;
        }
        case UBKAccessibilityWarningTypeTrait:
        {
            warningString = @"Accessibility trait";
            break;
        }
        case UBKAccessibilityWarningTypeLabel:
        {
            warningString = @"Accessibility label";
            break;
        }
        case UBKAccessibilityWarningTypeHint:
        {
            warningString = @"Accessibility hint";
            break;
        }
        case UBKAccessibilityWarningTypeValue:
        {
            warningString = @"Accessibility value";
            break;
        }
        case UBKAccessibilityWarningTypeDisabled:
        {
            warningString = @"Accessibility disabled";
            break;
        }
        case UBKAccessibilityWarningTypeWrongColour:
        {
            warningString = @"Wrong colour";
            break;
        }
        case UBKAccessibilityWarningTypeMissingLabel:
        {
            warningString= @"Missing accessibility label";
            break;
        }
        case UBKAccessibilityWarningTypeDynamicTextSize:
        {
            warningString = @"Dynamic text size";
            break;
        }
    }
    return warningString;
}

+ (NSString *)warningNameForWarningLevel:(UBKAccessibilityWarningLevel)warningLevel
{
    NSString *warningString = @"UNKNOWN level";
    switch (warningLevel)
    {
        case UBKAccessibilityWarningLevelPass:
        {
            warningString= @"UI without warnings";
            break;
        }
        case UBKAccessibilityWarningLevelLow:
        {
            warningString= @"Low warnings";
            break;
        }
        case UBKAccessibilityWarningLevelMedium:
        {
            warningString= @"Medium warnings";
            break;
        }
        case UBKAccessibilityWarningLevelHigh:
        {
            warningString= @"High warnings";
            break;
        }
    }
    return warningString;
}

+ (NSString *)objectClassNameForObjectClassNames:(UBKAccessibilityObjectClass)objectClass
{
    NSString *warningString = @"UNKNOWN class";
    switch (objectClass)
    {
        case UBKAccessibilityObjectClassUIButton:
        {
            warningString= @"UIButton";
            break;
        }
        case UBKAccessibilityObjectClassUIImageView:
        {
            warningString= @"UIImageView";
            break;
        }
        case UBKAccessibilityObjectClassUILabel:
        {
            warningString= @"UILabel";
            break;
        }
        case UBKAccessibilityObjectClassUISlider:
        {
            warningString= @"UISlider";
            break;
        }
        case UBKAccessibilityObjectClassUISwitch:
        {
            warningString= @"UISwitch";
            break;
        }
        case UBKAccessibilityObjectClassUITextfield:
        {
            warningString= @"UITextfield";
            break;
        }
        case UBKAccessibilityObjectClassUITextView:
        {
            warningString= @"UITextView";
            break;
        }
        case UBKAccessibilityObjectClassUIView:
        {
            warningString= @"UIView";
            break;
        }
    }
    return warningString;
}

- (void)applyFilter
{
    self.filteredObjects = [self filterObjects:self.filteredObjects];
}

- (NSMutableArray *)filterObjects:(NSArray *)objects
{
    NSMutableArray *filteredObjects = [[NSMutableArray alloc]init];
    for (UIView *view in objects)
    {
        if ([self filterObject:view])
        {
            [filteredObjects addObject:view];
        }
    }
    return filteredObjects;
}

- (BOOL)filterObject:(UIView *)view
{
    ///WIP: Check class
//    if (![self.objectClassNames containsObject:NSStringFromClass([view class])])
//    {
//        return false;
//    }
    
    //Check warning type and level
    BOOL addObject = false;
    NSArray *itemsArray = view.ubk_accessibilityDetails;
    UBKAccessibilitySection *section = [itemsArray ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];
    if (section)
    {
        for (UBKAccessibilityProperty *property in section.items)
        {
            UBKAccessibilityWarningLevel warningLevel = property.warningLevel;
            UBKAccessibilityWarningType warningType = property.warningType;

            if (([self.warningLevels containsObject:@(warningLevel)]) && ([self.warningTypesSelected containsObject:@(warningType)]))
            {
                addObject = true;
                break;
            }
        }
    }
    else if ([self.warningLevels containsObject:@(UBKAccessibilityWarningLevelPass)])
    {
        addObject = true;
    }
    return addObject;
}

- (NSInteger)filterCount
{
    NSInteger warningTypeCount = self.warningTypesSelected.count;
    NSInteger warningLevelCount = self.warningLevels.count;
    return warningTypeCount + warningLevelCount;
}

@end
