/*
 File: UBKAccessibilityFilterTableViewController.m
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

#import "UBKAccessibilityFilterTableViewController.h"
#import "UBKAccessibilityManager.h"
#import "UBKAccessibilityFilter.h"
#import "UIColor+HelperMethods.h"

typedef enum : NSUInteger {
    FilterSectionWarningLevels,
    FilterSectionWarningTypes,
    FilterSectionObjects
} FilterSection;

@interface UBKAccessibilityFilterTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation UBKAccessibilityFilterTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Filter";    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UBKAccessibilityManager sharedInstance]removeAllOutlines];
    [[UBKAccessibilityManager sharedInstance]configureAllUIElments];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Force focus to the back button
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.parentViewController);
}

- (IBAction)resetFilter:(id)sender
{
    [[UBKAccessibilityManager sharedInstance].accessibilityFilter resetFilter];
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Note this has been changed from 3 to 2. The filtering of object classes is not fully implemented yet. Best to hide until its ready.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case FilterSectionWarningLevels:
        {
            return UBKAccessibilityWarningLevelPass + 1;
            break;
        }
        case FilterSectionWarningTypes:
        {
            return [[UBKAccessibilityManager sharedInstance].accessibilityFilter.warningTypesAvailable count];
            break;
        }
        case FilterSectionObjects:
        {
            return UBKAccessibilityObjectClassUIView + 1;
        }
        default:
        {
            return 0;
            break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"]; //[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == FilterSectionWarningLevels)
    {
        UBKAccessibilityWarningLevel warningLevel = indexPath.row;
        cell.textLabel.text = [UBKAccessibilityFilter warningNameForWarningLevel:warningLevel];
        if ([[UBKAccessibilityManager sharedInstance].accessibilityFilter.warningLevels containsObject:@(warningLevel)])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        if (warningLevel == UBKAccessibilityWarningLevelHigh)
        {
            UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameHigh inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
            cell.imageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.tintColor = [UIColor ubk_warningLevelHighBackgroundColour];
        }
        else if (warningLevel == UBKAccessibilityWarningLevelMedium)
        {
            UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameMedium inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
            cell.imageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.tintColor = [UIColor ubk_warningLevelMediumBackgroundColour];
        }
        else if (warningLevel == UBKAccessibilityWarningLevelLow)
        {
            UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNameLow inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
            cell.imageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.tintColor = [UIColor ubk_warningLevelLowBackgroundColour];
        }
        else
        {
            UIImage *warningImage = [UIImage imageNamed:kUBKAccessibilityWarningLevelImageNamePass inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
            cell.imageView.image = [warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.tintColor = [UIColor ubk_warningLevelPassBackgroundColour];
        }
    }
    else if (indexPath.section == FilterSectionWarningTypes)
    {
        UBKAccessibilityWarningType warningType = [[[UBKAccessibilityManager sharedInstance].accessibilityFilter.warningTypesAvailable objectAtIndex:indexPath.row] integerValue];
        cell.textLabel.text = [UBKAccessibilityFilter warningNameForWarningType:warningType];
        if ([[UBKAccessibilityManager sharedInstance].accessibilityFilter.warningTypesSelected containsObject:@(warningType)])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.section == FilterSectionObjects)
    {
        UBKAccessibilityObjectClass className = indexPath.row;
        cell.textLabel.text = [UBKAccessibilityFilter objectClassNameForObjectClassNames:className];
        if ([[UBKAccessibilityManager sharedInstance].accessibilityFilter.objectClassNames containsObject:@(className)])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else
    {
        cell.textLabel.text = @"UNKNOWN";
    }
    
    if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
        cell.accessibilityLabel = [NSString stringWithFormat:@"Not selected, %@", cell.textLabel.text];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [NSString stringWithFormat:@"Warning levels (%lu selected)", (unsigned long)[[UBKAccessibilityManager sharedInstance].accessibilityFilter.warningLevels count]];
    }
    else if (section == 1)
    {
        return [NSString stringWithFormat:@"Warning types (%lu selected)", (unsigned long)[[UBKAccessibilityManager sharedInstance].accessibilityFilter.warningTypesSelected count]];
    }
    return [NSString stringWithFormat:@"Object classes (%lu selected)", (unsigned long)[[UBKAccessibilityManager sharedInstance].accessibilityFilter.objectClassNames count]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == FilterSectionWarningLevels)
    {
        UBKAccessibilityWarningLevel warningLevel = indexPath.row;
        [[UBKAccessibilityManager sharedInstance].accessibilityFilter toggleWarningLevelToWarningLevels:warningLevel];
        [[UBKAccessibilityManager sharedInstance].accessibilityFilter configureWarningTypesForWarningLevels];
    }
    else if (indexPath.section == FilterSectionWarningTypes)
    {
        UBKAccessibilityWarningType warningType = [[[UBKAccessibilityManager sharedInstance].accessibilityFilter.warningTypesAvailable objectAtIndex:indexPath.row] integerValue];
        [[UBKAccessibilityManager sharedInstance].accessibilityFilter toggleSelectedWarningType:warningType];
    }
    else if (indexPath.section == FilterSectionObjects)
    {
        UBKAccessibilityObjectClass objectClassName = indexPath.row;
        [[UBKAccessibilityManager sharedInstance].accessibilityFilter toggleObjectClassToObjectClassNames:objectClassName];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView reloadData];
    }];
}


@end
