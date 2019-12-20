/*
 File: UBKAccessibilitySection.h
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
#import "UBKAccessibilityProperty.h"
#import "UBKAccessibilityConstants.h"

typedef enum : NSUInteger {
    SectionDisplayTypeWarnings,
    SectionDisplayTypeAccessibilityAttributes,
    SectionDisplayTypeComponentAttributes,
    SectionDisplayTypeColour,
    SectionDisplayTypeTypography,
    SectionDisplayTypeVoiceOverGestures,
    SectionDisplayTypeGlobalAccessibilityProperties
} SectionDisplayType;

@interface UBKAccessibilitySection : NSObject

@property (nonatomic) SectionDisplayType sectionType;
@property (nonatomic) NSArray <UBKAccessibilityProperty *>*items;
@property (nonatomic) NSString *headerTitle;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHeader:(NSString *)header type:(SectionDisplayType)sectionType;

//Note if you pass a property with a duplicate title, the exisiting property will be overwritten
- (void)addProperty:(UBKAccessibilityProperty *)property;

//Remove property from section with matching display title
- (void)removePropertyWithDisplayTitle:(NSString *)displayTitle;

//Get the property from the sections.
- (UBKAccessibilityProperty *)getPropertyForTitleKey:(NSString *)titleKey;

//Get highest level warning
- (UBKAccessibilityWarningLevel)getHighestWarningLevelInSection;

//Configures the accessibility properties for the passed in view
- (void)configureAccessibilityProperties:(__kindof UIView *)view;

//Sorts items by warnings. Used for sorting the warnings list. Items are only sorted if the header for the section is the warning header. kUBKAccessibilityAttributeTitle_Warning_Header
- (void)sortWarningsByLevel;

// Helpers
+ (NSMutableArray *)removeSectionIn:(NSArray *)items matching:(SectionDisplayType)sectionTitle;

@end
