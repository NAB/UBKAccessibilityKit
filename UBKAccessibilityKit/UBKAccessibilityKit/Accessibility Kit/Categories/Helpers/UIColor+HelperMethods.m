/*
 File: UIColor+HelperMethods.m
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

#import "UIColor+HelperMethods.h"

@implementation UIColor (HelperMethods)

- (NSString *)ubk_hexStringFromColour
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    size_t count = CGColorGetNumberOfComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = 0;
    CGFloat b = 0;
    
    if (r < 0)
    {
        r = 0;
    }
    if (count == 2)
    {
        g = components[0];
        b = components[0];
    }
    else
    {
        g = components[1];
        if (g < 0)
        {
            g = 0;
        }
        
        b = components[2];
        if (b < 0)
        {
            b = 0;
        }
    }
    NSString *hextString = [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255)];
    return hextString;
}

- (NSString *)ubk_rgbStringFromColour
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    size_t count = CGColorGetNumberOfComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    
    if (r < 0)
    {
        r = 0;
    }
    if (count == 2)
    {
        g = components[0];
        b = components[0];
    }
    else
    {
        g = components[1];
        if (g < 0)
        {
            g = 0;
        }
        
        b = components[2];
        if (b < 0)
        {
            b = 0;
        }
        a = components[3];
        if (a < 0)
        {
            a = 0;
        }
    }

    NSString *rgbString = [NSString stringWithFormat:@"R: %0.0f B: %0.0f \nG: %0.0f A: %0.0f", r * 255, b * 255, g * 255, a * 100];
    return rgbString;
}

- (double)ubk_contrastRatio:(UIColor *)other
{
    double lum1 = [self luminance];
    double lum2 = [other luminance];
    return (MAX(lum1, lum2) + 0.05) / (MIN(lum1, lum2) + 0.05);
}

- (double)luminance
{
    NSArray *rgb = [self rgbComponents];
    
    double r = [rgb[0] integerValue]/255.0;
    double g = [rgb[1] integerValue]/255.0;
    double b = [rgb[2] integerValue]/255.0;
    
    r = [self convertSrgbLuminance:r];
    g = [self convertSrgbLuminance:g];
    b = [self convertSrgbLuminance:b];
    
    return (r * 0.2126) + (g * 0.7152) + (b * 0.0722);
}

- (double)convertSrgbLuminance:(double)input
{
    if (input > 0.03928)
    {
        return pow((input+0.055)/1.055,2.4);
    }
    else
    {
        return input / 12.92;
    }
}

- (NSArray<NSNumber *> *)rgbComponents
{
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    NSInteger r = 0;
    NSInteger g = 0;
    NSInteger b = 0;
    
    if (colorSpace == kCGColorSpaceModelMonochrome)
    {
        r = components[0] * 255;
        g = components[0] * 255;
        b = components[0] * 255;
    }
    else if (colorSpace == kCGColorSpaceModelRGB)
    {
        r = components[0] * 255;
        g = components[1] * 255;
        b = components[2] * 255;
    }
    return @[@(r),@(g),@(b)];
}

- (UIColor *)ubk_lighterColour
{
    CGFloat h = 0;
    CGFloat s = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
    {
        return [UIColor colorWithHue:h saturation:s brightness:MIN(b * 1.3, 1.0) alpha:a];
    }
    return nil;
}

- (UIColor *)ubk_darkerColour
{
    CGFloat h = 0;
    CGFloat s = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
    {
        return [UIColor colorWithHue:h saturation:s brightness:b * 0.75 alpha:a];
    }
    return nil;
}

//Refactor this method, was performing better before.
+ (UIColor *)ubk_findBetterContrastColour:(UIColor *)forground backgroundColour:(UIColor *)background previousContrast:(double)previousContrast
{
    if ((!background) || (!forground))
    {
        return nil;
    }
    double contrast = [forground ubk_contrastRatio:background];
    if (contrast == 0)
    {
        return forground;
    }
    if (((contrast >= previousContrast) && (contrast >= 4.5)) || (contrast >= 21))
    {
        return forground;
    }
    
    UIColor *lighterColour = [forground ubk_lighterColour];
    double contrastTwo = [lighterColour ubk_contrastRatio:background];

    UIColor *darkerColour = [forground ubk_darkerColour];
    double contrastThree = [darkerColour ubk_contrastRatio:background];
    
    if (contrastTwo > previousContrast)
    {
        return [self ubk_findBetterContrastColour:lighterColour backgroundColour:background previousContrast:contrast];
    }
    else if (contrastThree > previousContrast)
    {
        return [self ubk_findBetterContrastColour:[forground ubk_darkerColour] backgroundColour:background previousContrast:contrast];
    }
    else
    {
        return nil;
    }
}

//Calulate Analagous colour
- (UIColor *)ubk_analagousColour:(CGFloat)value
{
    return [self withHueOffset:value/12];
}

- (UIColor *)withHueOffset:(CGFloat)offset
{
    CGFloat h = 0;
    CGFloat s = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
    {
        return [UIColor colorWithHue:fmod(h + offset, 1) saturation:s brightness:b alpha:a];
    }
    return nil;
}

+ (UIColor *)ubk_colourFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)ubk_warningLevelHighForegroundColour
{
    //Red
    return [UIColor colorWithRed:0.896 green:0.230 blue:0.097 alpha:1.000];
}

+ (UIColor *)ubk_warningLevelHighBackgroundColour
{
    //Red
    return [UIColor colorWithRed:0.896 green:0.230 blue:0.097 alpha:1.000];
}

+ (UIColor *)ubk_warningLevelMediumForegroundColour
{
    //Orange
    return [UIColor colorWithRed:0.910 green:0.471 blue:0.055 alpha:1.000]; //[UIColor colorWithRed:0.958 green:0.503 blue:0.141 alpha:1.000]; //[UIColor colorWithRed:0.981 green:0.538 blue:0.152 alpha:1.000];
}

+ (UIColor *)ubk_warningLevelMediumBackgroundColour
{
    //Orange
    return [UIColor colorWithRed:0.910 green:0.471 blue:0.055 alpha:1.000]; //[UIColor colorWithRed:0.958 green:0.503 blue:0.141 alpha:1.000]; //[UIColor colorWithRed:0.981 green:0.538 blue:0.152 alpha:1.000];
}

+ (UIColor *)ubk_warningLevelLowForegroundColour
{
    //Green
    return [UIColor colorWithRed:0.001 green:0.511 blue:0.155 alpha:1.000];
}

+ (UIColor *)ubk_warningLevelLowBackgroundColour
{
    //Green
    return [UIColor colorWithRed:0.001 green:0.511 blue:0.155 alpha:1.000];
}

+ (UIColor *)ubk_warningLevelPassBackgroundColour
{
    //Light Green
    return [UIColor ubk_colourFromHexString:@"0FA115"];
}

@end
