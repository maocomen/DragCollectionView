//
//  CustomCollectionViewCell.m
//  DragCollectionView
//
//  Created by 马鑫 on 2017/5/22.
//  Copyright © 2017年 马鑫. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeMethod];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeMethod];
    }
    return self;
}

- (void)initializeMethod
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSelectState) name:kCustomEnterEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDefaultState) name:kCustomEndEditingNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method

- (void)setDefaultState
{
    self.backgroundColor = [UIColor orangeColor];
}

- (void)setSelectState
{
    self.backgroundColor = [UIColor purpleColor];
}

@end
