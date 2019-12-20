/*
 File: UBKAccessibilityButton.m
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

#import "UBKAccessibilityButton.h"
#import "UIColor+HelperMethods.h"
#import "UBKBadgeLayer.h"

@interface UBKAccessibilityButton () <CAAnimationDelegate>
@property (nonatomic) UIImageView *accessibilityImageView;
@property (nonatomic) UBKBadgeLayer *badgeLayer;
@end

@implementation UBKAccessibilityButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setTitle:@"" forState:UIControlStateNormal];
                
        self.adjustsImageWhenHighlighted = FALSE;
        self.layer.cornerRadius = 50/2;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0;
        [self.layer setShadowOffset:CGSizeMake(0, 0)];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        [self.layer setShadowOpacity:0.5];
        [self.layer setShadowRadius:4.0];
        self.layer.zPosition = 1000;
        
        //Configure the image for the inspector button. Get the accessibility icon for the button from the correct bundle.
        UIImage *imageTmp = [[UIImage imageNamed:@"icon_accessibilitykit" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.accessibilityImageView = [[UIImageView alloc]initWithImage:imageTmp];
        [self.accessibilityImageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.accessibilityImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.accessibilityImageView.tintColor = [UIColor colorWithRed:0.000 green:0.639 blue:0.867 alpha:1.000];
        self.accessibilityImageView.clipsToBounds = false;
        self.accessibilityImageView.hidden = false;
        [self addSubview:self.accessibilityImageView];
        
        self.accessibilityTraits |= UIAccessibilityTraitButton;
    }
    return self;
}

- (void)showWarningBadgeWithWarning:(UBKAccessibilityWarningLevel)warning
{
    CGFloat width = 25;
    CGFloat height = 25;

    if (!self.badgeLayer)
    {
        self.badgeLayer = [[UBKBadgeLayer alloc]init];
    }
    
    self.badgeLayer.frame =  CGRectMake(30, -5, width, height);
    [self.accessibilityImageView.layer addSublayer:self.badgeLayer];
    
    if (warning == UBKAccessibilityWarningLevelHigh)
    {
        [self.badgeLayer configureWarningTextLayerAppearance];
    }
    else
    {
        [self.badgeLayer configureUnknownWarningTextLayerAppearance];
    }
    [self.badgeLayer showBadgeAnimation];
}

- (void)hideWarningBadge
{
    if (self.badgeLayer != nil)
    {
        [self.badgeLayer hideBadgeAnimation];
    }
}

- (NSString *)accessibilityLabel
{
    return @"Inspector";
}

- (NSString *)accessibilityValue
{
    return [NSString stringWithFormat:@"%@", self.alpha == 1 ? @"Enabled" : @"Disabled"];
}

@end
