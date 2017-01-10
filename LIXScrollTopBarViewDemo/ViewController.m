//
//  ViewController.m
//  LIXScrollTopBarViewDemo
//
//  Created by lixu on 2016/12/28.
//  Copyright © 2016年 lixuzong. All rights reserved.
//

#import "ViewController.h"

#import "LIXScrollTopBarView.h"

@interface ViewController ()<LIXScrollTopBarViewDelegate, LIXScrollTopBarViewDataSource>

@property (nonatomic, strong) NSArray *tDataSource;

@end

@implementation ViewController

- (void)loadView {
    
    LIXScrollTopBarView *scrollTopBar = [[LIXScrollTopBarView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollTopBar.showTitleBaseLine = YES;
    
    scrollTopBar.scrollTitleType =  LIXScrollTopBarType_fontSize | LIXScrollTopBarType_gradient | LIXScrollTopBarType_transform;
    scrollTopBar.selectedTitleStyle = LIXScrollTopBarTitleSelectedStyle_spring;
    scrollTopBar.contentCellScrollStyle = LIXScrollTopBarContentScrollStyle_dynamic;
    
    scrollTopBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    scrollTopBar.delegate = self;
    scrollTopBar.dataSource = self;
    
    self.view = scrollTopBar;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupTestData];
}


#pragma mark - private method
- (void)setupTestData {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < 20; i ++) {
        NSString *title = [NSString stringWithFormat:@"title%d",i];
        
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

- (NSInteger )numberOfItemsInScrollTopBar:(LIXScrollTopBarView *)scrollTopBar {
    return [self.tDataSource count];
}

- (NSInteger)numberScetionsInContentView:(UICollectionView *)contentView {
    return 1;
}

- (NSInteger)numberOfItemsInContentView:(LIXSCrollTopBarCell *)cell atIndex:(NSInteger)index{
    
    return [(NSArray *)[self.tDataSource[index] valueForKey:@"data"] count];
}

- (id)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar titleDataForItem:(LIXSCrollTopBarCell *)cell atIndex:(NSInteger)index {
    
    return self.tDataSource[index];
}

- (id)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar contentItemDataForItem:(LIXSCrollTopBarCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    return [self.tDataSource[indexPath.row] valueForKey:@"data"];
}

#pragma mark - LIXScrollTopBarViewDelegate

- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar willScrollToIndex:(NSInteger)index {
    
    NSLog(@"=======scrollTopBarwillScrollToIndex: %ld",(long)index);
}
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didScrollToIndex:(NSInteger)index {
    
    NSLog(@"=======scrollTopBarDidScrollToIndex: %ld",(long)index);
}
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedTitleIndex:(NSInteger)index {
    
    NSLog(@"=======scrollTopBardidSelectedTitleIndex: %ld",(long)index);
}
- (void)scrollTopBar:(LIXScrollTopBarView *)scrollTopBar didSelectedContentItemIndex:(NSIndexPath *)indexPath inContainerView:(UICollectionView *)containerView{
    
    NSLog(@"=======scrollTopBardidSelectedContentItemIndex: %ld ==%ld",(long)indexPath.section,(long)indexPath.row);
}

@end
