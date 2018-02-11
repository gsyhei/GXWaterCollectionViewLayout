//
//  GXWaterCollectionViewLayout.m
//  GXUICollectionView
//
//  Created by GuoShengyong on 2017/12/11.
//  Copyright © 2017年 protruly. All rights reserved.
//

#import "GXWaterCollectionViewLayout.h"

@interface GXWaterCollectionViewLayout()

@property (strong, nonatomic) NSMutableDictionary *cellLayoutInfo;//保存cell的布局
@property (strong, nonatomic) NSMutableDictionary *headLayoutInfo;//保存头视图的布局
@property (strong, nonatomic) NSMutableDictionary *footLayoutInfo;//保存尾视图的布局

@property (strong, nonatomic) NSMutableDictionary *maxScrollDirPositionForColumn;//记录瀑布流每列滚动方向最后那个cell的底部的值
@property (strong, nonatomic) NSMutableArray *shouldanimationArr;//记录需要添加动画的NSIndexPath
@property (assign, nonatomic) CGFloat startScrollDirPosition;//记录滚动方向开始点

@end

@implementation GXWaterCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfColumns = 3;
        self.lineSpacing = 10.0;
        self.interitemSpacing = 10.0;
        self.headerSize = CGSizeMake(40, 40);
        self.footerSize = CGSizeMake(40, 40);
        self.sectionInset = UIEdgeInsetsZero;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        self.cellLayoutInfo = [NSMutableDictionary dictionary];
        self.headLayoutInfo = [NSMutableDictionary dictionary];
        self.footLayoutInfo = [NSMutableDictionary dictionary];
        self.maxScrollDirPositionForColumn = [NSMutableDictionary dictionary];
        self.shouldanimationArr = [NSMutableArray array];
        self.startScrollDirPosition = 0;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        [self prepareLayoutAtScrollDirectionVertical];
    } else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        [self prepareLayoutAtScrollDirectionHorizontal];
    }
}

- (void)prepareLayoutAtScrollDirectionVertical {
    // 每次重新布局都需要清空数据
    [self.cellLayoutInfo removeAllObjects];
    [self.headLayoutInfo removeAllObjects];
    [self.footLayoutInfo removeAllObjects];
    [self.maxScrollDirPositionForColumn removeAllObjects];
    
    // cell可支配的宽度
    CGFloat viewWidth = self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right;
    viewWidth -= (self.collectionView.contentInset.left + self.collectionView.contentInset.right);
    // 代理里面只取了高度，所以cell的宽度有列数还有cell的间距计算出来
    CGFloat itemWidth = (viewWidth - self.interitemSpacing*(self.numberOfColumns - 1))/self.numberOfColumns;
    // 设置开始显示视图的Y
    self.startScrollDirPosition = 0;
    
    // 取有多少个section
    NSInteger sectionsCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionsCount; section ++) {
        // 存储headerView属性
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        // 头视图的宽度不为0并且根据代理方法能取到对应的头视图的时候，添加对应头视图的布局对象
        if (!CGSizeEqualToSize(self.headerSize, CGSizeZero) && [self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:supplementaryViewIndexPath];
            // 设置frame
            attribute.frame = CGRectMake(0, self.startScrollDirPosition, self.headerSize.width, self.headerSize.height);
            // 保存布局对象
            self.headLayoutInfo[supplementaryViewIndexPath] = attribute;
            // 设置下个布局对象的开始Y值
            self.startScrollDirPosition += self.headerSize.height + self.sectionInset.top;
        }
        // 没有头视图的时候，也要设置section的第一排cell到left的距离
        else {
            self.startScrollDirPosition += self.sectionInset.top;
        }
        
        // 将Section第一排cell的frame的X值进行设置
        for (int i = 0; i < _numberOfColumns; i++) {
            // 从头视图开始每列Cell的X是相同的
            self.maxScrollDirPositionForColumn[@(i)] = @(self.startScrollDirPosition);
        }
        
        // 计算cell的布局
        // 取出section有多少个row
        NSInteger rowsCount = [self.collectionView numberOfItemsInSection:section];
        // 分别计算设置每个cell的布局对象
        for (NSInteger row = 0; row < rowsCount; row++) {
            // 取当前section/row所在的indexPath
            NSIndexPath *cellIndePath = [NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndePath];
            
            // 计算出当前的cell加到哪一列（瀑布流是加载到最短的一列）
            CGFloat y = [self.maxScrollDirPositionForColumn[@(0)] floatValue];
            NSInteger currentRow = 0;
            for (int i = 1; i < _numberOfColumns; i++) {
                CGFloat iY = [self.maxScrollDirPositionForColumn[@(i)] floatValue];
                if (iY < y) {
                    y = iY; currentRow = i;
                }
            }
            // 计算X值
            CGFloat x = self.sectionInset.left + (self.interitemSpacing + itemWidth) * currentRow;
            // 根据代理取当前cell的高度，因为当前是采用通过列数计算的宽度，高度根据图片的原始宽高比进行设置的
            CGFloat itemHeight = [self.delegate sizeWithLayout:self indexPath:cellIndePath itemSize:itemWidth];
            // 设置当前cell布局对象的frame
            attribute.frame = CGRectMake(x, y, itemWidth, itemHeight);
            
            // 重新设置当前列的Y值（也就是当前列cell到下个cell的值）
            y += self.lineSpacing + itemHeight;
            self.maxScrollDirPositionForColumn[@(currentRow)] = @(y);
            // 保存cell的布局对象
            self.cellLayoutInfo[cellIndePath] = attribute;
            
            //当是section的最后一个cell是，取出最后一列cell的底部X值，设置startScrollDirPosition(最长X的列)决定下个视图对象的起始X值
            if (row == rowsCount -1) {
                CGFloat maxY = [self.maxScrollDirPositionForColumn[@(0)] floatValue];
                for (int i = 1; i < _numberOfColumns; i++) {
                    CGFloat iY = [self.maxScrollDirPositionForColumn[@(i)] floatValue];
                    if (iY > maxY) {
                        NSLog(@"%f", [self.maxScrollDirPositionForColumn[@(i)] floatValue]);
                        maxY = iY;
                    }
                }
                // 由于下cell到下个cell的Y值，所以需要减去cell间距
                self.startScrollDirPosition = maxY - self.lineSpacing + self.sectionInset.bottom;
            }
        }
        
        //存储footView属性
        //尾视图的高度不为0并且根据代理方法能取到对应的尾视图的时候，添加对应尾视图的布局对象
        if (!CGSizeEqualToSize(self.footerSize, CGSizeZero) && [self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind: atIndexPath:)]) {
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:supplementaryViewIndexPath];
            
            attribute.frame = CGRectMake(0, self.startScrollDirPosition, self.footerSize.width, self.footerSize.height);
            self.footLayoutInfo[supplementaryViewIndexPath] = attribute;
            self.startScrollDirPosition += self.footerSize.height;
        }
    }
}

