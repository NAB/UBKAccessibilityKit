/*
 File: UBKColourPickerTableViewController.m
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

#import "UBKColourPickerTableViewController.h"
#import "UBKAccessibilityManager.h"

//Categories
#import "UIView+UBKAccessibility.h"
#import "UIColor+HelperMethods.h"

//Classes
#import "UBKAccessibilityValidation.h"
#import "UBKAccessibilityConstants.h"
#import "UBKAccessibilitySection.h"

//Cells
#import "UBKColourTableViewCell.h"
#import "UBKContrastTableViewCell.h"

@interface UBKColourPickerTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UIColor *currentColour;
@property (nonatomic) UIColor *originalForegroundColour;
@property (nonatomic) UIColor *originalBackgroundColour;
@property (nonatomic) double contrastRating;
@property (nonatomic) ColourContrastRating contrastWarningRating;
@property (nonatomic) BOOL boldFont;
@property (nonatomic) UBKAccessibilityProperty *accessibilityFont;
@property (nonatomic) BOOL checkingTextContrast;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *addColourButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *resetButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *swapColourButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) UIColor *customForegroundColour;
@property (nonatomic) UIColor *customBackgroundColour;
@end

@implementation UBKColourPickerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Update the title of the view depending on the update context.
    if (self.changingBackgroundColour)
    {
        self.title = self.accessibilityBackground.displayTitle;
    }
    else
    {
        self.title = self.accessibilityProperty.displayTitle;
    }
    
    [self createContrastSuggestedCells];
    
    self.addColourButton.accessibilityLabel = @"Create colour from hex code";
    self.resetButton.accessibilityLabel = @"Reset UI element to original colours";
    self.resetButton.enabled = false;
    [self.resetButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]} forState:UIControlStateDisabled];
    self.swapColourButton.accessibilityLabel = @"Swap foreground and background colours";
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88;
    [self.tableView registerNib:[UINib nibWithNibName:@"UBKColourTableViewCell" bundle:[NSBundle bundleForClass:[UBKColourTableViewCell class]]] forCellReuseIdentifier:@"UBKColourTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UBKContrastTableViewCell" bundle:[NSBundle bundleForClass:[UBKContrastTableViewCell class]]] forCellReuseIdentifier:@"UBKContrastTableViewCell"];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UBKAccessibilityManager sharedInstance].accessibilityColours removeAllSuggestedColours];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Force focus to the back button
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.parentViewController);
}

//Setter method for the Accessibility property, update view controller properties once this thas been set. These properties are used later in resets and calculations.
- (void)setAccessibilityProperty:(UBKAccessibilityProperty *)accessibilityProperty
{
    _accessibilityProperty = accessibilityProperty;
    self.customForegroundColour = self.accessibilityProperty.displayColour;
    self.originalForegroundColour = self.accessibilityProperty.displayColour;
}

//Setter method for the Accessibility property, update view controller properties once this thas been set. These properties are used later in resets and calculations.
- (void)setAccessibilityBackground:(UBKAccessibilityProperty *)accessibilityBackground
{
    _accessibilityBackground = accessibilityBackground;
    self.customBackgroundColour = self.accessibilityBackground.displayColour;
    self.originalBackgroundColour = self.accessibilityBackground.displayColour;
}

- (void)updateUIForForegroundColour:(UIColor *)foregroundColour withBackgroundColour:(UIColor *)backgroundColour
{
    self.customForegroundColour = foregroundColour;
    self.customBackgroundColour = backgroundColour;

    if (self.accessibilityBackground.colourUpdateCompletionBlock)
    {
        self.accessibilityBackground.colourUpdateCompletionBlock(self.customBackgroundColour);
    }
    self.accessibilityBackground.displayColour = self.customBackgroundColour;
    
    if (self.accessibilityProperty.colourUpdateCompletionBlock)
    {
        self.accessibilityProperty.colourUpdateCompletionBlock(self.customForegroundColour);
    }
    self.accessibilityProperty.displayColour = self.customForegroundColour;
    
    [self createContrastSuggestedCells];
}

//Reset the colours to the original state when the view was loaded.
- (IBAction)resetUIColour:(id)sender
{
    self.resetButton.enabled = false;

    //Pass in the original colours when the view was loaded.
    [self updateUIForForegroundColour:self.originalForegroundColour withBackgroundColour:self.originalBackgroundColour];
}

//Used to swap the foreground and the background colours
- (IBAction)swapColour:(id)sender
{
    //Enable reset button
    self.resetButton.enabled = true;

    //Swap the foreground and the background colours.
    UIColor *newForegroundColour = self.customBackgroundColour;
    UIColor *newBackgroundColour = self.customForegroundColour;
    [self updateUIForForegroundColour:newForegroundColour withBackgroundColour:newBackgroundColour];
}

//Adds a new colour to the inspector.
- (IBAction)addNewColour:(id)sender
{
    [UBKAccessibilityManager sharedInstance].alertOnScreenAllowTouchEvents = TRUE;
    
    [[UBKAccessibilityManager sharedInstance]hideInspector];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create colour from hex code" message:@"Enter a 6 digit hex code to add a colour to the picker" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Colour name";
         textField.textColor = [UIColor blackColor];
         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.placeholder = @"#000000";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        NSArray * textfields = alertController.textFields;
        UITextField *nameField = textfields[0];
        UITextField *hexCodeField = textfields[1];
        
        NSString *nameString = nameField.text;
        NSString *hexString = hexCodeField.text;
        
        if (nameString.length > 0 && hexString.length > 0)
        {
            //String validation
            hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
            hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
            UIColor *newColour = [UIColor ubk_colourFromHexString:hexString];
            if (newColour)
            {
                [[UBKAccessibilityManager sharedInstance].accessibilityColours addDefaultColour:newColour withTitle:nameString];
                [self.tableView reloadData];
            }
            [UBKAccessibilityManager sharedInstance].alertOnScreenAllowTouchEvents = FALSE;
            [[UBKAccessibilityManager sharedInstance] showInspector:false];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[UBKAccessibilityManager sharedInstance] showInspector:false];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//Updates the contrast warning and rating based on current colours for the foreground and background
- (void)checkContrastSetting
{
    self.contrastRating = [UBKAccessibilityValidation getViewContrastRatio:self.customForegroundColour backgroundColor:self.customBackgroundColour];
    self.contrastWarningRating = [UBKAccessibilityValidation getColourContrastRatingForNonText:self.contrastRating];
    NSArray *itemsArray = self.selectedElement.ubk_accessibilityDetails;
    
    for (UBKAccessibilitySection *section in itemsArray)
    {
        if ([section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_FontBold])
        {
            NSString *displayValue = [section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_FontBold].displayValue;
            if ([displayValue isEqualToString:@"Yes"])
            {
                self.boldFont = true;
            }
            else
            {
                self.boldFont = false;
            }
        }
        
        if ([section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_FontSize])
        {
            self.accessibilityFont = [section getPropertyForTitleKey:kUBKAccessibilityAttributeTitle_FontSize];
            self.contrastWarningRating = [UBKAccessibilityValidation getColourContrastRatingForText:self.contrastRating withTextSize:[self.accessibilityFont.displayValue doubleValue] withBoldFont:self.boldFont];
            self.checkingTextContrast = true;
        }
    }
}

//Checks if any suggestions can be provided for the current colour contrast
- (void)createContrastSuggestedCells
{
    [[UBKAccessibilityManager sharedInstance].accessibilityColours removeAllSuggestedColours];
    [self checkContrastSetting];
    
    if ((self.contrastWarningRating == ColourContrastRatingFail) && (!self.changingBackgroundColour))
    {
        //Suggested Colour 1
        UIColor *alternateColourOne = [UIColor ubk_findBetterContrastColour:self.customForegroundColour backgroundColour:self.customBackgroundColour previousContrast:self.contrastRating];
        if (alternateColourOne)
        {
            [[UBKAccessibilityManager sharedInstance].accessibilityColours addSuggestedColour:alternateColourOne withTitle:kUBKAccessibilityAttributeTitle_ColourSuggestionOne];

            //Suggested Colour 2
            UIColor *alternateColourTwo = [alternateColourOne ubk_analagousColour:-1];
            if (alternateColourTwo)
            {
                double contrast = [alternateColourTwo ubk_contrastRatio:self.customBackgroundColour];
                alternateColourTwo = [UIColor ubk_findBetterContrastColour:alternateColourTwo backgroundColour:self.customBackgroundColour previousContrast:contrast];
                if (![[alternateColourOne ubk_hexStringFromColour] isEqualToString:[alternateColourTwo ubk_hexStringFromColour]])
                {
                    [[UBKAccessibilityManager sharedInstance].accessibilityColours addSuggestedColour:alternateColourTwo withTitle:kUBKAccessibilityAttributeTitle_ColourSuggestionTwo];
                }
            }
            
            //Suggested Colour 3
            UIColor *alternateColourThree = [alternateColourOne ubk_analagousColour:1];
            if (alternateColourThree)
            {
                double contrast = [alternateColourThree ubk_contrastRatio:self.customBackgroundColour];
                alternateColourThree = [UIColor ubk_findBetterContrastColour:alternateColourThree backgroundColour:self.customBackgroundColour previousContrast:contrast];
                if (![[alternateColourOne ubk_hexStringFromColour] isEqualToString:[alternateColourThree ubk_hexStringFromColour]])
                {
                    [[UBKAccessibilityManager sharedInstance].accessibilityColours addSuggestedColour:alternateColourThree withTitle:kUBKAccessibilityAttributeTitle_ColourSuggestionThree];
                }
            }
        }
    }
    [self.tableView reloadData];
}

//Helper method to get the correct index in either the suggested colour array or the inspector colour array.
- (UBKAccessibilityProperty *)getPropertyForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return [[[UBKAccessibilityManager sharedInstance].accessibilityColours.suggestedColoursArray objectAtIndex:indexPath.row]mutableCopy];
    }
    else
    {
        return [[[UBKAccessibilityManager sharedInstance].accessibilityColours.defaultColoursArray objectAtIndex:indexPath.row]mutableCopy];
    }
}

//Update the colour on the accessibility property, this will result in the UI being updated.
- (void)didChangeUIColourWithColour:(UIColor *)colour
{
    if (self.changingBackgroundColour)
    {
        if (self.accessibilityBackground.colourUpdateCompletionBlock)
        {
            self.accessibilityBackground.colourUpdateCompletionBlock(colour);
        }
        self.accessibilityBackground.displayColour = colour;
        self.customBackgroundColour = colour;
    }
    else
    {
        if (self.accessibilityProperty.colourUpdateCompletionBlock)
        {
            self.accessibilityProperty.colourUpdateCompletionBlock(colour);
        }
        self.accessibilityProperty.displayColour = colour;
        self.customForegroundColour = colour;
    }
    
    [self createContrastSuggestedCells];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [[UBKAccessibilityManager sharedInstance].accessibilityColours.suggestedColoursArray count];
    }
    return [[UBKAccessibilityManager sharedInstance].accessibilityColours.defaultColoursArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBKColourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UBKColourTableViewCell"];
    
    UBKAccessibilityProperty *property = [self getPropertyForIndexPath:indexPath];
    
    CGFloat tempContrastRating = [UBKAccessibilityValidation getViewContrastRatio:property.displayColour backgroundColor:self.customBackgroundColour];
    ColourContrastRating rating = [UBKAccessibilityValidation getColourContrastRatingForText:tempContrastRating withTextSize:[self.accessibilityFont.displayValue doubleValue] withBoldFont:self.boldFont];
    
    if ((self.changingBackgroundColour) || (!self.checkingTextContrast))
    {
        tempContrastRating = [UBKAccessibilityValidation getViewContrastRatio:self.customForegroundColour backgroundColor:property.displayColour];
        rating = [UBKAccessibilityValidation getColourContrastRatingForNonText:tempContrastRating];
    }
    property.displayTitle = [NSString stringWithFormat:@"%@, Contrast %0.2f", property.displayTitle, tempContrastRating];
    
    if (rating == ColourContrastRatingFail)
    {
        property.warningLevel = UBKAccessibilityWarningLevelHigh;
        property.displayWarning = true;
    }
    else
    {
        property.displayWarning = false;
    }
    
    cell.cellProperty = property;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (self.changingBackgroundColour)
    {
        if (self.customBackgroundColour == property.displayColour)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else
    {
        if (self.customForegroundColour == property.displayColour)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    [cell updateTrailingUIConstraints];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    //Enable reset button
    self.resetButton.enabled = true;
    
    //Update the
    UBKAccessibilityProperty *property = [self getPropertyForIndexPath:indexPath];
    [self didChangeUIColourWithColour:property.displayColour];
}

//Displays the contrast cell in the header for easy tracking when scrolling through all the colours.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    BOOL contrastWarning = false;
    if (self.contrastWarningRating == ColourContrastRatingFail)
    {
        contrastWarning = true;
    }
    UBKAccessibilityProperty *contrastProperty = [[UBKAccessibilityProperty alloc]initWithTitle:kUBKAccessibilityAttributeTitle_W3CContrastRatio
                                                                                      withValue:[NSString stringWithFormat:@"%0.2f", self.contrastRating]
                                                                           withForegroundColour:self.customForegroundColour
                                                                           withBackgroundColour:self.customBackgroundColour
                                                                             withAlternateTitle:kUBKAccessibilityAttributeTitle_TintBackgroundColour
                                                                              withContrastScore:[UBKAccessibilityValidation getTitleColourContrastRatingForText:self.contrastRating withTextSize:[self.accessibilityFont.displayValue doubleValue] withBoldFont:self.boldFont]
                                                                            showContrastWarning:contrastWarning];
    
    UBKContrastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UBKContrastTableViewCell"];
    cell.cellProperty = contrastProperty;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight)
        {
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    } else {
        // Fallback on earlier versions
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell.contentView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return  [[UBKAccessibilityManager sharedInstance].accessibilityColours.suggestedColoursArray count] > 0 ? @"Suggested Colours" : @"";
    }
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return  [[UBKAccessibilityManager sharedInstance].accessibilityColours.suggestedColoursArray count] > 0 ? 40 : 0;
    }
    return 138;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return  [[UBKAccessibilityManager sharedInstance].accessibilityColours.suggestedColoursArray count] > 0 ? @" " : nil;
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return  [[UBKAccessibilityManager sharedInstance].accessibilityColours.suggestedColoursArray count] > 0 ? 40 : 0;
    }
    return 0;
}

@end
