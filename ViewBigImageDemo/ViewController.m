//
//  ViewController.m
//  ViewBigImageDemo
//
//  Created by Cloudox on 16/8/18.
//  Copyright © 2016年 Cloudox. All rights reserved.
//

#import "ViewController.h"

//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) UIImageView *smallImageView;// 小图视图
@property (nonatomic, strong) UIImageView *bigImageView;// 大图视图
@property (nonatomic, strong) UIView *bgView;// 阴影视图

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 小图
    self.smallImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 100)/2, (SCREENHEIGHT - 100)/2, 100, 100)];
    self.smallImageView.image = [UIImage imageNamed:@"icon"];
    // 添加点击响应
    self.smallImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewBigImage)];
    [self.smallImageView addGestureRecognizer:imageTap];
    [self.view addSubview:self.smallImageView];
}

// 大图视图
- (UIImageView *)bigImageView {
    if (nil == _bigImageView) {
        _bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (SCREENHEIGHT - SCREENWIDTH) / 2, SCREENWIDTH, SCREENWIDTH)];
        [_bigImageView setImage:self.smallImageView.image];
        // 设置大图的点击响应，此处为收起大图
        _bigImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBigImage)];
        [_bigImageView addGestureRecognizer:imageTap];
    }
    return _bigImageView;
}

// 阴影视图
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        // 设置阴影背景的点击响应，此处为收起大图
        _bgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBigImage)];
        [_bgView addGestureRecognizer:bgTap];
    }
    return _bgView;
}

// 显示大图
- (void)viewBigImage {
    [self bigImageView];// 初始化大图
    
    // 让大图从小图的位置和大小开始出现
    CGRect originFram = _bigImageView.frame;
    _bigImageView.frame = self.smallImageView.frame;
    [self.view addSubview:_bigImageView];
    
    // 动画到大图该有的大小
    [UIView animateWithDuration:0.3 animations:^{
        // 改变大小
        _bigImageView.frame = originFram;
        // 改变位置
        _bigImageView.center = self.view.center;// 设置中心位置到新的位置
    }];
    
    // 添加阴影视图
    [self bgView];
    [self.view addSubview:_bgView];
    
    // 将大图放到最上层，否则会被后添加的阴影盖住
    [self.view bringSubviewToFront:_bigImageView];
}

// 收起大图
- (void)dismissBigImage {
    [self.bgView removeFromSuperview];// 移除阴影
    
    // 将大图动画回小图的位置和大小
    [UIView animateWithDuration:0.3 animations:^{
        // 改变大小
        _bigImageView.frame = self.smallImageView.frame;
        // 改变位置
        _bigImageView.center = self.smallImageView.center;// 设置中心位置到新的位置
    }];
    
    // 延迟执行，移动回后再消灭掉
    double delayInSeconds = 0.3;
    __block ViewController* bself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [bself.bigImageView removeFromSuperview];
        bself.bigImageView = nil;
        bself.bgView = nil;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
