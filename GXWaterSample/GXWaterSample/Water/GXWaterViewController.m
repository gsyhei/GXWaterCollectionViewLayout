//
//  GXWaterViewController.m
//  GXUICollectionView
//
//  Created by GuoShengyong on 2017/12/11.
//  Copyright © 2017年 cong. All rights reserved.
//

#import "GXWaterViewController.h"
#import "GXWaterCollectionViewLayout.h"
#import "GXWaterCVCell.h"
#import "GXHeaderCRView.h"
#import "GXFooterCRView.h"

static NSString* GXSectionHeaderID = @"GXSectionHeaderID";
static NSString* GXSectionFooterID = @"GXSectionFooterID";
static NSString* GXSectionCellID   = @"GXSectionCellID";

@interface GXWaterViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,GXWaterCollectionViewLayoutDelegate>
@property (strong, nonatomic) UICollectionView *waterCollectionView;
@property (strong, nonatomic) GXWaterCollectionViewLayout *waterLayout;
@property (strong, nonatomic) NSMutableArray<NSMutableArray*> *imageArr;

@end

@implementation GXWaterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"瀑布流";
    
    self.waterLayout = [[GXWaterCollectionViewLayout alloc] init];
    self.waterLayout.lineSpacing = 10.0;
    self.waterLayout.interitemSpacing = 10.0;
    self.waterLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.waterLayout.scrollDirection = self.scrollDirection;//UICollectionViewScrollDirectionHorizontal;
    if (self.waterLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        self.waterLayout.numberOfColumns = 4;
        self.waterLayout.headerSize = CGSizeMake(self.view.bounds.size.width, 40);
        self.waterLayout.footerSize = CGSizeMake(self.view.bounds.size.width, 40);
    } else {
        self.waterLayout.numberOfColumns = 5;
        self.waterLayout.headerSize = CGSizeMake(40, self.view.bounds.size.height);
        self.waterLayout.footerSize = CGSizeMake(40, self.view.bounds.size.height);
    }
    self.waterLayout.delegate = self;
    
    CGFloat top = 44.0 + [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect frame = CGRectMake(0, top, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - top);
    self.waterCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.waterLayout];
    self.waterCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.waterCollectionView.backgroundColor = [UIColor whiteColor];
    self.waterCollectionView.delegate = self;
    self.waterCollectionView.dataSource = self;
    [self.view addSubview:self.waterCollectionView];
    
    // iOS11设置UIScrollView
    if (@available(iOS 11.0, *)) {
        [self.waterCollectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.waterCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([GXWaterCVCell class]) bundle:nil] forCellWithReuseIdentifier:GXSectionCellID];
    [self.waterCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([GXHeaderCRView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:GXSectionHeaderID];
    [self.waterCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([GXFooterCRView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:GXSectionFooterID];
    
    UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGest:)];
    [self.waterCollectionView addGestureRecognizer:longGest];
}

- (void)longGest:(UILongPressGestureRecognizer *)gest {
    if (@available(iOS 9.0, *)) {
        switch (gest.state) {
            case UIGestureRecognizerStateBegan: {
                NSIndexPath *touchIndexPath = [self.waterCollectionView indexPathForItemAtPoint:[gest locationInView:self.waterCollectionView]];
                if (touchIndexPath) {
                    [self.waterCollectionView beginInteractiveMovementForItemAtIndexPath:touchIndexPath];
                }
            }
                break;
            case UIGestureRecognizerStateChanged: {
                [self.waterCollectionView updateInteractiveMovementTargetPosition:[gest locationInView:gest.view]];
            }
                break;
            case UIGestureRecognizerStateEnded: {
                [self.waterCollectionView endInteractiveMovement];
            }
                break;
            default:
                break;
        }
    }
}

- (NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
        NSMutableArray *array = [NSMutableArray array];
        for(int i = 1; i < 100; i++) {
            [array addObject:[NSString stringWithFormat:@"%d.jpeg", i%13]];
        }
        [_imageArr addObject:array];
        NSMutableArray *array2 = [array mutableCopy];
        [_imageArr addObject:array2];
    }
    return _imageArr;
}

//设置head foot视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        GXHeaderCRView *head = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GXSectionHeaderID forIndexPath:indexPath];
        return head;
    }
    else if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        GXFooterCRView *foot = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GXSectionFooterID forIndexPath:indexPath];
        return foot;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0)
{
    cell.contentView.alpha = 0.2;
    cell.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.5, 0.5), 0);
    
    [UIView animateKeyframesWithDuration:.5 delay:0.0 options:0 animations:^{
        /** 分步动画   第一个参数是该动画开始的百分比时间  第二个参数是该动画持续的百分比时间 */
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.8 animations:^{
            cell.contentView.alpha = 0.5;
            cell.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.1, 1.1), 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            cell.contentView.alpha = 1.0;
            cell.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.0, 1.0), 0);
        }];
    } completion:^(BOOL finished) {}];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.imageArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageArr[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GXWaterCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GXSectionCellID forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.imageArr[indexPath.section][indexPath.row]];
    cell.textTitle.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(9_0) {
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath:%@", indexPath);
}

#pragma mark - GXWaterCollectionViewLayoutDelegate

- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath {
    return [UIImage imageNamed:[self.imageArr[indexPath.section] objectAtIndex:indexPath.row]];
}

- (CGFloat)sizeWithLayout:(GXWaterCollectionViewLayout*)layout indexPath:(NSIndexPath*)indexPath itemSize:(CGFloat)itemSize {
    if (layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return [self imageAtIndexPath:indexPath].size.height / [self imageAtIndexPath:indexPath].size.width * itemSize;
    } else {
        return [self imageAtIndexPath:indexPath].size.width / [self imageAtIndexPath:indexPath].size.height * itemSize;
    }
}

- (void)moveItemAtSourceIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(9_0) {
    if(sourceIndexPath.row != destinationIndexPath.row) {
        NSString *value = self.imageArr[sourceIndexPath.section][sourceIndexPath.row];
        [self.imageArr[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
        [self.imageArr[destinationIndexPath.section] insertObject:value atIndex:destinationIndexPath.row];
        NSLog(@"from:%@  to:%@", sourceIndexPath, destinationIndexPath);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

