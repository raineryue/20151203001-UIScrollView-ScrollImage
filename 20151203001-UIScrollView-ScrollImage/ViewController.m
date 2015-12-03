//
//  ViewController.m
//  20151203001-UIScrollView-ScrollImage
//
//  Created by Rainer on 15/12/3.
//  Copyright © 2015年 Rainer. All rights reserved.
//

#import "ViewController.h"

#define kViewPadding 10
#define kImageCount 5

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *imageScrollView;
@property (nonatomic, weak) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.循环添加图片到滚动视图中
    for (int i = 0; i < kImageCount; i++) {
        // 1.1.创建图片视图并设置图片
        NSString *imageName = [NSString stringWithFormat:@"img_%02d", i + 1];
    
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        
        // 1.2.设置图片位置大小
        CGFloat imageViewW = self.imageScrollView.bounds.size.width;
        CGFloat imageViewH = self.imageScrollView.bounds.size.height;
        CGFloat imageViewX = i * imageViewW;
        CGFloat imageViewY = 0;
        
        imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);

        // 1.3.将图片视图添加到滚动视图上
        [self.imageScrollView addSubview:imageView];
    }
    
    // 2.初始化分页控件页数
    self.pageControl.currentPage = 0;
    
    // 3.添加定时器
    [self addTimer];
}

#pragma mark - 控件懒加载

/**
 *  懒加载创建图片滚动视图
 */
- (UIScrollView *)imageScrollView {
    if (nil == _imageScrollView) {
        // 创建并设置Frame
        CGFloat imageScrollViewX = kViewPadding;
        CGFloat imageScrollViewY = 20;
        CGFloat imageScrollViewW = self.view.bounds.size.width - kViewPadding * 2;
        CGFloat imageScrollViewH = 130;
        
        UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(imageScrollViewX, imageScrollViewY, imageScrollViewW, imageScrollViewH)];
        
        // 设置contentSize
        CGFloat imageScrollViewContentW = imageScrollViewW * kImageCount;
        CGFloat imageScrollViewContentH = imageScrollViewH;
        
        imageScrollView.contentSize = CGSizeMake(imageScrollViewContentW, imageScrollViewContentH);
        
        // 设置滚动试图滚动条
        imageScrollView.showsHorizontalScrollIndicator = NO;
        imageScrollView.showsVerticalScrollIndicator = NO;
        
        // 设置滚动视图分页
        imageScrollView.pagingEnabled = YES;
        
        // 设置代理
        imageScrollView.delegate = self;
        
        // 弹簧效果设置
        imageScrollView.bounces = NO;
        
        // 添加到控制器跟视图上
        _imageScrollView = imageScrollView;
        
        [self.view addSubview:_imageScrollView];
    }
    
    return _imageScrollView;
}

/**
 *  懒加载分页控件
 */
- (UIPageControl *)pageControl {
    if (nil == _pageControl) {
        // 1.创建分页控件
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        
        // 3.设置总页数
        pageControl.numberOfPages = kImageCount;
        
        // 2.设置分页控件的位置大小
        CGSize pageSize = [pageControl sizeForNumberOfPages:pageControl.numberOfPages];

        pageControl.bounds = (CGRect){CGPointZero, pageSize};
        pageControl.center = CGPointMake(self.imageScrollView.center.x, self.imageScrollView.bounds.size.height + 10);
        
        // 4.设置分页按钮的颜色
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        
        // 5.添加分页控件值改变事件监听方法
        [pageControl addTarget:self action:@selector(pageControlValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        
        // 6.将分页控件添加到控制器根视图上
        _pageControl = pageControl;
        
        [self.view addSubview:_pageControl];
    }
    
    return _pageControl;
}

#pragma mark - 辅助私有方法
/**
 *  添加定时器
 */
- (void)addTimer {
    /**
     创建并启动定时器：
        1.scheduledTimerWithTimeInterval:使用该方法创建的定时器在主线程中受其它操作的干扰，当进行其它操作时当前定时器暂停等待操作完成。
        2.timerWithTimeInterval：使用该方法，需要将该定时器加入到运行循环中，默认的类型等同于1的效果，但使用NSRunLoopCommonModes类型不受其它操作干扰。
     */
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
    
    self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 事件监听方法处理
/**
 *  分页控件值改变事件处理
 */
- (void)pageControlValueChangedAction:(UIPageControl *)pageControl {
    // 1.获取当前页数
    int currentPage = pageControl.currentPage;
    
    // 2.判断当前页数是否为最大页：如果是从0开始，不是就＋＋到下一页
    if (currentPage == kImageCount - 1) {
        currentPage = 0;
    } else {
        currentPage++;
    }
    
    // 3.取出当前滚动视图的宽度
    CGFloat scrollViewW = self.imageScrollView.bounds.size.width;
    
    // 4.设置滚动视图的偏移量：实现点击分页按钮滚动图片
    self.imageScrollView.contentOffset = CGPointMake(scrollViewW * currentPage, 0);
}

/**
 *  开始定时器
 */
- (void)timerStart:(NSTimer *)timer {
    [self pageControlValueChangedAction:self.pageControl];
}

/**
 *  结束定时器
 */
- (void)timerEnd {
    [self.timer invalidate];
}

#pragma mark - 代理方法事件处理
/**
 *  滚动视图“滚动中”代理方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"滚动中：[%@]", NSStringFromCGPoint(scrollView.contentOffset));
    
    // 1.取出当前滚动视图X方向上的偏移量
    CGFloat contentOffSetX = scrollView.contentOffset.x;
    
    // 2.取出当前滚动视图的宽度
    CGFloat scrollViewW = scrollView.bounds.size.width;
    
    // 3.计算出当前页数:当前页数 = （偏移量 ＋ 滚动视图宽度的一半） / 滚动视图的宽度
    int currentPage = (contentOffSetX + scrollViewW * 0.5) / scrollViewW;
    
    // 4.设置分页控件当前的页数
    self.pageControl.currentPage = currentPage;
}

/**
 *  滚动视图“即将开始拖动”代理方法
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self timerEnd];
}

/**
 *  滚动视图“结束拖动”代理方法
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
