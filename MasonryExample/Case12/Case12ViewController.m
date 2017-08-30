//
//  Case12ViewController.m
//  MasonryExample
//
//  Created by tutuge on 16/8/6.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "Case12ViewController.h"
#import <Masonry/Masonry.h>

@interface Case12ViewController ()
@property (nonatomic, strong) UILabel *animationLabel;
@property (nonatomic, strong) MASConstraint *centerXConstraint;
@end

@implementation Case12ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animationLabel.text = @"tutuge.me";
    [self.view addSubview:self.animationLabel];
    
    [_animationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(200));
        make.height.equalTo(@(40));
        _centerXConstraint = make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

#pragma mark - Actions

- (IBAction)run:(id)sender {
    // 设置初始状态
    _centerXConstraint.equalTo(@(-CGRectGetWidth(self.view.frame)));
    // 立即让约束生效
    [self.view layoutIfNeeded];
    
    // lzy170830注：原版的意思，置为0，更像是恢复原状的意思，有点像核心动画的identify
    // 设置要动画的约束，移回原位
    _centerXConstraint.equalTo(@0);
    
    // lzy170830注：下面一句，label的中心点在self.view的右边缘
//    _centerXConstraint.equalTo(@(self.view.center.x));
    
    /* lzy170830注:下面一句，会崩溃
     Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Redefinition of constraint relation'
     */
//    _centerXConstraint.equalTo(self.view.mas_centerX);

    
    // 动画生效
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Getter

- (UILabel *)animationLabel {
    if (!_animationLabel) {
        _animationLabel = [UILabel new];
        _animationLabel.textColor = [UIColor whiteColor];
        _animationLabel.font = [UIFont systemFontOfSize:20];
        _animationLabel.numberOfLines = 2;
        _animationLabel.textAlignment = NSTextAlignmentCenter;
        _animationLabel.backgroundColor = [UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:1];
        _animationLabel.layer.masksToBounds = YES;
        _animationLabel.layer.cornerRadius = 2.0f;
    }
    return _animationLabel;
}

@end
