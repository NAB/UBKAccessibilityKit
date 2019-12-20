/*
 File: UBKAccessibilityColourTests.m
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

@interface UBKAccessibilityColourTests : XCTestCase

@end

@implementation UBKAccessibilityColourTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

//Test colour validation with known colours
- (void)testColourContrastValidation
{
    //Test the contrast between two colours
    double contrastRatioOne = [UBKAccessibilityValidation getViewContrastRatio:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    XCTAssertEqualWithAccuracy(contrastRatioOne, 21.00, 0.01);

    double contrastRatioTwo = [UBKAccessibilityValidation getViewContrastRatio:[UIColor whiteColor] backgroundColor:[UIColor blackColor]];
    XCTAssertEqualWithAccuracy(contrastRatioTwo, 21.00, 0.01);

    double contrastRatioThree = [UBKAccessibilityValidation getViewContrastRatio:[UIColor ubk_colourFromHexString:@"646464"] backgroundColor:[UIColor ubk_colourFromHexString:@"FFFFFF"]];
    XCTAssertEqualWithAccuracy(contrastRatioThree, 5.92, 0.01);

    double contrastRatioFour = [UBKAccessibilityValidation getViewContrastRatio:[UIColor ubk_colourFromHexString:@"aa86e5"] backgroundColor:[UIColor ubk_colourFromHexString:@"292a2f"]];
    XCTAssertEqualWithAccuracy(contrastRatioFour, 4.94, 0.01);
    
    double contrastRatioFive = [UBKAccessibilityValidation getViewContrastRatio:[UIColor ubk_colourFromHexString:@"ffffff"] backgroundColor:[UIColor ubk_colourFromHexString:@"d8d8d8"]];
    XCTAssertEqualWithAccuracy(contrastRatioFive, 1.43, 0.01);
}

@end
