/*
 File: UBKNavigationController.m
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

#import "UBKNavigationController.h"
#import "UBKAccessibilityElementsTableViewController.h"
#import "UBKAccessibilityInspectorViewController.h"

@interface UBKNavigationController ()
@property (nonatomic) CALayer *shadowLayer;
@end

@implementation UBKNavigationController

- (instancetype)initWithUIElementsViewController:(UBKAccessibilityElementsTableViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController])
    {
        self.navigationBar.translucent = false;
        self.elementsViewController = rootViewController;
        self.inspectorViewController = [[UBKAccessibilityInspectorViewController alloc]initWithNibName:@"UBKAccessibilityInspectorViewController" bundle:[NSBundle bundleForClass:[UBKAccessibilityInspectorViewController class]]];
    }
    return self;
}

- (void)updateAllElements:(NSArray *)elementsArray
{
    self.elementsViewController.elementsArray = elementsArray;
}

- (void)selectElement:(UIView *)selectedElement
{
    self.elementsViewController.selectedElement = selectedElement;
    [self.inspectorViewController configureInspectorForUIElement:selectedElement];
    
    //Check if the elements view is on screen, if so then animate pushing to the inspector view.
    if ((self.childViewControllers.lastObject == self.elementsViewController) && (self.isShowingInspector))
    {
        [self pushViewController:self.inspectorViewController animated:true];
    }
    else
    {
        [self popToRootViewControllerAnimated:false];
        [self pushViewController:self.inspectorViewController animated:false];
    }
}

- (void)updateNearbyTouchedElement:(NSArray *)elementsArray
{
    [self.inspectorViewController configureInspectorForNearbyElements:elementsArray];
}

@end
