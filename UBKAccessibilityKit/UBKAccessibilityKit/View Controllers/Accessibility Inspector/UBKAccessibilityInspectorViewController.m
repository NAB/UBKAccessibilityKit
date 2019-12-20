/*
 File: UBKAccessibilityInspectorViewController.m
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

#import "UBKAccessibilityInspectorViewController.h"

//View Controllers
#import "UBKColourPickerTableViewController.h"

#import "UBKAccessibilityConstants.h"
#import "UBKAccessibilitySuggestionViewController.h"

//Categories
#import "UIColor+HelperMethods.h"
#import "UIView+UBKAccessibility.h"
#import "NSArray+HelperMethods.h"

//Properties
#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityProperty.h"

//Cells
#import "UBKColourTableViewCell.h"
#import "UBKAccessibilityTitleValueTableViewCell.h"
#import "UBKContrastTableViewCell.h"

typedef enum : NSUInteger {
    SegmentControlViewAccessibility,
    SegmentControlViewColours,
    SegmentControlViewAttributes
} SegmentControlView;

@interface UBKAccessibilityInspectorViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UBKAccessibilitySuggestionViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *itemsArray;
@property (nonatomic) NSArray *controlsArray;
@property (nonatomic) BOOL showingPicker;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UIView *selectedItem;
@property (nonatomic) IBOutlet UISegmentedControl *viewSelectionControl;
@property (nonatomic) IBOutlet UIBarButtonItem *layersButton;
@property (nonatomic) BOOL loadingDetailView;
@property (nonatomic) BOOL hasChangedSelection;
@end

@implementation UBKAccessibilityInspectorViewController

- (void)loadView
{
    [super loadView];
    [self configureNavBarButtons];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"UBKAccessibilityTitleValueTableViewCell" bundle:[NSBundle bundleForClass:[UBKAccessibilityTitleValueTableViewCell class]]] forCellReuseIdentifier:@"UBKAccessibilityTitleValueTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UBKColourTableViewCell" bundle:[NSBundle bundleForClass:[UBKColourTableViewCell class]]] forCellReuseIdentifier:@"UBKColourTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UBKContrastTableViewCell" bundle:[NSBundle bundleForClass:[UBKContrastTableViewCell class]]] forCellReuseIdentifier:@"UBKContrastTableViewCell"];
    
    self.showingPicker = false;
    self.view.shouldGroupAccessibilityChildren = true;
    
    self.pickerView = [[UIPickerView alloc]init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.alpha = 0;
    [self.pickerView setFrame:CGRectMake(self.tableView.frame.origin.x, self.view.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    [self.view addSubview:self.pickerView];
    
    self.layersButton.accessibilityHint = @"Select a layer infront or behind the selected UI element";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.hasChangedSelection)
    {
        if (!self.loadingDetailView)
        {
            [self.viewSelectionControl setSelectedSegmentIndex:0];
            [self reloadViewItems];
        }
        else
        {
            self.loadingDetailView = false;
        }
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasChangedSelection)
    {
        //Force focus to the back button
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.parentViewController);
    }
    self.hasChangedSelection = false;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self)
    {
        //New view controller being pushed
    }
    else if ([viewControllers indexOfObject:self] == NSNotFound)
    {
        //View is disappearing because it was popped from the stack
        [self.selectedItem ubk_setDeselectedItemAppearance];
    }
}

- (void)configureNavBarButtons
{
    //Navigation bar appearance when showing picker.
    if (self.showingPicker)
    {
        //when showing picker
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(selectDifferentLayer:)];
        self.navigationItem.hidesBackButton = true;
        self.title = @"Layers";
    }
    else
    {
        //when not showing picker
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = false;
        self.title = @"Inspector";
    }
}

//WIP: This should show a list of all the layers on the selected UI element.
- (IBAction)selectDifferentLayer:(id)sender
{
    if (self.showingPicker)
    {
        [self.selectedItem ubk_setSelectedItemAppearanceColour:[UIColor ubk_warningLevelHighBackgroundColour]];
        self.showingPicker = FALSE;
        [UIView animateWithDuration:0.2 animations:^{
            [self.pickerView setFrame:CGRectMake(self.tableView.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
            self.tableView.alpha = 1;
            self.viewSelectionControl.alpha = 1;
            self.pickerView.alpha = 0;
            [self configureNavBarButtons];
        }];
    }
    else
    {
        self.showingPicker = TRUE;
        if ([self.controlsArray containsObject:self.selectedItem])
        {
            NSInteger index = [self.controlsArray indexOfObject:self.selectedItem];
            [self.pickerView selectRow:index inComponent:0 animated:FALSE];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.pickerView setFrame:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.viewSelectionControl.frame.origin.y + self.viewSelectionControl.frame.size.height + self.tableView.frame.size.height)];
            self.tableView.alpha = 0;
            self.viewSelectionControl.alpha = 0;
            self.pickerView.alpha = 1;
            [self configureNavBarButtons];
        }];
    }
}

- (void)configureInspectorForUIElement:(UIView *)element
{
    [self updateViewAppearanceWithControl:element];
}

- (void)configureInspectorForNearbyElements:(NSArray *)controls
{
    self.controlsArray = controls;
    [self.pickerView reloadAllComponents];
    [self updateViewAppearanceWithControl:[self.controlsArray lastObject]];
}

- (void)updateViewAppearanceWithControl:(UIView *)control
{
    [self.selectedItem ubk_setDeselectedItemAppearance];
    self.selectedItem = control;
    if (self.showingPicker)
    {
        [self.selectedItem ubk_setHighlightedItemAppearanceColour:[UIColor ubk_warningLevelHighBackgroundColour]];
    }
    else
    {
        [self.selectedItem ubk_setSelectedItemAppearanceColour:[UIColor ubk_warningLevelHighBackgroundColour]];
    }
    
    if ([self.controlsArray containsObject:self.selectedItem])
    {
        NSInteger index = [self.controlsArray indexOfObject:self.selectedItem];
        [self.pickerView selectRow:index inComponent:0 animated:FALSE];
    }

    if (!self.itemsArray)
    {
        self.itemsArray = [[NSMutableArray alloc]init];
    }
    else
    {
        [self.itemsArray removeAllObjects];
    }
    
    //Extension, check if control responds to protocol and if so use those properties.
    self.itemsArray = control.ubk_accessibilityDetails.mutableCopy;
    [self reloadViewItems];
}

//Called by the segment control when a different option is selected.
- (IBAction)changeSegmentControlValue:(id)sender
{
    [self.tableView setContentOffset:CGPointZero];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.03 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self reloadViewItems];
    });
}

//Used to filter out the items to display on screen. This is based on the segment control selected index (SegmentControlView value)
- (void)reloadViewItems
{
    self.itemsArray = self.selectedItem.ubk_accessibilityDetails.mutableCopy;

    NSArray *sectionsForView = nil;
    switch (self.viewSelectionControl.selectedSegmentIndex)
    {
        case SegmentControlViewAccessibility:
        {
            sectionsForView = @[@(SectionDisplayTypeWarnings), @(SectionDisplayTypeAccessibilityAttributes), @(SectionDisplayTypeVoiceOverGestures), @(SectionDisplayTypeGlobalAccessibilityProperties)];
            break;
        }
        case SegmentControlViewColours:
        {
            sectionsForView = @[@(SectionDisplayTypeColour)];
            break;
        }
        case SegmentControlViewAttributes:
        {
            sectionsForView = @[@(SectionDisplayTypeComponentAttributes), @(SectionDisplayTypeTypography)];
            break;
        }
    }

    self.itemsArray = [self filterItemsFromArray:self.itemsArray showingSections:sectionsForView];
    [self.tableView reloadData];
}

- (NSMutableArray *)filterItemsFromArray:(NSArray *)array showingSections:(NSArray *)viewSections
{
    NSMutableArray *sectionsArray = [[NSMutableArray alloc]init];
    for (UBKAccessibilitySection *accessibilitySection in array)
    {
        if ([viewSections containsObject:@(accessibilitySection.sectionType)])
        {
            [sectionsArray addObject:accessibilitySection];
        }
    }
    return sectionsArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.itemsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UBKAccessibilitySection *accessiblitySection = [self.itemsArray objectAtIndex:section];
    return [accessiblitySection.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBKAccessibilitySection *accessibilitySection = [self.itemsArray objectAtIndex:indexPath.section];
    UBKAccessibilityProperty *accessibilityProperty = [accessibilitySection.items objectAtIndex:indexPath.row];
    
    if (accessibilityProperty.displayType == PropertyDisplayTypeColour)
    {
        UBKColourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UBKColourTableViewCell"];
        cell.cellProperty = accessibilityProperty;
        return cell;
    }
    else if (accessibilityProperty.displayType == PropertyDisplayTypeContrast)
    {
        UBKContrastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UBKContrastTableViewCell"];
        cell.cellProperty = accessibilityProperty;
        return cell;
    }
    else if (accessibilityProperty.displayType == PropertyDisplayTypeAction)
    {
        UBKAccessibilityTitleValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UBKAccessibilityTitleValueTableViewCell"];
        cell.cellProperty = accessibilityProperty;
        if (accessibilityProperty.actionUpdateCompletionBlock != nil)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    else
    {
        UBKAccessibilityTitleValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UBKAccessibilityTitleValueTableViewCell"];
        if ([accessibilitySection.headerTitle isEqualToString:kUBKAccessibilityAttributeTitle_Warning_Header])
        {
            [accessibilitySection sortWarningsByLevel];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UBKAccessibilityProperty *accessibilityProperty = [accessibilitySection.items objectAtIndex:indexPath.row];
        cell.cellProperty = accessibilityProperty;
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    UBKAccessibilitySection *accessiblitySection = [self.itemsArray objectAtIndex:section];
    return accessiblitySection.headerTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    UBKAccessibilitySection *accessibilitySection = [self.itemsArray objectAtIndex:indexPath.section];
    UBKAccessibilityProperty *accessibilityProperty = [accessibilitySection.items objectAtIndex:indexPath.row];
    
    if (accessibilityProperty.displayType == PropertyDisplayTypeColour)
    {
        if (accessibilityProperty.canUpdateUI)
        {
            UBKColourPickerTableViewController *viewController = [[UBKColourPickerTableViewController alloc]initWithNibName:@"UBKColourPickerTableViewController" bundle:[NSBundle bundleForClass:[UBKColourPickerTableViewController class]]];
            viewController.selectedElement = self.selectedItem;
            if ([accessibilityProperty.displayTitle isEqualToString:kUBKAccessibilityAttributeTitle_BackgroundColour])
            {
                viewController.changingBackgroundColour = true;
                UBKAccessibilityProperty *accessibilityText = [accessibilitySection getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_TextColour];
                viewController.accessibilityProperty = accessibilityText;
                viewController.accessibilityBackground = accessibilityProperty;
            }
            else
            {
                UBKAccessibilityProperty *accessibilityBackground = [accessibilitySection getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_BackgroundColour];
                viewController.accessibilityProperty = accessibilityProperty;
                viewController.accessibilityBackground = accessibilityBackground;
            }
            self.loadingDetailView = true;
            [self.navigationController pushViewController:viewController animated:true];
        }
    }
    else if (accessibilityProperty.displayType == PropertyDisplayTypeAction)
    {
        //Run custom action
        accessibilityProperty.actionUpdateCompletionBlock(self);
    }
    else if ([accessibilitySection.headerTitle isEqualToString:kUBKAccessibilityAttributeTitle_Warning_Header])
    {
        UBKAccessibilitySuggestionViewController *viewController = [[UBKAccessibilitySuggestionViewController alloc]initWithNibName:@"UBKAccessibilitySuggestionViewController" bundle:[NSBundle bundleForClass:[UBKAccessibilitySuggestionViewController class]]];
        viewController.accessibilityProperty = accessibilityProperty;
        viewController.delegate = self;
        self.loadingDetailView = true;
        [self.navigationController pushViewController:viewController animated:true];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.controlsArray.count > row)
    {
        UIView *control = [self.controlsArray objectAtIndex:row];
        return NSStringFromClass([control class]);
    }
    return @"";
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.controlsArray.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.controlsArray.count > row)
    {
        UIView *control = [self.controlsArray objectAtIndex:row];
        [self updateViewAppearanceWithControl:control];
    }
}

#pragma mark - UBKAccessibilitySuggestionViewControllerDelegate

- (void)showSectionWithWarning:(UBKAccessibilityProperty *)accessibilityProperty
{
    //This param is used to match again the section scrolled to in the tableview.
    NSString *matchingSectionTitle = @"";
    
    //Once we get the warning type, we can switch over the warnings to determine the section to show, Accessibility | colours | attributes.
    switch (accessibilityProperty.warningType)
    {
        case UBKAccessibilityWarningTypeTrait:
        case UBKAccessibilityWarningTypeLabel:
        case UBKAccessibilityWarningTypeHint:
        case UBKAccessibilityWarningTypeValue:
        case UBKAccessibilityWarningTypeDisabled:
        case UBKAccessibilityWarningTypeMissingLabel:
        case UBKAccessibilityWarningTypeDynamicTextSize:
        {
            [self.viewSelectionControl setSelectedSegmentIndex:SegmentControlViewAccessibility];
            matchingSectionTitle = kUBKAccessibilityAttributeTitle_AccessibilityAttributes;
            break;
        }
        case UBKAccessibilityWarningTypeColourContrast:
        case UBKAccessibilityWarningTypeColourContrastBackground:
        case UBKAccessibilityWarningTypeWrongColour:
        {
            [self.viewSelectionControl setSelectedSegmentIndex:SegmentControlViewColours];
            matchingSectionTitle = kUBKAccessibilityAttributeTitle_Colours;
            break;
        }
        case UBKAccessibilityWarningTypeMinimumSize:
        {
            [self.viewSelectionControl setSelectedSegmentIndex:SegmentControlViewAttributes];
            matchingSectionTitle = kUBKAccessibilityAttributeTitle_Attributes;
            break;
        }
    }
    
    NSString *warningTitle = @"";
    switch (accessibilityProperty.warningType)
    {
        case UBKAccessibilityWarningTypeTrait:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Trait;
            break;
        }
        case UBKAccessibilityWarningTypeLabel:
        case UBKAccessibilityWarningTypeMissingLabel:
        {
            warningTitle =kUBKAccessibilityAttributeTitle_Label;
            break;
        }
        case UBKAccessibilityWarningTypeHint:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Hint;
            break;
        }
        case UBKAccessibilityWarningTypeValue:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Value;
            break;
        }
        case UBKAccessibilityWarningTypeDisabled:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_Enabled;
            break;
        }
        case UBKAccessibilityWarningTypeDynamicTextSize:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_DynamicTextSupported;
            break;
        }
        case UBKAccessibilityWarningTypeWrongColour:
        case UBKAccessibilityWarningTypeColourContrast:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_TintColour;
            break;
        }
        case UBKAccessibilityWarningTypeColourContrastBackground:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_BackgroundColour;
            break;
        }
        case UBKAccessibilityWarningTypeMinimumSize:
        {
            warningTitle = kUBKAccessibilityAttributeTitle_MinimumSizeWarning;
            break;
        }
    }
    
    //Now that the segment control has been changed we filter out the sections based on the section and reload the TableView.
    [self reloadViewItems];
    
    //We use the section string set above to find the section to scroll to.
    NSInteger sectionIndex = [self.itemsArray ubk_indexForSectionTitleKey:matchingSectionTitle];

    //Let's be safe with our indexes just in case we're out of bounds.
    if ((sectionIndex < 0) || (self.itemsArray.count <= sectionIndex))
    {
        sectionIndex = 0;
    }
    
    //Row index
    
    UBKAccessibilitySection *accessibilitySection = [self.itemsArray objectAtIndex:sectionIndex];
    NSInteger cellIndex = [accessibilitySection.items ubk_indexForCellTitleKey:warningTitle];
    if ((cellIndex < 0) || (accessibilitySection.items.count <= cellIndex))
    {
        cellIndex = 0;
    }
    
    self.hasChangedSelection = true;

    //Pop the information view off screen
    [self.navigationController popViewControllerAnimated:true];

    //Scroll to the view with the warning after a delay.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:true];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            //Force focus to the back button
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:sectionIndex]];
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, cell);
        });
    });
}

@end
