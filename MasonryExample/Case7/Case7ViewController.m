//
//  Case7ViewController.m
//  MasonryExample
//
//  Created by zorro on 15/11/30.
//  Copyright © 2015年 tutuge. All rights reserved.
//

#import "Case7ViewController.h"
#import "Masonry.h"

static CGFloat ParallaxHeaderHeight = 235;
static NSString *CellIdentifier = @"Cell";

@interface Case7ViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIImageView *parallaxHeaderView;
@property (strong, nonatomic) MASConstraint *parallaxHeaderHeightConstraint;
@end

@implementation Case7ViewController

- (void)dealloc {
    [_tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTableView];
    [self initView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @(indexPath.row).stringValue;
    return cell;
}

// *************************
// 两种方法监听contentOffset
// *************************

// 方法1：直接在scrollViewDidScroll:刷新
#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    /* lzy170829注:
//     这个原始代码，是要崩溃的，直接是EXC_BAD_ACCESS，蹦到修改约束常数的那一行。
//     猜测是约束broken。
//     这个内部还是应该调用observe中的方法
//     */
//    if (scrollView.contentOffset.y < 0) {
//        _parallaxHeaderHeightConstraint.equalTo(@(ParallaxHeaderHeight - scrollView.contentOffset.y));
//    } else {
//        _parallaxHeaderHeightConstraint.equalTo(@(ParallaxHeaderHeight));
//    }
//}

// 方法2：利用KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = ((NSValue *)change[NSKeyValueChangeNewKey]).CGPointValue;
        if (contentOffset.y < -ParallaxHeaderHeight) {
            _parallaxHeaderHeightConstraint.equalTo(@(-contentOffset.y));
        }
    }
}

#pragma mark - Private methods

- (void)configTableView {
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    /* lzy170829注:
     The distance that the content view is inset from the enclosing scroll view.
     Use this property to add to the scrolling area around the content. The unit of size is points. The default value is UIEdgeInsetsZero.
     */
    _tableView.contentInset = UIEdgeInsetsMake(ParallaxHeaderHeight, 0, 0, 0);
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)initView {
    _parallaxHeaderView = [UIImageView new];
    [self.view insertSubview:_parallaxHeaderView belowSubview:_tableView];
    /* lzy170829注:
     看到前面后面有点儿疑惑，回来看到这里似乎找到了灵感。
     这个view，约束了左右和高。并使用属性保存了高约束的常数到_parallaxHeaderHeightConstraint。
     并在scrollView滑动，contentOffset.y < -ParallaxHeaderHeight 的时候，
     改变_parallaxHeaderHeightConstraint = -contentOffset.y;
     
     改变了view的高度，而view的显示是等比缩放填充的，所以会有随着拉扯view放大的感觉。
     */
    _parallaxHeaderView.contentMode = UIViewContentModeScaleAspectFill;
    _parallaxHeaderView.image = [UIImage imageNamed:@"parallax_header_back"];

    [_parallaxHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        // lzy170829注：对高进行约束，并保存到属性中
        _parallaxHeaderHeightConstraint = make.height.equalTo(@(ParallaxHeaderHeight));
    }];
    
    // Add KVO
    [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

@end
