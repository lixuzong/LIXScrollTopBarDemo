//
//  LIXScrollTopBarView.m
//
//  Created by lixu on 2016/12/22.
//

#import "LIXScrollTopBarView.h"

static NSString *const kTitleCellIdentifier = @"LIXScrollTopBarTitleCell";
static NSString *const kContentCellIdentifier = @"LIXScrollTopBarContentCell";
static NSString *const kContentItemCellIdentifier = @"kContentItemCellIdentifier";
static CGFloat const kDefaultTopBarHeight = 60;
static CGFloat const kDefatultTopBarCellWidth = 80;

BOOL validateDelegateWithSelector(NSObject *delegate, SEL selector) {
    if (delegate && [delegate respondsToSelector:selector]) {
        return YES;
    }
    return NO;
}

@protocol LIXScrollTopBarViewContentCellDataSource <NSObject>

@required

- (NSInteger)numberOfSectionInContentCollectionView:(UICollectionView *)contentCollectionView;
- (NSInteger)contentCollectionView:(UICollectionView *)contentCollectionView numberOfItemsInSection:(NSInteger)section;
- (void)didSelectedContentItem:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

@end


@interface LIXScrollTopBarTitleCellLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) BOOL shouldRasterize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat fontSize;

@end

@interface LIXSCrollTopBarCell : UICollectionViewCell

- (void)updateWithModel:(id)model;

@property (nonatomic, strong) NSString *cellClassName;
@property (nonatomic, weak) id<LIXScrollTopBarViewContentCellDataSource> dataSource;

@end

@implementation LIXSCrollTopBarCell

- (void)updateWithModel:(id)model {};

@end

@interface LIXScrollTopBarTitleCell : LIXSCrollTopBarCell

@property (nonatomic, strong) UILabel *titleLabel;


@end

@interface LIXScrollTopBarContentCell : LIXSCrollTopBarCell

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


@interface LIXScrollTopBarView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,LIXScrollTopBarViewContentCellDataSource>

//data source
@property (nonatomic, strong) NSArray *tDataSource;//数据源

@property (nonatomic, strong) UIView *topBarbaseLine;//下划线
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
    
    //config data
    self.topBarHeight = _topBarHeight?: kDefaultTopBarHeight;
    self.baseLineSize = CGSizeMake(80, 2);
    self.topBarTitleCellSize = CGSizeMake(kDefatultTopBarCellWidth, kDefaultTopBarHeight);
    self.backgroundColor = [UIColor redColor];
    
    [self setupTestData];
    
    [self setupView];
    
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

- (void)setupView {
    
    [self addSubview:self.topBarCollectionView];
//    [_topBarCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self);
//        make.right.equalTo(self);
//        make.top.equalTo(self);
//        make.height.mas_equalTo(self.topBarHeight);
//    }];
//    [NSLayoutConstraint constraintWithItem:self.topBarCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
//    [NSLayoutConstraint constraintWithItem:self.topBarCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
//    [NSLayoutConstraint constraintWithItem:self.topBarCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
//    [NSLayoutConstraint constraintWithItem:self.topBarCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.topBarHeight];
    
    [self addSubview:self.contentCollectionView];
//    [_contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self);
//        make.right.equalTo(self);
//        make.top.equalTo(_topBarCollectionView.mas_bottom);
//        make.bottom.equalTo(self);
//    }];
//    
//    [NSLayoutConstraint constraintWithItem:self.contentCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
//    [NSLayoutConstraint constraintWithItem:self.contentCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
//    [NSLayoutConstraint constraintWithItem:self.contentCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//    [NSLayoutConstraint constraintWithItem:self.contentCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topBarCollectionView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
}

- (void)setupNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    [self.contentCollectionView reloadData];
    [self.topBarCollectionView reloadData];
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

- (NSInteger)numberOfSectionInContentCollectionView:(UICollectionView *)contentCollectionView {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberScetionsInContentView:)]) {
        return [self.dataSource numberScetionsInContentView:contentCollectionView];
    }
    
    return 0;
}

