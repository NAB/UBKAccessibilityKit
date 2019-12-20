/*
 File: UBKAccessibilityButtonTests.m
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

@interface UBKAccessibilityButtonTests : XCTestCase

@end

@implementation UBKAccessibilityButtonTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UIButton *)createNormalButton
{
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:@"test" forState:UIControlStateNormal];
    button.accessibilityLabel = @"Button text";
    button.accessibilityHint = @"Button hint text";
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    button.frame = CGRectMake(0, 0, 100, 100);
    button.isAccessibilityElement = true;
    button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    button.titleLabel.adjustsFontForContentSizeCategory = true;
    return button;
}

- (void)testButtonValidation
{
    /*
     Test button colour contrast validation
     */
    UIButton *buttonOne = [self createNormalButton];
    [buttonOne setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];

    //Get the warnings section
    UBKAccessibilitySection *sectionOne = [[buttonOne ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionOne getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_ColourContrast], @"Button colour contrast not failing");

    
    /*
     Test button dynamic font size validation
     */
    UIButton *buttonTwo = [self createNormalButton];
    buttonTwo.titleLabel.adjustsFontForContentSizeCategory = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionTwo = [[buttonTwo ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionTwo getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_DynamicTextSize], @"Button dynamic font size not failing");


    /*
     Test button minimum size validation
     */
    UIButton *buttonThree = [self createNormalButton];
    buttonThree.frame = CGRectMake(0, 0, 30, 30);
    buttonThree.userInteractionEnabled = true;

    //Get the warnings section
    UBKAccessibilitySection *sectionThree = [[buttonThree ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionThree getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_MinimumSize], @"Button minimum size not failing");


    /*
     Test button accessibility hint validation
     */
    UIButton *buttonFour = [self createNormalButton];
    buttonFour.accessibilityHint = @"";
    
    //Get the warnings section
    UBKAccessibilitySection *sectionFour = [[buttonFour ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFour getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Hint], @"Button accessibility hint not failing");

    
    /*
     Test button accessibility label validation
     */
    UIButton *buttonFive = [self createNormalButton];
    buttonFive.accessibilityLabel = @"";

    //Get the warnings section
    UBKAccessibilitySection *sectionFive = [[buttonFive ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFive getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Label], @"Button accessibility label not failing");


    /*
     Test button isAccessibility validation
     */
    UIButton *buttonSix = [self createNormalButton];
    buttonSix.userInteractionEnabled = true;
    buttonSix.isAccessibilityElement = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionSix = [[buttonSix ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionSix getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled], @"Button isAccessibility not failing");

    
    /*
     Test button colour contrast validation
     */
    UIButton *buttonSeven = [self createNormalButton];
    [buttonSeven setTitleColor:[UIColor ubk_colourFromHexString:@"646464"] forState:UIControlStateNormal];
    buttonSeven.backgroundColor = [UIColor ubk_colourFromHexString:@"FFFFFF"];

    //Get the warnings section
    UBKAccessibilitySection *sectionSeven = [[buttonSeven ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Colours];
    UBKAccessibilityProperty *propertySeven = [sectionSeven getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_W3CContrastRatio];
    
    //Test to make sure the correct warning is provided
    XCTAssertNotNil(propertySeven, @"Button colour contrast not failing");
    
    double contrastRatioSeven = [UBKAccessibilityValidation getViewContrastRatio:propertySeven.displayColour backgroundColor:propertySeven.displayAlternateColour];
    XCTAssertEqualWithAccuracy(contrastRatioSeven, 5.92, 0.01);
}

@end
