//
//  TKHomeMenuCustomEditCollectionView.h
//  TKApp
//
//  Created by 马鑫 on 2017/4/28.
//  Copyright © 2017年 liubao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKCustomDragCollectionView;

@protocol TKCustomDragCollectionViewDragDelegate <NSObject>

@optional
/**
 长按触发编辑状态
 */
- (void)dragCollectionViewBeginEditing:(TKCustomDragCollectionView *)collectionView;
/**
 是否允许item进行拖拽
 */
- (BOOL)dragCollectionView:(TKCustomDragCollectionView *)collectionView shouldTriggerGestureWithIndex:(NSIndexPath *)indexPath;

@required
- (void)dragCollectionView:(TKCustomDragCollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end

/**
 内部实现了长按编辑功能的collectionView
 */
@interface TKCustomDragCollectionView : UICollectionView

@property (nonatomic , assign) BOOL tk_editing;

@property (nonatomic , assign) BOOL longPressGestureEnabled;

@property (nonatomic , weak) id <TKCustomDragCollectionViewDragDelegate> tk_dragDelegate;


@end
