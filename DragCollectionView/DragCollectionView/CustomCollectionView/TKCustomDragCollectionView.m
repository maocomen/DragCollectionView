//
//  TKHomeMenuCustomEditCollectionView.m
//  TKApp
//
//  Created by 马鑫 on 2017/4/28.
//  Copyright © 2017年 liubao. All rights reserved.
//

#import "TKCustomDragCollectionView.h"

struct
{
    unsigned int moveItemFromTo : 1;
    unsigned int beginEditing   : 1;
    unsigned int shouldBeginWithIndexPath : 1;
}TKCustomDragCollectionViewDelegateFlags;


@interface TKCustomDragCollectionView ()

@property (nonatomic , assign)  CGFloat minimumPressDuration;
@property (nonatomic , weak)    UICollectionViewCell *tempCell;
@property (nonatomic , weak)    UIView *frontCell;

@property (nonatomic, strong)   NSIndexPath *originalIndexPath;
@property (nonatomic, strong)   NSIndexPath *moveIndexPath;

@property (nonatomic , assign)  CGPoint lastPoint;

@property (nonatomic , strong)  UILongPressGestureRecognizer *longPress;

@end

@implementation TKCustomDragCollectionView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self initializationMethod];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializationMethod];
    }
    return self;
}

- (void)initializationMethod
{
    [self addGestureMethod];
}

#pragma mark - Gesture Method


- (void)addGestureMethod
{
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    self.longPress.minimumPressDuration = self.minimumPressDuration;
    [self addGestureRecognizer:self.longPress];
}

- (void)longPressed:(UILongPressGestureRecognizer *)longPressGesture
{
    static BOOL state = NO;
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!self.tk_editing) {
                self.tk_editing = YES;
                [self triggerLongPressAndBeginEditing];
            }
            state = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.11 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self gestureBeginMethod:longPressGesture];
                state = NO;
            });
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if(state) return;
            [self gestureChangedMethod:longPressGesture];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            if(state) return;
            [self gestureEndedMethod:longPressGesture];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if(state) return;
            [self gestureEndedMethod:longPressGesture];
        }
            break;
            
        default:
            break;
    }
}

- (void)gestureBeginMethod:(UILongPressGestureRecognizer *)longPressGesture
{
    NSInteger touchCount = longPressGesture.numberOfTouches;
    if(touchCount == 0) return;
    
    self.originalIndexPath = [self indexPathForItemAtPoint:[longPressGesture locationOfTouch:0 inView:longPressGesture.view]];
    if (![self shouldResponderWithIndexPath:_originalIndexPath]) return ;
    
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    self.tempCell = cell;
    
    UIView *snapView = [cell snapshotViewAfterScreenUpdates:NO];
    self.frontCell = snapView;
    cell.hidden = YES;
    
    self.frontCell.frame = cell.frame;
    self.frontCell.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [self addSubview:self.frontCell];
    
    self.lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
}

- (void)gestureChangedMethod:(UILongPressGestureRecognizer *)longPressGesture
{
    if (![self shouldResponderWithIndexPath:_originalIndexPath]) return ;
    CGPoint tempPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    CGFloat tranX = tempPoint.x - _lastPoint.x;
    CGFloat tranY = tempPoint.y - _lastPoint.y;
    _frontCell.center = CGPointApplyAffineTransform(_frontCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = tempPoint;
    
    self.moveIndexPath = [self indexPathForItemAtPoint:tempPoint];
    if (![self shouldResponderWithIndexPath:_moveIndexPath]) return ;
    if (self.moveIndexPath && ![self.moveIndexPath isEqual:self.originalIndexPath])
    {
        [self exchangeItemFromIndexPath:self.originalIndexPath toIndexPath:self.moveIndexPath];
        self.originalIndexPath = self.moveIndexPath;
    }
}

- (void)gestureEndedMethod:(UILongPressGestureRecognizer *)longPressGesture
{
    NSArray *totalArray = [self findAllLastIndexPathInVisibleSection];
    
    CGRect rect;
    _moveIndexPath = nil;
    
    for (NSIndexPath *indexPath in totalArray) {
        UICollectionViewCell *sectionLastCell = [self cellForItemAtIndexPath:indexPath];
        CGRect tempRect = CGRectMake(CGRectGetMaxX(sectionLastCell.frame), CGRectGetMinY(sectionLastCell.frame), self.frame.size.width-CGRectGetMaxX(sectionLastCell.frame), CGRectGetHeight(sectionLastCell.frame));
        
        if (CGRectGetWidth(tempRect) < CGRectGetWidth(sectionLastCell.frame))
        {
            continue;
        }
        if (CGRectContainsPoint(tempRect, _frontCell.center)) {
            rect = tempRect;
            _moveIndexPath = indexPath;
            break;
        }
    }
    CGFloat defaultDuration = 0.f;
    if (_moveIndexPath) {
        defaultDuration = 0.1f;
        [self moveItemToIndexPath:_moveIndexPath];
    }
    else
    {
        _moveIndexPath = totalArray.lastObject;
        UICollectionViewCell *sectionLastCell = [self cellForItemAtIndexPath:_moveIndexPath];
        float spaceHeight =    (self.frame.size.height - CGRectGetMaxY(sectionLastCell.frame)) > CGRectGetHeight(sectionLastCell.frame)?
        (self.frame.size.height - CGRectGetMaxY(sectionLastCell.frame)):0;
        
        CGRect spaceRect = CGRectMake(0,
                                      CGRectGetMaxY(sectionLastCell.frame),
                                      self.frame.size.width,
                                      spaceHeight);
        
        if (spaceHeight != 0 && CGRectContainsPoint(spaceRect, _frontCell.center)) {
            defaultDuration = 0.1f;
            [self moveItemToIndexPath:_moveIndexPath];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(defaultDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _frontCell.center = self.tempCell.center;
        } completion:^(BOOL finished) {
            [_frontCell removeFromSuperview];
            self.tempCell.hidden = NO;
        }];
    });
}


