/*
 File: UBKAccessibilityImageViewTests.m
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

@interface UBKAccessibilityImageViewTests : XCTestCase

@end

@implementation UBKAccessibilityImageViewTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (UIImageView *)createNormalImageView
{
    UIImage *imageTmp = [[UIImage imageNamed:@"icon_accessibilitykit" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:imageTmp];
    imageView.accessibilityLabel = @"ImageView text";
    imageView.accessibilityHint = @"ImageView hint text";
    imageView.tintColor = [UIColor blackColor];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.frame = CGRectMake(0, 0, 100, 100);
    imageView.isAccessibilityElement = true;
    return imageView;
}

- (void)testImageViewValidation
{
    /*
     Test imageView colour contrast validation
     */
    UIImageView *imageViewOne = [self createNormalImageView];
    imageViewOne.tintColor = [UIColor lightTextColor];

    //Get the warnings section
    UBKAccessibilitySection *sectionOne = [[imageViewOne ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionOne getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_ColourContrast], @"ImageView colour contrast not failing");

    /*
     Test imageView accessibility hint validation
     */
    UIImageView *imageViewTwo = [self createNormalImageView];
    imageViewTwo.accessibilityHint = @"";
    
    //Get the warnings section
    UBKAccessibilitySection *sectionTwo = [[imageViewTwo ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionTwo getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Hint], @"ImageView accessibility hint not failing");

    
    /*
     Test imageView accessibility label validation
     */
    UIImageView *imageViewThree = [self createNormalImageView];
    imageViewThree.accessibilityLabel = @"";

    //Get the warnings section
    UBKAccessibilitySection *sectionThree = [[imageViewThree ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionThree getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Label], @"ImageView accessibility label not failing");


    /*
     Test imageView isAccessibility validation
     */
    UIImageView *imageViewFour = [self createNormalImageView];
    imageViewFour.userInteractionEnabled = true;
    imageViewFour.isAccessibilityElement = false;

    //Get the warnings section
    UBKAccessibilitySection *sectionFour = [[imageViewFour ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];

    //Test to make sure the correct warning is provided
    XCTAssertNotNil([sectionFour getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled], @"ImageView isAccessibility not failing");

    
    /*
     Test imageView colour contrast validation
     */
    UIImageView *imageViewFive = [self createNormalImageView];
    imageViewFive.tintColor = [UIColor ubk_colourFromHexString:@"646464"];
    imageViewFive.backgroundColor = [UIColor ubk_colourFromHexString:@"FFFFFF"];

    //Get the warnings section
    UBKAccessibilitySection *sectionFive = [[imageViewFive ubk_accessibilityDetails] ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Colours];
    UBKAccessibilityProperty *propertyFive = [sectionFive getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_W3CContrastRatio];
    
    //Test to make sure the correct warning is provided
    XCTAssertNotNil(propertyFive, @"ImageView colour contrast not failing");
    
    double contrastRatioFive = [UBKAccessibilityValidation getViewContrastRatio:propertyFive.displayColour backgroundColor:propertyFive.displayAlternateColour];
    XCTAssertEqualWithAccuracy(contrastRatioFive, 5.92, 0.01);
}

@end
