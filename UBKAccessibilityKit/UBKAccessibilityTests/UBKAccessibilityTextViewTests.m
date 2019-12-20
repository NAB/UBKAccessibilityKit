/*
 File: UBKAccessibilityTextViewTests.m
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

@interface UBKAccessibilityTextViewTests : XCTestCase

@end

@implementation UBKAccessibilityTextViewTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UITextView *)createNormalTextView
{
    UITextView *textView = [[UITextView alloc]init];
    textView.text = @"test";
    textView.accessibilityLabel = @"TextView text";
    textView.accessibilityHint = @"TextView hint text";
    textView.textColor = [UIColor blackColor];
    textView.backgroundColor = [UIColor whiteColor];
    textView.frame = CGRectMake(0, 0, 100, 100);
    textView.isAccessibilityElement = true;
    textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    textView.adjustsFontForContentSizeCategory = true;
    return textView;
}

- (void)testTextViewValidation
{
    /*
     Test textview colour contrast validation
     */
    UITextView *textviewOne = [self createNormalTextView];
    textviewOne.textColor = [UIColor lightTextColor];

    //Get the warnings section
    UBKAccessibilitySection *sectionOne = [[textviewOne ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionOne getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_ColourContrast], @"TextView colour contrast not failing");

    
    /*
     Test textview dynamic font size validation
     */
    UITextView *textviewTwo = [self createNormalTextView];
    textviewTwo.adjustsFontForContentSizeCategory = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionTwo = [[textviewTwo ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionTwo getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_DynamicTextSize], @"TextView dynamic font size not failing");


    /*
     Test textview minimum size validation
     */
    UITextView *textviewThree = [self createNormalTextView];
    textviewThree.frame = CGRectMake(0, 0, 30, 30);
    textviewThree.userInteractionEnabled = true;

    //Get the warnings section
    UBKAccessibilitySection *sectionThree = [[textviewThree ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionThree getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_MinimumSize], @"TextView minimum size not failing");


    /*
     Test textview accessibility hint validation
     */
    UITextView *textviewFour = [self createNormalTextView];
    textviewFour.accessibilityHint = @"";
    
    //Get the warnings section
    UBKAccessibilitySection *sectionFour = [[textviewFour ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFour getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Hint], @"TextView accessibility hint not failing");

    
    /*
     Test textview accessibility label validation
     */
    UITextView *textviewFive = [self createNormalTextView];
    textviewFive.accessibilityLabel = @"";

    //Get the warnings section
    UBKAccessibilitySection *sectionFive = [[textviewFive ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFive getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Label], @"TextView accessibility label not failing");


    /*
     Test textview isAccessibility validation
     */
    UITextView *textviewSix = [self createNormalTextView];
    textviewSix.userInteractionEnabled = true;
    textviewSix.isAccessibilityElement = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionSix = [[textviewSix ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionSix getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled], @"TextView isAccessibility not failing");

    
    /*
     Test textview colour contrast validation
     */
    UITextView *textviewSeven = [self createNormalTextView];
    textviewSeven.textColor = [UIColor ubk_colourFromHexString:@"646464"];
    textviewSeven.backgroundColor = [UIColor ubk_colourFromHexString:@"FFFFFF"];

    //Get the warnings section
    UBKAccessibilitySection *sectionSeven = [[textviewSeven ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Colours];
    UBKAccessibilityProperty *propertySeven = [sectionSeven getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_W3CContrastRatio];
    
    //Test to make sure the correct warning is provided
    XCTAssertNotNil(propertySeven, @"TextView colour contrast not failing");
    
    double contrastRatioSeven = [UBKAccessibilityValidation getViewContrastRatio:propertySeven.displayColour backgroundColor:propertySeven.displayAlternateColour];
    XCTAssertEqualWithAccuracy(contrastRatioSeven, 5.92, 0.01);
}

@end
