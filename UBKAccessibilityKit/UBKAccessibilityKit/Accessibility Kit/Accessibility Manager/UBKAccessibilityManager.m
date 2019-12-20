/*
 File: UBKAccessibilityManager.m
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

#import "UBKAccessibilityManager.h"
#import "UBKAccessibilityWindow.h"
#import "UBKNavigationController.h"
#import "UBKAccessibilityElementsTableViewController.h"
#import "UBKAccessibilityButton.h"
#import "UIView+UBKAccessibility.h"
#import "UBKAccessibilityValidation.h"
#import "UBKAccessibilitySection.h"
#import "UBKAccessibilityConstants.h"
#import "UBKAccessibilityInspectorContainerView.h"
#import "UBKAccessibilityValidColour.h"
#import "UBKAccessibilityInspectorGutterContainerView.h"
#import "UBKAccessibilityFilter.h"
#import "UBKAccessibilityTouchView.h"
#import "UBKAccessibilityVisibleWarningView.h"
#import "UIView+HelperMethods.h"

const CGFloat maxWidth = 414;
static const UBKAccessibilityManager *_ubkAccessibilityManager = nil;

@interface UBKAccessibilityManager ()

@end

@implementation UBKAccessibilityManager

+ (UBKAccessibilityManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ubkAccessibilityManager = [[UBKAccessibilityManager alloc] init];
    });
    return (UBKAccessibilityManager *)_ubkAccessibilityManager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        //Configure the navigation of the inspector.
        UBKAccessibilityElementsTableViewController *elementsViewController = [[UBKAccessibilityElementsTableViewController alloc]initWithNibName:@"UBKAccessibilityElementsTableViewController" bundle:[NSBundle bundleForClass:[UBKAccessibilityElementsTableViewController class]]];
        self.navigationViewController = [[UBKNavigationController alloc]initWithUIElementsViewController:elementsViewController];
        
        self.inspectorContainerView = [[UBKAccessibilityInspectorContainerView alloc]initWithFrame:CGRectMake(0, 0, self.navigationViewController.view.frame.size.width, self.navigationViewController.view.bounds.size.height/2)];
        self.inspectorContainerView.layer.zPosition = 999;
        [self.inspectorContainerView addNavigationViewController:self.navigationViewController];
        
        self.accessibilityViews = [[NSMutableSet alloc]init];
        
        //Init properties
        self.allowNormalTouchEvents = false;
        self.navigationViewController.isShowingInspector = false;
        self.currentTouchedElements = [[NSMutableArray alloc]init];
        self.isValidatingColours = false;
        self.accessibilityFilter = [[UBKAccessibilityFilter alloc]init];
        self.accessibilityColours = [[UBKAccessibilityColours alloc] init];
    }
    return self;
}

//Check if any UI elements have a warning.
- (UBKAccessibilityWarningLevel)showWarningLevelForView
{
    [self configureAllUIElments];
    
    UBKAccessibilityWarningLevel warningLevel = UBKAccessibilityWarningLevelPass;
    for (UIView *uiElement in self.accessibilityFilter.filteredObjects)
    {
        NSArray *itemsArray = uiElement.ubk_accessibilityDetails;
        for (UBKAccessibilitySection *section in itemsArray)
        {
            if (section.sectionType == SectionDisplayTypeWarnings)
            {
                warningLevel = MIN([section getHighestWarningLevelInSection], warningLevel);
                if (warningLevel == UBKAccessibilityWarningLevelHigh)
                {
                    return warningLevel;
                }
            }
        }
    }
    return warningLevel;
}

//Called when the inspector button has been enabled/disabled.
- (void)setAllowNormalTouchEvents:(BOOL)allowNormalTouchEvents
{
    _allowNormalTouchEvents = allowNormalTouchEvents;
    
    if (self.allowNormalTouchEvents)
    {
        [self hideInspector];
    }
    else
    {
        [self configureAllUIElments];
    }

    //This will cause the first responder to resign.
    [self.window.rootViewController.view endEditing:true];
    
    //Dismiss if presented view is first responder
    if (self.window.rootViewController.presentedViewController)
    {
        [self.window.rootViewController.presentedViewController.view endEditing:true];
    }
}

//Get all UI elements on screen. This is only called when the accessbility inspector is enabled.
- (void)configureAllUIElments
{
    [self.accessibilityFilter.filteredObjects removeAllObjects];
    [self configureAccessibiltyViewIgnoreList];
    
    for (UIView *viewTmp in self.window.subviews)
    {
        if (![self.accessibilityViews containsObject:viewTmp])
        {
            if ([self canAddView:viewTmp])
            {
                [self getChildUIElements:viewTmp];
            }
        }
    }
    
    [self.accessibilityFilter applyFilter];
    [self.navigationViewController updateAllElements:self.accessibilityFilter.filteredObjects];
}

//Recurrsion to get all child subviews.
- (void)getChildUIElements:(UIView *)parentView
{
    for (UIView *viewTmp in parentView.subviews)
    {
        if ([self canAddView:viewTmp])
        {
            if (![viewTmp isKindOfClass:[UBKAccessibilityVisibleWarningView class]])
            {
                [self.accessibilityFilter.filteredObjects addObject:viewTmp];
            }
            [self getChildUIElements:viewTmp];
        }
    }
}

- (void)removeAllOutlines
{
    for (UIView *viewTmp in self.window.subviews)
    {
        [self removeOutlineFromView:viewTmp];
    }
}

- (void)removeOutlineFromView:(UIView *)view
{
    if (view == nil)
    {
        return;
    }
    if ([view isKindOfClass:[UBKAccessibilityVisibleWarningView class]])
    {
        [view removeFromSuperview];
    }
    for (UIView *viewTmp in view.subviews)
    {
        [self removeOutlineFromView:viewTmp];
    }
}

- (void)setWindow:(UBKAccessibilityWindow *)window
{
    _window = window;
    
    //Add shadow view
    CGFloat inspectorWidth = self.window.frame.size.width;
    if (inspectorWidth > maxWidth)
    {
        inspectorWidth = maxWidth;
    }
    [self.inspectorContainerView setFrame:CGRectMake(0, self.window.frame.size.height, inspectorWidth, self.window.frame.size.height/2)];
    self.inspectorContainerView.originalHeight = self.window.frame.size.height/2;
    self.inspectorContainerView.originalWidth = inspectorWidth;
    [self.window addSubview:self.inspectorContainerView];
    
    [self configureAccessibiltyViewIgnoreList];
    [self configureAllUIElments];
}

- (void)configureAccessibiltyViewIgnoreList
{
    if (self.navigationViewController.view)
    {
        [self.accessibilityViews addObject:self.navigationViewController.view];
    }
    if (self.inspectorContainerView)
    {
        [self.accessibilityViews addObject:self.inspectorContainerView];
    }
    if (self.inspectorContainerView.gutterView)
    {
        [self.accessibilityViews addObject:self.inspectorContainerView.gutterView];
    }
    if (self.window.inspectorButton)
    {
        [self.accessibilityViews addObject:self.window.inspectorButton];
    }
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self.currentTouchedElements removeAllObjects];
    for (UITouch *touch in touches)
    {
        CGRect buttonRectTmp = self.inspectorContainerView.frame;
        CGPoint pointTmp = [touch locationInView:self.window];

        //Check if user touched inside inspector view controller
        if ((CGRectContainsPoint(buttonRectTmp, pointTmp)) && (self.navigationViewController.isShowingInspector))
        {
            
        }
        else
        {
            for (UIView *view in self.window.subviews)
            {
                //Make sure we're not adding any of the inspector views or helper views.
                if ((![self.accessibilityViews containsObject:view]) && (![view isKindOfClass:[UBKAccessibilityTouchView class]]))
                {
                    [self checkHitTest:view withTouches:touch];
                }
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{    
    if (self.currentTouchedElements.count > 0)
    {
        [self sendItemsToInspector];
        [self showInspector:false];
    }
    else
    {
        [self hideInspector];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - Hit test helper

//Create an array of UI elements under the touch point.
- (void)checkHitTest:(UIView *)view withTouches:(UITouch *)touch
{
    if (view.alpha == 0 || view.hidden)
    {
        //View is not visible, ignore it and any children
        return;
    }
    CGFloat buffer = 10;
    //Check if the touch point is within the bounds of the inspector button
    CGRect buttonRectTmp = CGRectMake(view.frame.origin.x - buffer, view.frame.origin.y - buffer, view.frame.size.width + (buffer * 2), view.frame.size.height + (buffer * 2));
        
    CGPoint pointTmp = [touch locationInView:view.superview];
    if (!touch)
    {
        pointTmp = view.frame.origin;
    }
    if (CGRectContainsPoint(buttonRectTmp, pointTmp))
    {
        if (view != self.window.rootViewController.view)
        {
            //Don't interact with Apple private classes
            if ([self canAddView:view])
            {
                [self.currentTouchedElements addObject:view];
            }
        }
    }
    
    //Use recursion to ensure we get all the views and subviews into the touched elements list
    for (UIView *viewTmp in view.subviews)
    {
        [self checkHitTest:viewTmp withTouches:touch];
    }
}

- (BOOL)canAddView:(UIView *)view
{
    //Don't interact with Apple private classes
    if (![[NSStringFromClass([view class])substringToIndex:1]isEqualToString:@"_"])
    {
        return true;
    }
    return false;
}

#pragma mark - Inspector methods

- (void)sendItemsToInspector
{
    UIView *tmpView = [self.currentTouchedElements lastObject];
    
    //Used to show the layers of a view. Eg if you tap a label on a UIButton it will allow you to easily select the button.
    [self.navigationViewController updateNearbyTouchedElement:self.currentTouchedElements];

    //The UI element that was touched is in the global array. Let's show it in the inspector.
    [self.navigationViewController selectElement:tmpView];
}

- (void)hideInspector
{
    for (UIView *viewTmp in self.currentTouchedElements)
    {
        [viewTmp ubk_setDeselectedItemAppearance];
    }
    
    self.navigationViewController.isShowingInspector = false;
    [self.inspectorContainerView hideInspectorViewAnimated:true];
    
    [self.currentTouchedElements removeAllObjects];
}

- (void)showInspector:(BOOL)popViewController
{
    if (popViewController)
    {
        [self.navigationViewController popViewControllerAnimated:false];
    }    
    [self.inspectorContainerView showInspectorView];
    self.navigationViewController.isShowingInspector = true;
}



#pragma mark - Helper Methods

//Find the elements superview in the global array of UI elements.
- (UIView *)findParentView:(UIView *)childView
{
    if ([self.accessibilityFilter.filteredObjects containsObject:childView])
    {
        return childView;
    }
    if (childView.superview)
    {
        return [self findParentView:childView.superview];
    }
    else
    {
        return childView;
    }
}

@end
