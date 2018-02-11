# GXWaterCollectionViewLayout

一个好用的瀑布流布局，可以设置纵横方向和排列数等。

Requirements
--
- iOS 7.0 or later
- Xcode 8.0 or later

Usage in you Podfile:
--

```
pod 'GXWaterCollectionViewLayout'
```

可以设置纵横方向
--

```objc
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;  //滚动方向
```

可以设置的其它参数
--

```objc
@property (nonatomic, assign) NSInteger    numberOfColumns;   //瀑布流横排数
@property (nonatomic, assign) CGFloat      lineSpacing;       //纵向间距
@property (nonatomic, assign) CGFloat      interitemSpacing;  //横向间距
@property (nonatomic, assign) CGSize       headerSize;        //页眉尺寸
@property (nonatomic, assign) CGSize       footerSize;        //页脚尺寸
@property (nonatomic, assign) UIEdgeInsets sectionInset;      //分类inset
```

实例应用代码
--

```objc
// 初始化瀑布流布局
self.waterLayout = [[GXWaterCollectionViewLayout alloc] init];
self.waterLayout.numberOfColumns = 4;
self.waterLayout.lineSpacing = 10.0;
self.waterLayout.interitemSpacing = 10.0;
self.waterLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
self.waterLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
self.waterLayout.headerSize = CGSizeMake(self.view.bounds.size.width, 40);
self.waterLayout.footerSize = CGSizeMake(self.view.bounds.size.width, 40);
self.waterLayout.delegate = self;
// 初始化UICollectionView
self.waterCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.waterLayout];
self.waterCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
self.waterCollectionView.backgroundColor = [UIColor whiteColor];
self.waterCollectionView.delegate = self;
self.waterCollectionView.dataSource = self;
[self.view addSubview:self.waterCollectionView];
```

方向UICollectionViewScrollDirectionVertical效果
--

![](/IMG_Vertical.PNG '描述')

方向UICollectionViewScrollDirectionHorizontal效果
--

![](/IMG_Horizontal.PNG '描述')

License
--
MIT


