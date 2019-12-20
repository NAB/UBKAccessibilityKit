/*
 File: UBKColourTableViewCell.m
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

#import "UBKColourTableViewCell.h"
#import "UBKAccessibilityProperty.h"
#import "UIColor+HelperMethods.h"

@interface UBKColourTableViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellRGBLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellHexLabel;
@property (nonatomic, weak) IBOutlet UIView *colourView;
@property (nonatomic, weak) IBOutlet UIImageView *warningImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *warningTrailingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *warningWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *cellRGBTrailingConstraint;
@end

@implementation UBKColourTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.colourView.layer.cornerRadius = 4;
    self.colourView.clipsToBounds = true;
    self.colourView.layer.borderWidth = 1;
    self.colourView.layer.borderColor = [UIColor grayColor].CGColor;
    
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            self.cellTitleLabel.textColor = [UIColor lightTextColor];
            self.cellRGBLabel.textColor = [UIColor lightTextColor];
            self.cellHexLabel.textColor = [UIColor lightTextColor];
        }
    }
}

- (void)setCellProperty:(UBKAccessibilityProperty *)cellProperty
{
    [super setCellProperty:cellProperty];
    
    self.cellTitleLabel.text = self.cellProperty.displayTitle;
    
    self.cellRGBLabel.text = self.cellProperty.displayColour.ubk_rgbStringFromColour;

    NSString *colourRGBString = self.cellProperty.displayColour.ubk_rgbStringFromColour;
    colourRGBString = [colourRGBString stringByReplacingOccurrencesOfString:@"R:" withString:@", Red "];
    colourRGBString = [colourRGBString stringByReplacingOccurrencesOfString:@"B:" withString:@", Blue "];
    colourRGBString = [colourRGBString stringByReplacingOccurrencesOfString:@"G:" withString:@", Green "];
    colourRGBString = [colourRGBString stringByReplacingOccurrencesOfString:@"A:" withString:@", Alpha "];
    self.cellRGBLabel.accessibilityLabel = colourRGBString;

    self.cellHexLabel.text = self.cellProperty.displayColour.ubk_hexStringFromColour;

    //VoiceOver will some times read hex colour value as a word instead of individual letters.
    //TODO: When support for Xcode 10 is dropped, add this back in. The const UIAccessibilitySpeechAttributeSpellOut is not available in pre Xcode 11.
//    if (@available(iOS 13.0, *))
//    {
//        NSString *hexAccessibilityString =  [NSString stringWithFormat:@"colour hex value, %@", [self.cellProperty.displayColour.ubk_hexStringFromColour stringByReplacingOccurrencesOfString:@"#" withString:@""]];
//        NSMutableAttributedString *accessibilityAttributes = [[NSMutableAttributedString alloc]initWithString:hexAccessibilityString];
//        [accessibilityAttributes addAttribute:UIAccessibilitySpeechAttributeSpellOut value:[NSNumber numberWithBool:true] range:NSMakeRange(hexAccessibilityString.length - [self.cellProperty.displayColour.ubk_hexStringFromColour stringByReplacingOccurrencesOfString:@"#" withString:@""].length, [self.cellProperty.displayColour.ubk_hexStringFromColour stringByReplacingOccurrencesOfString:@"#" withString:@""].length)];
//        self.cellHexLabel.accessibilityAttributedLabel = accessibilityAttributes;
//    }
//    else
//    {
        // Fallback on earlier versions
        NSString *hexString = [self.cellProperty.displayColour.ubk_hexStringFromColour stringByReplacingOccurrencesOfString:@"#" withString:@""];
        
        //Separate the hexString into an array.
        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[hexString length]];
        for (int i = 0; i<[hexString length]; i++)
        {
            NSString *ichar  = [NSString stringWithFormat:@"%c", [hexString characterAtIndex:i]];
            [characters addObject:ichar];
        }
        
        //Recreate the hexString by adding a space between each letter, this allows voice over to read out each character for backwards compatibility.
        NSString *hexAccessibilityString =  [NSString stringWithFormat:@"colour hex value, %@", [characters componentsJoinedByString:@" "]];
        self.cellHexLabel.accessibilityLabel = hexAccessibilityString;
//    }


    self.colourView.backgroundColor = self.cellProperty.displayColour;
    
    if (self.cellProperty.canUpdateUI)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.cellRGBTrailingConstraint.constant = 0;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.cellRGBTrailingConstraint.constant = 20;
    }
    
    if (([self.cellProperty displayWarning]) && (self.cellProperty.warningLevel != UBKAccessibilityWarningLevelPass))
    {
        [self showWarning];
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
        [self hideWarning];
    }
}

- (void)updateTrailingUIConstraints
{
    if (self.accessoryType == UITableViewCellAccessoryNone)
    {
        self.cellRGBTrailingConstraint.constant = 20;
    }
    else
    {
        self.cellRGBTrailingConstraint.constant = 0;
    }
}

- (void)showWarning
{
    self.warningImageView.hidden = false;
    self.warningWidthConstraint.constant = 24;
    self.warningTrailingConstraint.constant = 10;
}

- (void)hideWarning
{
    self.warningImageView.hidden = true;
    self.warningWidthConstraint.constant = 0;
    self.warningTrailingConstraint.constant = 0;
}

- (NSString *)accessibilityLabel
{
    return [NSString stringWithFormat:@"%@%@, %@, %@", self.warningImageView.hidden?@"":@"Warning, ", self.cellTitleLabel.accessibilityLabel, self.cellHexLabel.accessibilityLabel, self.cellRGBLabel.accessibilityLabel];
}

@end
