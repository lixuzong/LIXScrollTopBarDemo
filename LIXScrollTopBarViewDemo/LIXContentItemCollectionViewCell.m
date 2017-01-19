//
//  LIXContentItemCollectionViewCell.m
//  LIXScrollTopBarViewDemo
//
//  Created by lixu on 2017/1/18.
//  Copyright © 2017年 lixuzong. All rights reserved.
//

#import "LIXContentItemCollectionViewCell.h"

@implementation LIXContentItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor redColor];
    
    return self;
}

- (void)updateWithData:(id)data {
    
}

@end
