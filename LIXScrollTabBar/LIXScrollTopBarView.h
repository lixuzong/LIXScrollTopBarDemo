//
//  LIXScrollTopBarView.h
//
//
//  Created by lixu on 2016/12/22.

#import <UIKit/UIKit.h>
@class LIXSCrollTopBarCell;


/**
 这个版本暂时没有可以借鉴的点击动画，暂不支持

 - LIXScrollTopBarTitleSelectedStyle_default: 暂不支持
 - LIXScrollTopBarTitleSelectedStyle_spring: 暂不支持
 */
typedef NS_ENUM(NSUInteger, LIXScrollTopBarTitleSelectedStyle) {
    LIXScrollTopBarTitleSelectedStyle_default,
    LIXScrollTopBarTitleSelectedStyle_spring
};


/**
 提供page滑动的动画，研发中

 - LIXScrollTopBarContentTransformStyle_default: 研发中
 - LIXScrollTopBarContentTransformStyle_solid: 研发中
 */
typedef NS_ENUM(NSUInteger, LIXScrollTopBarContentTransformStyle) {
    LIXScrollTopBarContentTransformStyle_default,
    LIXScrollTopBarContentTransformStyle_solid
};

typedef NS_ENUM(NSUInteger, LIXScrollTopBarType) {
    LIXScrollTopBarType_default = 1 ,
    LIXScrollTopBarType_gradient = 1 << 1,
    LIXScrollTopBarType_transform = 1 << 2,
    LIXScrollTopBarType_fontSize = 1 << 3
};


/**
 contentView里面cell的动画效果，目前有加速效果，由于旋转屏幕的时候会产生问题，暂时不能用

 - LIXScrollTopBarContentScrollStyle_default: 默认效果
 - LIXScrollTopBarContentScrollStyle_dynamic: 加速度效果，调优中
 */
typedef NS_ENUM(NSUInteger, LIXScrollTopBarContentScrollStyle) {
    LIXScrollTopBarContentScrollStyle_default,
    LIXScrollTopBarContentScrollStyle_dynamic
};


@protocol LIXScrollTopBarViewDataSource;
@protocol LIXScrollTopBarViewDelegate;


@interface LIXScrollTopBarView : UIView

@property (nonatomic, assign) BOOL canScrollPage;
@property (nonatomic, assign) LIXScrollTopBarType scrollTitleType;
@property (nonatomic, assign) LIXScrollTopBarTitleSelectedStyle selectedTitleStyle;
@property (nonatomic, assign) BOOL hideTitleBaseLine;
@property (nonatomic, assign) LIXScrollTopBarContentTransformStyle transformStyle;
@property (nonatomic, assign) LIXScrollTopBarContentScrollStyle contentCellScrollStyle;
@property (nonatomic, weak) id<LIXScrollTopBarViewDataSource> dataSource;
@property (nonatomic, weak) id<LIXScrollTopBarViewDelegate> delegate;
@property (nonatomic, assign) UIEdgeInsets titleBarEdgeInsets;

- (void)registerPageItemClass:(Class)className;

@end

@protocol LIXScrollTopBarItemProtocol <NSObject>
@required
- (void)updateWithData:(id)data;
@end

@protocol LIXScrollTopBarViewDelegate <NSObject>

@optional;

/**
 即将滚动改变index时候出发的方法

 @param scrollTopBar LIXScrollTopBarView
 @param index 即将滑到的索引
 */
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar willScrollToIndex:(NSInteger)index;

/**
 滑动到index索引之后触发的方法

 @param scrollTopBar LIXScrollTopBarView
 @param index 已经到达的索引位置
 */
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didScrollToIndex:(NSInteger)index;

/**
 点击顶部title触发的方法

 @param scrollTopBar LIXScrollTopBarView
 @param index title的索引
 */
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedTitleIndex:(NSInteger)index;

/**
 点击item的回调方法

 @param scrollTopBar LIXScrollTopBarView
 @param indexPath item的索引位置
 @param index page的索引
 */
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedContentItemIndex:(NSIndexPath *)indexPath inPage:(NSUInteger)index;

@end

@protocol LIXScrollTopBarViewDataSource <NSObject>

@required


/**
 pages数量

 @param scrollTopBar LIXScrollTopBarView
 @return pages数量
 */
- (NSInteger)numberOfPagesInScrollTopBar:(LIXScrollTopBarView *)scrollTopBar;

/**
 page里面的section数量

 @param index page的index
 @return section数量
 */
- (NSInteger)numberOfScetionsInPage:(NSUInteger)index;

/**
 page里面对应的section的item数量

 @param index page index
 @param section section index
 @return item 数量
 */
- (NSInteger)numberOfItemsAtPageIndex:(NSUInteger)index forSection:(NSInteger)section;

/**
 标题

 @param scrollTopBar LIXScrollTopBarView
 @param cell 所在的itemCell
 @param index 页面索引
 @return 标题，NSString
 */
- (NSString *)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar titleDataForItem:(LIXSCrollTopBarCell *)cell atIndex:(NSInteger)index;

/**
 每个item的数据，这里需要传入每个item的Model，然后在cell的updateData:方法里面可以取到相同类型的数据

 @param scrollTopBar LIXScrollTopBarView
 @param index 页面索引
 @param indexPath item的indexPath
 @return 数据模型
 */
- (id)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar pageItemDataForPage:(NSUInteger)index forIndexPath:(NSIndexPath *)indexPath;


/**
 提供遵循protocol的UICollectionCell类型或者其子类的cell

 @param scrollTopBar LIXScrollTopBarView
 @param index 页面索引
 @param indexPath item对应的索引
 @return  遵循protocol的UICollectionCell类型
 */
- (UICollectionViewCell<LIXScrollTopBarItemProtocol> *)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar pageItemCellForPage:(NSUInteger)index forIndexPath:(NSIndexPath *)indexPath;

@optional
//添加改变两个UICollectionView的edgeInset方法

/**
 改变title bar指示条的大小,默认大小是cell的宽度

 @param scrollTopBar LIXScrollTopBarView
 @param page 指示条
 @return CGSize
 */
- (CGSize)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar sizeForTitleBarBottomLineInpage:(NSUInteger)page;


/**
 返回指定page的edgeInsets

 @param scrollTopBar LIXScrollTopBarView
 @param collectionView 包裹在titleCell的CollectionView
 @param collectionViewLayout CollectionView的layout
 @param section section的索引
 @param page page的索引
 @return page的edgeInsets
 */
- (UIEdgeInsets)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar contentContainerView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insertForSectionAtIndex:(NSUInteger)section forPageIndex:(NSUInteger)page;



//指定layout的方法


@end
