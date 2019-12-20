/*
 File: UBKAccessibilitySwitchTests.m
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

@interface UBKAccessibilitySwitchTests : XCTestCase

@end

@implementation UBKAccessibilitySwitchTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UISwitch *)createNormalSwitch
{
    UISwitch *switchObject = [[UISwitch alloc]init];
    [switchObject setOn:true];
    switchObject.accessibilityLabel = @"Switch text";
    switchObject.accessibilityHint = @"Switch hint text";
    switchObject.accessibilityValue = @"Switched on";
    switchObject.tintColor = [UIColor blackColor];
    switchObject.backgroundColor = [UIColor whiteColor];
    switchObject.frame = CGRectMake(0, 0, 100, 100);
    switchObject.isAccessibilityElement = true;
    return switchObject;
}

- (void)testSwitchValidation
{
    /*
     Test switch minimum size validation
     */
    UISwitch *switchOne = [self createNormalSwitch];
    switchOne.frame = CGRectMake(0, 0, 30, 30);
    switchOne.userInteractionEnabled = true;

    //Get the warnings section
    UBKAccessibilitySection *sectionOne = [[switchOne ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionOne getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_MinimumSize], @"Switch minimum size not failing");


    /*
     Test switch accessibility hint validation
     */
    UISwitch *switchTwo = [self createNormalSwitch];
    switchTwo.accessibilityHint = @"";
    
    //Get the warnings section
    UBKAccessibilitySection *sectionTwo = [[switchTwo ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionTwo getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Hint], @"Switch accessibility hint not failing");

    
    /*
     Test switch accessibility label validation
     */
    UISwitch *switchThree = [self createNormalSwitch];
    switchThree.accessibilityLabel = @"";

    //Get the warnings section
    UBKAccessibilitySection *sectionThree = [[switchThree ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionThree getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Label], @"Switch accessibility label not failing");


    /*
     Test switch isAccessibility validation
     */
    UISwitch *switchFour = [self createNormalSwitch];
    switchFour.userInteractionEnabled = true;
    switchFour.isAccessibilityElement = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionFour = [[switchFour ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFour getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled], @"Switch isAccessibility not failing");
}

@end
