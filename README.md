# ViewBigImageDemo
动画放大缩小查看图片大图的demo

对于图片来说，除了表情包，几乎都会被点击查看大图。今天就讲解一个查看和收起大图的动画效果，先直接看效果图：

![](http://img.blog.csdn.net/20160818195124596)


如图所示，最开始是一个小图，点击小图可以查看大图。大图会从小图的位置和大小“弹”出来，同时背景变成半透明的阴影。点击大图或者阴影后，收起大图，同样地弹回到小图去，同时去掉阴影背景，就像是一张图片在伸大缩小一样。

现在看看这是怎么实现的。在思考一个动画的实现方法时，把动画的动作进行分解然后再一个个去思考怎么实现是一个好的习惯，我们稍微分解一下，这个动画在显示大图和收起大图的时候做了这些事情：

* 打开时先显示一个半透明的阴影背景；
* 然后显示一个逐渐变大的图片，直到撑到屏幕的边界；
* 收起时先让阴影背景消失；
* 然后将图片逐渐收小到小图原本的大小。

这样看其实还蛮简单的，下面看代码怎么实现。

首先我们定义三个属性，因为我们需要在多个方法中调用，所以定义为类的@property：

```objective-c
@property (nonatomic, strong) UIImageView *smallImageView;// 小图视图
@property (nonatomic, strong) UIImageView *bigImageView;// 大图视图
@property (nonatomic, strong) UIView *bgView;// 阴影视图
```

然后我们将小图片直接添加到界面上去：

```objective-c
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
```

注意这里我在设置小图的大小时用到了两个事先设好的常量：屏幕的高和宽，这样就会根据手机的屏幕大小来保证图片始终是居中显示的，关于这两个常量，可以查看我这篇博客：[iOS获取屏幕宽高、设备型号、系统版本信息](http://blog.csdn.net/cloudox_/article/details/50337137)

好现在小图已经添加到界面上了，我们也给小图添加了响应点击的方法，只需要在响应方法中实现动画就可以了。但是在这之前，我们先来完成大图片和阴影背景的初始化：

```objective-c
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
```

可以看到我们单独使用了两个方法来初始化大图和阴影背景，大图的大小设为了垂直居中，宽度正好与屏幕一致，高度与宽度相同，是个正方形。阴影背景则是占据整个屏幕。同时，我也设置了两个视图的点击相应方法，都是收起大图的动画方法，我们之后再去实现。现在，我们可以来着手实现显示大图的动画了。

```objective-c
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
```

看代码，我们首先调用了大图的初始化方法，但是注意，此时还并没有将大图添加到界面上，如果这时候添加，就会直接显示大图了，在此之前，我们先保存了大图自身的尺寸，然后将其尺寸位置设为和小图完全一样，然后才将它添加到界面上，从小图的位置和尺寸，去动画到大图原本的尺寸，看起来就像是小图放大成了大图一样对吧。这里的动画我们使用的是最简单的iOS 7开始支持的基于block的UIView动画，在我的这篇博客中也有详细讲解：[iOS基础动画教程](http://blog.csdn.net/cloudox_/article/details/50736092)

然后，我们初始化了阴影背景视图，并添加到界面上，此时不要忘记，要再次将大图手动推送到最上层，否则是会被后添加的阴影视图覆盖的。

到此，显示大图的动画就结束了，挺简单的吧，接下来我们看收起大图的动画，基本就是把上面的步骤倒过来了一次。

```objective-c
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
```

我们先移除阴影背景，然后将大图动画回小图的尺寸和位置，看起来就像是缩小成了小图一样。然后我们使用了一个延迟函数，确保在图片收缩回小图以后，再将图片移除界面，保证动画的效果。

至此，就完成了我们整个的动画了。这个例子中图片是中规中矩地放在居中位置，你也可以试一下将小图放在其他位置，其实真实的app中很少有居中放置的，从别的地方伸缩放大缩小效果会更加有趣的。当然了，如果小图的位置不好获取，那就直接设为从屏幕的中点开始缩放，效果也不错。另外，你可能会疑惑为什么我要另行添加一个大图的对象，而不直接对小图的尺寸进行动画呢？其实是完全可以的，只是在我的工程中有这个需求，所以我就直接拿过来讲了哈哈哈。

[查看博客](http://blog.csdn.net/Cloudox_/article/details/52244284)
