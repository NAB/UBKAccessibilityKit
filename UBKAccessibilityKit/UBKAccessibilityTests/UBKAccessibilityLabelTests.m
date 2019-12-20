/*
 File: UBKAccessibilityLabelTests.m
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

#import <XCTest/XCTest.h>

#import <UBKAccessibilityKit/UBKAccessibilityKit.h>

@interface UBKAccessibilityLabelTests : XCTestCase

@end

@implementation UBKAccessibilityLabelTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UILabel *)createNormalLabel
{
    UILabel *label = [[UILabel alloc]init];
    label.text = @"test";
    label.accessibilityLabel = @"Label text";
    label.accessibilityHint = @"Label hint text";
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    label.frame = CGRectMake(0, 0, 100, 100);
    label.isAccessibilityElement = true;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    label.adjustsFontForContentSizeCategory = true;
    return label;
}

- (void)testLabelValidation
{
    /*
     Test label colour contrast validation
     */
    UILabel *labelOne = [self createNormalLabel];
    labelOne.textColor = [UIColor lightTextColor];

    //Get the warnings section
    UBKAccessibilitySection *sectionOne = [[labelOne ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionOne getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_ColourContrast], @"Label colour contrast not failing");

    
    /*
     Test label dynamic font size validation
     */
    UILabel *labelTwo = [self createNormalLabel];
    labelTwo.adjustsFontForContentSizeCategory = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionTwo = [[labelTwo ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionTwo getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_DynamicTextSize], @"Label dynamic font size not failing");


    /*
     Test label minimum size validation
     */
    UILabel *labelThree = [self createNormalLabel];
    labelThree.frame = CGRectMake(0, 0, 30, 30);
    labelThree.userInteractionEnabled = true;

    //Get the warnings section
    UBKAccessibilitySection *sectionThree = [[labelThree ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionThree getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_MinimumSize], @"Label minimum size not failing");


    /*
     Test label accessibility hint validation
     */
    UILabel *labelFour = [self createNormalLabel];
    labelFour.accessibilityHint = @"";
    
    //Get the warnings section
    UBKAccessibilitySection *sectionFour = [[labelFour ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFour getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Hint], @"Label accessibility hint not failing");

    
    /*
     Test label accessibility label validation
     */
    UILabel *labelFive = [self createNormalLabel];
    labelFive.accessibilityLabel = @"";

    //Get the warnings section
    UBKAccessibilitySection *sectionFive = [[labelFive ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFive getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Label], @"Label accessibility label not failing");


    /*
     Test label isAccessibility validation
     */
    UILabel *labelSix = [self createNormalLabel];
    labelSix.userInteractionEnabled = true;
    labelSix.isAccessibilityElement = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionSix = [[labelSix ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionSix getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled], @"Label isAccessibility not failing");

    
    /*
     Test label colour contrast validation
     */
    UILabel *labelSeven = [self createNormalLabel];
    labelSeven.textColor = [UIColor ubk_colourFromHexString:@"646464"];
    labelSeven.backgroundColor = [UIColor ubk_colourFromHexString:@"FFFFFF"];

    //Get the warnings section
    UBKAccessibilitySection *sectionSeven = [[labelSeven ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Colours];
    UBKAccessibilityProperty *propertySeven = [sectionSeven getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_W3CContrastRatio];
    
    //Test to make sure the correct warning is provided
    XCTAssertNotNil(propertySeven, @"Label colour contrast not failing");
    
    double contrastRatioSeven = [UBKAccessibilityValidation getViewContrastRatio:propertySeven.displayColour backgroundColor:propertySeven.displayAlternateColour];
    XCTAssertEqualWithAccuracy(contrastRatioSeven, 5.92, 0.01);
}

@end
