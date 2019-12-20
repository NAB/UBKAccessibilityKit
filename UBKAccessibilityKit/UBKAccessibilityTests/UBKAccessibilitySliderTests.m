/*
 File: UBKAccessibilitySliderTests.m
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

@interface UBKAccessibilitySliderTests : XCTestCase

@end

@implementation UBKAccessibilitySliderTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UISlider *)createNormalSlider
{
    UISlider *slider = [[UISlider alloc]init];
    slider.accessibilityLabel = @"Slider text";
    slider.accessibilityHint = @"Slider hint text";
    slider.accessibilityValue = @"Slider value";
    slider.backgroundColor = [UIColor whiteColor];
    slider.value = 0.1;
    slider.frame = CGRectMake(0, 0, 100, 100);
    slider.isAccessibilityElement = true;
    return slider;
}

- (void)testSliderValidation
{
    /*
     Test slider minimum size validation
     */
    UISlider *sliderOne = [self createNormalSlider];
    sliderOne.frame = CGRectMake(0, 0, 30, 30);
    sliderOne.userInteractionEnabled = true;

    //Get the warnings section
    UBKAccessibilitySection *sectionOne = [[sliderOne ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionOne getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_MinimumSize], @"Slider minimum size not failing");

    
    /*
     Test slider accessibility hint validation
     */
    UISlider *sliderTwo = [self createNormalSlider];
    sliderTwo.accessibilityHint = @"";
    
    //Get the warnings section
    UBKAccessibilitySection *sectionTwo = [[sliderTwo ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionTwo getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Hint], @"Slider accessibility hint not failing");

    
    /*
     Test slider accessibility label validation
     */
    UISlider *sliderThree = [self createNormalSlider];
    sliderThree.accessibilityLabel = @"";

    //Get the warnings section
    UBKAccessibilitySection *sectionThree = [[sliderThree ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionThree getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Label], @"Slider accessibility label not failing");


    /*
     Test slider isAccessibility validation
     */
    UISlider *sliderFour = [self createNormalSlider];
    sliderFour.userInteractionEnabled = true;
    sliderFour.isAccessibilityElement = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionFour = [[sliderFour ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFour getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled], @"Slider isAccessibility not failing");
}

@end
