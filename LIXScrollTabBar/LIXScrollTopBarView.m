//
//  LIXScrollTopBarView.m
//
//  Created by lixu on 2016/12/22.
//

#import "LIXScrollTopBarView.h"

@interface LIXScrollTopBarViewDataSourceModel : NSObject

@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, assign) CGSize titleSize;
@property (nonatomic, assign) CGSize baselineSize;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, strong) NSArray *contentItemCellClasses;
@property (nonatomic, strong) id data;

@end

@implementation LIXScrollTopBarViewDataSourceModel

@end

@interface LIXScrollTopBarViewDataSource : NSObject

+ (LIXScrollTopBarViewDataSource *)shareInstance;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) NSUInteger pagesCount;

- (void)clear;

- (void)setTitleName:(NSString *)titleName forIndex:(NSInteger)index;
- (NSString *)getTitleName:(NSInteger)index;
- (void)setTitleSize:(CGSize)size forIndex:(NSUInteger)index;
- (CGSize)getTitleSizeForIndex:(NSUInteger)index;
- (void)setContentOffsetY:(CGPoint)offsetY forIndex:(NSUInteger)index;
- (CGPoint)getContentOffsetYForIndex:(NSUInteger)index;
- (void)setCurrentIndexContentOffsetY:(CGPoint)offsetY;
- (CGPoint)getContentOffsetYForCurrentIndex;
- (void)setData:(id)contentData forIndex:(NSUInteger)index;
- (id)getDataForIndex:(NSUInteger)index;

@property (nonatomic, strong) NSMutableDictionary *dataSource;

@property (nonatomic, strong) NSString *pageItemClass;

@end

@implementation LIXScrollTopBarViewDataSource

static LIXScrollTopBarViewDataSource *_instance = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [self shareInstance];
}

+ (LIXScrollTopBarViewDataSource *)shareInstance {
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        _instance.dataSource = [NSMutableDictionary dictionary];
    });
    
    return _instance;
}

- (void)clear {
    _instance = nil;
}

- (void)setTopBarBottomLine:(CGSize)size forPage:(NSInteger)page {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:page];
    model.baselineSize = size;
}

- (CGSize)getTopBarBottomLineSizeForPage:(NSUInteger)page {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:page];
    return model.baselineSize;
}

- (void)setContentItemCellClasses:(NSArray *)classes forIndex:(NSInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    model.contentItemCellClasses = classes;
    
}

- (NSArray *)getContentItemCellClassesForIndex:(NSInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    return model.contentItemCellClasses;
}

- (void)setTitleName:(NSString *)titleName forIndex:(NSInteger)index {
    
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    model.titleName = titleName;
}

- (NSString *)getTitleName:(NSInteger)index {
    
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    return model.titleName;
}

- (void)setTitleSize:(CGSize)size forIndex:(NSUInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    model.titleSize = size;
}

- (CGSize)getTitleSizeForIndex:(NSUInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    return model.titleSize;
}

- (void)setContentOffsetY:(CGPoint)offsetY forIndex:(NSUInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    model.contentOffset = offsetY;
}

- (CGPoint)getContentOffsetYForIndex:(NSUInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    return model.contentOffset;
}

- (void)setCurrentIndexContentOffsetY:(CGPoint)offsetY {
    [self setContentOffsetY:offsetY forIndex:self.currentIndex];
}

- (CGPoint)getContentOffsetYForCurrentIndex {
    return CGPointEqualToPoint([self getContentOffsetYForIndex:self.currentIndex], CGPointZero) ? [self getContentOffsetYForIndex:self.currentIndex] : CGPointZero;
}

- (void)setData:(id)contentData forIndex:(NSUInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    model.data = contentData;
}

- (id)getDataForIndex:(NSUInteger)index {
    LIXScrollTopBarViewDataSourceModel *model = [self getContentDataForIndex:index];
    return model.data;
}

- (LIXScrollTopBarViewDataSourceModel *)getContentDataForIndex:(NSInteger)index {
    
    LIXScrollTopBarViewDataSourceModel *model = [self.dataSource objectForKey:@(index)];
    if (!model) {
        model = [[LIXScrollTopBarViewDataSourceModel alloc] init];
        [self.dataSource setObject:model forKey:@(index)];
    }
    
    return model;
}

@end

static NSString *const kTitleCellIdentifier = @"LIXScrollTopBarTitleCell";
static NSString *const kContentCellIdentifier = @"LIXScrollTopBarContentCell";
static NSString *const kContentItemCellIdentifier = @"kContentItemCellIdentifier";
static CGFloat const kDefaultTopBarHeight = 60;
static CGFloat const kDefatultTopBarCellWidth = 80;


@interface LIXScrollTopBarTitleBarView : UIView

@property (nonatomic, strong) UIView *colorView;

- (void)updateSize:(CGSize)size;
- (void)updateColor:(UIColor *)color;

@end

@implementation LIXScrollTopBarTitleBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.colorView = [[UIView alloc] initWithFrame:self.bounds];
    self.colorView.backgroundColor = [UIColor redColor];
    [self addSubview:self.colorView];
    
    return self;
}

- (void)updateSize:(CGSize)size {
    self.colorView.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (void)updateColor:(UIColor *)color {
    self.colorView.backgroundColor = color;
}

@end

BOOL validateDelegateWithSelector(NSObject *delegate, SEL selector) {
    if (delegate && [delegate respondsToSelector:selector]) {
        return YES;
    }
    return NO;
}

@protocol LIXScrollTopBarViewContentCellDataSource <NSObject>

@required

- (void)didSelectedContentItem:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath inPage:(NSUInteger)index;

@end


@interface LIXScrollTopBarTitleCellLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) BOOL shouldRasterize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat fontScale;

@end

@interface LIXSCrollTopBarCell : UICollectionViewCell

- (void)updateWithModel:(id)model forIndex:(NSUInteger)index;
- (void)updateContentYForIndex:(NSUInteger)index;

@property (nonatomic, strong) NSString *cellClassName;
@property (nonatomic, assign) LIXScrollTopBarContentScrollStyle scrollStyle;
@property (nonatomic, weak) id<LIXScrollTopBarViewContentCellDataSource> dataSource;


@end

@implementation LIXSCrollTopBarCell

- (void)updateWithModel:(id)model forIndex:(NSUInteger)index {}
- (void)updateContentYForIndex:(NSUInteger)index{}

@end

@interface LIXScrollTopBarTitleCell : LIXSCrollTopBarCell

@property (nonatomic, strong) UILabel *titleLabel;


@end

@interface LIXScrollTopBarContentCell : LIXSCrollTopBarCell<LIXScrollTopBarItemProtocol>

@property (nonatomic, strong) UILabel *contentLabel;


@end


@interface LIXScrollTopBarTitleFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) LIXScrollTopBarType style;
@property (nonatomic, assign) CGRect targetRect;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *deSelectedColor;

@end

@interface LIXScrollTopBarContentFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) LIXScrollTopBarContentTransformStyle transformStyle;

@end

@interface LIXSCrollTopBarContentCellFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) UIDynamicAnimator *dynamicAniamtor;

@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat lastestDelta;

@property (nonatomic, assign) LIXScrollTopBarContentScrollStyle style;

@end


@interface LIXScrollTopBarView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,LIXScrollTopBarViewContentCellDataSource>

//data source
@property (nonatomic, strong) NSMutableArray *tDataSource;//数据源

@property (nonatomic, strong) LIXScrollTopBarTitleBarView *topBarbaseLine;//下划线
@property (nonatomic, assign) CGSize baseLineSize;//topBar下划线size
@property (nonatomic, strong) UIColor *baseLineColor;//topBar下划线颜色

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) CGSize topBarTitleCellSize;
@property (nonatomic, assign) NSInteger draggingNextIndex;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isDragging;

//frame config
@property (nonatomic, assign) CGFloat topBarHeight;

@property (nonatomic, strong) UICollectionView *topBarCollectionView;
@property (nonatomic, strong) LIXScrollTopBarTitleFlowLayout *topBarFlowLayout;
@property (nonatomic, strong) LIXScrollTopBarContentFlowLayout *contentFlowLayout;
@property (nonatomic, strong) UICollectionView *contentCollectionView;

@property (nonatomic, strong) NSArray *attributesArray;



@end

@implementation LIXScrollTopBarView
{
    CGFloat preContentOffsetX;
    BOOL isLeft;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) return nil;
    self.backgroundColor = [UIColor whiteColor];
    
    //config data
    self.topBarHeight = _topBarHeight?: kDefaultTopBarHeight;
    self.topBarTitleCellSize = CGSizeMake(kDefatultTopBarCellWidth, kDefaultTopBarHeight);
    self.baseLineSize = CGSizeMake(80, 2);
    
    self.canScrollPage = YES;
    self.currentIndex = 0;
    
    
    
    [self setupNotification];
    
    return self;
}

- (void)setupTestData {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < 20; i ++) {
        NSDictionary *dic = @{
                              @"title":@"标题"
                              };
        [tempArray addObject:dic];
    }
    self.tDataSource = [tempArray copy];
}

#pragma mark - private method

