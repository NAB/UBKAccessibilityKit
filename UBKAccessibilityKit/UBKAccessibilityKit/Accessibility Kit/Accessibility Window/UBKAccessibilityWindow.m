/*
 File: UBKAccessibilityWindow.m
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

#import "UBKAccessibilityWindow.h"
#import "UBKAccessibilityButton.h"
#import "UBKAccessibilityManager.h"
#import "UBKAccessibilityInspectorViewController.h"
#import "UBKNavigationController.h"
#import "UBKAccessibilityInspectorContainerView.h"
#import "UBKAccessibilityTouchAnimations.h"
#import "UBKAccessibilityReportViewController.h"
#import "UBKAccessibilityFilter.h"
#import "UIView+HelperMethods.h"

@interface UBKAccessibilityWindow () <UIScreenshotServiceDelegate>
@property (nonatomic) BOOL passTouchToWindow;
@property (nonatomic) BOOL movingInspectorButton;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) NSTimer *warningTimer;
@property (nonatomic) UBKAccessibilityTouchAnimations *accessibilityTouchAnimations;
@property (nonatomic) NSString *currentViewName;
@end

@implementation UBKAccessibilityWindow

//The entry point into the class. becomeKeyWindow is called when the window has become the main(key) window.
- (void)becomeKeyWindow
{
    if (!self.enableInspector)
    {
        [super becomeKeyWindow];
        return;
    }
    
    [super becomeKeyWindow];
    [UBKAccessibilityManager sharedInstance].window = self;
    self.passTouchToWindow = FALSE;
    [self configureInspectorButton];
    [self changeInspectorStatus];
    [self configureAccessibilityTouchAnimations];
    [self configureScreenshotService];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"traitCollectionDidChange" object:previousTraitCollection];
}

//Configure inspector button appearance
- (void)configureInspectorButton
{
    if (!self.enableInspector)
    {
        return;
    }
    
    if (!self.inspectorButton)
    {
        self.inspectorButton = [[UBKAccessibilityButton alloc]initWithFrame:CGRectMake(40, self.frame.size.height/2-50, 50, 50)];
    }
    else
    {
        [self.inspectorButton removeFromSuperview];
    }
    self.inspectorButton.accessibilityLabel = @"Inspector";
    self.inspectorButton.accessibilityTraits |= UIAccessibilityTraitButton;
    [self updateInspectorButtonLocation:CGPointMake(40, self.frame.size.height/2-50)];
    [self addSubview:self.inspectorButton];
}

- (void)configureAccessibilityTouchAnimations
{
    self.accessibilityTouchAnimations = [[UBKAccessibilityTouchAnimations alloc]initWithView:self];
}

//Called when the button is pressed, this changes the status of the inspector
- (void)changeInspectorStatus
{
    //Check if inspector is enabled.
    if (!self.enableInspector)
    {
        return;
    }
    
    [UBKAccessibilityManager sharedInstance].allowNormalTouchEvents = ![UBKAccessibilityManager sharedInstance].allowNormalTouchEvents;
    
    if ([UBKAccessibilityManager sharedInstance].allowNormalTouchEvents)
    {
        self.inspectorButton.alpha = 0.5;
        [self startWarningTimer];
        
        //Force focus to the back button of the inspector
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Inspector view removed from screen");
        });
    }
    else
    {
        self.inspectorButton.alpha = 1.0;
        [self stopWarningTimer];
        
        //Force focus to the back button of the inspector after a small delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Inspector view, 50% of screen");
        });
    }
    self.inspectorButton.selected = FALSE;
}

//Moves the inspector button to a CGPoint location, validates point with validation.
- (void)updateInspectorButtonLocation:(CGPoint)point
{
    //Should look at adding hot corners and making the button pin to the sides of the view. At the moment it can be moved any where
    CGFloat gutter = 80;
    CGRect customFrame = CGRectMake(self.frame.origin.x + (gutter / 2), self.frame.origin.y + gutter, self.frame.size.width - gutter, self.frame.size.height - (gutter * 2));

    //Check left and right gutters
    if (point.x < customFrame.origin.x)
    {
        point.x = customFrame.origin.x;
    }
    else if (point.x > (customFrame.origin.x + customFrame.size.width))
    {
        point.x = customFrame.origin.x + customFrame.size.width;
    }
    
    //Check top and bottom gutters
    if (point.y < customFrame.origin.y)
    {
        point.y = customFrame.origin.y;
    }
    else if (point.y > (customFrame.origin.y + customFrame.size.height))
    {
        point.y = customFrame.origin.y + customFrame.size.height;
    }
    
    [self.inspectorButton setFrame:CGRectMake(point.x - 25, point.y - 25, 50, 50)];
}

//Called when a user touches any where within the UIWindow
- (void)sendEvent:(UIEvent *)event
{
    // Collect touches
    NSSet *touches = [event allTouches];
    
    if ([UBKAccessibilityManager sharedInstance].isShowingTouchAnimations)
    {
        [self.accessibilityTouchAnimations touchDidHappen:touches withEvent:event];
    }
    
    //Check if a UIAlertController is on screen when the user touches the alert. If so the inspector is dismissed.
    if ([self.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]])
    {
        [[UBKAccessibilityManager sharedInstance]hideInspector];
    }

    //If enableInspector is false, return as inspector has been turned off.
    //If a UIAlertController is onscreen when the user touches the screen, pass the touch through to the view so it can be dismissed.
    if ((!self.enableInspector) || ([UBKAccessibilityManager sharedInstance].alertOnScreenAllowTouchEvents) || [self.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]])
    {
        [super sendEvent:event];
        return;
    }
    
    NSMutableSet *began = nil;
    NSMutableSet *moved = nil;
    NSMutableSet *ended = nil;
    NSMutableSet *cancelled = nil;
    
    
    // Sort the touches by phase for event dispatch
    for (UITouch *touch in touches)
    {
        switch ([touch phase])
        {
            case UITouchPhaseBegan:
            {
                if (!began)
                {
                    began = [NSMutableSet set];
                }
                [began addObject:touch];
                
                //Save this to compare if the user has dragged on screen.
                self.startPoint = [touch locationInView:self];
                
                //Has touched within the inspector button so we must be moving it or we have tapped it.
                if ([self checkTouchPoint:touch withInView:self.inspectorButton])
                {
                    //Touched the button, we don't know if it was a tap or a drag.
                    self.movingInspectorButton = TRUE;
                }
                else if ([self checkTouchPoint:touch inCollection:[UBKAccessibilityManager sharedInstance].accessibilityViews])
                {
                    //Touched within the inspector container view
                    self.passTouchToWindow = TRUE;
                }
                else
                {
                    //Touched UI Element in the window.
                    self.passTouchToWindow = FALSE;
                }
                break;
            }
            case UITouchPhaseMoved:
            {
                if (!moved)
                {
                    moved = [NSMutableSet set];
                }
                [moved addObject:touch];
                
                //Did we start our touch within the inspector button?
                if (self.movingInspectorButton == TRUE)
                {
                    //Find the touch point in the view
                    CGPoint movePoint = [touch locationInView:self];
                    
                    //To prevent jaggered movements, only move the inspector button if the difference between the startPoint and endPoint when dragging is 5 or more.
                    if ([self hasMovedUIElement:self.startPoint endTouchPoint:movePoint withTolerance:5])
                    {
                        //Move the inspector button to the movePoint
                        [self updateInspectorButtonLocation:CGPointMake(movePoint.x, movePoint.y)];
                    }
                }
                break;
            }
            case UITouchPhaseEnded:
            {
                if (!ended)
                {
                    ended = [NSMutableSet set];
                }
                [ended addObject:touch];
                
                //Check if the touch point is within the inspector button
                if ([self checkTouchPoint:touch withInView:self.inspectorButton])
                {
                    //Find the touch point in the view
                    CGPoint endPoint = [touch locationInView:self];
                    
                    //Check if the difference between the startPoint and the endPoint is greater than 20. If it is then the button was tapped. If it has moved, pass the touch to the window.
                    if ([self hasMovedUIElement:self.startPoint endTouchPoint:endPoint withTolerance:20])
                    {
                        //Inspector button was moved
                        self.passTouchToWindow = TRUE;
                    }
                    else if (self.movingInspectorButton)
                    {
                        //Inspector button was tapped
                        self.inspectorButton.accessibilityLabel = nil;
                        [self changeInspectorStatus];
                        self.passTouchToWindow = FALSE;
                    }
                    
                    //No longer moving the button
                    self.movingInspectorButton = FALSE;
                }
                break;
            }
            case UITouchPhaseCancelled:
            {
                if (!cancelled)
                {
                    cancelled = [NSMutableSet set];
                }
                [cancelled addObject:touch];
                //No longer moving the button
                self.movingInspectorButton = FALSE;
                break;
            }
            default:
            {
                break;
            }
        }
    }
    
    // Call normal handler for default responder chain
    if (([UBKAccessibilityManager sharedInstance].allowNormalTouchEvents) || (self.passTouchToWindow == TRUE))
    {
        //Has touched within the inspector container view or allow normal (inspector turned off) touches on window.
        [super sendEvent:event];
    }
    else
    {
        //Touch is not within the inspector container view.
        //Is touch within the inspecton button.
        if (![self checkTouchPoint:touches.allObjects.lastObject withInView:self.inspectorButton])
        {
            // Create pseudo-event dispatch
            if (began)
            {
                [[UBKAccessibilityManager sharedInstance] touchesBegan:began withEvent:event];
            }
            
            if (moved)
            {
                [[UBKAccessibilityManager sharedInstance] touchesMoved:moved withEvent:event];
            }
            
            if (ended)
            {
                [[UBKAccessibilityManager sharedInstance] touchesEnded:ended withEvent:event];
            }
            
            if (cancelled)
            {
                [[UBKAccessibilityManager sharedInstance] touchesCancelled:cancelled withEvent:event];
            }
        }
        else if (self.movingInspectorButton == false)
        {
            //Inspector buton was disabled and is now being moved so show the elements views.
            [[UBKAccessibilityManager sharedInstance]showInspector:true];
        }
    }
}

#pragma mark - Touch validation methods

//Check if the touch point is within the view plus a buffer around the view.
- (BOOL)checkTouchPoint:(UITouch *)touch withInView:(UIView *)view
{
    //Check if the touch point is within the bounds of the inspector button
    CGFloat buffer = 10;
    CGRect buttonRectTmp = CGRectMake(view.frame.origin.x - buffer, view.frame.origin.y - buffer, view.frame.size.width + buffer + buffer, view.frame.size.height + buffer + buffer);
    CGPoint pointTmp = [touch locationInView:view.superview];
    if (CGRectContainsPoint(buttonRectTmp, pointTmp))
    {
        return true;
    }
    return false;
}

- (BOOL)checkTouchPoint:(UITouch *)touch inCollection:(NSSet *)collection
{
    BOOL touched = false;
    for (UIView *view in collection)
    {
        if ([self checkTouchPoint:touch withInView:view])
        {
            return true;
        }
    }
    return touched;
}

//Check if the user has moved a UI element, check difference between startTouch and endTouch.
- (BOOL)hasMovedUIElement:(CGPoint)startTouch endTouchPoint:(CGPoint)endTouch withTolerance:(CGFloat)tolerance
{
    CGFloat xDifference = fabs(startTouch.x - endTouch.x);
    CGFloat yDifference = fabs(startTouch.y - endTouch.y);
    if ((xDifference >= tolerance) || (yDifference >= tolerance))
    {
        return true;
    }
    return false;
}

#pragma mark - Accessibility Validation Warning Timer

//Setup the warning timer
- (void)startWarningTimer
{
    if (self.warningTimer)
    {
        [self.warningTimer invalidate];
    }
    self.warningTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(warningChecker:) userInfo:nil repeats:true];
}

- (void)stopWarningTimer
{
    [self.warningTimer invalidate];
}

//Update the inspector button with the appropriate accessibility label and hint. Send a delayed voice over announcement notification.
- (void)warningChecker:(id)sender
{
    switch ([[UBKAccessibilityManager sharedInstance]showWarningLevelForView])
    {
        case UBKAccessibilityWarningLevelHigh:
        {
            [self.inspectorButton showWarningBadgeWithWarning:UBKAccessibilityWarningLevelHigh];
            self.inspectorButton.accessibilityHint = @"User interface elements with high warnings visible";
            [self delayedAnnounceWarningsFound:@"User interface elements with high warnings visible"];
            break;
        }
        case UBKAccessibilityWarningLevelMedium:
        {
            [self.inspectorButton showWarningBadgeWithWarning:UBKAccessibilityWarningLevelMedium];
            self.inspectorButton.accessibilityHint = @"User interface elements with medium warnings visible";
            [self delayedAnnounceWarningsFound:@"User interface elements with medium warnings visible"];
            break;
        }
        default:
        {
            [self.inspectorButton hideWarningBadge];
            self.inspectorButton.accessibilityHint = @"";
            break;
        }
    }
}

- (void)delayedAnnounceWarningsFound:(NSString *)message
{
    if (message)
    {
        if (![self.currentViewName isEqualToString:message])
        {
            self.currentViewName = message;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
            });
        }
    }
}

#pragma mark - Pre Xcode 11. Add this commented code back in

//Configures the screenshot service, screenshot service is only available in iOS 13+ and provides an Accessibility Report when a screenshot is taken.
- (void)configureScreenshotService
{
    if (@available(iOS 13.0, *))
    {
        self.windowScene.screenshotService.delegate = self;
    }
    else
    {
        // Fallback on earlier versions
    }
}

//#pragma mark - UIScreenshotServiceDelegate

- (void)screenshotService:(UIScreenshotService *)screenshotService generatePDFRepresentationWithCompletion:(nonnull void (^)(NSData * _Nullable, NSInteger, CGRect))completionHandler API_AVAILABLE(ios(13.0))
{
    UBKAccessibilityWindow *window = (UBKAccessibilityWindow *)self;
    UIImage *viewControllerImage = [window.rootViewController.view ubk_createImage];
    NSString *viewControllerString = NSStringFromClass(window.rootViewController.class);
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController *)window.rootViewController;
        NSString *navigationChildClassName = NSStringFromClass(navController.childViewControllers.firstObject.class);
        viewControllerString = [NSString stringWithFormat:@"%@/%@", viewControllerString, navigationChildClassName];
    }
    
    NSString *appNameString = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleName"];
    NSString *appVersionString = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    NSString *appBundleVersionString = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
    NSString *appName = [NSString stringWithFormat:@"%@ - %@ (%@)", appNameString, appVersionString, appBundleVersionString];
    
    NSArray *elements = [UBKAccessibilityManager sharedInstance].accessibilityFilter.filteredObjects;
    
    UBKAccessibilityReportViewController *viewController = [[UBKAccessibilityReportViewController alloc]initWithNibName:@"UBKAccessibilityReportViewController" bundle:[NSBundle bundleForClass:self.class]];
    viewController.classString = viewControllerString;
    viewController.appNameString = appName;
    viewController.viewControllerImage = viewControllerImage;
    viewController.elements = elements;
    [viewController.view setNeedsLayout];
    [viewController.view layoutIfNeeded];
    UIView *tmpView = viewController.view;
    NSData *data = [self createPDFfromUIView:tmpView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        completionHandler(data, 0, CGRectZero);
    });
}

- (NSData *)createPDFfromUIView:(UIView *)view
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    [view.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

@end
