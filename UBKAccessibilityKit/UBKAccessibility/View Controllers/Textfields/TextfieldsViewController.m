/*
 File: TextfieldsViewController.m
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

#import "TextfieldsViewController.h"

@interface TextfieldsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textfield1;
@property (weak, nonatomic) IBOutlet UITextField *textfield2;
@property (weak, nonatomic) IBOutlet UITextField *textfield3;
@property (weak, nonatomic) IBOutlet UITextField *textfield4;

@end

@implementation TextfieldsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textfield1.isAccessibilityElement = YES;

    self.textfield2.isAccessibilityElement = YES;
    self.textfield2.textColor = [UIColor lightGrayColor];
    self.textfield2.backgroundColor = [UIColor darkGrayColor];
    self.textfield2.text = @"Textfield Contrast Fail";
    self.textfield2.accessibilityLabel = @"textfield label";
    self.textfield2.accessibilityHint = @"textfield hint";

    self.textfield3.isAccessibilityElement = YES;
    self.textfield3.accessibilityLabel = @"textfield label";
    self.textfield3.accessibilityHint = @"textfield hint";
    self.textfield3.textColor = [UIColor redColor];
    self.textfield3.text = @"Contrast Fail";
    
    self.textfield4.isAccessibilityElement = YES;
    self.textfield4.accessibilityLabel = @"textfield label";
    self.textfield4.accessibilityHint = @"textfield hint";
}

@end
