/*
 File: UBKAccessibilityColours.m
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

#import "UBKAccessibilityColours.h"
#import "UBKAccessibilityProperty.h"
#import "UBKAccessibilityValidColour.h"

@implementation UBKAccessibilityColours

- (instancetype)init
{
    if (self = [super init])
    {
        self.defaultColoursArray = [NSMutableArray new];
        self.suggestedColoursArray = [NSMutableArray new];
        [self resetDefaultsColours];
    }
    return self;
}

#pragma mark - Standard colour Helper methods

//Removes and adds all the default colours again.
- (void)resetDefaultsColours
{
    [self.defaultColoursArray removeAllObjects];
    
    [self.defaultColoursArray addObjectsFromArray:
     @[
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Teal" withColour:[UIColor colorWithRed:0.004 green:0.590 blue:0.534 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Green" withColour:[UIColor colorWithRed:0.198 green:0.756 blue:0.173 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Light Green" withColour:[UIColor colorWithRed:0.531 green:0.779 blue:0.208 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Lime" withColour:[UIColor colorWithRed:0.803 green:0.878 blue:0.000 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Yellow" withColour:[UIColor colorWithRed:0.999 green:0.936 blue:0.006 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Amber" withColour:[UIColor colorWithRed:1.000 green:0.805 blue:0.002 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Orange" withColour:[UIColor colorWithRed:1.000 green:0.602 blue:0.002 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Deep Orange" withColour:[UIColor colorWithRed:0.999 green:0.334 blue:0.001 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Light Red" withColour:[UIColor colorWithRed:0.919 green:0.297 blue:0.198 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Red" withColour:[UIColor colorWithRed:0.833 green:0.044 blue:0.000 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Light Blue" withColour:[UIColor colorWithRed:0.000 green:0.648 blue:0.977 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Blue" withColour:[UIColor colorWithRed:0.321 green:0.433 blue:0.999 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Indigo" withColour:[UIColor colorWithRed:0.242 green:0.287 blue:0.733 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Cyan" withColour:[UIColor colorWithRed:0.002 green:0.736 blue:0.850 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Brown" withColour:[UIColor colorWithRed:0.486 green:0.333 blue:0.277 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Deep Brown" withColour:[UIColor colorWithRed:0.312 green:0.204 blue:0.173 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Purple" withColour:[UIColor colorWithRed:0.496 green:0.308 blue:0.787 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Deep Purple" withColour:[UIColor colorWithRed:0.410 green:0.173 blue:0.749 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Blue Grey" withColour:[UIColor colorWithRed:0.373 green:0.489 blue:0.556 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Grey" withColour:[UIColor colorWithRed:0.620 green:0.620 blue:0.620 alpha:1.000]],
       [[UBKAccessibilityProperty alloc] initWithTitle:@"Black" withColour:[UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000]]
       ]];
}

//Removes all the standard colours and replaces with colours you have provided.
- (void)replaceDefaultColours:(NSArray <UBKAccessibilityValidColour *> *)colourArray
{
    [self.defaultColoursArray removeAllObjects];
    
    for (UBKAccessibilityValidColour *validColour in colourArray)
    {
        UBKAccessibilityProperty *property = [[UBKAccessibilityProperty alloc]initWithTitle:validColour.title withColour:validColour.colour];
        [self.defaultColoursArray addObject:property];
    }
}

//Add a colour to the colours array
- (void)addDefaultColour:(UIColor *)colour withTitle:(NSString *)title
{
    for (UBKAccessibilityProperty *tmpProperty in self.defaultColoursArray)
    {
        if (tmpProperty.displayColour == colour)
        {
            return;
        }
    }
    UBKAccessibilityProperty *property = [[UBKAccessibilityProperty alloc]initWithTitle:title withColour:colour];
    [self.defaultColoursArray addObject:property];
}

//Remove colour from colour array
- (void)removeDefaultColour:(UBKAccessibilityProperty *)colourProperty
{
    [self.defaultColoursArray removeObject:colourProperty];
}

#pragma mark - Suggested colours

//Add suggested colour
- (void)addSuggestedColour:(UIColor *)colour withTitle:(NSString *)title
{
    for (UBKAccessibilityProperty *tmpProperty in self.suggestedColoursArray)
    {
        if (tmpProperty.displayColour == colour)
        {
            return;
        }
    }
    UBKAccessibilityProperty *property = [[UBKAccessibilityProperty alloc]initWithTitle:title withColour:colour];
    [self.suggestedColoursArray addObject:property];
}

//Remove single suggested colour
- (void)removeSuggestedColour:(UBKAccessibilityProperty *)colourProperty
{
    [self.suggestedColoursArray removeObject:colourProperty];
}

//Removes all suggested colours
- (void)removeAllSuggestedColours
{
    [self.suggestedColoursArray removeAllObjects];
}

@end
