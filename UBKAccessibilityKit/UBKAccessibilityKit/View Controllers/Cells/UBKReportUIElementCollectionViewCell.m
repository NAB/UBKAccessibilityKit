/*
 File: UBKReportUIElementCollectionViewCell.m
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

#import "UBKReportUIElementCollectionViewCell.h"
#import "UIView+UBKAccessibility.h"
#import "UBKAccessibilityConstants.h"
#import "UIView+HelperMethods.h"
#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityTitleValueTableViewCell.h"
#import "UIColor+HelperMethods.h"

@interface UBKReportUIElementCollectionViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UIView *numberView;
@property (nonatomic, weak) IBOutlet UILabel *classNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *elementImageView;
@property (nonatomic, weak) IBOutlet UIStackView *stackView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *widthConstraint;
@end

@implementation UBKReportUIElementCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.contentView.translatesAutoresizingMaskIntoConstraints = false;
    self.widthConstraint = [self.contentView.widthAnchor constraintEqualToConstant:0];
    
//    self.widthConstraint.constant = 0;
    self.elementImageView.layer.borderWidth = 1;
    self.elementImageView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)setCellWidth:(CGFloat)width
{
    self.widthConstraint.constant = width;
    self.widthConstraint.active = true;
}

- (CGFloat)getCellHeight:(CGFloat)width
{
    CGSize size = UILayoutFittingCompressedSize;
    size.width = width;
    CGFloat height = [self.contentView systemLayoutSizeFittingSize:size withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityDefaultLow].height;
    return height;
}

- (void)setElementView:(UIView *)elementView
{
    _elementView = elementView;
    [self configureAppearanceForView:elementView];
}

- (void)configureAppearanceForView:(UIView *)view
{
    NSArray *itemsArray = view.ubk_accessibilityDetails;
    for (UBKAccessibilitySection *section in itemsArray)
    {
        if (section.sectionType == SectionDisplayTypeWarnings)
        {
            for (UBKAccessibilityProperty *property in section.items)
            {
                UIView *tmpView = [[UIView alloc]init];
                tmpView.backgroundColor = [UIColor whiteColor];

                UIImageView *warningIcon = [[UIImageView alloc]init];
                switch (property.warningLevel)
                {
                    case UBKAccessibilityWarningLevelHigh:
                    {
                        UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameHigh inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
                        warningIcon.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        warningIcon.tintColor = [UIColor ubk_warningLevelHighBackgroundColour];
                        break;
                    }
                    case UBKAccessibilityWarningLevelMedium:
                    {
                        UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameMedium inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
                        warningIcon.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        warningIcon.tintColor = [UIColor ubk_warningLevelMediumBackgroundColour];
                        break;
                    }
                    case UBKAccessibilityWarningLevelLow:
                    {
                        UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameLow inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
                        warningIcon.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        warningIcon.tintColor = [UIColor ubk_warningLevelLowBackgroundColour];
                        break;
                    }
                    case UBKAccessibilityWarningLevelPass:
                    {
                        break;
                    }
                }
                warningIcon.translatesAutoresizingMaskIntoConstraints = false;
                [tmpView addSubview: warningIcon];
                [warningIcon.leftAnchor constraintEqualToAnchor:tmpView.leftAnchor constant:10].active = true;
                [warningIcon.heightAnchor constraintEqualToConstant:25].active = true;
                [warningIcon.widthAnchor constraintEqualToConstant:25].active = true;
                [warningIcon.centerYAnchor constraintEqualToAnchor:tmpView.centerYAnchor].active = true;
                
                UILabel *tmpLabel = [[UILabel alloc]init];
                tmpLabel.text = property.displayTitle;
                tmpLabel.numberOfLines = 0;
                tmpLabel.translatesAutoresizingMaskIntoConstraints = false;
                [tmpView addSubview:tmpLabel];
                [tmpLabel.leftAnchor constraintEqualToAnchor:warningIcon.rightAnchor constant:10].active = true;
                [tmpLabel.rightAnchor constraintEqualToAnchor:tmpView.rightAnchor].active = true;
                [tmpLabel.topAnchor constraintEqualToAnchor:tmpView.topAnchor constant:10].active = true;
                [tmpLabel.bottomAnchor constraintEqualToAnchor:tmpView.bottomAnchor constant:-10].active = true;
                
                [self.stackView addArrangedSubview:tmpView];
            }
        }
        else if (section.sectionType == SectionDisplayTypeComponentAttributes)
        {
            UBKAccessibilityProperty *className = [section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_ClassName];
            self.classNameLabel.text = className.displayValue;
        }
    }
    
    self.numberView.backgroundColor = self.numberColour;
    self.numberView.layer.cornerRadius = self.numberView.frame.size.width/2;
    self.numberView.clipsToBounds = true;
    self.numberLabel.text = [NSString stringWithFormat:@"%li", (long)self.index];
    //Need to check the colour of the numberView backgroundColor and update the colour of the numberLabel

    UIImage *image = [view ubk_createImage];
    self.elementImageView.image = image;
}

@end
