//
//  Case10ViewController.m
//  MasonryExample
//
//  Created by tutuge on 16/8/6.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "Case10ViewController.h"
#import <Masonry/Masonry.h>

@interface Case10ViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) MASConstraint *leftConstraint;
@property (nonatomic, strong) MASConstraint *topConstraint;
@end

@implementation Case10ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /* lzy170830注:
     containerView是红边框的大view。
     tipLabel是灰色背景白色字体label。
     pan手势是加载containerView上的，主要是获取手指在containerView上的坐标。
     _leftConstraint，_topConstraint对应是tipLabel的centerX和centerY
     
     */
    _containerView.layer.masksToBounds = YES;
    _containerView.layer.borderWidth = 1.0f;
    _containerView.layer.borderColor = [UIColor redColor].CGColor;
    
    self.tipLabel.text = @"tutuge.me\niOS";
    [_containerView addSubview:self.tipLabel];
    [_tipLabel sizeToFit];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        // 设置边界条件约束，保证内容可见，优先级1000
        make.left.greaterThanOrEqualTo(_containerView.mas_left);
        make.right.lessThanOrEqualTo(_containerView.mas_right);
        make.top.greaterThanOrEqualTo(_containerView.mas_top);
        make.bottom.lessThanOrEqualTo(_containerView.mas_bottom);
        
            /* TODO: #待完成# 
             这是灰色label初始的位置，不清楚这么设置，左侧是紧贴红边线的。从case11才发觉没有理解这里
             */
        _leftConstraint = make.centerX.equalTo(_containerView.mas_left).with.offset(50).priorityHigh(); // 优先级要比边界条件低
        _topConstraint = make.centerY.equalTo(_containerView.mas_top).with.offset(50).priorityHigh(); // 优先级要比边界条件低
        make.width.mas_equalTo(CGRectGetWidth(_tipLabel.frame) + 8);
        make.height.mas_equalTo(CGRectGetHeight(_tipLabel.frame) + 4);
    }];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWithGesture:)];
    [_containerView addGestureRecognizer:pan];
}

#pragma mark - Pan gesture

- (void)panWithGesture:(UIPanGestureRecognizer *)pan {
    CGPoint touchPoint = [pan locationInView:_containerView];
    _logLabel.text = NSStringFromCGPoint(touchPoint);

    _leftConstraint.offset = touchPoint.x;
    _topConstraint.offset = touchPoint.y;
    /* lzy170830注:我第一反应想到的是：
     _leftConstraint.mas_equalTo(touchPoint.x);
     _topConstraint.mas_equalTo(touchPoint.y);
     与demo的效果时一样的。不清楚是否是完全一样的api。
     */
        /* TODO: #待完成# 
         看Masonry源代码时，可以看下MASConstraint的offset和mas_equalTo()是否一致
         */
}

#pragma mark - Getter

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont systemFontOfSize:20];
        _tipLabel.numberOfLines = 2;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.backgroundColor = [UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:1];
        _tipLabel.layer.borderColor = [UIColor blackColor].CGColor;
        _tipLabel.layer.borderWidth = 1.0f;
        _tipLabel.layer.masksToBounds = YES;
        _tipLabel.layer.cornerRadius = 2.0f;
    }
    return _tipLabel;
}

@end