- (void)configData {
    
    if (validateDelegateWithSelector(self.dataSource,@selector(scrollTopBar:pageItemCellForPage:forIndexPath:))) {
        if (validateDelegateWithSelector(self.dataSource, @selector(numberOfPagesInScrollTopBar:))) {
            NSInteger pagesCount = [self.dataSource numberOfPagesInScrollTopBar:self];
            [LIXScrollTopBarViewDataSource shareInstance].pagesCount = pagesCount;
            
            for (int page = 0; page < pagesCount; page ++) {
                if (validateDelegateWithSelector(self.dataSource, @selector(numberOfScetionsInPage:))) {
                    
                    NSUInteger sectionsCount = [self.dataSource numberOfScetionsInPage:page];
                    
                    NSMutableArray *sectionArr = [NSMutableArray arrayWithCapacity:sectionsCount];
                    
                    for (int section = 0; section < sectionsCount; section ++) {
                        
                        //                        NSMutableDictionary *sectionDic = [NSMutableDictionary dictionary];
                        if (validateDelegateWithSelector(self.dataSource, @selector(numberOfItemsAtPageIndex:forSection:))) {
                            
                            NSUInteger itemsCount = [self.dataSource numberOfItemsAtPageIndex:page forSection:section];
                            
                            NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:itemsCount];
                            for (int item = 0; item < itemsCount; item ++) {
                                
                                
                                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                                
                                Class cellClass = [[self.dataSource scrollTopBar:self pageItemCellForPage:page forIndexPath:indexPath] class];
                                id data = [self.dataSource scrollTopBar:self pageItemDataForPage:page forIndexPath:indexPath];
                                
                                NSDictionary *dic = @{
                                                      @"className":NSStringFromClass(cellClass),
                                                      @"data":data
                                                      };
                                
                                [itemArray addObject:dic];
                            }
                            
                            //                            [sectionDic setObject:itemArray forKey:@(section)];
                            [sectionArr addObject:itemArray];
                        }
                        
                    }
                    [[LIXScrollTopBarViewDataSource shareInstance] setContentItemCellClasses:sectionArr forIndex:page];
                    if (validateDelegateWithSelector(self.dataSource, @selector(scrollTopBar: sizeForTitleBarBottomLineInpage:)))                    {
                        CGSize baselineSize = [self.dataSource scrollTopBar:self sizeForTitleBarBottomLineInpage:page];
                        [[LIXScrollTopBarViewDataSource shareInstance] setTopBarBottomLine:baselineSize forPage:page];
                    }
                    
                }
            }
        }
    }

}

- (void)registerPageItemClass:(Class)className {
    NSString *class = NSStringFromClass(className);
    [[LIXScrollTopBarViewDataSource shareInstance] setPageItemClass:class];
}

- (void)setupView {
    
    [self addSubview:self.topBarCollectionView];
    [self addSubview:self.contentCollectionView];
}

- (void)setupNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    [self.contentCollectionView reloadData];
    [self.topBarCollectionView reloadData];
    
    //解决旋转之后contentSize不对应的问题,延迟为了让动画看起来不奇怪
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.contentCollectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        [self.topBarCollectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    });
    
}


- (void)scrollTopBarBaseLineToIndexPath:(NSIndexPath *)indexPath {
    
    CGRect rect = [self.topBarCollectionView cellForItemAtIndexPath:indexPath].frame;
    [self scrollTopBarBaseLineToRect:rect];
}

- (void)scrollTopBarBaseLineToRect:(CGRect)rect {
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.topBarbaseLine.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(self.topBarbaseLine.frame));
    } completion:^(BOOL finished) {
        //TODO:finish animation
    }];
}

#pragma mark - LIXScrollViewContentCellDataSource