- (NSInteger)contentCollectionView:(UICollectionView *)contentCollectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInContentView:atIndex:)]) {
        
        return [self.dataSource numberOfItemsInContentView:contentCollectionView atIndex:self.currentIndex];
    }
    
    return 0;
}

- (void)didSelectedContentItem:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didSelectedContentItemIndex:inContainerView:))) {
        [self.delegate scrollTopBar:self didSelectedContentItemIndex:indexPath inContainerView:collectionView];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInScrollTopBar:)]) {
        
        //NSLog(@"======mainCollectionViewItemsCount : %ld",(long)[self.dataSource numberOfItemsInScrollTopBar:self]);
        
       return [self.dataSource numberOfItemsInScrollTopBar:self];
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
    }
    else {
        cellIdentifier = kContentCellIdentifier;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        model = [self.dataSource scrollTopBar:self contentItemDataForItem:cell atIndexPath:indexPath];
        cell.dataSource = self;
        cell.cellClassName = @"UICollectionViewCell";
    }

    [cell updateWithModel:model];
    
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



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.topBarCollectionView) {
        
        if (self.selectedTitleStyle == LIXScrollTopBarTitleSelectedStyle_spring) {
            
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            CGRect frame = cell.frame;
            [UIView animateWithDuration:0.1
                                  delay:0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cell.frame = CGRectInset(cell.frame, 5, 5);
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
        
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
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
        
        CGPoint originToTitleView = [self convertPoint:self.topBarbaseLine.frame.origin fromView:self.topBarCollectionView];
        
        if (originToTitleView.x + CGRectGetWidth(_topBarbaseLine.bounds) > CGRectGetMaxX(self.frame)
            || originToTitleView.x < CGRectGetMinX(self.frame)) {
            
            [self.topBarCollectionView scrollRectToVisible:self.topBarbaseLine.frame animated:NO];
        }
        
        self.attributesArray = [self.topBarFlowLayout layoutAttributesForElementsInRect:CGRectMake(0, 0, self.topBarCollectionView.contentSize.width, self.topBarCollectionView.contentSize.height)];
        for (UICollectionViewLayoutAttributes *attributes in self.attributesArray) {
            
            LIXScrollTopBarTitleCell *cell = (LIXScrollTopBarTitleCell *)[self.topBarCollectionView cellForItemAtIndexPath:attributes.indexPath];
            [cell applyLayoutAttributes:attributes];
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
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentCollectionView) {
        self.isScrolling = NO;
        
        NSIndexPath *indexPath = [self.topBarCollectionView indexPathForItemAtPoint:self.topBarbaseLine.center];
        if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didScrollToIndex:))) {
            [self.delegate scrollTopBar:self didScrollToIndex:indexPath.row];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentCollectionView) {
        self.isDragging = NO;
        
        NSIndexPath *indexPath = [self.topBarCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.topBarbaseLine.frame), 0)];
        self.currentIndex = indexPath.row;
        
        if (validateDelegateWithSelector(self.delegate, @selector(scrollTopBar:didScrollToIndex:))) {
            [self.delegate scrollTopBar:self didScrollToIndex:indexPath.row];
        }
    }
    
}

#pragma mark - get & set method

- (void)setCurrentIndex:(NSInteger)currentIndex {
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
    
    _topBarbaseLine = ({
       
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBarHeight - self.baseLineSize.height, self.baseLineSize.width, self.baseLineSize.height)];
        line.backgroundColor = (self.baseLineColor ? : [UIColor redColor]);
        line;
    });
    
    return _topBarbaseLine;
}

- (void)setBaseLineColor:(UIColor *)baseLineColor {
    
    _baseLineColor = baseLineColor;
    self.topBarbaseLine.backgroundColor = baseLineColor;
}

- (void)setBaseLineSize:(CGSize)baseLineSize {
    
    _baseLineSize = baseLineSize;
    self.topBarbaseLine.frame = CGRectMake(self.topBarbaseLine.frame.origin.x, self.topBarbaseLine.frame.origin.y, baseLineSize.width, baseLineSize.height);
}

