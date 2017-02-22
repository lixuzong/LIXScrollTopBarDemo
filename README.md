

# LIXScrollTopBarView
首先主要提供了基础的两种切换页面的效果，提供了多种顶部titleBar的多种选中效果。包括颜色提供渐变和突变两种样式，大小提供了根据颜色条靠近的距离时间大小的渐变，可以定义底部选中条的颜色，可以定义每个分类下选中条的大小。最近看到优酷、微博等app在选中条上面做文章，感觉也是挺有心意，以后会考虑加上。底部的内容视图的话可以编辑任意一个cell，总之下面的内容视图就是一个UICollectionView，可以实现各种自定义的layout。

## 使用方法
首先是titleBar的几种样式可供选择，在使用的时候可以直接设置scrollTitleType属性就可以了，下面提供几种style的默认样式。当然你也可以传入自己的flowLayout。

+ LIXScrollTopBarType_default 
![展示图片](/Users/lixu/Desktop/default.gif)

+ LIXScrollTopBarType_transform & LIXScrollTopBarType_default
![defaultcolor&transform](/Users/lixu/Desktop/transform&color.gif)

+ LIXScrollTopBarType_transform & LIXScrollTopBarType_gradient
![colorGradient](/Users/lixu/Desktop/colorGradient.gif)

> 各种样式可以叠加使用，也可以单独使用，叠加的时候可以出现各种效果，就不一一展示了。

关于内容视图的滚动也提供了一种加速度的样式，最近看到百度外卖的app有加入这种模式。但是在实践的过程中发现，这种方式在滑动过程中进行屏幕旋转的过程中会出现crash。如不不支持横竖屏适配的话是完全没问题的。

+ contentCellScrollStyle = LIXScrollTopBarContentScrollStyle_dynamic
![加速度](/Users/lixu/Desktop/加速度效果.gif)

加速度效果使用的是dynamic框架，是苹果提供用来模仿物理效果的。其原理也是计算每个cell距离触点的位置，然后改变每个cell的frame，在frame改变的过程中加入物理加速度的效果。

## 结构
![结构图](/Users/lixu/Desktop/屏幕快照 2017-02-21 16.54.50.png)    
如图所示，使用的类比较多，因为是在UICollectionView的基础上进行的封装，所以遵守的是UICollectionView的使用方法。

+ LIXScrollTopBarView是主要的类，主要是管理上下两个UICollectionView的同步问题，主要是要根据下面UICollectionView的移动距离，来同步上面UICollectionView的选中态。
+ LIXScrollTopBarTitleBarView可能根据名字很难看出来是干什么的，这个是下面的指示条，如果你困惑为什么一个指示条还要单独建一个类的话，其实就是万恶的设计想要每个title分类下都展示和文字同样长度的指示条（为什么说是万恶的设计那，因为他最后又给去掉了，让展示同样长度的指示条）
+ LIXScrollTopBarTitleCell是分类的cell，LIXScrollTopBarCell是下面UICollectionView的Cell，里面的又是一个UICollectionView，最里面的cell是LIXScrollTopBarContentCell。
+ flowLayout，因为是简单的流式布局，所以直接使用的是flowLayout，对于flowLayout的话，就是每个UICollectionView就对应一个flowLayout
+ model分类下的是每个页面的model（LIXScrollTopBarViewDataSourceModel）和整个页面的数据（LIXScrollTopBarViewDataSource），整个页面的数据，也可以说成是manager吧。
+ LIXScrollTopBarTitleCellLayoutAttributes这个是定制的UICollectionViewCellAttributes，因为有部分属性需要改变，但是attributes类并没有提供，这里继承扩展一些。

> 后期优化使用工厂方法来创建对象，还有就是类的命名问题，真的成了开发效率的瓶颈了，这个地方需要加强一下。

## 核心思想
核心思想是最大的可定制化吧，刚开始的时候想的是可以使用viewController之间的自定义转场也可以实现这种效果，而且可以完美的管理每个view的生命周期；或者是直接使用ScrollView，计算每个page页面所在的位置，像iCarousel那样建立自己的重用队列，管理重用问题；当然也可以像iCarousel那样，不使用scrollView，直接计算每个page页面的transform，自己管理重用。后来考虑到UICollectionView有现成的API可以调用，而且对于flowLayout分离的方式可以最大程度的提供灵活的切换方式（完全可以新建一个flowLayout，创建不拘于实现过的几种方式）。

