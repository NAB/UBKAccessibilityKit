/*
 File: UBKAccessibilityTitleValueTableViewCell.m
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

#import "UBKAccessibilityTitleValueTableViewCell.h"
#import "UBKAccessibilityProperty.h"
#import "UIColor+HelperMethods.h"

@interface UBKAccessibilityTitleValueTableViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellValueLabel;
@property (nonatomic, weak) IBOutlet UIImageView *warningIconImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *warningIconLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *warningIconWidthConstraint;
@end

@implementation UBKAccessibilityTitleValueTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIImage *warningImage = [UIImage imageNamed:@"icon_warning_red" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    self.warningIconImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.warningIconImageView.tintColor = [UIColor ubk_warningLevelHighBackgroundColour];
    
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            self.cellValueLabel.textColor = [UIColor lightTextColor];
        }
    }
}

- (void)setCellProperty:(UBKAccessibilityProperty *)cellProperty
{
    [super setCellProperty:cellProperty];
    
    self.cellTitleLabel.text = self.cellProperty.displayTitle;
    self.cellValueLabel.text = self.cellProperty.displayValue;
    self.showWarningIcon = self.cellProperty.displayWarning;
    self.accessoryType = self.cellProperty.cellAccessoryType;
}

- (void)setShowWarningIcon:(BOOL)showWarningIcon
{
    _showWarningIcon = showWarningIcon;
    
    if (self.showWarningIcon)
    {
        self.warningIconWidthConstraint.constant = 24;
        self.warningIconLeadingConstraint.constant = 20;
        self.warningIconImageView.hidden = false;
        
        switch (self.cellProperty.warningLevel)
        {
            case UBKAccessibilityWarningLevelHigh:
            {
                UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameHigh inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
                self.warningIconImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.warningIconImageView.tintColor = [UIColor ubk_warningLevelHighBackgroundColour];
                break;
            }
            case UBKAccessibilityWarningLevelMedium:
            {
                UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameMedium inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
                self.warningIconImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.warningIconImageView.tintColor = [UIColor ubk_warningLevelMediumBackgroundColour];
                break;
            }
            case UBKAccessibilityWarningLevelLow:
            {
                UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameLow inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
                self.warningIconImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.warningIconImageView.tintColor = [UIColor ubk_warningLevelLowBackgroundColour];
                break;
            }
            default:
            {
                [self hideWarningIcon];
                break;
            }
        }
    }
    else
    {
        [self hideWarningIcon];
    }
}

- (void)hideWarningIcon
{
    self.warningIconWidthConstraint.constant = 0;
    self.warningIconLeadingConstraint.constant = 10;
    self.warningIconImageView.hidden = true;
}

- (NSString *)accessibilityLabel
{
    NSString *warningLevel = @"";
    if (self.showWarningIcon)
    {
        switch (self.cellProperty.warningLevel)
        {
            case UBKAccessibilityWarningLevelHigh:
            {
                warningLevel = @"High warning, ";
                break;
            }
            case UBKAccessibilityWarningLevelMedium:
            {
                warningLevel = @"Medium warning, ";
                break;
            }
            case UBKAccessibilityWarningLevelLow:
            {
                warningLevel = @"Low warning, ";
                break;
            }
            default:
            {
                warningLevel = @"";
                break;
            }
        }
    }
    return [NSString stringWithFormat:@"%@%@, %@", warningLevel, self.cellTitleLabel.accessibilityLabel, self.cellValueLabel.accessibilityLabel];
}

@end