- (void)prepareLayoutAtScrollDirectionHorizontal {
    // 每次重新布局都需要清空数据
    [self.cellLayoutInfo removeAllObjects];
    [self.headLayoutInfo removeAllObjects];
    [self.footLayoutInfo removeAllObjects];
    [self.maxScrollDirPositionForColumn removeAllObjects];
    
    // cell可支配的高度
    CGFloat viewHeight = self.collectionView.frame.size.height - self.sectionInset.top - self.sectionInset.bottom;
    viewHeight -= (self.collectionView.contentInset.top + self.collectionView.contentInset.bottom);
    // 代理里面只取了宽度，所以cell的高度有列数还有cell的间距计算出来
    CGFloat itemHeight = (viewHeight - self.lineSpacing*(self.numberOfColumns - 1))/self.numberOfColumns;
    // 设置开始显示视图的X
    self.startScrollDirPosition = 0;
    
    // 取有多少个section
    NSInteger sectionsCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionsCount; section ++) {
        // 存储headerView属性
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        // 头视图的宽度不为0并且根据代理方法能取到对应的头视图的时候，添加对应头视图的布局对象
        if (!CGSizeEqualToSize(self.headerSize, CGSizeZero) && [self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:supplementaryViewIndexPath];
            // 设置frame
            attribute.frame = CGRectMake(self.startScrollDirPosition, 0, self.headerSize.width, self.headerSize.height);
            // 保存布局对象
            self.headLayoutInfo[supplementaryViewIndexPath] = attribute;
            // 设置下个布局对象的开始Y值
            self.startScrollDirPosition += self.headerSize.width + self.sectionInset.left;
        }
        // 没有头视图的时候，也要设置section的第一排cell到left的距离
        else {
            self.startScrollDirPosition += self.sectionInset.left;
        }
        
        // 将Section第一排cell的frame的X值进行设置
        for (int i = 0; i < _numberOfColumns; i++) {
            // 从头视图开始每列Cell的X是相同的
            self.maxScrollDirPositionForColumn[@(i)] = @(self.startScrollDirPosition);
        }
        
        // 计算cell的布局
        // 取出section有多少个row
        NSInteger rowsCount = [self.collectionView numberOfItemsInSection:section];
        // 分别计算设置每个cell的布局对象
        for (NSInteger row = 0; row < rowsCount; row++) {
            // 取当前section/row所在的indexPath
            NSIndexPath *cellIndePath = [NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndePath];
            
            // 计算出当前的cell加到哪一列（瀑布流是加载到最短的一列）
            CGFloat x = [self.maxScrollDirPositionForColumn[@(0)] floatValue];
            NSInteger currentRow = 0;
            for (int i = 1; i < _numberOfColumns; i++) {
                CGFloat iX = [self.maxScrollDirPositionForColumn[@(i)] floatValue];
                if (iX < x) {
                    x = iX; currentRow = i;
                }
            }
            // 计算Y值
            CGFloat y = self.sectionInset.top + (self.lineSpacing + itemHeight) * currentRow;
            // 根据代理去当前cell的高度  因为当前是采用通过列数计算的宽度，高度根据图片的原始宽高比进行设置的
            CGFloat itemWidth = [self.delegate sizeWithLayout:self indexPath:cellIndePath itemSize:itemHeight];
            // 设置当前cell布局对象的frame
            attribute.frame = CGRectMake(x, y, itemWidth, itemHeight);
            
            // 重新设置当前列的X值（也就是当前列cell到下个cell的值）
            x += self.interitemSpacing + itemWidth;
            self.maxScrollDirPositionForColumn[@(currentRow)] = @(x);
            // 保存cell的布局对象
            self.cellLayoutInfo[cellIndePath] = attribute;
            
            //当是section的最后一个cell是，取出最后一列cell的底部X值，设置startScrollDirPosition(最长X的列)决定下个视图对象的起始X值
            if (row == rowsCount -1) {
                CGFloat maxX = [self.maxScrollDirPositionForColumn[@(0)] floatValue];
                for (int i = 1; i < _numberOfColumns; i++) {
                    CGFloat iX = [self.maxScrollDirPositionForColumn[@(i)] floatValue];
                    if (iX > maxX) {
                        NSLog(@"%f", [self.maxScrollDirPositionForColumn[@(i)] floatValue]);
                        maxX = iX;
                    }
                }
                // 由于下cell到下个cell的X值，所以需要减去cell间距
                self.startScrollDirPosition = maxX - self.interitemSpacing + self.sectionInset.right;
            }
        }
        
        //存储footView属性
        //尾视图的高度不为0并且根据代理方法能取到对应的尾视图的时候，添加对应尾视图的布局对象
        if (!CGSizeEqualToSize(self.footerSize, CGSizeZero) && [self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind: atIndexPath:)]) {
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:supplementaryViewIndexPath];
            
            attribute.frame = CGRectMake(self.startScrollDirPosition, 0, self.footerSize.width, self.footerSize.height);
            self.footLayoutInfo[supplementaryViewIndexPath] = attribute;
            self.startScrollDirPosition += self.footerSize.width;
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray array];
    //添加当前屏幕可见的cell的布局
    [self.cellLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    //添加当前屏幕可见的头视图的布局
    [self.headLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    //添加当前屏幕可见的尾部的布局
    [self.footLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    return allAttributes;
}

//插入cell的时候系统会调用改方法
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = self.cellLayoutInfo[indexPath];
    return attribute;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        attribute = self.headLayoutInfo[indexPath];
    }
    else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        attribute = self.footLayoutInfo[indexPath];
    }
    return attribute;
}

