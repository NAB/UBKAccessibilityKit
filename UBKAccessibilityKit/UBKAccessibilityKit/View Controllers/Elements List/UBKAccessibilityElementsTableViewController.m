/*
 File: UBKAccessibilityElementsTableViewController.m
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

#import "UBKAccessibilityElementsTableViewController.h"
#import "UBKNavigationController.h"
#import "UBKAccessibilityManager.h"
#import "UIView+UBKAccessibility.h"
#import "UBKUIElementTableViewCell.h"
#import "UBKAccessibilityButton.h"
#import "UBKAccessibilitySection.h"
#import "UIColor+HelperMethods.h"
#import "UBKAccessibilityVisibleWarningView.h"
#import "UBKAccessibilityFilterTableViewController.h"
#import "UBKAccessibilityFilter.h"
#import "UBKAccessibilityHighlightAction.h"
#import "UBKAccessibilitySettingsViewController.h"
#import "NSArray+HelperMethods.h"
#import "UIView+HelperMethods.h"

@interface UBKAccessibilityElementsTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isFilteringWarnings;
@property (nonatomic) NSMutableArray *filteredList;
@property (nonatomic) NSIndexPath *selectedUIElementIndex;
@property (nonatomic) UIBarButtonItem *warningButton;
@property (nonatomic) UIBarButtonItem *filterButton;
@property (nonatomic) UIBarButtonItem *settingsButton;
@property (nonatomic) IBOutlet UIBarButtonItem *highlightButton;
@property (nonatomic) IBOutlet UILabel *noResultsLabel;
@property (nonatomic, weak) UIButton *previousSelectedButton;
@end

@implementation UBKAccessibilityElementsTableViewController

- (void)setElementsArray:(NSArray *)elementsArray
{
    _elementsArray = elementsArray;
    [self configureFilteredArray];
    [self.tableView reloadData];
}

- (void)setSelectedUIElementIndex:(NSIndexPath *)selectedUIElementIndex
{
    if (self.selectedUIElementIndex)
    {
        [[self getUIElementForIndex:self.selectedUIElementIndex.row] ubk_setDeselectedItemAppearance];
    }
    
    _selectedUIElementIndex = selectedUIElementIndex;
}

- (void)configureFilteredArray
{
    //Reset the view filtered list before adding new ui elements
    if (!self.filteredList)
    {
        self.filteredList = [[NSMutableArray alloc]init];
    }
    else
    {
        [self.filteredList removeAllObjects];
    }
    
    //Loop over ALL ui elements and add them to the view controller filtered list.
    //Update the selection outline if view has warning.
    for (UIView *uiElement in self.elementsArray)
    {
        if ((![self.filteredList containsObject:uiElement]) && (![uiElement isKindOfClass:[UBKAccessibilityVisibleWarningView class]]))
        {
            [self.filteredList addObject:uiElement];
        }
        
        NSArray *itemsArray = uiElement.ubk_accessibilityDetails;
        //Get the warning section, if no section, remove outline
        UBKAccessibilitySection *section = [itemsArray ubk_sectionForTitleKey:kUBKAccessibilityAttributeTitle_Warning_Header];
        if ((section) && ([UBKAccessibilityManager sharedInstance].isShowingHighlightedUI))
        {
            //Get the highest warning level for view
            UBKAccessibilityWarningLevel warningLevel = [section getHighestWarningLevelInSection];

            //When active highlighting is turned on
            if ([UBKAccessibilityManager sharedInstance].isShowingHighlightedUI)
            {
                //Add active highlighting to the view. Updates selection colour based on warning level
                [uiElement ubk_addSelectionOutline:warningLevel];
            }
            else
            {
                //Remove active highlighting
                [uiElement ubk_removeSelectionOutline];
            }
        }
        else
        {
            //Remove active highlighting
            [uiElement ubk_removeSelectionOutline];
        }
    }
    
    //Update tableview if no ui elements
    if (self.filteredList.count == 0)
    {
        self.tableView.hidden = true;
        self.noResultsLabel.hidden = false;
    }
    else
    {
        self.tableView.hidden = false;
        self.noResultsLabel.hidden = true;
    }
}

- (UIView *)getUIElementForIndex:(NSInteger)index
{
    UIView *tmpView = nil;
    if (self.elementsArray.count > index)
    {
        tmpView = [self.elementsArray objectAtIndex:index];
    }
    if (self.isFilteringWarnings)
    {
        if (self.filteredList.count > index)
        {
            tmpView = [self.filteredList objectAtIndex:index];
        }
    }
    return tmpView;
}

- (void)refreshElementsList
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableView.refreshControl endRefreshing];
    });
    
    [[UBKAccessibilityManager sharedInstance]configureAllUIElments];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"UI Elements";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88;
    [self.tableView registerNib:[UINib nibWithNibName:@"UBKUIElementTableViewCell" bundle:[NSBundle bundleForClass:[UBKUIElementTableViewCell class]]] forCellReuseIdentifier:@"UBKUIElementTableViewCell"];
    self.selectedUIElementIndex = [NSIndexPath indexPathForRow:INT_MAX inSection:0];

    UIRefreshControl * refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshElementsList) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    
    self.highlightButton.accessibilityLabel = @"Outline warnings: off";
    self.highlightButton.accessibilityHint = @"Outline UI elements with warnings.";

    UIImage *imageTmpFilter = [[UIImage imageNamed:@"icon_filter" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.filterButton = [[UIBarButtonItem alloc]initWithImage:imageTmpFilter style:UIBarButtonItemStylePlain target:self action:@selector(showFilterView)];
    self.filterButton.accessibilityLabel = @"Filter UI elements";
    
    UIImage *imageTmp = [[UIImage imageNamed:@"icon_settings" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.settingsButton = [[UIBarButtonItem alloc]initWithImage:imageTmp style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    self.settingsButton.accessibilityLabel = @"Settings";
    
    self.navigationItem.leftBarButtonItems = @[self.settingsButton, self.filterButton];

    self.isFilteringWarnings = false;
    self.filteredList = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)hideInspectorView
{
    [[UBKAccessibilityManager sharedInstance]hideInspector];
}

- (void)showSettings
{
    UBKAccessibilitySettingsViewController *viewController = [[UBKAccessibilitySettingsViewController alloc]initWithNibName:@"UBKAccessibilitySettingsViewController" bundle:[NSBundle bundleForClass:[UBKAccessibilityFilterTableViewController class]]];
    [self.navigationController pushViewController:viewController animated:true];
}

- (void)showFilterView
{
    UBKAccessibilityFilterTableViewController *viewController = [[UBKAccessibilityFilterTableViewController alloc]initWithNibName:@"UBKAccessibilityFilterTableViewController" bundle:[NSBundle bundleForClass:[UBKAccessibilityFilterTableViewController class]]];
    [self.navigationController pushViewController:viewController animated:true];
}

- (void)filterElementsWithWarnings
{
    self.isFilteringWarnings = !self.isFilteringWarnings;
    self.selectedUIElementIndex = [NSIndexPath indexPathForRow:INT_MAX inSection:0];

    //Only showing warnings
    if (self.isFilteringWarnings)
    {
        [self configureFilteredArray];
        self.warningButton.tintColor = [UIColor ubk_warningLevelHighBackgroundColour];
        self.warningButton.accessibilityLabel = @"Filter Warnings, on";
    }
    else
    {
        self.warningButton.tintColor = [UIColor lightGrayColor];
        self.warningButton.accessibilityLabel = @"Filter Warnings, off";
    }
    
    [UIView transitionWithView:self.tableView duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.tableView reloadData];
    } completion:nil];
}

- (IBAction)showWarningsOnUIElements:(id)sender
{
    [UBKAccessibilityManager sharedInstance].isShowingHighlightedUI = ![UBKAccessibilityManager sharedInstance].isShowingHighlightedUI;
    [[UBKAccessibilityManager sharedInstance]configureAllUIElments];
    
    //Only showing warnings
    NSString *outlineLabelString = @"Outline warnings: off";
    if ([UBKAccessibilityManager sharedInstance].isShowingHighlightedUI)
    {
        outlineLabelString = @"Outline warnings: on";
    }    
    self.highlightButton.title = outlineLabelString;
}

- (void)outlineElement:(UIButton *)button
{
    UIView *selectedUI = [self getUIElementForIndex:button.tag];
    
    if (self.previousSelectedButton != button)
    {
        [self.previousSelectedButton setTitle:@"Outline" forState:UIControlStateNormal];
    }
    
    if (self.selectedUIElementIndex.row == button.tag)
    {
        button.accessibilityLabel = @"Outline";
        [button setTitle:@"Outline" forState:UIControlStateNormal];
        [self.selectedElement ubk_setDeselectedItemAppearance];
        [selectedUI ubk_setDeselectedItemAppearance];
        self.selectedUIElementIndex = [NSIndexPath indexPathForRow:INT_MAX inSection:0];
    }
    else
    {
        button.accessibilityLabel = @"Remove outline";
        [button setTitle:@"Outlined" forState:UIControlStateNormal];
        [self.selectedElement ubk_setDeselectedItemAppearance];
        [selectedUI ubk_setDeselectedItemAppearance];
        [selectedUI ubk_setHighlightedItemAppearanceColour:[UIColor ubk_warningLevelHighBackgroundColour]];
        self.selectedElement = selectedUI;
        self.previousSelectedButton = button;
        self.selectedUIElementIndex = [NSIndexPath indexPathForRow:button.tag inSection:0];
    }
}

- (BOOL)customActionHighlightMethod:(UBKAccessibilityHighlightAction *)sender
{
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"UI element highlighted, activate to unhighlight");

    UIButton *buttonTmp = [UIButton new];
    buttonTmp.tag = sender.actionTag;
    [self outlineElement:buttonTmp];
    
    return true;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFilteringWarnings)
    {
        return self.filteredList.count;
    }
    return self.elementsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBKUIElementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UBKUIElementTableViewCell" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UBKUIElementTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UBKUIElementTableViewCell"];
    }
    cell.elementView = [self getUIElementForIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.isAccessibilityElement = true;
    
    cell.outlineButton.tag = indexPath.row;
    cell.outlineButton.isAccessibilityElement = false;
    [cell.outlineButton addTarget:self action:@selector(outlineElement:) forControlEvents:UIControlEventTouchUpInside];
    
    UBKAccessibilityHighlightAction *highlightAction = [[UBKAccessibilityHighlightAction alloc]initWithName:@"Highlight UI element" target:self selector:@selector(customActionHighlightMethod:)];
    highlightAction.actionTag = indexPath.row;
    cell.accessibilityCustomActions = @[highlightAction];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (self.selectedUIElementIndex)
    {
        [[self getUIElementForIndex:self.selectedUIElementIndex.row] ubk_setDeselectedItemAppearance];
    }
    
    self.selectedUIElementIndex = [NSIndexPath indexPathForRow:INT_MAX inSection:0];
    UIView *selectedView = [self getUIElementForIndex:indexPath.row];
    
    [[UBKAccessibilityManager sharedInstance].currentTouchedElements removeAllObjects];
    [self addViewToArray:selectedView];
    [[UBKAccessibilityManager sharedInstance].navigationViewController updateNearbyTouchedElement:[UBKAccessibilityManager sharedInstance].currentTouchedElements];
    
    UBKNavigationController *navController = (UBKNavigationController *)self.navigationController;
    [navController selectElement:selectedView];
}

- (void)addViewToArray:(UIView *)view
{
    if (!view.superview)
    {
        return;
    }
    
    [[UBKAccessibilityManager sharedInstance].currentTouchedElements insertObject:view atIndex:0];
    [self addViewToArray:view.superview];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.selectedUIElementIndex = [NSIndexPath indexPathForRow:INT_MAX inSection:0];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.filteredList.count > 0)
    {
        return [NSString stringWithFormat:@"%lu Accessibility warnings", (unsigned long)self.filteredList.count];
    }
    else
    {
        return @"No Accessibility warnings";
    }
    return @"";
}

@end
