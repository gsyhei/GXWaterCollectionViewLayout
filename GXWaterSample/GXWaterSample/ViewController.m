//
//  ViewController.m
//  GX_UIKitSample
//
//  Created by GuoShengyong on 2018/2/11.
//  Copyright © 2018年 protruly. All rights reserved.
//

#import "ViewController.h"
#import "GXWaterViewController.h"

#define GX_ITEM_TITLE @[@"瀑布流UICollectionView_纵向", @"瀑布流UICollectionView_横向"]

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"GX_UIKitSample";
    
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return GX_ITEM_TITLE.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = GX_ITEM_TITLE[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            GXWaterViewController *ctr = [[GXWaterViewController alloc] init];
            ctr.scrollDirection = UICollectionViewScrollDirectionVertical;
            ctr.view.backgroundColor = [UIColor whiteColor];
            ctr.title = GX_ITEM_TITLE[indexPath.row];
            [self.navigationController pushViewController:ctr animated:YES];
        }
            break;
        case 1:{
            GXWaterViewController *ctr = [[GXWaterViewController alloc] init];
            ctr.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            ctr.view.backgroundColor = [UIColor whiteColor];
            ctr.title = GX_ITEM_TITLE[indexPath.row];
            [self.navigationController pushViewController:ctr animated:YES];
        }
            break;
    }
}


@end

