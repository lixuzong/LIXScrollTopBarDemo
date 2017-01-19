//
//  ViewController.m
//  LIXScrollTopBarViewDemo
//
//  Created by lixu on 2016/12/28.
//  Copyright © 2016年 lixuzong. All rights reserved.
//

#import "ViewController.h"

#import "LIXScrollTopBarView.h"
#import "LIXContentItemCollectionViewCell.h"
#import "LIXPage2CollectionViewCell.h"

@interface ViewController ()<LIXScrollTopBarViewDelegate, LIXScrollTopBarViewDataSource>

@property (nonatomic, strong) NSArray *tDataSource;

@end

@implementation ViewController

- (void)loadView {
    
    [self setupTestData];
    
    LIXScrollTopBarView *scrollTopBar = [[LIXScrollTopBarView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollTopBar.hideTitleBaseLine = NO;
    scrollTopBar.canScrollPage = YES;
    
    scrollTopBar.scrollTitleType = LIXScrollTopBarType_gradient | LIXScrollTopBarType_transform;
    [scrollTopBar registerPageItemClass:[UICollectionViewCell class]];
//    scrollTopBar.selectedTitleStyle = LIXScrollTopBarTitleSelectedStyle_spring;
//    scrollTopBar.contentCellScrollStyle = LIXScrollTopBarContentScrollStyle_dynamic;
    
    scrollTopBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    scrollTopBar.delegate = self;
    scrollTopBar.dataSource = self;
    
    scrollTopBar.titleBarEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 50);
    
    self.view = scrollTopBar;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}


#pragma mark - private method
- (void)setupTestData {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < 20; i ++) {
        NSString *title = [NSString stringWithFormat:@"热点%d",i];
        
        NSMutableArray *arr = [NSMutableArray array];
        for (int j = 0; j < 20 + i; j ++) {
            NSString *content = [NSString stringWithFormat:@"index%d",j];
            [arr addObject:content];
        }
        
        NSDictionary *dic = @{
                              @"title":title,
                              @"data":arr
                              };
        [tempArray addObject:dic];
    }
    self.tDataSource = [tempArray copy];
}

#pragma mark - LIXScrollTopBarViewDataSource

- (NSInteger )numberOfPagesInScrollTopBar:(LIXScrollTopBarView *)scrollTopBar {
    return [self.tDataSource count];
}

- (NSInteger)numberOfScetionsInPage:(NSUInteger)index {
    return 1;
}

- (NSInteger)numberOfItemsAtPageIndex:(NSUInteger)index forSection:(NSInteger)section{
    
    return [(NSArray *)[self.tDataSource[index] valueForKey:@"data"] count];
}

- (NSString *)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar titleDataForItem:(LIXSCrollTopBarCell *)cell atIndex:(NSInteger)index {
    
    return self.tDataSource[index];
}

- (id)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar pageItemDataForPage:(NSUInteger)index forIndexPath:(NSIndexPath *)indexPath {
    
    return [[self.tDataSource[index] valueForKey:@"data"] objectAtIndex:indexPath.row];
}

- (UICollectionViewCell<LIXScrollTopBarItemProtocol> *)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar pageItemCellForPage:(NSUInteger)index forIndexPath:(NSIndexPath *)indexPath {
    
    if (index == 1) {
        LIXPage2CollectionViewCell *cell = [[LIXPage2CollectionViewCell alloc] init];
        return cell;
    }
    LIXContentItemCollectionViewCell *cell = [[LIXContentItemCollectionViewCell alloc] init];
    
    [cell updateWithData:[[self.tDataSource[index] valueForKey:@"data"] objectAtIndex:indexPath.row]];
    
    return cell;
}

//- (UIEdgeInsets)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar titleContainerView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insertForSectionAtIndex:(NSUInteger)section {
//    
//    return UIEdgeInsetsMake(0, 50, 0, 50);
//}

- (CGSize)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar sizeForTitleBarBottomLineInpage:(NSUInteger)page {
    
    if (page == 1) {
        return CGSizeMake(100, 2);
    }
    return CGSizeMake(50, 3);
}

#pragma mark - LIXScrollTopBarViewDelegate

- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar willScrollToIndex:(NSInteger)index {
    
//    NSLog(@"=======scrollTopBarwillScrollToIndex: %ld",(long)index);
}
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didScrollToIndex:(NSInteger)index {
    
//    NSLog(@"=======scrollTopBarDidScrollToIndex: %ld",(long)index);
}
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedTitleIndex:(NSInteger)index {
    
//    NSLog(@"=======scrollTopBardidSelectedTitleIndex: %ld",(long)index);
}
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedContentItemIndex:(NSIndexPath *)indexPath inPage:(NSUInteger)index{
    
    NSLog(@"=======scrollTopBardidSelectedContentItemIndex: %ld => %ld => %ld",(long)index,(long)indexPath.section,(long)indexPath.row);
}

@end
