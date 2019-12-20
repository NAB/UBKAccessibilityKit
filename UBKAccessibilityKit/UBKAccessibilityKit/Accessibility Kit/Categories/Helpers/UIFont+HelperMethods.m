/*
 File: UIFont+HelperMethods.m
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

#import "UIFont+HelperMethods.h"

@implementation UIFont (HelperMethods)

- (BOOL)ubk_isFontBold
{
    UIFontDescriptor *fontDescriptor = self.fontDescriptor;
    UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;
    return (fontDescriptorSymbolicTraits & UIFontDescriptorTraitBold) != 0;
}

- (NSString *)ubk_fontStyleName
{
    NSString *fontStyleString = [self.fontDescriptor objectForKey:UIFontDescriptorTextStyleAttribute];
    if ([fontStyleString isEqualToString:@"UIFontTextStyleHeadline"])
    {
        fontStyleString = @"Headline";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleSubheadline"])
    {
        fontStyleString = @"Subheadline";
    }
    else if ([fontStyleString isEqualToString:@"UICTFontTextStyleBody"])
    {
        fontStyleString = @"Body";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleFootnote"])
    {
        fontStyleString = @"Footnote";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleCaption1"])
    {
        fontStyleString = @"Caption 1";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleCaption2"])
    {
        fontStyleString = @"Caption 2";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleCallout"])
    {
        fontStyleString = @"Callout";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleLargeTitle"])
    {
        fontStyleString = @"Large Title";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleTitle1"])
    {
        fontStyleString = @"Title 1";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleTitle2"])
    {
        fontStyleString = @"Title 2";
    }
    else if ([fontStyleString isEqualToString:@"UIFontTextStyleTitle3"])
    {
        fontStyleString = @"Title 3";
    }
    else if ([fontStyleString isEqualToString:@"CTFontRegularUsage"])
    {
        fontStyleString = @"N/A";
    }
    return fontStyleString;
}
@end
