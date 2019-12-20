//
//  NSArray+HelperMethods.m
//  UBKAccessibilityKit
//
//  Created by Aaron Stephenson on 1/4/19.
//  Copyright © 2019 UBank. All rights reserved.
//

#import "NSArray+HelperMethods.h"
#import "UBKAccessibilitySection.h"

@implementation NSArray (HelperMethods)

- (UBKAccessibilitySection *)ubk_sectionForTitleKey:(NSString *)titleKey
{
    UBKAccessibilitySection *section = nil;
    for (UBKAccessibilitySection *currSection in self)
    {
        if ([titleKey isEqualToString:currSection.headerTitle])
        {
            section = currSection;
            break;
        }
    }
    return section;
}

- (NSInteger)ubk_indexForSectionTitleKey:(NSString *)titleKey
{
    NSInteger index = 0;
    for (UBKAccessibilitySection *currSection in self)
    {
        if ([titleKey isEqualToString:currSection.headerTitle])
        {
            break;
        }
        index = index + 1;
    }
    return index;
}

- (NSInteger)ubk_indexForCellTitleKey:(NSString *)titleKey
{
    NSInteger index = 0;
    for (UBKAccessibilityProperty *accessibilityProperty in self)
    {
        if ([titleKey isEqualToString:accessibilityProperty.displayTitle])
        {
            break;
        }
        index = index + 1;
    }
    return index;
}

@end
