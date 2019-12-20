/*
 File: UBKUIElementTableViewCell.m
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

#import "UBKUIElementTableViewCell.h"
#import "UIColor+HelperMethods.h"
#import "UIView+UBKAccessibility.h"
#import "UBKAccessibilityValidation.h"
#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityProperty.h"
#import "UBKAccessibilityConstants.h"

@interface UBKUIElementTableViewCell ()
@property (nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic) IBOutlet UILabel *cellForegroundTitleLabel;
@property (nonatomic) IBOutlet UIView *cellForegroundColourView;
@property (nonatomic) IBOutlet UILabel *cellBackgroundTitleLabel;
@property (nonatomic) IBOutlet UIView *cellBackgroundColourView;
@property (nonatomic) IBOutlet UIImageView *classImageView;
@property (nonatomic) IBOutlet UIImageView *chevronImageView;
@property (nonatomic) IBOutlet UIImageView *warningImageView;
@property (nonatomic) IBOutlet UIView *warningBackgroundView;
@property (nonatomic) IBOutlet UILabel *warningTitleLabel;
@property (nonatomic) BOOL showWarning;
@end

@implementation UBKUIElementTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code

    self.cellForegroundColourView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cellForegroundColourView.layer.borderWidth = 1;
    self.cellBackgroundColourView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cellBackgroundColourView.layer.borderWidth = 1;
    
    self.warningBackgroundView.layer.cornerRadius = 5;
    self.warningBackgroundView.clipsToBounds = true;
    
    self.classImageView.tintColor = [UIColor darkGrayColor];
    
    [self updateContentForTheme];
}

- (void)updateContentForTheme
{
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            self.cellTitleLabel.textColor = [UIColor whiteColor];
            self.cellForegroundTitleLabel.textColor = [UIColor whiteColor];
            self.cellBackgroundTitleLabel.textColor = [UIColor whiteColor];
            self.classImageView.tintColor = [UIColor whiteColor];
            self.chevronImageView.tintColor = [UIColor whiteColor];
        }
        else
        {
            self.cellTitleLabel.textColor = [UIColor darkTextColor];
            self.cellForegroundTitleLabel.textColor = [UIColor darkTextColor];
            self.cellBackgroundTitleLabel.textColor = [UIColor darkTextColor];
            self.classImageView.tintColor = [UIColor darkGrayColor];
            self.chevronImageView.tintColor = [UIColor darkGrayColor];
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self updateContentForTheme];
    self.outlineButton.accessibilityLabel = @"Outline";
    [self.outlineButton setTitle:@"Outline" forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setElementView:(UIView *)elementView
{
    _elementView = elementView;
    [self configureCellAppearance];
}

- (void)configureCellAppearance
{
    NSArray *itemsArray = self.elementView.ubk_accessibilityDetails;

    UBKAccessibilityProperty *backgroundProperty = nil;
    UBKAccessibilityProperty *foregroundProperty = nil;
    UBKAccessibilityProperty *fontSizeProperty = nil;
    self.showWarning = false;
    UBKAccessibilityWarningLevel highestWarning = UBKAccessibilityWarningLevelPass;

    for (UBKAccessibilitySection *section in itemsArray)
    {
        if (!backgroundProperty)
        {
            if ([section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_BackgroundColour])
            {
                backgroundProperty = [section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_BackgroundColour];
            }
        }
        
        if (!foregroundProperty)
        {
            if (([self.elementView isKindOfClass:[UIButton class]]) || ([self.elementView isKindOfClass:[UILabel class]]))
            {
                foregroundProperty = [section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_TextColour];
            }
            else if ([self.elementView isKindOfClass:[UIView class]])
            {
                foregroundProperty = [section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_TintColour];
            }
        }
        
        if (!fontSizeProperty)
        {
            if ([section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_FontSize])
            {
                fontSizeProperty = [section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_FontSize];
            }
        }
        
        if (section.sectionType == SectionDisplayTypeWarnings)
        {
            self.showWarning = true;
            highestWarning = [section getHighestWarningLevelInSection];
        }
    }
    
    self.cellTitleLabel.text = NSStringFromClass([self.elementView class]);
    
    self.cellForegroundColourView.backgroundColor = foregroundProperty.displayColour;
    self.cellBackgroundColourView.backgroundColor = backgroundProperty.displayColour;

    //Should show a warning for this ui element
    if (self.showWarning)
    {
        //Update the cell to show the heightest warning level

        if (highestWarning == UBKAccessibilityWarningLevelHigh)
        {
            [self configureCellForElement:kUBKAccessibilityWarningLevelImageNameHigh
                        withWarningColour:[UIColor ubk_warningLevelHighBackgroundColour]
                         withWarningTitle:@"High warnings"
                     withBackgroundColour:[UIColor ubk_colourFromHexString:@"F8EBBE"]];
        }
        else if (highestWarning == UBKAccessibilityWarningLevelMedium)
        {
            [self configureCellForElement:kUBKAccessibilityWarningLevelImageNameMedium
                        withWarningColour:[UIColor ubk_warningLevelMediumBackgroundColour]
                         withWarningTitle:@"Medium warnings"
                     withBackgroundColour:[UIColor ubk_colourFromHexString:@"F8EBBE"]];
        }
        else if (highestWarning == UBKAccessibilityWarningLevelLow)
        {
            [self configureCellForElement:kUBKAccessibilityWarningLevelImageNameLow
                        withWarningColour:[UIColor ubk_warningLevelLowBackgroundColour]
                         withWarningTitle:@"Low warnings"
                     withBackgroundColour:[UIColor ubk_colourFromHexString:@"F8EBBE"]];
        }
    }
    else
    {
        [self configureCellForElement:kUBKAccessibilityWarningLevelImageNamePass
                    withWarningColour:[UIColor ubk_warningLevelPassBackgroundColour]
                     withWarningTitle:@"Pass"
                 withBackgroundColour:[UIColor ubk_colourFromHexString:@"ECECEC"]];
    }
    
    //Displays the icon for the class, eg UIImageView, UIView, UIButton etc
    UIImage *classImage = [UIImage imageNamed:self.elementView.ubk_classIconName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    
    //If no image is returned for the class, use the defect unknown icon
    if (classImage == nil)
    {
        classImage = [UIImage imageNamed:@"icon_unknown" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    }
    self.classImageView.image = classImage;
}

- (void)configureCellForElement:(NSString *)imageName withWarningColour:(UIColor *)warningColour withWarningTitle:(NSString *)warningTitle withBackgroundColour:(UIColor *)backgroundColour
{
    UIImage *warningImage = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    self.warningImageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.warningImageView.tintColor = warningColour;
    
    //Update the warning title label
    self.warningTitleLabel.text = warningTitle;
    
    //Reset the warning background colour
    self.warningBackgroundView.backgroundColor = backgroundColour;
}

- (NSString *)accessibilityLabel
{
    if (self.showWarning)
    {
        return [NSString stringWithFormat:@"%@, %@", self.cellTitleLabel.accessibilityLabel, self.warningTitleLabel.accessibilityLabel];
    }
    else
    {
        return [NSString stringWithFormat:@"%@, no warnings", self.cellTitleLabel.accessibilityLabel];
    }
}

@end