#pragma mark - Private Method

- (NSArray *)findAllLastIndexPathInVisibleSection
{
    NSArray *array = [self indexPathsForVisibleItems];
    array = [array sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        if (obj1.section == obj2.section) {
            return obj1.item > obj2.item;
        }
        return obj1.section > obj2.section;
    }];
    
    NSIndexPath *tempIndexPath;
    NSMutableArray *totalArray = [NSMutableArray new];
    for (NSIndexPath *indexPath in array) {
        if (indexPath.section != tempIndexPath.section) {
            tempIndexPath ? [totalArray addObject:tempIndexPath] : nil;
        }
        tempIndexPath = indexPath;
    }
    [totalArray addObject:array.lastObject];
    return totalArray;
}

- (void)moveItemToIndexPath:(NSIndexPath *)indexPath
{
    if (_originalIndexPath.section == indexPath.section ){
        //同一分组
        if (_originalIndexPath.row == indexPath.row) return;
        if (_originalIndexPath.row != indexPath.row)
        {
            [self exchangeItemFromIndexPath:_originalIndexPath toIndexPath:indexPath];
        }
    }
}

#pragma mark - TKCustomDragCollectionViewDelegate

- (void)builtDragDelegateInitialize
{
    TKCustomDragCollectionViewDelegateFlags.moveItemFromTo = _tk_dragDelegate && [_tk_dragDelegate respondsToSelector:@selector(dragCollectionView:moveItemAtIndexPath:toIndexPath:)];
    TKCustomDragCollectionViewDelegateFlags.beginEditing = _tk_dragDelegate && [_tk_dragDelegate respondsToSelector:@selector(dragCollectionViewBeginEditing:)];
    TKCustomDragCollectionViewDelegateFlags.shouldBeginWithIndexPath = _tk_dragDelegate && [_tk_dragDelegate respondsToSelector:@selector(dragCollectionView:shouldTriggerGestureWithIndex:)];
}

- (void)triggerLongPressAndBeginEditing
{
    if (TKCustomDragCollectionViewDelegateFlags.beginEditing) {
        [self.tk_dragDelegate dragCollectionViewBeginEditing:self];
    }
}

- (void)exchangeItemFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (TKCustomDragCollectionViewDelegateFlags.moveItemFromTo) {
        [self.tk_dragDelegate dragCollectionView:self moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

- (BOOL)shouldResponderWithIndexPath:(NSIndexPath *)indexPath
{
    if (TKCustomDragCollectionViewDelegateFlags.shouldBeginWithIndexPath) {
        return [self.tk_dragDelegate dragCollectionView:self shouldTriggerGestureWithIndex:indexPath];
    }
    return YES;
}

#pragma mark - Setter and Getter

- (void)setTk_editing:(BOOL)tk_editing
{
    _tk_editing = tk_editing;
}

- (void)setLongPressGestureEnabled:(BOOL)longPressGestureEnabled
{
    _longPressGestureEnabled = longPressGestureEnabled;
    
    self.longPress.enabled = longPressGestureEnabled;
}

- (void)setTk_dragDelegate:(id<TKCustomDragCollectionViewDragDelegate>)tk_dragDelegate {
    _tk_dragDelegate = tk_dragDelegate;
    [self builtDragDelegateInitialize];
}

- (CGFloat)minimumPressDuration
{
    return .3f;
}

@end