- (UICollectionView *)topBarCollectionView {
    
    if(_topBarCollectionView) return _topBarCollectionView;
    
    _topBarCollectionView = ({
        self.topBarFlowLayout = [[LIXScrollTopBarTitleFlowLayout alloc] init];
        self.topBarFlowLayout.style = self.scrollTitleType;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.topBarHeight) collectionViewLayout:_topBarFlowLayout];
        
        collectionView.backgroundColor = [UIColor yellowColor];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        collectionView.translatesAutoresizingMaskIntoConstraints = YES;
        
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
        
        collectionView.backgroundColor = [UIColor lightGrayColor];
        
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.translatesAutoresizingMaskIntoConstraints = YES;
        
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.pagingEnabled = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[LIXScrollTopBarContentCell class] forCellWithReuseIdentifier:kContentCellIdentifier];
        collectionView;
    });
    
        return _contentCollectionView;
}

@end


@implementation LIXScrollTopBarTitleCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) return nil;
    
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        label.font = [UIFont systemFontOfSize:14];
//        label.backgroundColor = [UIColor yellowColor];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    [self.contentView addSubview:_titleLabel];
    
//    self.contentView.backgroundColor = [UIColor greenColor];
    
//    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.contentView);
//    }];
    
    return self;
}

- (void)prepareForReuse {
    
    self.titleLabel.text = @"";
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)updateWithModel:(id)model {
    
    self.titleLabel.text = [model valueForKey:@"title"];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    self.titleLabel.textColor = [layoutAttributes valueForKey:@"textColor"];
//    NSLog(@"indexPath:%ld========color:%@",(long)layoutAttributes.indexPath.row, self.titleLabel.textColor);
    self.layer.shouldRasterize = [layoutAttributes valueForKey:@"shouldRasterize"];
    //CGFloat fontSize = [(LIXScrollTopBarTitleCellLayoutAttributes*)layoutAttributes fontSize];
    //self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.layer.affineTransform = layoutAttributes.transform;
}



@end

@interface LIXScrollTopBarContentCell ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) id model;

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
    
    self.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_contentLabel];
    
    return self;
}

- (void)prepareForReuse {
    
    self.contentLabel.text = @"";
}

- (void)updateWithModel:(id)model {
    
    self.model = model;
    
    if (!self.collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.itemSize = CGSizeMake(300, 300);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.collectionView = ({
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:flowLayout];
            
            collectionView.backgroundColor = [UIColor grayColor];
            collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            collectionView.translatesAutoresizingMaskIntoConstraints = YES;
            
            collectionView.dataSource = self;
            collectionView.delegate = self;
            
            Class cellClass = NSClassFromString(self.cellClassName);
            [collectionView registerClass:cellClass forCellWithReuseIdentifier:kContentItemCellIdentifier];
            collectionView;
        });
        
        [self.contentView addSubview:_collectionView];
        
    }
    
    [self.collectionView reloadData];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    

    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSectionInContentCollectionView:)]) {
        
        //NSLog(@"===========contentCollectioViewSectionCount:%ld",(long)[self.dataSource numberOfSectionInContentCollectionView:self.collectionView]);
        
        return [self.dataSource numberOfSectionInContentCollectionView:self.collectionView];
    }
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [(NSArray *)_model count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LIXSCrollTopBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContentItemCellIdentifier forIndexPath:indexPath];
    id model = [(NSArray *)_model objectAtIndex:indexPath.row];
//    if (self.dataSource && [self.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        
//        cell =  [self.dataSource contentCollectionView:collectionView cellForItemAtIndexPath:indexPath];
//    }
    
//    if (!cell) {
//        cell = [NSClassFromString(self.cellClassName) new];
//    }
    
//    if (self.dataSource && [self.dataSource respondsToSelector:@selector(contentItem:dataForIndexPath:)]) {
//        model = [self.dataSource contentItem:cell dataForIndexPath:indexPath];
//    }
    
    for (UIView *view in cell.contentView.subviews) {
        if (view.tag == 1000) {
            UILabel *label = (UILabel *)view;
            label.text = model;
        }
        
        return cell;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.tag = 1000;
    [cell.contentView addSubview:label];
    
    label.text = model;
    
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (validateDelegateWithSelector(self.dataSource, @selector(didSelectedContentItem:atIndexPath:))) {
        [self.dataSource didSelectedContentItem:collectionView atIndexPath:indexPath];
    }
}

