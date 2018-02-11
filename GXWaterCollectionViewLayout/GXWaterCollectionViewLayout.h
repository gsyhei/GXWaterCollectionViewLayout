//
//  GXWaterCollectionViewLayout.h
//  GXUICollectionView
//
//  Created by GuoShengyong on 2017/12/11.
//  Copyright © 2017年 protruly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GXWaterCollectionViewLayout;
@protocol GXWaterCollectionViewLayoutDelegate

//代理利用固定的高度取cell的宽(按照scrollDirection方向取值)
- (CGFloat)sizeWithLayout:(GXWaterCollectionViewLayout*)layout indexPath:(NSIndexPath*)indexPath itemSize:(CGFloat)itemSize;
//处理移动相关的数据源
- (void)moveItemAtSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(9_0);
@end

// 横向瀑布流布局(有规则的固定高度适应宽度)
@interface GXWaterCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) NSInteger    numberOfColumns;   //瀑布流横排数
@property (nonatomic, assign) CGFloat      lineSpacing;       //纵向间距
@property (nonatomic, assign) CGFloat      interitemSpacing;  //横向间距
@property (nonatomic, assign) CGSize       headerSize;        //页眉尺寸
@property (nonatomic, assign) CGSize       footerSize;        //页脚尺寸
@property (nonatomic, assign) UIEdgeInsets sectionInset;      //分类inset

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;  //滚动方向
@property (nonatomic,   weak) id<GXWaterCollectionViewLayoutDelegate> delegate; //代理

@end