- (void)didSelectedContentItem:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath inPage:(NSUInteger)index{
    if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didSelectedContentItemIndex:inPage:))) {
        [self.delegate scrollTopBar:self didSelectedContentItemIndex:indexPath inPage:index];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (validateDelegateWithSelector(self.dataSource, @selector(numberOfPagesInScrollTopBar:))) {
        
        NSInteger count = [self.dataSource numberOfPagesInScrollTopBar:self];
        
       return count;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier;
    id model;
    LIXSCrollTopBarCell *cell;
    if (collectionView == self.topBarCollectionView) {
        cellIdentifier = kTitleCellIdentifier;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        model = [self.dataSource scrollTopBar:self titleDataForItem:cell atIndex:indexPath.row];
        [[LIXScrollTopBarViewDataSource shareInstance] setTitleName:model forIndex:indexPath.row];
        UIFont *font = [UIFont systemFontOfSize:16];
        CGSize fontSize = [model[@"title"] sizeWithAttributes:@{NSFontAttributeName:font}];
        [[LIXScrollTopBarViewDataSource shareInstance] setTitleSize:fontSize forIndex:indexPath.row];
    }
    else {
        cellIdentifier = kContentCellIdentifier;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [[LIXScrollTopBarViewDataSource shareInstance] setData:model forIndex:indexPath.row];
        cell.dataSource = self;
        cell.cellClassName = @"UICollectionViewCell";
        cell.scrollStyle = self.contentCellScrollStyle;
    }

    [cell updateWithModel:model forIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGSize cellSize;
    if (collectionView == self.contentCollectionView) {
        cellSize = CGSizeMake(self.contentCollectionView.frame.size.width, self.contentCollectionView.frame.size.height);
    }
    else {
        cellSize = CGSizeMake(kDefatultTopBarCellWidth, kDefaultTopBarHeight);
    }
    return cellSize;
}


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    
//    if (collectionView == self.topBarCollectionView) {
//        if (validateDelegateWithSelector(self.dataSource, @selector(scrollTopBar:titleContainerView:layout:insertForSectionAtIndex:))) {
//            
//            return [self.dataSource scrollTopBar:self titleContainerView:collectionView layout:collectionViewLayout insertForSectionAtIndex:section];
//        }
//    }
//    
//    return [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
//}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.topBarCollectionView) {
        
        if (self.selectedTitleStyle == LIXScrollTopBarTitleSelectedStyle_spring &&
            !(self.scrollTitleType & LIXScrollTopBarType_transform)) {
            
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            CGRect frame = cell.frame;
            [UIView animateWithDuration:0.1
                                  delay:0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cell.frame = CGRectInset(cell.frame, -1, -1);
                             }
                             completion:^(BOOL finish){
                                 cell.frame = frame;
                             }];
        }
        
        if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didSelectedTitleIndex:))) {
            [self.delegate scrollTopBar:self didSelectedTitleIndex:indexPath.row];
        }
        
        if (indexPath.row == self.currentIndex) {
            return;
        }
        
        if (self.isScrolling || self.isDragging) {
            return;
        }
        
        self.isScrolling = YES;
        self.isDragging = NO;
        
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        self.currentIndex = indexPath.row;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentCollectionView) {
        self.isDragging = YES;
        
        preContentOffsetX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x < 0) {
        return;
    }
    
    isLeft = (scrollView.contentOffset.x - preContentOffsetX < 0);
    
    //下划线跟着移动
    if (scrollView == self.contentCollectionView) {
        CGFloat distance = scrollView.contentOffset.x * (self.topBarTitleCellSize.width / scrollView.frame.size.width);
        self.topBarbaseLine.frame = CGRectMake(distance, self.topBarbaseLine.frame.origin.y, CGRectGetWidth(self.topBarbaseLine.frame), CGRectGetHeight(self.topBarbaseLine.frame));

        self.topBarFlowLayout.targetRect = self.topBarbaseLine.frame;
        
        
        //当滑动contentView的时候始终漏出下划线
        if(self.isDragging) {
            CGPoint originToTitleView = [self convertPoint:self.topBarbaseLine.frame.origin fromView:self.topBarCollectionView];
            
            if (originToTitleView.x + CGRectGetWidth(_topBarbaseLine.bounds) > CGRectGetMaxX(self.topBarCollectionView.frame)
                || originToTitleView.x < CGRectGetMinX(self.topBarCollectionView.frame)) {
                
                [self.topBarCollectionView scrollRectToVisible:self.topBarbaseLine.frame animated:NO];
            }
        }
        
       
        
        //计算willscrollto的index
        CGPoint point = isLeft ? CGPointMake(CGRectGetMinX(self.topBarbaseLine.frame) + 10, 0) : CGPointMake(CGRectGetMaxX(self.topBarbaseLine.frame) - 10, 0);
        
        if (point.x < self.topBarCollectionView.contentSize.width && point.x > 0) {
            NSIndexPath *indexPath = [self.topBarCollectionView indexPathForItemAtPoint:point];
            if (self.isScrolling) {
                if (indexPath.row == self.currentIndex) {
                    
                    self.draggingNextIndex = indexPath.row;
                }
            }
            else {
                self.draggingNextIndex = indexPath.row;
            }
        }
    }
    
    //update topbarTitleCell attributes
    self.attributesArray = [self.topBarFlowLayout layoutAttributesForElementsInRect:CGRectMake(0, 0, self.topBarCollectionView.contentSize.width, self.topBarCollectionView.contentSize.height)];
    for (UICollectionViewLayoutAttributes *attributes in self.attributesArray) {
        
        LIXScrollTopBarTitleCell *cell = (LIXScrollTopBarTitleCell *)[self.topBarCollectionView cellForItemAtIndexPath:attributes.indexPath];
        [cell applyLayoutAttributes:attributes];
    }
}

- (void)didScrollToPage {
    
    NSIndexPath *indexPath = [self.topBarCollectionView indexPathForItemAtPoint:self.topBarbaseLine.center];
    LIXSCrollTopBarCell *cell = (LIXSCrollTopBarCell *)[self.contentCollectionView cellForItemAtIndexPath:indexPath];
    [cell updateContentYForIndex:indexPath.row];
    self.currentIndex = indexPath.row;
    
    CGSize baselineSize = [[LIXScrollTopBarViewDataSource shareInstance] getTopBarBottomLineSizeForPage:indexPath.row];
    [UIView animateWithDuration:0.25
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.baseLineSize = baselineSize;
                     }
                     completion:nil];
    
    if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didScrollToIndex:))) {
        [self.delegate scrollTopBar:self didScrollToIndex:indexPath.row];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentCollectionView) {
        self.isScrolling = NO;
        
//        NSIndexPath *indexPath = [self.topBarCollectionView indexPathForItemAtPoint:self.topBarbaseLine.center];
//        LIXSCrollTopBarCell *cell = (LIXSCrollTopBarCell *)[self.contentCollectionView cellForItemAtIndexPath:indexPath];
//        [cell updateContentYForIndex:indexPath.row];
//        
//        CGSize baselineSize = [[LIXScrollTopBarViewDataSource shareInstance] getTitleSizeForIndex:indexPath.row];
//        
//        if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didScrollToIndex:))) {
//            [self.delegate scrollTopBar:self didScrollToIndex:indexPath.row];
//        }
        
        [self didScrollToPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentCollectionView) {
        self.isDragging = NO;
        
//        NSIndexPath *indexPath = [self.topBarCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.topBarbaseLine.frame), 0)];
//        self.currentIndex = indexPath.row;
//        
//        if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didScrollToIndex:))) {
//            [self.delegate scrollTopBar:self didScrollToIndex:indexPath.row];
//        }
        [self didScrollToPage];
    }
    
}