@end

#pragma mark =========LIXScrollTopBarTitleCellLayoutAttributes============

@implementation LIXScrollTopBarTitleCellLayoutAttributes

- (instancetype)copyWithZone:(NSZone *)zone {
    
    LIXScrollTopBarTitleCellLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.shouldRasterize = self.shouldRasterize;
    attributes.textColor = self.textColor;
    attributes.fontSize = self.fontSize;
    
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
    
//    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
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
    
    CGColorRef fromcolor = [[UIColor redColor] CGColor];
    size_t fromNumComponents = CGColorGetNumberOfComponents(fromcolor);
    CGFloat fR, fG = 0.0, fB = 0.0;
    if (fromNumComponents == 4) {
        const CGFloat *components = CGColorGetComponents(fromcolor);
        fR = components[0];
        fG = components[1];
        fB = components[2];
    }
    
    CGFloat red = fR * (1 - normalizedDistance);
    CGFloat blue = normalizedDistance <= 0.5 ? fB * 2 * normalizedDistance : fB * 2 * (1 -normalizedDistance);
    CGFloat green = normalizedDistance <= 0.5 ? fG * 2 * normalizedDistance : fG * 2 * (1 -normalizedDistance);
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
//    NSLog(@"========%f=========",normalizedDistance);
    
    CATransform3D transform = CATransform3DIdentity;
    
    CGAffineTransform affineTransform = CGAffineTransformIdentity;
    
    CGFloat scale;
    if (normalizedDistance >= 1) {
        scale = 1;
    }
    else {
        scale = 2 - normalizedDistance;
    }
    transform = CATransform3DMakeScale(scale, scale, 1);
    
    affineTransform = CGAffineTransformScale(affineTransform, scale, scale);
    //attributes.transform3D = transform;
    
    if (self.style == 0) {
        return;
    }
    
    if (self.style & LIXScrollTopBarType_default) {
        
    }
    
    if (self.style & LIXScrollTopBarType_gradient) {
        [(LIXScrollTopBarTitleCellLayoutAttributes *)attributes setTextColor:color];
    }
    if (self.style & LIXScrollTopBarType_transform) {
        attributes.transform = affineTransform;
    }
    [(LIXScrollTopBarTitleCellLayoutAttributes *)attributes setTextColor:color];
    //[(LIXScrollTopBarTitleCellLayoutAttributes *)attributes setFontSize:fontSize];
    
//    NSLog(@"color:%@===distance:%f",color,normalizedDistance);
//    [(LIXScrollTopBarTitleCellLayoutAttributes *)attributes setShouldRasterize:YES];
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
    NSLog(@"attributes %@=======disatanceTo center : %f",layoutAttributes, distanceToCenter);
    if (self.transformStyle == LIXScrollTopBarContentTransformStyle_solid) {
        CGFloat angle;
        if (distanceToCenter > 0) {
            angle = distanceToCenter / (self.collectionView.frame.size.width / 2) * M_PI_4;
        }
        else {
            angle = - distanceToCenter / (self.collectionView.frame.size.width / 2) * M_PI_4;
        }
        
        //    CATransform3D perspective = CATransform3DIdentity;
        //    perspective.m34 = -1.0 / 500.0;
        //    perspective = CATransform3DRotate(perspective, - M_PI_4, 1, 0, 0);
        //    layoutAttributes.transform3D = perspective;
        
        CATransform3D transfrom = CATransform3DIdentity;
        transfrom.m34 = -1.0 / 1000;
        transfrom = CATransform3DRotate(transfrom, angle, 0, 1, 0);
        
        layoutAttributes.transform3D = transfrom;
    }
    
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    CGFloat xOffset = 0;
    xOffset = self.currentIndexPath.row *
    (CGRectGetWidth([UIScreen mainScreen].bounds));
    return CGPointMake(xOffset, proposedContentOffset.y);
}

@end
