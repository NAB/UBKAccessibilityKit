/*
 File: DemoViewController.m
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

#import "DemoViewController.h"
#import "DemoDetailViewController.h"

@interface DemoViewController ()
@property (nonatomic) IBOutlet UIImageView *imageViewOne;
@property (nonatomic) IBOutlet UIImageView *imageViewTwo;
@property (nonatomic) IBOutlet UIImageView *imageViewThree;
@property (nonatomic) IBOutlet UIImageView *imageViewFour;

@property (nonatomic) IBOutlet UILabel *labelOne;
@property (nonatomic) IBOutlet UILabel *labelTwo;
@property (nonatomic) IBOutlet UILabel *labelThree;
@property (nonatomic) IBOutlet UILabel *labelFour;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.labelOne.text = @"Black and white jetty";
    self.labelTwo.text = @"High contrast jetty";
    self.labelThree.text = @"Dusk jetty";
    self.labelFour.text = @"Sunset jetty";
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    DemoDetailViewController *viewController = segue.destinationViewController;
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 1:
        {
            viewController.detailText = self.labelOne.text;
            viewController.detailImage = self.imageViewOne.image;
            break;
        }
        case 2:
        {
            viewController.detailText = self.labelTwo.text;
            viewController.detailImage = self.imageViewTwo.image;
            break;
        }
        case 3:
        {
            viewController.detailText = self.labelThree.text;
            viewController.detailImage = self.imageViewThree.image;
            break;
        }
        case 4:
        {
            viewController.detailText = self.labelFour.text;
            viewController.detailImage = self.imageViewFour.image;
            break;
        }
        default:
        {
            break;
        }
    }
}

- (IBAction)showDetailView:(id)sender
{
    [self performSegueWithIdentifier:@"showDetails" sender:sender];
}

@end