#pragma mark - get & set method

- (void)setDataSource:(id<LIXScrollTopBarViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self configData];
    [self setupView];
}

- (void)setTitleBarEdgeInsets:(UIEdgeInsets)titleBarEdgeInsets {
    self.topBarCollectionView.frame = CGRectMake(titleBarEdgeInsets.left, titleBarEdgeInsets.top
                                                 , CGRectGetWidth(self.topBarCollectionView.frame) - (titleBarEdgeInsets.left + titleBarEdgeInsets.right), self.topBarHeight);
}

- (void)setCanScrollPage:(BOOL)canScrollPage {
    if (!canScrollPage) {
        self.contentCollectionView.scrollEnabled = NO;
    }
    _canScrollPage = canScrollPage;
}

- (void)setHideTitleBaseLine:(BOOL)hideTitleBaseLine {
  
    [_topBarbaseLine updateColor:(hideTitleBaseLine ? [UIColor clearColor] : [UIColor redColor])];
    _hideTitleBaseLine = hideTitleBaseLine;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [LIXScrollTopBarViewDataSource shareInstance].currentIndex = currentIndex;
    self.contentFlowLayout.currentIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
}

- (NSInteger)currentIndex {
    return self.contentFlowLayout.currentIndexPath.row;
}

- (void)setIsScrolling:(BOOL)isScrolling {
    if (isScrolling) {
        self.userInteractionEnabled = NO;
    }
    else {
        self.userInteractionEnabled = YES;
    }
    
    _isScrolling = isScrolling;
}

- (void)setDraggingNextIndex:(NSInteger)draggingNextIndex {
    if (_draggingNextIndex == draggingNextIndex) {
        return;
    }
    
    _draggingNextIndex = draggingNextIndex;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:draggingNextIndex inSection:0];
    LIXSCrollTopBarCell *cell = (LIXSCrollTopBarCell *)[self.contentCollectionView cellForItemAtIndexPath:indexPath];
    [cell updateContentYForIndex:draggingNextIndex];
    
    if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:willScrollToIndex:))) {
        [self.delegate scrollTopBar:self willScrollToIndex:draggingNextIndex];
    }
}

- (void)setScrollTitleType:(LIXScrollTopBarType)scrollTitleType {
    
    self.topBarFlowLayout.style = scrollTitleType;
    _scrollTitleType = scrollTitleType;
    //[self.topBarFlowLayout layoutAttributesForElementsInRect:CGRectMake(0, 0, self.topBarCollectionView.contentSize.width, self.topBarCollectionView.contentSize.height)];
}

- (UIView *)topBarbaseLine {
    if(_topBarbaseLine) return _topBarbaseLine;
    
    _topBarbaseLine = [[LIXScrollTopBarTitleBarView alloc] initWithFrame:CGRectMake(0, self.topBarHeight - self.baseLineSize.height, self.baseLineSize.width, self.baseLineSize.height)];
    
    [_topBarbaseLine updateColor:_baseLineColor ?: [UIColor redColor]];
//    _topBarbaseLine = ({
//       
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBarHeight - self.baseLineSize.height, self.baseLineSize.width, self.baseLineSize.height)];
//        line.backgroundColor = self.baseLineColor;
//        line;
//    });
    
    return _topBarbaseLine;
}

- (void)setBaseLineColor:(UIColor *)baseLineColor {
    
    _baseLineColor = baseLineColor;
    
    if (_topBarbaseLine) {
        [self.topBarbaseLine updateColor:baseLineColor];
    }
}

- (void)setBaseLineSize:(CGSize)baseLineSize {
    
    _baseLineSize = baseLineSize;
    [self.topBarbaseLine updateSize:baseLineSize];
//    self.topBarbaseLine.bounds = CGRectMake(0, 0, baseLineSize.width, baseLineSize.height);
//    self.topBarbaseLine.frame = CGRectMake(self.topBarbaseLine.frame.origin.x + (CGRectGetWidth(self.topBarbaseLine.frame)- baseLineSize.width) / 2, self.topBarbaseLine.frame.origin.y, baseLineSize.width, baseLineSize.height);
}

