/*
 File: UBKAccessibilitySection.m
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

#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityValidation.h"
#import "UIView+HelperMethods.h"

@implementation UBKAccessibilitySection

- (instancetype)initWithHeader:(NSString *)header type:(SectionDisplayType)sectionType
{
    if (self = [super init])
    {
        self.sectionType = sectionType;
        self.headerTitle = header;
        self.items = @[];
    }
    return self;
}

- (void)addProperty:(UBKAccessibilityProperty *)property
{
    BOOL replaceProperty = false;
    NSInteger index = INT_MAX;
    
    //Checks if a section with the same title has already been added. If it has than get the index.
    for (UBKAccessibilityProperty *currProperty in self.items)
    {
        if ([property.displayTitle isEqualToString:currProperty.displayTitle])
        {
            //Should replace property
            replaceProperty = true;
            index = [self.items indexOfObject:currProperty];
            break;
        }
    }
    
    //If should replace the section with a new section.
    if (replaceProperty)
    {
        //Replace property
        NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithArray:self.items];
        [tmpArray replaceObjectAtIndex:index withObject:property];
        self.items = tmpArray;
    }
    else
    {
        //Add new property
        self.items = [self.items arrayByAddingObject:property];
    }
}

- (void)removePropertyWithDisplayTitle:(NSString *)displayTitle
{
    UBKAccessibilityProperty *property = nil;

    //Checks if a section with the same title has already been added. If it has than get the index.
    for (UBKAccessibilityProperty *currProperty in self.items)
    {
        if ([displayTitle isEqualToString:currProperty.displayTitle])
        {
            //Should replace property
            property = currProperty;
            break;
        }
    }
    
    if (property)
    {
        NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithArray:self.items];
        [tmpArray removeObject:property];
        self.items = tmpArray;
    }
}

- (UBKAccessibilityProperty *)getPropertyForTitleKey:(NSString *)titleKey
{
    UBKAccessibilityProperty *property = nil;
    for (UBKAccessibilityProperty *currProperty in self.items)
    {
        if ([titleKey isEqualToString:currProperty.displayTitle])
        {
            property = currProperty;
            break;
        }
    }
    return property;
}

- (UBKAccessibilityWarningLevel)getHighestWarningLevelInSection
{
    UBKAccessibilityWarningLevel warningLevel = UBKAccessibilityWarningLevelPass;

    if (self.sectionType == SectionDisplayTypeWarnings)
    {
        for (UBKAccessibilityProperty *property in self.items)
        {
            warningLevel = MIN(warningLevel, property.warningLevel);
            
            if ((property.warningLevel == UBKAccessibilityWarningLevelHigh) || (warningLevel == UBKAccessibilityWarningLevelHigh))
            {
                break;
            }
        }
    }
    return warningLevel;
}

- (void)configureAccessibilityProperties:(__kindof UIView *)view
{
    UBKAccessibilityProperty *accessibilityEnabled = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_AccessibilityEnabled withValue:view.isAccessibilityElement?@"Yes":@"No" withWarningType:UBKAccessibilityWarningTypeDisabled];
    
//   TODO: Add back in when iOS supports checking the isAccessibilityElement boolean. At the moment value is unpredictable and returns false positive results in the inspector. See ReadMe file for more information.
    accessibilityEnabled.displayWarning = !view.isAccessibilityElement;
    
    [self addProperty:accessibilityEnabled];

    UBKAccessibilityProperty *traitProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Trait withValue:[view ubk_formattedAccessibilityTraitString] withWarningType:UBKAccessibilityWarningTypeTrait];
    traitProperty.displayWarning = [UBKAccessibilityValidation hasAccessibilityTraitWarning:view];
    [self addProperty:traitProperty];

    [self addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Identifier withValue:view.accessibilityIdentifier]];

    UBKAccessibilityProperty *labelProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Label withValue:view.accessibilityLabel withWarningType:UBKAccessibilityWarningTypeLabel];
    labelProperty.displayWarning = [UBKAccessibilityValidation hasAccessibilityLabelWarning:view];
    [self addProperty:labelProperty];

    UBKAccessibilityProperty *hintProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Hint withValue:view.accessibilityHint withWarningType:UBKAccessibilityWarningTypeHint];
    hintProperty.displayWarning = [UBKAccessibilityValidation hasAccessibilityHintWarning:view];
    [self addProperty:hintProperty];

    [self addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Frame withValue:[view ubk_formattedRect:view.accessibilityFrame]]];
    [self addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_Value withValue:view.accessibilityValue withWarningType:UBKAccessibilityWarningTypeValue]];

    if ([view respondsToSelector:@selector(accessibilityPerformEscape)])
    {
        [self addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_EscapteGestureCompatible withValue:@"Yes"]];
    }

    if (@available(iOS 11.0, *)) {
        [self addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_IgnoreInvertColours withValue:view.accessibilityIgnoresInvertColors?@"Yes":@"No"]];
    } else {
        // Fallback on earlier versions
    }

    NSInteger actionCount = 1;
    for (UIAccessibilityCustomAction *action in self.accessibilityCustomActions)
    {
        [self addProperty:[[UBKAccessibilityProperty alloc]initWithTitle:[NSString stringWithFormat:@"%@ %li", kUBKAccessibilityAttributeTitle_CustomActions, (long)actionCount] withValue:action.name]];
        actionCount = actionCount + 1;
    }
}

- (void)sortWarningsByLevel
{
    if ([self.headerTitle isEqualToString:kUBKAccessibilityAttributeTitle_Warning_Header])
    {
        self.items = [self.items sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            UBKAccessibilityProperty *p1 = obj1;
            UBKAccessibilityProperty *p2 = obj2;

            if (p1.warningLevel < p2.warningLevel)
            {
                return NSOrderedAscending;
            }
            else if (p1.warningLevel > p2.warningLevel)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedSame;
            }
        }];
    }
}

#pragma mark - Helpers

+ (NSMutableArray *)removeSectionIn:(NSArray *)items matching:(SectionDisplayType)sectionTitle
{
    NSMutableArray *itemsTmp = [[NSMutableArray alloc]initWithArray:items];
    NSInteger indexTmp = INT_MAX;
    for (UBKAccessibilitySection *accessibilitySection in itemsTmp)
    {
        if (accessibilitySection.sectionType == sectionTitle)
        {
            indexTmp = [itemsTmp indexOfObject:accessibilitySection];
            break;
        }
    }
    if (indexTmp < itemsTmp.count)
    {
        [itemsTmp removeObjectAtIndex:indexTmp];
    }
    return itemsTmp;
}

@end
