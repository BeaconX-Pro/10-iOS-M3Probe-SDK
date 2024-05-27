//
//  MKCPSensorController.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/24.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCPSensorController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKCPSensorCell.h"

#import "MKCPProbeController.h"

@interface MKCPSensorController ()<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKCPSensorController

- (void)dealloc {
    NSLog(@"MKCPSensorController销毁");
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_cp_popToRootViewControllerNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKCPProbeController *vc = [[MKCPProbeController alloc] init];
    vc.type = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKCPSensorCell *cell = [MKCPSensorCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKCPSensorCellModel *cellModel1 = [[MKCPSensorCellModel alloc] init];
    cellModel1.icon = LOADICON(@"MKMThreeProbe", @"MKCPSensorController", @"cp_temp_probe.png");
    cellModel1.msg = @"Temperature Probe";
    cellModel1.detailMsg = @"(PT100)";
    [self.dataList addObject:cellModel1];
    
    MKCPSensorCellModel *cellModel2 = [[MKCPSensorCellModel alloc] init];
    cellModel2.icon = LOADICON(@"MKMThreeProbe", @"MKCPSensorController", @"cp_th_probe.png");
    cellModel2.msg = @"Temperature & Humidity";
    cellModel2.detailMsg = @"Probe";
    [self.dataList addObject:cellModel2];
    
    MKCPSensorCellModel *cellModel3 = [[MKCPSensorCellModel alloc] init];
    cellModel3.icon = LOADICON(@"MKMThreeProbe", @"MKCPSensorController", @"cp_waterleak_probe.png");
    cellModel3.msg = @"Water leakage detection";
    cellModel3.detailMsg = @"Probe";
    [self.dataList addObject:cellModel3];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"SENSOR";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