- (UICollectionView *)topBarCollectionView {
    
    if(_topBarCollectionView) return _topBarCollectionView;
    
    _topBarCollectionView = ({
        self.topBarFlowLayout = [[LIXScrollTopBarTitleFlowLayout alloc] init];
        self.topBarFlowLayout.style = self.scrollTitleType;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.topBarHeight) collectionViewLayout:_topBarFlowLayout];
        
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        collectionView.translatesAutoresizingMaskIntoConstraints = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[LIXScrollTopBarTitleCell class] forCellWithReuseIdentifier:kTitleCellIdentifier];
        
        [collectionView addSubview:self.topBarbaseLine];
        
        self.topBarFlowLayout.targetRect = self.topBarbaseLine.frame;
        
        collectionView;
    });
    
    return _topBarCollectionView;
}

- (UICollectionView *)contentCollectionView {
    
    if (_contentCollectionView) return _contentCollectionView;
    
    _contentCollectionView = ({
        self.contentFlowLayout = [[LIXScrollTopBarContentFlowLayout alloc] init];
        self.currentIndex = 0;
        _contentFlowLayout.minimumLineSpacing = 0;
        _contentFlowLayout.minimumInteritemSpacing = 0;
        _contentFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.topBarHeight, self.bounds.size.width, self.bounds.size.height - self.topBarHeight) collectionViewLayout:_contentFlowLayout];
        collectionView.backgroundColor = [UIColor whiteColor];
        
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor lightGrayColor];
        
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.translatesAutoresizingMaskIntoConstraints = YES;
        
        [collectionView registerClass:[LIXScrollTopBarContentCell class] forCellWithReuseIdentifier:kContentCellIdentifier];
        
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.pagingEnabled = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView;
    });
    
        return _contentCollectionView;
}

- (void)setContentCellScrollStyle:(LIXScrollTopBarContentScrollStyle)contentCellScrollStyle {
    if (_contentCellScrollStyle != contentCellScrollStyle) {
        _contentCellScrollStyle = contentCellScrollStyle;
        
    }
}

@end


@implementation LIXScrollTopBarTitleCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) return nil;
    
//    self.backgroundColor = [UIColor yellowColor];
    
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    [self.contentView addSubview:_titleLabel];
    self.titleLabel.center = self.contentView.center;
    
    return self;
}

- (void)prepareForReuse {
    
    self.titleLabel.text = @"";
    self.titleLabel.textColor = [UIColor blackColor];
}

- (void)updateWithModel:(id)model forIndex:(NSUInteger)index {
    
    self.titleLabel.text = [model valueForKey:@"title"];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    self.titleLabel.textColor = [layoutAttributes valueForKey:@"textColor"];

    //使用shouldRasterize会导致label文字模糊
//    self.layer.shouldRasterize = [layoutAttributes valueForKey:@"shouldRasterize"];
    
    CGFloat fontSize = 16 * [(LIXScrollTopBarTitleCellLayoutAttributes *)layoutAttributes fontScale];
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.layer.affineTransform = layoutAttributes.transform;
}



@end

@interface LIXScrollTopBarContentCell ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) id model;
@property (nonatomic, assign) NSUInteger currentIndex;

@end


@implementation LIXScrollTopBarContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(!(self == [super initWithFrame:frame])) return nil;
    
    self.contentLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label;
    });
    
//    self.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_contentLabel];
    
    return self;
}

- (void)prepareForReuse {
    
    self.contentLabel.text = @"";
}

#pragma - mark item protocol
- (void)updateWithData:(id)data {
    
}

- (void)updateContentYForIndex:(NSUInteger)index {
    self.collectionView.contentOffset = [[LIXScrollTopBarViewDataSource shareInstance] getContentOffsetYForIndex:index];
    
//    NSLog(@"========[currentIndex:%lul, contentOffsety:%f]=========",(unsigned long)index, self.collectionView.contentOffset.y);
}

- (void)updateWithModel:(id)model forIndex:(NSUInteger)index{
    
    self.currentIndex = index;
    
    if (!self.collectionView) {
        UICollectionViewFlowLayout *flowLayout;
        if (self.scrollStyle == LIXScrollTopBarContentScrollStyle_dynamic) {
            flowLayout = [[LIXSCrollTopBarContentCellFlowLayout alloc] init];
        }
        else {
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
        }
        
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.itemSize = CGSizeMake(150, 150);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.collectionView = ({
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:flowLayout];
            
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            collectionView.translatesAutoresizingMaskIntoConstraints = YES;
            
            collectionView.dataSource = self;
            collectionView.delegate = self;
            
            collectionView;
        });
        
        [self.contentView addSubview:_collectionView];
    }
    
    NSArray *sections = [[LIXScrollTopBarViewDataSource shareInstance] getContentItemCellClassesForIndex:index];
    
    for (int section = 0; section < [sections count] ; section ++) {
        NSArray *items = [sections objectAtIndex:section];
        for (int item = 0; item < [items count]; item ++) {
            NSString *cellClass = [[items objectAtIndex:item] valueForKey:@"className"];
            
            [_collectionView registerClass:NSClassFromString(cellClass) forCellWithReuseIdentifier:cellClass];
        }
        
    }
    
    [self.collectionView reloadData];

}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [[LIXScrollTopBarViewDataSource shareInstance] setCurrentIndexContentOffsetY:scrollView.contentOffset];
        
        NSLog(@"========set [currentIndex:%lul, contentOffsety:%f]=========",(unsigned long)[LIXScrollTopBarViewDataSource shareInstance].currentIndex, self.collectionView.contentOffset.y);
    }
}