## UICollectionView基础

并没有使用很复杂的UICollectionView的知识吧，主要的就是flowLayout和每个cell的交互花了点心思，这里还是需要一些UICollectionView的基础知识的。下面列出来几点用到的。

### 自定义UICollectionViewCellAttributes
attributes类提供的功能主要是定制cell的frame，transFrom等属性，一个attributes对应一个cell，管理一个cell的layout。但是有些没有进行默认的提供，比如我们想改变字体的颜色，我们就可以定制其子类，加上一个fontColor属性，当滑动到相应的cell的时候就可以发生刷新cell的样式。这是每个title cell可以定制化的基础。

### UICollectionViewFlowLayout与Attributes的交互
既然每个cell都对应一个attributes属性的话，那么layout做的事情就是管理这些attributes的变化。UICollectionViewFlowLayout是UICollectionViewLayout的定制子类，是一种特定的流式布局，用起来比直接使用layout简单一下，定制起来也有些不同。这里只说到用到的flowLayout。在我的理解看来，layout类的功能就是刷新每个attributes。

```objective-C

+ (Class)layoutAttributesClass {
    
    return [JDScrollTopBarTitleCellLayoutAttributes class];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributesArray) {
        
        //如果判断交集的话会出现复用的时候属性不对的问题
//        if(CGRectIntersectsRect(attributes.frame, rect)) {
            [self applyAttributes:attributes forVisibleRect:rect];
//        }
    }
    
    return layoutAttributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
    [self applyAttributes:layoutAttributes forVisibleRect:visibleRect];
    
    return layoutAttributes;
}

```

一个是返回attributes数组，一个是返回每个indexPath对应下的attributes。*layoutAttributesClass*方法是将默认的attributes类替换成我们的attributes类， 
*shouldInvalidateLayoutForBoundsChange*是bounds发生改变的时候更新attributes，这里boundsChange也可以理解成UIScrollVIew滚动，因为UIScrollView的实现方式就是改变view的bounds，所以在滚动的时候就会更新attributes了。

## UICollectionViewCell接收Attributes属性
```objective-c
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    self.titleLabel.textColor = [(JDScrollTopBarTitleCellLayoutAttributes *)layoutAttributes textColor];
    
    //使用shouldRasterize会导致label文字模糊
    //    self.layer.shouldRasterize = [layoutAttributes valueForKey:@"shouldRasterize"];
    
    CGFloat fontSize = 16 * [(JDScrollTopBarTitleCellLayoutAttributes *)layoutAttributes fontScale];
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.layer.affineTransform = layoutAttributes.transform;
}
```
在这个方法里面，attributes发生更新的时候，cell就能过得到通知，应该是UICollectionView在底层做了一个观察者吧。layer有一个shouldRasterize属性，该方法可以栅格化layer，并且触发离屏渲染，缓存栅格化之后的数据，这样在cell比较多的情况下会有很好的内存表现。但是这里会引发一个问题，就是label问题模糊，不知道是否是渲染文字的时候出现的问题，有大神知道的话望留言告知。

# 具体实现
基于UICollectionView的以上各种，完成了ScrollTopBar。通过TopBarCell和titleCell之间的比例，可以计算出滑动之后标题指示条的位置。根据指示条中心的位置和titleCell的位置之间的差值来计算选中的titleCell。具体实现可以参照源码。具体讲一下开发中遇到的问题。

### 问题及解决
+ 最棘手的问题是，在滑动底部的UICollectionView的时候，没办法让titleBar的cell的attributes发生更新操作。这里的解决方法是在didScroll方法里面计算出相应的cell，并且主动调用cell的applyAttributes方法。
+ 需要定制选中指示条，但是指示条是计算选中cell的基础，不能随意变动，所以设计成一个view树，最外层的view是透明的，里面的子view提供颜色，这样就可以根据需求给指示条做动画，也可以根据每个不同的cell做不同的变化等。
+ 关于数据的同步，感觉处理的不够好，但是为了偷懒，是用一个单例来实现了，在网上也找到替换单例的方法，就是注入依赖替换单例，说白了就是在创建的时候将数据传入，跟JS里面传递prop有点类似吧。