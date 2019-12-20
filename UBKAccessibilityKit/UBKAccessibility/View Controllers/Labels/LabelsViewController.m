/*
 File: LabelsViewController.m
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

#import "LabelsViewController.h"

@interface LabelsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell4;

@end

@implementation LabelsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cell1.textLabel.isAccessibilityElement = YES;
    self.cell1.textLabel.accessibilityTraits = UIAccessibilityTraitStaticText;

    self.cell2.textLabel.isAccessibilityElement = YES;
    self.cell2.textLabel.accessibilityTraits = UIAccessibilityTraitStaticText;

    self.cell3.textLabel.isAccessibilityElement = YES;
    self.cell3.textLabel.accessibilityTraits = UIAccessibilityTraitStaticText;

    self.cell4.textLabel.isAccessibilityElement = YES;
    self.cell4.textLabel.accessibilityTraits = UIAccessibilityTraitStaticText;

}

@end
