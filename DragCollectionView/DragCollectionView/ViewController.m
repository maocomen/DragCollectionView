//
//  ViewController.m
//  DragCollectionView
//
//  Created by 马鑫 on 2017/5/22.
//  Copyright © 2017年 马鑫. All rights reserved.
//

#import "ViewController.h"
#import "TKCustomDragCollectionView.h"
#import "CustomCollectionHeadView.h"
#import "CustomCollectionViewCell.h"

@interface ViewController ()<UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , TKCustomDragCollectionViewDragDelegate>
@property (weak, nonatomic) IBOutlet TKCustomDragCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@property (nonatomic , strong) NSMutableArray *customDataSources;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self builtDataSources];
    self.collectionView.tk_dragDelegate = self;
    [self.collectionView registerClass:[CustomCollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (IBAction)editAction:(UIBarButtonItem *)sender
{
    static BOOL editState = NO;
    editState = !editState;
    if (editState) {
        self.collectionView.tk_editing = YES;
        sender.title = @"完成";
        [[NSNotificationCenter defaultCenter] postNotificationName:kCustomEnterEditingNotification object:nil];
    }
    else
    {
        self.collectionView.tk_editing = NO;
        sender.title = @"编辑";
        [[NSNotificationCenter defaultCenter] postNotificationName:kCustomEndEditingNotification object:nil];
    }
}


#pragma mark - CollectionView Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.customDataSources.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.customDataSources[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    TKCustomDragCollectionView *dragCollectionView = (TKCustomDragCollectionView *)collectionView;
    dragCollectionView.tk_editing ? [cell setSelectState] : [cell setDefaultState];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head" forIndexPath:indexPath];
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width, 30);
}

#pragma mark - TKCustomDragCollectionViewDragDelegate

- (void)dragCollectionViewBeginEditing:(TKCustomDragCollectionView *)collectionView
{
    [self editAction:self.rightBarButtonItem];
}

- (BOOL)dragCollectionView:(TKCustomDragCollectionView *)collectionView shouldTriggerGestureWithIndex:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (void)dragCollectionView:(TKCustomDragCollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self reloadDataSourcesWithSourceIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    [collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

#pragma mark - dataSource 

- (void)builtDataSources
{
    self.customDataSources = [NSMutableArray new];
    for (int i=0; i<3; i++) {
        NSMutableArray *array = [NSMutableArray new];
        for (int j=0; j<10; j++)
        {
            [array addObject:@"1"];
        }
        [self.customDataSources addObject:array];
    }
}

- (void)reloadDataSourcesWithSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.section == destinationIndexPath.section) {
        NSMutableArray *array = [self.customDataSources objectAtIndex:sourceIndexPath.section];
        id obj = [array objectAtIndex:sourceIndexPath.row];
        [array removeObjectAtIndex:sourceIndexPath.row];
        [array insertObject:obj atIndex:destinationIndexPath.row];
    }
    else
    {
        NSMutableArray *sourceArray = [self.customDataSources objectAtIndex:sourceIndexPath.section];
        NSMutableArray *destinationArray = [self.customDataSources objectAtIndex:destinationIndexPath.section];
        
        id obj = [sourceArray objectAtIndex:sourceIndexPath.row];
        [sourceArray removeObjectAtIndex:sourceIndexPath.row];
        
        [destinationArray insertObject:obj atIndex:destinationIndexPath.row];
    }
}
@end
