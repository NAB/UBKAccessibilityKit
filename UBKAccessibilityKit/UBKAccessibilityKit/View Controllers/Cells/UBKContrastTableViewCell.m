/*
 File: UBKContrastTableViewCell.m
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

#import "UBKContrastTableViewCell.h"
#import "UBKAccessibilityProperty.h"
#import "UIColor+HelperMethods.h"

@interface UBKContrastTableViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellForegroundColourLabel;
@property (nonatomic, weak) IBOutlet UIView *cellBackgroundColourView;
@property (nonatomic, weak) IBOutlet UILabel *cellContrastValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellForegroundHexColourLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellBackgroundHexColourLabel;
@property (nonatomic, weak) IBOutlet UIImageView *warningImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *warningImageViewTrailingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *warningImageViewWidthConstraint;
@end

@implementation UBKContrastTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.cellBackgroundColourView.layer.cornerRadius = 4;
    self.cellBackgroundColourView.clipsToBounds = true;
    self.cellBackgroundColourView.layer.borderWidth = 1;
    self.cellBackgroundColourView.layer.borderColor = [UIColor grayColor].CGColor;
    
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            self.cellTitleLabel.textColor = [UIColor lightTextColor];
            self.cellForegroundColourLabel.textColor = [UIColor lightTextColor];
            self.cellContrastValueLabel.textColor = [UIColor lightTextColor];
            self.cellForegroundHexColourLabel.textColor = [UIColor lightTextColor];
            self.cellBackgroundHexColourLabel.textColor = [UIColor lightTextColor];
        }
    }
}

- (void)setCellProperty:(UBKAccessibilityProperty *)cellProperty
{
    [super setCellProperty:cellProperty];

    //Set cell title
    self.cellTitleLabel.text = self.cellProperty.displayTitle;
    
    //Set colours on cell
    self.cellForegroundColourLabel.textColor = self.cellProperty.displayColour;
    self.cellBackgroundColourView.backgroundColor = self.cellProperty.displayAlternateColour;

    //Foreground title
    self.cellForegroundColourLabel.text = self.cellProperty.displayAlternateTitle;
    
    //Configure the values for contrast
    self.cellContrastValueLabel.attributedText = [self configureAttributedStringContrastValue:self.cellProperty.displayValue withRating:self.cellProperty.displayContrastScore];
    self.cellContrastValueLabel.accessibilityLabel = [NSString stringWithFormat:@"Contrast ratio, %@, rating, %@", self.cellProperty.displayValue, self.cellProperty.displayContrastScore];
    
    self.cellForegroundHexColourLabel.text = [self.cellProperty.displayColour ubk_hexStringFromColour];
    self.cellForegroundHexColourLabel.isAccessibilityElement = false;

    self.cellBackgroundHexColourLabel.text = [self.cellProperty.displayAlternateColour ubk_hexStringFromColour];
    self.cellBackgroundHexColourLabel.isAccessibilityElement = false;
    
    //Hide or show the warning icon
    if (([self.cellProperty displayWarning]) && (self.cellProperty.warningLevel != UBKAccessibilityWarningLevelPass))
    {
        //Configure warning icon
        self.warningImageView.hidden = false;
        self.warningImageViewWidthConstraint.constant = 24;
        self.warningImageViewTrailingConstraint.constant = 10;
        
        if (self.cellProperty.warningLevel == UBKAccessibilityWarningLevelHigh)
        {
            UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameHigh inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
            self.warningImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.warningImageView.tintColor = [UIColor ubk_warningLevelHighBackgroundColour];
        }
        else if (self.cellProperty.warningLevel == UBKAccessibilityWarningLevelMedium)
        {
            UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameMedium inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
            self.warningImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.warningImageView.tintColor = [UIColor ubk_warningLevelMediumBackgroundColour];
        }
        else //Low warnings
        {
            UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameLow inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
            self.warningImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.warningImageView.tintColor = [UIColor ubk_warningLevelLowBackgroundColour];
        }
    }
    else
    {
        self.warningImageView.hidden = true;
        self.warningImageViewWidthConstraint.constant = 0;
        self.warningImageViewTrailingConstraint.constant = 0;
    }
}

- (NSAttributedString*)configureAttributedStringContrastValue:(NSString *)contrast withRating:(NSString *)rating
{
    if (contrast == nil)
    {
        contrast = @"";
    }
    if (rating == nil)
    {
        rating = @"";
    }
    if (contrast.length > 0 && rating.length > 0)
    {
        rating = [NSString stringWithFormat:@"\n%@", rating];
    }
    
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@", contrast, rating]];
    
    // Declare the fonts
    UIFont *myStringFont1 = [UIFont fontWithName:@"Helvetica" size:26.0];
    UIFont *myStringFont2 = [UIFont fontWithName:@"Helvetica" size:16.0];
    
    // Declare the paragraph styles
    NSMutableParagraphStyle *myStringParaStyle1 = [[NSMutableParagraphStyle alloc]init];
    myStringParaStyle1.alignment = NSTextAlignmentRight;
    
    // Create the attributes and add them to the string
    [myString addAttribute:NSFontAttributeName value:myStringFont1 range:NSMakeRange(0, contrast.length)];
    [myString addAttribute:NSFontAttributeName value:myStringFont2 range:NSMakeRange(contrast.length, rating.length)];
    [myString addAttribute:NSParagraphStyleAttributeName value:myStringParaStyle1 range:NSMakeRange(0, contrast.length + rating.length)];

    return [[NSAttributedString alloc]initWithAttributedString:myString];
}

- (NSString *)accessibilityLabel
{
    return [NSString stringWithFormat:@"%@, %@, %@", self.cellTitleLabel.accessibilityLabel, self.cellForegroundColourLabel.accessibilityLabel, self.cellContrastValueLabel.accessibilityLabel];
}

@end
