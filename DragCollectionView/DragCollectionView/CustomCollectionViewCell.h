//
//  CustomCollectionViewCell.h
//  DragCollectionView
//
//  Created by 马鑫 on 2017/5/22.
//  Copyright © 2017年 马鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kCustomEnterEditingNotification = @"kCustomEnterEditingNotification";
static NSString * const kCustomEndEditingNotification = @"kCustomEndEditingNotification";

@interface CustomCollectionViewCell : UICollectionViewCell

- (void)setDefaultState;

- (void)setSelectState;

@end
