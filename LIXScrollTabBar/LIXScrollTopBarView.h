//
//  LIXScrollTopBarView.h
//
//
//  Created by lixu on 2016/12/22.

#import <UIKit/UIKit.h>
@class LIXSCrollTopBarCell;

typedef NS_ENUM(NSUInteger, LIXScrollTopBarTitleSelectedStyle) {
    LIXScrollTopBarTitleSelectedStyle_default,
    LIXScrollTopBarTitleSelectedStyle_spring
};

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

typedef NS_ENUM(NSUInteger, LIXScrollTopBarContentScrollStyle) {
    LIXScrollTopBarContentScrollStyle_default,
    LIXScrollTopBarContentScrollStyle_dynamic
};


@protocol LIXScrollTopBarViewDataSource;
@protocol LIXScrollTopBarViewDelegate;


@interface LIXScrollTopBarView : UIView

@property (nonatomic, assign) LIXScrollTopBarType scrollTitleType;
@property (nonatomic, assign) LIXScrollTopBarTitleSelectedStyle selectedTitleStyle;
@property (nonatomic, assign) BOOL showTitleBaseLine;
@property (nonatomic, assign) LIXScrollTopBarContentTransformStyle transformStyle;
@property (nonatomic, assign) LIXScrollTopBarContentScrollStyle contentCellScrollStyle;
@property (nonatomic, weak) id<LIXScrollTopBarViewDataSource> dataSource;
@property (nonatomic, weak) id<LIXScrollTopBarViewDelegate> delegate;

@end

@protocol LIXScrollTopBarViewDelegate <NSObject>

@optional;
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar willScrollToIndex:(NSInteger)index;
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didScrollToIndex:(NSInteger)index;
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedTitleIndex:(NSInteger)index;
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedContentItemIndex:(NSIndexPath *)indexPath inContainerView:(UICollectionView *)containerView;

@end

@protocol LIXScrollTopBarViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInScrollTopBar:(LIXScrollTopBarView *)scrollTopBar;
- (NSInteger)numberScetionsInContentView:(UICollectionView *)contentView;
- (NSInteger)numberOfItemsInContentView:(UICollectionView *)containerView atIndex:(NSInteger)index;


- (id)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar titleDataForItem:(LIXSCrollTopBarCell *)cell atIndex:(NSInteger)index;
- (id)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar contentItemDataForItem:(LIXSCrollTopBarCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGSize)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar layout:(UICollectionViewLayout *)contentViewLayout sizeForItemAtIndex:(NSInteger)index;
- (UICollectionViewLayout *)layoutForContentItem:(UICollectionViewCell *)containerView;
- (UICollectionViewCell *)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar cellForContentItemAtIndex:(NSInteger)index;
- (UICollectionViewCell *)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar cellForTitleItemAtIndex:(NSInteger)index;

@end
