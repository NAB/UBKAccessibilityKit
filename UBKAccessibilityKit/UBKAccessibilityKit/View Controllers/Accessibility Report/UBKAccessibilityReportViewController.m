/*
 File: UBKAccessibilityReportViewController.m
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

#import "UBKAccessibilityReportViewController.h"
#import "UBKReportUIElementCollectionViewCell.h"

@interface UBKAccessibilityReportViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) IBOutlet UILabel *viewControllerNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *appNameLabel;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,weak) IBOutlet UIImageView *viewControllerImageView;
@property (nonatomic) NSMutableArray *colourArray;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@end

@implementation UBKAccessibilityReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.scrollEnabled = false;
    [self.collectionView registerNib:[UINib nibWithNibName:@"UBKReportUIElementCollectionViewCell" bundle:[NSBundle bundleForClass:[self class]]] forCellWithReuseIdentifier:@"UBKReportUIElementCollectionViewCell"];
    self.collectionView.collectionViewLayout = self.flowLayout;
    
    self.viewControllerNameLabel.text = self.classString;
    self.appNameLabel.text = self.appNameString;
    
    self.viewControllerImageView.image = self.viewControllerImage;
    self.viewControllerImageView.layer.borderWidth = 1;
    self.viewControllerImageView.layer.borderColor = [UIColor blackColor].CGColor;
  
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)setElements:(NSArray *)elements
{
    _elements = elements;
    [self configureColours];
}

- (void)configureColours
{
    if (!self.colourArray)
    {
        self.colourArray = [[NSMutableArray alloc]init];
    }
    
    for (int x = 0; x < self.elements.count; x++)
    {
        NSInteger redValue = arc4random() % 255;
        NSInteger greenValue = arc4random() % 255;
        NSInteger blueValue = arc4random() % 255;

        UIColor *randomColour = [UIColor colorWithRed:redValue/255.0f green:greenValue/255.0f blue:blueValue/255.0f alpha:1.0f];
        if (randomColour)
        {
            [self.colourArray addObject:randomColour];
        } else {
            [self.colourArray addObject:[UIColor darkTextColor]];
        }
    }
}

- (void)setViewControllerImage:(UIImage *)viewControllerImage
{
    _viewControllerImage = viewControllerImage;
    self.viewControllerImageView.image = self.viewControllerImage;
}

#pragma mark - UICollectionViewDelegate

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UIView *viewTmp = [self.elements objectAtIndex:indexPath.row];
    UBKReportUIElementCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UBKReportUIElementCollectionViewCell" forIndexPath:indexPath];
    cell.index = indexPath.row + 1;
    cell.numberColour = [self.colourArray objectAtIndex:indexPath.row];
    cell.elementView = viewTmp;
    [cell setCellWidth:270];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.elements.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *viewTmp = [self.elements objectAtIndex:indexPath.row];
    UBKReportUIElementCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UBKReportUIElementCollectionViewCell" forIndexPath:indexPath];
    cell.elementView = viewTmp;
    [cell setCellWidth:270];
    CGFloat height = [cell getCellHeight:270];
    return CGSizeMake(270, height);
}

@end
