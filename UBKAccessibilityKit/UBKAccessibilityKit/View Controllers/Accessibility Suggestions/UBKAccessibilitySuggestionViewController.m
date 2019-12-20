/*
 File: UBKAccessibilitySuggestionViewController.m
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

#import "UBKAccessibilitySuggestionViewController.h"
#import "UBKAccessibilityProperty.h"
#import "UBKAccessibilityConstants.h"

@interface UBKAccessibilitySuggestionViewController ()
@property (nonatomic) IBOutlet UITextView *suggestionTextView;
@end

@implementation UBKAccessibilitySuggestionViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Force focus to the back button
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.parentViewController);
}

- (void)setAccessibilityProperty:(UBKAccessibilityProperty *)accessibilityProperty
{
    _accessibilityProperty = accessibilityProperty;
    [self configureView];
}

- (void)configureView
{
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight)
        {
            self.view.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000];
        }
        else
        {
            // Available with iOS13
            // viewTmp.backgroundColor = [UIColor systemBackgroundColor];
            self.view.backgroundColor = [UIColor blackColor];
        }
    }
    else
    {
        // Fallback on earlier versions
        self.view.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000];
    }
    
    self.title = @"Accessibility warning";

    NSString *suggestionString = @"Unknown warning!";
    switch (self.accessibilityProperty.warningType)
    {
        case UBKAccessibilityWarningTypeDisabled:
        {
            suggestionString = @"The user interface element has user interaction set to YES but isAccessibilityElement has been set to NO. The isAccessibilityElement property is a boolean (Yes/No) value indicating whether the item is an accessibility element an assistive application can access.";
            break;
        }
        case UBKAccessibilityWarningTypeHint:
        {
            suggestionString = @"The accessibilityHint is missing for this user interface element. \n\nThe accessibilityHint property provides additional context (or actions) for the selected user interface element.";
            break;
        }
        case UBKAccessibilityWarningTypeLabel:
        {
            suggestionString = @"The accessibilityLabel text is missing for this user interface element. \n\nThe accessibilityLabel property provides descriptive text that VoiceOver/Voice Control reads when the user selects a user interface element.";
            break;
        }
        case UBKAccessibilityWarningTypeTrait:
        {
            suggestionString = @"The accessibilityTraits is missing for this user interface element. \n\nThe accessibilityTraits are a combination of traits that best characterize the user interface element.";
            break;
        }
        case UBKAccessibilityWarningTypeValue:
        {
            suggestionString = @"The accessibilityValue is missing for this user interface element. \n\nThe accessibilityValue allows VoiceOver to only read out minor details on value changes. This should be used on user interface elements such as sliders, switches or custom controls.";
            break;
        }
        case UBKAccessibilityWarningTypeColourContrast:
        {
            suggestionString = @"Colour contrast doesn't meet the minimum W3C guidelines. \n\nTry changing the foreground colour and testing again.";
            break;
        }
        case UBKAccessibilityWarningTypeColourContrastBackground:
        {
            suggestionString = @"Colour contrast doesn't meet the minimum W3C guidelines. \n\nTry changing the background colour and testing again.";
            break;
        }
        case UBKAccessibilityWarningTypeDynamicTextSize:
        {
            suggestionString = @"The user interface element does not support dynamic type and will not automatically update the font when the user changes the accessibility text size.";
            break;
        }
        case UBKAccessibilityWarningTypeMinimumSize:
        {
            suggestionString = @"The minimum size of a user interface element that is interactive is 44 x 44.";
            break;
        }
        case UBKAccessibilityWarningTypeMissingLabel:
        {
            suggestionString = @"The accessibilityLabel text is missing for this user interface element. \n\nThe accessibilityLabel property provides descriptive text that VoiceOver/Voice Control reads when the user selects a user interface element.";
            break;
        }
        case UBKAccessibilityWarningTypeWrongColour:
        {
            suggestionString = @"Colour used for this user interface element does not match the supplied colours. Check you've set the correct colour.";
            break;
        }
    }
    
    self.suggestionTextView.attributedText = [self configureAttributedStringTitle:self.accessibilityProperty.displayTitle withBody:suggestionString];
}

- (IBAction)showSectionWithWarning:(id)sender
{
    [self.delegate showSectionWithWarning:self.accessibilityProperty];
}

- (NSAttributedString*)configureAttributedStringTitle:(NSString *)title withBody:(NSString *)body
{
    if (title == nil)
    {
        title = @"";
    }
    if (body == nil)
    {
        body = @"";
    }
    if (title.length > 0 && body.length > 0)
    {
        body = [NSString stringWithFormat:@"\n\n%@", body];
    }
    
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@", title, body]];
    
    // Declare the fonts
    UIFont *myStringFont1 = [UIFont fontWithName:@"Helvetica" size:26.0];
    UIFont *myStringFont2 = [UIFont fontWithName:@"Helvetica" size:16.0];
        
    // Create the attributes and add them to the string
    [myString addAttribute:NSFontAttributeName value:myStringFont1 range:NSMakeRange(0, title.length)];
    [myString addAttribute:NSFontAttributeName value:myStringFont2 range:NSMakeRange(title.length, body.length)];

    UIColor *textColour = [UIColor blackColor];
    
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            textColour = [UIColor whiteColor];
        }
    }
    
    [myString addAttribute:NSForegroundColorAttributeName value:textColour range:NSMakeRange(0, myString.length)];
    
    return [[NSAttributedString alloc]initWithAttributedString:myString];
}


@end