#pragma mark - UICollectionViewDelegate & dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return [[[LIXScrollTopBarViewDataSource shareInstance] getContentItemCellClassesForIndex:_currentIndex] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [[[[LIXScrollTopBarViewDataSource shareInstance] getContentItemCellClassesForIndex:_currentIndex] objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *className = [[[[[LIXScrollTopBarViewDataSource shareInstance] getContentItemCellClassesForIndex:_currentIndex] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"className"];
    
    UICollectionViewCell<LIXScrollTopBarItemProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:className forIndexPath:indexPath];
    id data = [[LIXScrollTopBarViewDataSource shareInstance] getDataForIndex:_currentIndex];

    [cell updateWithData:data];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (validateDelegateWithSelector(self.dataSource, @selector(didSelectedContentItem:atIndexPath:inPage:))) {
        [self.dataSource didSelectedContentItem:collectionView atIndexPath:indexPath inPage:_currentIndex];
    }
}

@end

#pragma mark =========LIXScrollTopBarTitleCellLayoutAttributes============

@implementation LIXScrollTopBarTitleCellLayoutAttributes

- (instancetype)copyWithZone:(NSZone *)zone {
    
    LIXScrollTopBarTitleCellLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.shouldRasterize = self.shouldRasterize;
    attributes.textColor = self.textColor;
    attributes.fontScale = self.fontScale;
    
    return attributes;
}


@end

#pragma mark =============LIXScrollTopBarTitleFlowLayout==================

@implementation LIXScrollTopBarTitleFlowLayout

- (instancetype)init {
    if(!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(kDefatultTopBarCellWidth, kDefaultTopBarHeight);
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return self;
    
}

+ (Class)layoutAttributesClass {
    
    return [LIXScrollTopBarTitleCellLayoutAttributes class];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributesArray) {
        
        if(CGRectIntersectsRect(attributes.frame, rect)) {
            [self applyAttributes:attributes forVisibleRect:rect];
        }
    }
    
    return layoutAttributesArray;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
    [self applyAttributes:layoutAttributes forVisibleRect:visibleRect];
    
    return layoutAttributes;
}

#pragma mark - private method
- (void)applyAttributes:(UICollectionViewLayoutAttributes *)attributes forVisibleRect:(CGRect)visibleRect {
    
    if(attributes.representedElementKind) return;
    
    
    CGFloat distanceFromTargetRectToItem = CGRectGetMidX(self.targetRect) - attributes.center.x;
    CGFloat normalizedDistance = MIN(1, ABS(distanceFromTargetRectToItem / attributes.size.width));
    
    //change color
// this is the rgb method,it is not good enough
//    CGColorRef fromcolor = [[UIColor redColor] CGColor];
//    size_t fromNumComponents = CGColorGetNumberOfComponents(fromcolor);
//    CGFloat fR, fG = 0.0, fB = 0.0;
//    if (fromNumComponents == 4) {
//        const CGFloat *components = CGColorGetComponents(fromcolor);
//        fR = components[0];
//        fG = components[1];
//        fB = components[2];
//    }
    
//    CGFloat red = fR * (1 - normalizedDistance);
//    CGFloat blue = normalizedDistance <= 0.5 ? fB * 2 * normalizedDistance : fB * 2 * (1 -normalizedDistance);
//    CGFloat green = normalizedDistance <= 0.5 ? fG * 2 * normalizedDistance : fG * 2 * (1 -normalizedDistance);
//    
//    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    //this is the HSL method , this is simple!
    UIColor *color = [UIColor colorWithHue:1 saturation:1 brightness:(1 - normalizedDistance) alpha:1];
    
    
    
    CGFloat transformFactor = 0.2;
    
    CGFloat (^DestinationScale)(CGFloat factor) = ^CGFloat (CGFloat factor) {
        
        return distanceFromTargetRectToItem < 0 ? ((1 + factor) + factor * MAX(-1, -ABS(distanceFromTargetRectToItem / attributes.size.width))) : ((1 + factor) - factor * MIN(1, ABS(distanceFromTargetRectToItem / attributes.size.width)));
    };
    
    //change font scale
    CGFloat fontScale ;
    
    if (self.style & LIXScrollTopBarType_fontSize) {
        
        fontScale = DestinationScale(transformFactor);
        
    }
    else {
        
        fontScale = 1.0f;
    }
    [(LIXScrollTopBarTitleCellLayoutAttributes *)attributes setFontScale:fontScale];
    
    // change transform
    CATransform3D transform = CATransform3DIdentity;
    CGAffineTransform affineTransform = CGAffineTransformIdentity;
    CGFloat scale;
    scale = DestinationScale(transformFactor);
    transform = CATransform3DMakeScale(scale, scale, 1);
    
    affineTransform = CGAffineTransformScale(affineTransform, scale, scale);
    
    if (self.style & LIXScrollTopBarType_default) {
        
    }
    
    if (self.style & LIXScrollTopBarType_gradient) {
        [(LIXScrollTopBarTitleCellLayoutAttributes *)attributes setTextColor:color];
    }
    if (self.style & LIXScrollTopBarType_transform &&
        !(self.style & LIXScrollTopBarType_fontSize)) {
        
        attributes.transform = affineTransform;
    }
    
//    [(LIXScrollTopBarTitleCellLayoutAttributes *)attributes setTextColor:color];
}
@end

