/*
 File: SwitchesViewController.m
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

#import "SwitchesViewController.h"

@interface SwitchesViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switch1;
@property (weak, nonatomic) IBOutlet UISwitch *switch2;
@property (weak, nonatomic) IBOutlet UISwitch *switch3;

@end

@implementation SwitchesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.switch1.isAccessibilityElement = YES;
    self.switch2.isAccessibilityElement = YES;
    
    self.switch2.onTintColor = [UIColor lightGrayColor];
    self.switch2.backgroundColor = [UIColor darkGrayColor];
    self.switch2.accessibilityLabel = @"Textfield Contrast Fail";
    
    self.switch3.isAccessibilityElement = YES;
    self.switch3.accessibilityValue = @"0";
    self.switch3.accessibilityLabel = @"switch label";
    self.switch3.accessibilityHint = @"hint label";
    self.switch3.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitAdjustable;
}

@end
