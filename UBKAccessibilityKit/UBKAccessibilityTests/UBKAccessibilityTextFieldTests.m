/*
 File: UBKAccessibilityTextFieldTests.m
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

@interface UBKAccessibilityTextFieldTests : XCTestCase

@end

@implementation UBKAccessibilityTextFieldTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UITextField *)createNormalTextField
{
    UITextField *textfield = [[UITextField alloc]init];
    textfield.text = @"test";
    textfield.accessibilityLabel = @"Textfield text";
    textfield.accessibilityHint = @"Textfield hint text";
    textfield.textColor = [UIColor blackColor];
    textfield.backgroundColor = [UIColor whiteColor];
    textfield.frame = CGRectMake(0, 0, 100, 100);
    textfield.isAccessibilityElement = true;
    textfield.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    textfield.adjustsFontForContentSizeCategory = true;
    return textfield;
}

- (void)testTextFieldValidation
{
    /*
     Test textfield colour contrast validation
     */
    UITextField *textfieldOne = [self createNormalTextField];
    textfieldOne.textColor = [UIColor lightTextColor];

    //Get the warnings section
    UBKAccessibilitySection *sectionOne = [[textfieldOne ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionOne getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_ColourContrast], @"Textfield colour contrast not failing");

    
    /*
     Test textfield dynamic font size validation
     */
    UITextField *textfieldTwo = [self createNormalTextField];
    textfieldTwo.adjustsFontForContentSizeCategory = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionTwo = [[textfieldTwo ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionTwo getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_DynamicTextSize], @"Textfield dynamic font size not failing");


    /*
     Test textfield minimum size validation
     */
    UITextField *textfieldThree = [self createNormalTextField];
    textfieldThree.frame = CGRectMake(0, 0, 30, 30);
    textfieldThree.userInteractionEnabled = true;

    //Get the warnings section
    UBKAccessibilitySection *sectionThree = [[textfieldThree ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionThree getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_MinimumSize], @"Textfield minimum size not failing");


    /*
     Test textfield accessibility hint validation
     */
    UITextField *textfieldFour = [self createNormalTextField];
    textfieldFour.accessibilityHint = @"";
    
    //Get the warnings section
    UBKAccessibilitySection *sectionFour = [[textfieldFour ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFour getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Hint], @"Textfield accessibility hint not failing");

    
    /*
     Test textfield accessibility label validation
     */
    UITextField *textfieldFive = [self createNormalTextField];
    textfieldFive.accessibilityLabel = @"";

    //Get the warnings section
    UBKAccessibilitySection *sectionFive = [[textfieldFive ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFive getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Label], @"Textfield accessibility label not failing");


    /*
     Test textfield isAccessibility validation
     */
    UITextField *textfieldSix = [self createNormalTextField];
    textfieldSix.userInteractionEnabled = true;
    textfieldSix.isAccessibilityElement = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionSix = [[textfieldSix ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionSix getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled], @"Textfield isAccessibility not failing");

    
    /*
     Test textfield colour contrast validation
     */
    UITextField *textfieldSeven = [self createNormalTextField];
    textfieldSeven.textColor = [UIColor ubk_colourFromHexString:@"646464"];
    textfieldSeven.backgroundColor = [UIColor ubk_colourFromHexString:@"FFFFFF"];

    //Get the warnings section
    UBKAccessibilitySection *sectionSeven = [[textfieldSeven ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Colours];
    UBKAccessibilityProperty *propertySeven = [sectionSeven getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_W3CContrastRatio];
    
    //Test to make sure the correct warning is provided
    XCTAssertNotNil(propertySeven, @"Textfield colour contrast not failing");
    
    double contrastRatioSeven = [UBKAccessibilityValidation getViewContrastRatio:propertySeven.displayColour backgroundColor:propertySeven.displayAlternateColour];
    XCTAssertEqualWithAccuracy(contrastRatioSeven, 5.92, 0.01);
}

@end
