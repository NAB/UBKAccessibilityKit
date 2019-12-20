/*
 File: UBKAccessibilityInspectorContainerView.m
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

#import "UBKAccessibilityInspectorContainerView.h"
#import "UBKNavigationController.h"
#import "UBKContainerDragButton.h"
#import "UBKAccessibilityInspectorGutterContainerView.h"

const CGFloat minimumInspectorHeight = 280;
typedef void (^AnimationCompletionBlock)(void);

@interface UBKAccessibilityInspectorContainerView () <UBKContainerDragButtonDelegate, UBKAccessibilityInspectorGutterViewDelegate, UITraitEnvironment>
@property (nonatomic, weak) UBKNavigationController *navigationViewController;
@property (nonatomic) UBKContainerDragButton *containerDragButton;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic) CGFloat bottomSpace;

@property (nonatomic) GutterPosition currentGutterPosition;
@property (nonatomic) NSLayoutConstraint *customCenterXAnchor;
@property (nonatomic) NSLayoutConstraint *customCenterYAnchor;
@property (nonatomic) NSLayoutConstraint *customTopAnchor;
@property (nonatomic) NSLayoutConstraint *customLeftAnchor;
@property (nonatomic) NSLayoutConstraint *customRightAnchor;
@property (nonatomic) NSLayoutConstraint *customBottomAnchor;
@property (nonatomic) NSLayoutConstraint *customHeightAnchor;
@property (nonatomic) NSLayoutConstraint *customWidthAnchor;
@property (nonatomic) NSLayoutConstraint *maxHeightAnchor;
@property (nonatomic) NSLayoutConstraint *maxWidthAnchor;
@end

@implementation UBKAccessibilityInspectorContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        //Add shadow to the view
        [self.layer setShadowOffset:CGSizeMake(0, 0)];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        [self.layer setShadowOpacity:0.5];
        [self.layer setShadowRadius:2.0];
        self.backgroundColor = [UIColor clearColor]; //[UIColor colorWithWhite:0.97 alpha:0.8];
        
        self.originalWidth = frame.size.width;
        self.originalHeight = frame.size.height;
        
        [self configureAppearance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(traitDidChange:) name:@"traitCollectionDidChange" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNavigationViewController:(UBKNavigationController *)navigationViewController
{
    self.navigationViewController = navigationViewController;
    UIView *viewTmp = [[UIView alloc]initWithFrame:self.frame];
    viewTmp.layer.cornerRadius = 10;
    viewTmp.clipsToBounds = true;
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight)
        {
            viewTmp.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000];
        }
        else
        {
            // Available with iOS13
            // viewTmp.backgroundColor = [UIColor systemBackgroundColor];
            viewTmp.backgroundColor = [UIColor blackColor];
        }
    }
    else
    {
        // Fallback on earlier versions
        viewTmp.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000];
    }
    viewTmp.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:viewTmp];
    
    [viewTmp.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = true;
    [viewTmp.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = true;
    [viewTmp.topAnchor constraintEqualToAnchor:self.topAnchor].active = true;
    [viewTmp.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = true;
    
    [viewTmp addSubview:navigationViewController.view];

    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 6)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.translatesAutoresizingMaskIntoConstraints = false;
    lineView.layer.cornerRadius = 3;
    lineView.clipsToBounds = true;
    [viewTmp addSubview:lineView];
    
    [lineView.topAnchor constraintEqualToAnchor:viewTmp.topAnchor constant:10].active = true;
    [lineView.heightAnchor constraintEqualToConstant:6].active = true;
    [lineView.widthAnchor constraintEqualToConstant:40].active = true;
    [lineView.centerXAnchor constraintEqualToAnchor:viewTmp.centerXAnchor].active = true;
    
    //Add the navigation controller to the container. Move it down enough space to allow for the corner radius and dragging button.
    navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false;
    [navigationViewController.view.leftAnchor constraintEqualToAnchor:viewTmp.leftAnchor].active = true;
    [navigationViewController.view.rightAnchor constraintEqualToAnchor:viewTmp.rightAnchor].active = true;
    [navigationViewController.view.topAnchor constraintEqualToAnchor:lineView.bottomAnchor constant:-5].active = true;
    if (@available(iOS 11.0, *)) {
        [navigationViewController.view.bottomAnchor constraintEqualToAnchor:viewTmp.safeAreaLayoutGuide.bottomAnchor constant:0].active = true;
    } else {
        // Fallback on earlier versions
        [navigationViewController.view.bottomAnchor constraintEqualToAnchor:viewTmp.bottomAnchor constant:0].active = true;
    }
    
    //This button is used to move the inspector around.
    self.containerDragButton = [[UBKContainerDragButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.containerDragButton.isAccessibilityElement = true;
    self.containerDragButton.accessibilityLabel = @"Change inspector height";
    self.containerDragButton.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0];
    self.containerDragButton.translatesAutoresizingMaskIntoConstraints = false;
    self.containerDragButton.accessibilityTraits = UIAccessibilityTraitAdjustable;
    self.containerDragButton.userInteractionEnabled = false;
    self.containerDragButton.delegate = self;
    [self addSubview:self.containerDragButton];
    
    [self.containerDragButton.centerXAnchor constraintEqualToAnchor:lineView.centerXAnchor].active = true;
    [self.containerDragButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:0].active = true;
    [self.containerDragButton.heightAnchor constraintEqualToConstant:30].active = true;
    [self.containerDragButton.widthAnchor constraintEqualToConstant:120].active = true;
    
    //Allow the user to move the inspector taller or smaller
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureMethod:)];
    self.panGesture.cancelsTouchesInView = false;
    [self addGestureRecognizer:self.panGesture];
    
    //Allow the user to move the inspector
    self.longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureMethod:)];
    self.longPressGesture.cancelsTouchesInView = false;
    [self addGestureRecognizer:self.longPressGesture];
    
    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [[UIImage imageNamed:@"icon_cross" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.hideButton setImage:closeImage forState:UIControlStateNormal];
    [self.hideButton setTintColor:[UIColor lightGrayColor]];
    [self.hideButton addTarget:self action:@selector(hideInspector) forControlEvents:UIControlEventTouchUpInside];
    self.hideButton.accessibilityLabel = @"Hide inspector";
    self.hideButton.translatesAutoresizingMaskIntoConstraints = false;
    self.hideButton.adjustsImageWhenHighlighted = true;
    [self addSubview:self.hideButton];
    
    [self.hideButton.widthAnchor constraintEqualToConstant:44].active = true;
    [self.hideButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = true;
    [self.hideButton.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-5].active = true;
    [self.hideButton.bottomAnchor constraintEqualToAnchor:navigationViewController.navigationBar.bottomAnchor constant:-5].active = true;
    
    self.isMovingInspector = false;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self didDropInspectorInGutter:GutterPositionBottom];
    [self hideInspectorViewAnimated:false];
}

//This moves the inspector container around when the user drags on the line view of the inspector
- (void)panGestureMethod:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.superview];
    CGFloat height = self.superview.frame.size.height - touchPoint.y;
    [self animateToHeight:height withBounce:true];
}

//When the user long presses on the inspector line it will get smaller so it can be moved around.
- (void)longPressGestureMethod:(UITapGestureRecognizer *)gestureRecognizer
{
    self.isMovingInspector = true;
    
    if (!self.gutterView)
    {
        self.gutterView = [[UBKAccessibilityInspectorGutterContainerView alloc]init];
        self.gutterView.delegate = self;
        [self.superview insertSubview:self.gutterView belowSubview:self];
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.superview];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //Reset the inspector view.
        self.alpha = 1.0;
        [self.gutterView hideAllGutterViews];
        [self.gutterView checkInspectorDropTouchPoint:touchPoint];
    }
    else
    {
        [self setFrame:CGRectMake(touchPoint.x - (self.customWidthAnchor.constant/2), touchPoint.y, self.customWidthAnchor.constant, self.customHeightAnchor.constant)];
        self.alpha = 0.7;        
        [self.gutterView initalizeGutterViews];
        [self.gutterView highlightGutterUnderTouchPoint:touchPoint];
    }
}

//Animate the view to a location either with or without bounce.
- (void)animateToHeight:(CGFloat)height withBounce:(BOOL)shouldBounce
{
    if (self.currentGutterPosition != GutterPositionTop)
    {
        CGFloat topBuffer = 40;
        if (height < (minimumInspectorHeight - 20))
        {
            //Not showing the inspector, update the flag.
            self.navigationViewController.isShowingInspector = false;
            self.customHeightAnchor.constant = minimumInspectorHeight;
            [self hideInspectorViewAnimated:true];
            return;
        }
        else if (height > (self.superview.frame.size.height - topBuffer))
        {
            //Inspector is within the top buffer distance, move it back to a responsible size.
            self.navigationViewController.isShowingInspector = true;
            height = self.superview.frame.size.height - topBuffer;
        }
        
        if ((self.currentGutterPosition == GutterPositionLeft) || (self.currentGutterPosition == GutterPositionRight))
        {
            
            if (self.panGesture.state == UIGestureRecognizerStateBegan)
            {
                self.bottomSpace = (self.superview.frame.size.height - self.frame.size.height)/2;
                self.customBottomAnchor.constant = -self.bottomSpace;
                self.customBottomAnchor.active = true;
                
                if ((self.currentGutterPosition == GutterPositionLeft) || (self.currentGutterPosition == GutterPositionRight))
                {
                    self.customCenterYAnchor.active = false;
                }
            }
            else if (self.panGesture.state == UIGestureRecognizerStateEnded)
            {
                self.customBottomAnchor.active = false;
                self.customCenterYAnchor.active = true;
                [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:shouldBounce?0.5:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.superview layoutIfNeeded];
                } completion:nil];
                self.bottomSpace = 0;
                return;
            }
            height = height - self.bottomSpace;
            
            if (height < (minimumInspectorHeight - 20))
            {
                //Not showing the inspector, update the flag.
                self.navigationViewController.isShowingInspector = false;
                self.customHeightAnchor.constant = minimumInspectorHeight;
                return; 
            }
        }
        else if (self.currentGutterPosition == GutterPositionBottom)
        {
            self.bottomSpace = 0;
            self.customCenterYAnchor.active = false;
            self.customBottomAnchor.constant = 0;
        }
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:shouldBounce?0.5:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.customHeightAnchor.constant = height;
            [self.superview layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Inspector height %0.0f%% of screen", (height/self.superview.frame.size.height)*100]);
        }];
    }
}

- (void)showInspectorView
{
    [self.superview layoutIfNeeded];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         switch (self.currentGutterPosition) {
                             case GutterPositionTop:
                             {
                                 self.customTopAnchor.constant = 40;
                                 break;
                             }
                             case GutterPositionLeft:
                             {
                                 self.customLeftAnchor.constant = 0;
                                 break;
                             }
                             case GutterPositionRight:
                             {
                                 self.customRightAnchor.constant = 0;
                                 break;
                             }
                             case GutterPositionBottom:
                             case GutterPositionNone:
                             {
                                 self.customBottomAnchor.constant = 0;
                                 break;
                             }
                             default:
                             {
                                 break;
                             }
                         }
                         [self.superview layoutIfNeeded];
                     }];
    
    //Force focus to the back button
//    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self);
}

- (void)hideInspector
{
    [self hideInspectorViewAnimated:true];
}

- (void)hideInspectorViewAnimated:(BOOL)animated
{
    AnimationCompletionBlock completion = ^(void){
        switch (self.currentGutterPosition) {
            case GutterPositionTop:
            {
                self.customTopAnchor.constant = -self.frame.size.height;
                break;
            }
            case GutterPositionLeft:
            {
                self.customLeftAnchor.constant = -self.frame.size.width;
                break;
            }
            case GutterPositionRight:
            {
                self.customRightAnchor.constant = self.frame.size.width;
                break;
            }
            case GutterPositionBottom:
            case GutterPositionNone:
            {
                self.customBottomAnchor.constant = self.frame.size.height;
                break;
            }
            default:
            {
                break;
            }
        }
        
        [self.superview layoutIfNeeded];
    };
    
    [self.superview layoutIfNeeded];
    if (animated)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             completion();
                         }];
    }
    else
    {
        completion();
    }
   
}

- (void)traitDidChange:(NSNotification *)notification
{
    switch (self.traitCollection.verticalSizeClass)
    {
        case UIUserInterfaceSizeClassRegular:
        {
            //Check the height of the inspector
            if (self.customHeightAnchor.constant > self.superview.frame.size.height)
            {
                [self animateToHeight:self.superview.frame.size.height-40 withBounce:true];
            }
            break;
        }
        default:
        {
            break;
        }
    }
 }

#pragma mark - Appearance

- (void)configureAppearance
{
    //UIBarButtonItem appearance setup, prevents the users app overriding the appearance for ui elements inside the framework.
    NSNumber *kern = [NSNumber numberWithFloat:0.0];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *defaultAttributes = @{NSForegroundColorAttributeName:[self defaultSystemTintColor], NSFontAttributeName: font, NSKernAttributeName: kern};
    NSDictionary *highlightAttributes = @{NSForegroundColorAttributeName:[self defaultSystemTintColor], NSFontAttributeName: font, NSKernAttributeName: kern};
    NSDictionary *disabledAttributes = @{NSForegroundColorAttributeName:[self defaultSystemTintColor], NSFontAttributeName: font, NSKernAttributeName: kern};
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[UBKNavigationController.class]] setTitleTextAttributes:defaultAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[UBKNavigationController.class]] setTitleTextAttributes:highlightAttributes forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[UBKNavigationController.class]] setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];    
}

- (UIColor *)defaultSystemTintColor
{
    static UIColor* systemTintColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView* view = [[UIView alloc] init];
        systemTintColor = view.tintColor;
    });
    return systemTintColor;
}

#pragma mark - UBKAccessibilityInspectorGutterViewDelegate

- (void)didDropInspectorInGutter:(GutterPosition)gutterPosition
{
    self.translatesAutoresizingMaskIntoConstraints = false;
    self.currentGutterPosition = gutterPosition;
    
    //Add constraints if not setup
    if (!self.customTopAnchor) {
        self.customTopAnchor = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:40];
        self.customLeftAnchor = [self.leftAnchor constraintEqualToAnchor:self.superview.leftAnchor];
        self.customRightAnchor = [self.rightAnchor constraintEqualToAnchor:self.superview.rightAnchor];
        self.customBottomAnchor = [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor];
        self.customCenterXAnchor = [self.centerXAnchor constraintEqualToAnchor:self.superview.centerXAnchor];
        self.customCenterYAnchor = [self.centerYAnchor constraintEqualToAnchor:self.superview.centerYAnchor];
        self.customHeightAnchor = [self.heightAnchor constraintEqualToConstant:self.originalHeight];
        self.customHeightAnchor.priority = UILayoutPriorityDefaultHigh;
        self.customWidthAnchor = [self.widthAnchor constraintEqualToConstant:self.originalWidth];
        self.customWidthAnchor.priority = UILayoutPriorityDefaultHigh;
        
        //Make sure the bounds do not extend greater than the window
        self.maxHeightAnchor = [self.heightAnchor constraintLessThanOrEqualToAnchor:self.superview.heightAnchor constant:-40];
        self.maxHeightAnchor.active = true;
        
        self.maxWidthAnchor = [self.widthAnchor constraintLessThanOrEqualToAnchor:self.superview.widthAnchor constant:-10];
        self.maxWidthAnchor.active = true;
    }

    self.customHeightAnchor.active = true;
    self.customWidthAnchor.active = true;

    //Reset all the anchors
    self.customTopAnchor.active = false;
    self.customLeftAnchor.active = false;
    self.customRightAnchor.active = false;
    self.customBottomAnchor.active = false;
    self.customCenterYAnchor.active = false;
    self.customCenterXAnchor.active = false;
    
    switch (gutterPosition)
    {
        case GutterPositionTop:
        {
            self.customTopAnchor.active = true;
            self.customCenterXAnchor.active = true;
            break;
        }
        case GutterPositionLeft:
        {
            self.customLeftAnchor.active = true;
            self.customCenterYAnchor.active = true;
            break;
        }
        case GutterPositionRight:
        {
            self.customRightAnchor.active = true;
            self.customCenterYAnchor.active = true;
            break;
        }
        case GutterPositionBottom:
        case GutterPositionNone:
        {
            self.customBottomAnchor.constant = 0;
            self.customBottomAnchor.active = true;
            self.customCenterXAnchor.active = true;
            break;
        }
    }
    
    [self.superview setNeedsLayout];

    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.superview layoutIfNeeded];
                     }];
}

#pragma mark - UBKContainerDragButtonDelegate

//Used with VoiceOver to change the height of the inspector view
- (void)moveContainerUp
{
    NSInteger bounceDistance = 20;
    CGFloat yPoint = self.frame.origin.y + bounceDistance - 100;
    CGFloat height = self.superview.frame.size.height - yPoint;
    [self animateToHeight:height withBounce:true];
}

//Used with VoiceOver to change the height of the inspector view
- (void)moveContainerDown
{
    NSInteger bounceDistance = 20;
    CGFloat yPoint = self.frame.origin.y + bounceDistance + 100;
    CGFloat height = self.superview.frame.size.height - yPoint;
    [self animateToHeight:height withBounce:true];
}

- (BOOL)shouldGroupAccessibilityChildren
{
    return true;
}

@end