@implementation LIXScrollTopBarContentFlowLayout

- (void)prepareLayout {
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    NSArray *arr = [self layoutAttributesForElementsInRect:visibleRect];
    for(UICollectionViewLayoutAttributes *attributes in arr) {
        attributes.transform3D = CATransform3DIdentity;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributesArr = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
    for (UICollectionViewLayoutAttributes *attributes in attributesArr) {
        [self applyLayoutAttributes:attributes forRect:visibleRect];
    }
    
    return attributesArr;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
    [self applyLayoutAttributes:attributes forRect:visibleRect];
    
    return attributes;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forRect:(CGRect)rect {
    
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat distanceToCenter = layoutAttributes.center.x - center.x;
//    BOOL isLeft = (distanceToCenter < 0);
    if (self.transformStyle == LIXScrollTopBarContentTransformStyle_solid) {
        CGFloat angle;
        if (distanceToCenter > 0) {
            angle = distanceToCenter / (self.collectionView.frame.size.width / 2) * M_PI_4;
        }
        else {
            angle = - distanceToCenter / (self.collectionView.frame.size.width / 2) * M_PI_4;
        }
        
        CATransform3D transfrom = CATransform3DIdentity;
        transfrom.m34 = -1.0 / 1000;
        transfrom = CATransform3DRotate(transfrom, angle, 0, 1, 0);
        
        layoutAttributes.transform3D = transfrom;
    }
    
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    CGFloat xOffset = 0;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    xOffset = self.currentIndexPath.row * screenWidth;
    return CGPointMake(xOffset, proposedContentOffset.y);
}

@end

@implementation LIXSCrollTopBarContentCellFlowLayout

- (instancetype)init {
    
    if (!(self = [super init])) return nil;
    
    self.minimumInteritemSpacing = 50;
    self.minimumLineSpacing = 50;
    self.itemSize = CGSizeMake(240, 240);
    self.sectionInset = UIEdgeInsetsMake(50, 50, 50, 50);
    
    self.dynamicAniamtor = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPathsSet = [NSMutableSet set];
    
    return self     ;
    
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CGRect visibleRect = CGRectInset((CGRect){
        .origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size
    }, -100, -100);
    
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    
    NSArray *noLongerVisibleBehavious = [self.dynamicAniamtor.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behavior, NSDictionary *bindings) {
        
        BOOL currentVisible = [itemsIndexPathsInVisibleRectSet member:[(UICollectionViewLayoutAttributes *)[[behavior items] firstObject] indexPath]] != nil;
        
        return !currentVisible;
    }]];
    
    [noLongerVisibleBehavious enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self.dynamicAniamtor removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[(UICollectionViewLayoutAttributes *)[[obj items] firstObject] indexPath]];
    }];
    
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        
        BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath] != nil;
        
        return !currentlyVisible;
        
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehavior.length = 0.0f;
        springBehavior.damping = 0.8f;
        springBehavior.frequency = 1.0f;
        
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            
            CGFloat yDistanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y);
            CGFloat xDistanceFromTouch = fabs(touchLocation.x - springBehavior.anchorPoint.x);
            CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch)/ 1500.0f;
            
            if (self.lastestDelta < 0) {
                center.y += MAX(self.lastestDelta, self.lastestDelta * scrollResistance);
            }
            else {
                
                center.y += MIN(self.lastestDelta, self.lastestDelta * scrollResistance);
            }
            item.center = center;
        }
        
        [self.dynamicAniamtor addBehavior:springBehavior];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAniamtor itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAniamtor layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    self.lastestDelta = delta;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.dynamicAniamtor.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehavior, NSUInteger idx, BOOL *stop) {
        
        CGFloat yDistanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabs(touchLocation.x - springBehavior.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = (UICollectionViewLayoutAttributes *)[springBehavior.items firstObject];
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta * scrollResistance);
        }
        else {
            center.y += MIN(delta, delta * scrollResistance);
        }
        item.center = center;
        
        [self.dynamicAniamtor updateItemUsingCurrentState:item];
    }];
    
    return NO;
}


@end
