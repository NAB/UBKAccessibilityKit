/*
 File: UBKAccessibilitySettingsViewController.m
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

#import "UBKAccessibilitySettingsViewController.h"
#import "UBKAccessibilityManager.h"

typedef enum : NSUInteger {
    UBKAccessibilitySettingsSectionGlobalAccessibilitySettings,
    UBKAccessibilitySettingsSectionVisual
} UBKAccessibilitySettingsSection;

typedef enum : NSUInteger {
    UBKAccessibilitySettingsVisualShowTouches,
} UBKAccessibilitySettings;

@interface UBKAccessibilitySettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation UBKAccessibilitySettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Force focus to the back button
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.parentViewController);
}

- (void)toggleShowTouches:(UISwitch *)toggleSwitch
{
    [UBKAccessibilityManager sharedInstance].isShowingTouchAnimations = toggleSwitch.isOn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return UBKAccessibilitySettingsSectionVisual + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == UBKAccessibilitySettingsSectionGlobalAccessibilitySettings)
    {
        return 5;
    }
    else if (section == UBKAccessibilitySettingsSectionVisual)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == UBKAccessibilitySettingsSectionGlobalAccessibilitySettings)
    {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Settings"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UBKAccessibilitySettingsGlobalSettings settingId = indexPath.row;
        switch (settingId)
        {
            case UBKAccessibilitySettingsGlobalSettingsBoldTextEnabled:
            {
                cell.textLabel.text = kUBKAccessibilityAttributeTitle_BoldTextEnabled;
                cell.detailTextLabel.text = UIAccessibilityIsBoldTextEnabled()?@"Yes":@"No";
                break;
            }
            case UBKAccessibilitySettingsGlobalSettingsFontSizeCategory:
            {
                NSString *preferredContentSizeCategory = [UIScreen mainScreen].traitCollection.preferredContentSizeCategory;
                cell.textLabel.text = kUBKAccessibilityAttributeTitle_GlobalFontSize;
                cell.detailTextLabel.text = preferredContentSizeCategory;
                break;
            }
            case UBKAccessibilitySettingsGlobalSettingsDarkColoursEnabled:
            {
                cell.textLabel.text = kUBKAccessibilityAttributeTitle_DarkerColoursEnabled;
                cell.detailTextLabel.text = UIAccessibilityIsInvertColorsEnabled()?@"Yes":@"No";
                break;
            }
            case UBKAccessibilitySettingsGlobalSettingsReducedTransparency:
            {
                cell.textLabel.text = kUBKAccessibilityAttributeTitle_ReducedTransparencyEnabled;
                cell.detailTextLabel.text = UIAccessibilityIsReduceTransparencyEnabled()?@"Yes":@"No";
                break;
            }
            case UBKAccessibilitySettingsGlobalSettingsReducedMotionEnabled:
            {
                cell.textLabel.text = kUBKAccessibilityAttributeTitle_ReducedMotionEnabled;
                cell.detailTextLabel.text = UIAccessibilityIsReduceMotionEnabled()?@"Yes":@"No";
                break;
            }
        }
        return cell;
    }
    else if (indexPath.section == UBKAccessibilitySettingsSectionVisual)
    {
        cell.textLabel.text = @"Show touches on screen";
        UISwitch *touchesSwitch = [[UISwitch alloc]init];
        [touchesSwitch removeTarget:self action:@selector(toggleShowTouches:) forControlEvents:UIControlEventValueChanged];
        [touchesSwitch addTarget:self action:@selector(toggleShowTouches:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = touchesSwitch;
        [touchesSwitch setOn:[UBKAccessibilityManager sharedInstance].isShowingTouchAnimations];
    }
    else
    {
        cell.textLabel.text = @"UNKNOWN";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == UBKAccessibilitySettingsSectionVisual)
    {
        if (indexPath.row == UBKAccessibilitySettingsVisualShowTouches)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UISwitch *toggleSwitch = (UISwitch *)cell.accessoryView;
            [toggleSwitch setOn:!toggleSwitch.isOn animated:true];
            [self toggleShowTouches:toggleSwitch];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    UBKAccessibilitySettingsSection sectionId = section;
    switch (sectionId)
    {
        case UBKAccessibilitySettingsSectionGlobalAccessibilitySettings:
        {
            return @"Global Accessibility Settings";
            break;
        }
        case UBKAccessibilitySettingsSectionVisual:
        {
            return @"Visual";
            break;
        }
            default:
        {
            return @"";
            break;
        }
    }
}

@end
