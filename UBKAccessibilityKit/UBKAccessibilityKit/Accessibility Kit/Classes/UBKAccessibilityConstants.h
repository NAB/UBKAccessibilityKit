/*
 File: UBKAccessibilityConstants.h
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

#define kUBKAccessibilityAttributeTitle_Attributes                         @"Attributes"
#define kUBKAccessibilityAttributeTitle_ClassName                          @"Class Name"
#define kUBKAccessibilityAttributeTitle_Text                               @"Text"
#define kUBKAccessibilityAttributeTitle_Enabled                            @"Enabled"
#define kUBKAccessibilityAttributeTitle_Frame                              @"Frame"
#define kUBKAccessibilityAttributeTitle_UserInteractionEnabled             @"User interaction enabled"
#define kUBKAccessibilityAttributeTitle_MinimumSizeWarning                 @"Minimum size warning"
#define kUBKAccessibilityAttributeTitle_Colours                            @"Colours"
#define kUBKAccessibilityAttributeTitle_W3CContrastRatio                   @"W3C Contrast Ratio"
#define kUBKAccessibilityAttributeTitle_TintBackgroundColour               @"Tint & background colour"
#define kUBKAccessibilityAttributeTitle_TextBackgroundColour               @"Text & background colour"
#define kUBKAccessibilityAttributeTitle_BackgroundColour                   @"Background Colour"
#define kUBKAccessibilityAttributeTitle_TintColour                         @"Tint Colour"
#define kUBKAccessibilityAttributeTitle_TextColour                         @"Text Colour"
#define kUBKAccessibilityAttributeTitle_NormalStateColour                  @"Normal State Colour"
#define kUBKAccessibilityAttributeTitle_HighlightedStateColour             @"Highlighted State Colour"
#define kUBKAccessibilityAttributeTitle_DisabledStateColour                @"Disabled State Colour"
#define kUBKAccessibilityAttributeTitle_SelectedStateColour                @"Selected State Colour"
#define kUBKAccessibilityAttributeTitle_Typography                         @"Typography"
#define kUBKAccessibilityAttributeTitle_Font                               @"Font"
#define kUBKAccessibilityAttributeTitle_FontBold                           @"Bold Font"
#define kUBKAccessibilityAttributeTitle_FontSize                           @"Font Size"
#define kUBKAccessibilityAttributeTitle_FontStyle                          @"Font Style"
#define kUBKAccessibilityAttributeTitle_AccessibilityAttributes            @"Accessibility Attributes"
#define kUBKAccessibilityAttributeTitle_VoiceOverGestures                  @"VoiceOver Gestures"
#define kUBKAccessibilityAttributeTitle_GlobalAccessibilityProperties      @"Global Accessibility Properties"
#define kUBKAccessibilityAttributeTitle_AccessibilityEnabled               @"Accessibility enabled"
#define kUBKAccessibilityAttributeTitle_Trait                              @"Trait"
#define kUBKAccessibilityAttributeTitle_Identifier                         @"Identifier"
#define kUBKAccessibilityAttributeTitle_Label                              @"Label"
#define kUBKAccessibilityAttributeTitle_Hint                               @"Hint"
#define kUBKAccessibilityAttributeTitle_Frame                              @"Frame"
#define kUBKAccessibilityAttributeTitle_Value                              @"Value"
#define kUBKAccessibilityAttributeTitle_CustomActions                      @"Custom Action"
#define kUBKAccessibilityAttributeTitle_EscapteGestureCompatible           @"Escape Gesture compatible"
#define kUBKAccessibilityAttributeTitle_IgnoreInvertColours                @"Ignore Invert Colours"
#define kUBKAccessibilityAttributeTitle_BoldTextEnabled                    @"Bold Text enabled"
#define kUBKAccessibilityAttributeTitle_GlobalFontSize                     @"Font Size Category"
#define kUBKAccessibilityAttributeTitle_ReducedTransparencyEnabled         @"Reduced Transparency enabled"
#define kUBKAccessibilityAttributeTitle_DarkerColoursEnabled               @"Darker colours enabled"
#define kUBKAccessibilityAttributeTitle_ReducedMotionEnabled               @"Reduced motion enabled"
#define kUBKAccessibilityAttributeTitle_ColourSuggestionOne                @"Colour #1"
#define kUBKAccessibilityAttributeTitle_ColourSuggestionTwo                @"Colour #2"
#define kUBKAccessibilityAttributeTitle_ColourSuggestionThree              @"Colour #3"
#define kUBKAccessibilityAttributeTitle_DynamicTextSupported               @"Dynamic Text supported"
#define kUBKAccessibilityAttributeTitle_DynamicTypeValue                   @"Dynamic Type name"

#define kUBKAccessibilityAttributeTitle_Warning_Header                     @"Accessibility Warnings"
#define kUBKAccessibilityAttributeTitle_Warning_MinimumSize                @"Minimum Size warning"
#define kUBKAccessibilityAttributeTitle_Warning_ColourContrast             @"W3C Colour Contrast warning"
#define kUBKAccessibilityAttributeTitle_Warning_BackgroundColourContrast   @"W3C Background Colour Contrast warning"
#define kUBKAccessibilityAttributeTitle_Warning_Trait                      @"Missing accessibilityTraits"
#define kUBKAccessibilityAttributeTitle_Warning_Label                      @"Missing accessibilityLabel"
#define kUBKAccessibilityAttributeTitle_Warning_Hint                       @"Missing accessibilityHint"
#define kUBKAccessibilityAttributeTitle_Warning_Value                      @"Missing accessibilityValue"
#define kUBKAccessibilityAttributeTitle_Warning_AccessibilityDisabled      @"Missing isAccessibilityElement"
#define kUBKAccessibilityAttributeTitle_Warning_WrongColour                @"Invalid colour used"
#define kUBKAccessibilityAttributeTitle_Warning_LabelNotSet                @"Missing accessibilityLabel not set"
#define kUBKAccessibilityAttributeTitle_Warning_DynamicTextSize            @"Dynamic text sizes are not supported"

typedef enum : NSUInteger {
    UBKAccessibilityWarningLevelHigh,
    UBKAccessibilityWarningLevelMedium,
    UBKAccessibilityWarningLevelLow,
    UBKAccessibilityWarningLevelPass
} UBKAccessibilityWarningLevel;

typedef enum : NSUInteger {
    ///isAccessibilityElement
    UBKAccessibilityWarningTypeDisabled,
    ///accessibilityHint
    UBKAccessibilityWarningTypeHint,
    ///accessibilityLabel
    UBKAccessibilityWarningTypeLabel,
    ///accessibilityTraits
    UBKAccessibilityWarningTypeTrait,
    ///accessibilityValue
    UBKAccessibilityWarningTypeValue,
    ///warning for colour contrast between the foreground and background colours
    UBKAccessibilityWarningTypeColourContrast,
    ///warning for colour contrast between the background and foreground colours
    UBKAccessibilityWarningTypeColourContrastBackground,
    ///adjustsFontForContentSizeCategory
    UBKAccessibilityWarningTypeDynamicTextSize,
    ///Less than 44 x 44
    UBKAccessibilityWarningTypeMinimumSize,
    ///accessibilityLabel
    UBKAccessibilityWarningTypeMissingLabel,
    ///checks against supplied colours and if colours don't match
    UBKAccessibilityWarningTypeWrongColour
} UBKAccessibilityWarningType;

typedef enum : NSUInteger {
    UBKAccessibilityObjectClassUIButton,
    UBKAccessibilityObjectClassUIImageView,
    UBKAccessibilityObjectClassUILabel,
    UBKAccessibilityObjectClassUISlider,
    UBKAccessibilityObjectClassUISwitch,
    UBKAccessibilityObjectClassUITextfield,
    UBKAccessibilityObjectClassUITextView,
    UBKAccessibilityObjectClassUIView
} UBKAccessibilityObjectClass;

//Icons for each warning type
#define kUBKAccessibilityWarningLevelImageNamePass      @"icon_warning_pass"
#define kUBKAccessibilityWarningLevelImageNameLow       @"icon_warning_low"
#define kUBKAccessibilityWarningLevelImageNameMedium    @"icon_warning_medium"
#define kUBKAccessibilityWarningLevelImageNameHigh      @"icon_warning_high"

typedef enum : NSUInteger {
    UBKAccessibilitySettingsGlobalSettingsBoldTextEnabled,
    UBKAccessibilitySettingsGlobalSettingsFontSizeCategory,
    UBKAccessibilitySettingsGlobalSettingsReducedTransparency,
    UBKAccessibilitySettingsGlobalSettingsDarkColoursEnabled,
    UBKAccessibilitySettingsGlobalSettingsReducedMotionEnabled
} UBKAccessibilitySettingsGlobalSettings;