- (CGSize)collectionViewContentSize {
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        return CGSizeMake(MAX(self.startScrollDirPosition, self.collectionView.frame.size.width), self.collectionView.frame.size.height);
    } else {
        return CGSizeMake(self.collectionView.frame.size.width, MAX(self.startScrollDirPosition, self.collectionView.frame.size.height));
    }
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        switch (updateItem.updateAction) {
            case UICollectionUpdateActionInsert:
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            case UICollectionUpdateActionDelete:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                break;
            case UICollectionUpdateActionMove:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            default:
                NSLog(@"unhandled case: %@", updateItem);
                break;
        }
    }
    self.shouldanimationArr = indexPaths;
}

//对应UICollectionViewUpdateItem 的indexPathBeforeUpdate 设置调用
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];

    if ([self.shouldanimationArr containsObject:itemIndexPath]) {
        attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
//        attr.transform = CGAffineTransformMakeScale(0.1, 0.1); // CGAffineTransformRotate(CGAffineTransformMakeScale(0, 0), M_PI);
        attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMidY(self.collectionView.bounds));
        attr.alpha = 0.1;
        [self.shouldanimationArr removeObject:itemIndexPath];
    }
    return attr;
}

//对应UICollectionViewUpdateItem 的indexPathAfterUpdate 设置调用
- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    if ([self.shouldanimationArr containsObject:itemIndexPath]) {
        
        attr.transform = CGAffineTransformMakeScale(0.1, 0.1); //CGAffineTransformRotate(CGAffineTransformMakeScale(0.1, 0.1), 0);
//        attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMidY(self.collectionView.bounds));
        attr.alpha = 0.1;
        [self.shouldanimationArr removeObject:itemIndexPath];
    }
    return attr;
}

- (void)finalizeCollectionViewUpdates {
    self.shouldanimationArr = nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        return YES;
    }
    return NO;
}

//移动相关
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForInteractivelyMovingItems:(NSArray<NSIndexPath *> *)targetIndexPaths withTargetPosition:(CGPoint)targetPosition previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths previousPosition:(CGPoint)previousPosition NS_AVAILABLE_IOS(9_0)
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForInteractivelyMovingItems:targetIndexPaths withTargetPosition:targetPosition previousIndexPaths:previousIndexPaths previousPosition:previousPosition];
    if(self.delegate) {
        [self.delegate moveItemAtSourceIndexPath:previousIndexPaths[0] toIndexPath:targetIndexPaths[0]];
    }
    return context;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths movementCancelled:(BOOL)movementCancelled NS_AVAILABLE_IOS(9_0)
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:indexPaths previousIndexPaths:previousIndexPaths movementCancelled:movementCancelled];
    if(!movementCancelled) {
        
    }
    return context;
}

@end
