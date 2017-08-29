//
//  Case8ViewController.m
//  MasonryExample
//
//  Created by zorro on 15/12/5.
//  Copyright © 2015年 tutuge. All rights reserved.
//
/* lzy170829注:
 整体流程是这样：
 model中缓存了：
 cell的高，
 cell是否展开的标识。
 
 
 cell布局按正常来，只是内容label的加了高度约束：
 _contentHeightConstraint = make.height.equalTo(@64).with.priorityHigh(); // 优先级只设置成High,比正常的高度约束低一些,防止冲突

 之后点击cell中的button，delegate回到到VC中，
 vc的代理方法中做如下操作：
 
 1、model中取反 『是否展开』标识
 2、model中重置高度缓存
 3、刷新cell（begin / end update、刷新index的cell）
 
 cell的delegate方法调用完毕，
 heightForRowAtIndexPath的tableView代理方法将被调用。
 寻求所有cell的高度。
 其他未被点击的cell，由于高度没有被重置，所以都是使用的model中缓存的高。
 而被点击的cell，由于在cell的代理方法中把缓存的高度给重置了，所以会重新使用模板cell，重新算高
 
 cell中关联model，会根据 『是否展开』标识，对约束进行操作：
 if (_entity.expanded) {
     [_contentHeightConstraint uninstall];
 } else {
     [_contentHeightConstraint install];
 }
 
 */
#import "Case8ViewController.h"
#import "Case8Cell.h"
#import "Case8DataEntity.h"
#import "Common.h"

@interface Case8ViewController () <UITableViewDelegate, UITableViewDataSource, Case8CellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Case8Cell *templateCell;

@property (nonatomic, strong) NSArray *data;
@end

@implementation Case8ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;

    // 注册Cell
    [_tableView registerClass:[Case8Cell class] forCellReuseIdentifier:NSStringFromClass([Case8Cell class])];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self generateData];
    [_tableView reloadData];
}

#pragma mark - Case8CellDelegate

- (void)case8Cell:(Case8Cell *)cell switchExpandedStateWithIndexPath:(NSIndexPath *)index {
    // 改变数据
    Case8DataEntity *case8DataEntity = _data[(NSUInteger) index.row];
    case8DataEntity.expanded = !case8DataEntity.expanded; // 切换展开还是收回
    case8DataEntity.cellHeight = 0; // 重置高度缓存

    // **********************************
    // 下面两种方法均可实现高度更新，都尝试下吧
    // **********************************

    // 刷新方法1：只会重新计算高度,不会reload cell,所以只是把原来的cell撑大了而已,还是同一个cell实例
//    [_tableView beginUpdates];
//    [_tableView endUpdates];

    // 刷新方法2：先重新计算高度,然后reload,不是原来的cell实例
    [_tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
    
    // 让展开/收回的Cell居中，酌情加，看效果决定
    [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_templateCell) {
        _templateCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([Case8Cell class])];
    }

    // 获取对应的数据
    Case8DataEntity *dataEntity = _data[(NSUInteger) indexPath.row];

    // 判断高度是否已经计算过
    if (dataEntity.cellHeight <= 0) {
        // 填充数据
        [_templateCell setEntity:dataEntity indexPath:[NSIndexPath indexPathForRow:-1 inSection:-1]]; // 设置-1只是为了方便调试，在log里面可以分辨出哪个cell被调用
        // 根据当前数据，计算Cell的高度，注意+1
        dataEntity.cellHeight = [_templateCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 0.5f;
        NSLog(@"Calculate height: %ld", (long) indexPath.row);
    } else {
        NSLog(@"Get cache %ld", (long) indexPath.row);
    }

    return dataEntity.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Case8Cell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([Case8Cell class]) forIndexPath:indexPath];
    [cell setEntity:_data[(NSUInteger) indexPath.row] indexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - Private methods

// 生成数据
- (void)generateData {
    NSMutableArray *tmpData = [NSMutableArray new];

    for (int i = 0; i < 20; i++) {
        Case8DataEntity *dataEntity = [Case8DataEntity new];
        dataEntity.content = [Common getText:@"case 8 content. " withRepeat:i * 2 + 10];
        [tmpData addObject:dataEntity];
    }

    _data = tmpData;
}

@end
