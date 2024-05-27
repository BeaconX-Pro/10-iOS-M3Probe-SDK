//
//  MKCPScanViewController.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPScanViewController.h"

#import <objc/runtime.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "Masonry.h"

#import "UIViewController+HHTransition.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "NSObject+MKModel.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"
#import "MKProgressView.h"
#import "MKTableSectionLineHeader.h"
#import "MKAlertController.h"

#import "MKCPScanFilterView.h"
#import "MKCPScanSearchButton.h"


#import "MKCPSDK.h"

#import "MKCPConnectManager.h"

#import "MKCPScanInfoCellModel.h"

#import "MKCPScanInfoCell.h"

#import "MKCPTabBarController.h"
#import "MKCPAboutController.h"

static CGFloat const offset_X = 15.f;
static CGFloat const searchButtonHeight = 40.f;

static NSTimeInterval const kRefreshInterval = 0.5f;

@interface MKCPScanViewController ()<UITableViewDelegate,
UITableViewDataSource,
MKCPScanSearchButtonDelegate,
mk_cp_centralManagerScanDelegate,
MKCPScanInfoCellDelegate,
MKCPTabBarControllerDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKCPScanSearchButtonModel *buttonModel;

@property (nonatomic, strong)MKCPScanSearchButton *searchButton;

@property (nonatomic, strong)UIImageView *refreshIcon;

@property (nonatomic, strong)UIButton *refreshButton;

@property (nonatomic, strong)dispatch_source_t scanTimer;

/// 定时刷新
@property (nonatomic, assign)CFRunLoopObserverRef observerRef;
//扫描到新的设备不能立即刷新列表，降低刷新频率
@property (nonatomic, assign)BOOL isNeedRefresh;

@property (nonatomic, strong)UITextField *passwordField;

@end

@implementation MKCPScanViewController

- (void)dealloc {
    NSLog(@"MKCPScanViewController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除runloop的监听
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
    [[MKCPCentralManager shared] stopScan];
    [MKCPCentralManager removeFromCentralList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self startRefresh];
}

#pragma mark - super method
- (void)rightButtonMethod {
    MKCPAboutController *vc = [[MKCPAboutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKCPScanInfoCell *cell = [MKCPScanInfoCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.section];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MKTableSectionLineHeader *headerView = [MKTableSectionLineHeader initHeaderViewWithTableView:tableView];
    MKTableSectionLineHeaderModel *sectionData = [[MKTableSectionLineHeaderModel alloc] init];
    sectionData.contentColor = RGBCOLOR(237, 243, 250);
    headerView.headerModel = sectionData;
    return headerView;
}

#pragma mark - MKCPScanSearchButtonDelegate
- (void)cp_scanSearchButtonMethod {
    [MKCPScanFilterView showSearchDeviceName:self.buttonModel.searchCondition 
                                        rssi:self.buttonModel.searchRssi
                                 searchBlock:^(NSString * _Nonnull deviceName, NSInteger searchRssi) {
        self.buttonModel.searchRssi = searchRssi;
        self.buttonModel.searchCondition = deviceName;
        self.searchButton.dataModel = self.buttonModel;
        
        self.refreshButton.selected = NO;
        [self refreshButtonPressed];
    }];
}

- (void)cp_scanSearchButtonClearMethod {
    self.buttonModel.searchRssi = -100;
    self.buttonModel.searchCondition = @"";
    self.refreshButton.selected = NO;
    [self refreshButtonPressed];
}

#pragma mark - mk_cp_centralManagerScanDelegate
- (void)mk_cp_receiveDevicePara:(NSDictionary *)devicePara {
    MKCPScanInfoCellModel *cellModel = [MKCPScanInfoCellModel mk_modelWithJSON:devicePara];
    CBPeripheral *peripheral = devicePara[@"peripheral"];
    cellModel.identifier = peripheral.identifier.UUIDString;
    [self updateData:cellModel];
}

- (void)mk_cp_stopScan {
    //如果是左上角在动画，则停止动画
    if (self.refreshButton.isSelected) {
        [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
        [self.refreshButton setSelected:NO];
    }
}

#pragma mark - MKCPScanInfoCellDelegate
- (void)cp_scanInfoCell_connect:(CBPeripheral *)peripheral {
    [self connectPeripheral:peripheral];
}

#pragma mark - MKCPTabBarControllerDelegate
- (void)mk_cp_needResetScanDelegate:(BOOL)need {
    if (need) {
        [MKCPCentralManager shared].delegate = self;
    }
    [self performSelector:@selector(startScanDevice) withObject:nil afterDelay:(need ? 1.f : 0.1f)];
}

#pragma mark - event method
- (void)refreshButtonPressed {
    if ([MKCPCentralManager shared].centralStatus != mk_cp_centralManagerStatusEnable) {
        [self.view showCentralToast:@"The current system of bluetooth is not available!"];
        return;
    }
    self.refreshButton.selected = !self.refreshButton.selected;
    [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
    if (!self.refreshButton.isSelected) {
        //停止扫描
        [[MKCPCentralManager shared] stopScan];
        return;
    }
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
    //刷新顶部设备数量
    [self.titleLabel setText:[NSString stringWithFormat:@"DEVICE(%@)",[NSString stringWithFormat:@"%ld",(long)self.dataList.count]]];
    [self.refreshIcon.layer addAnimation:[MKCustomUIAdopter refreshAnimation:2.f] forKey:@"mk_refreshAnimationKey"];
    [[MKCPCentralManager shared] startScan];
}

#pragma mark - notice method
- (void)showCentralStatus{
    if ([MKCPCentralManager shared].centralStatus != mk_cp_centralManagerStatusEnable) {
        NSString *msg = @"The current system of bluetooth is not available!";
        MKAlertController *alertController = [MKAlertController alertControllerWithTitle:@"Dismiss"
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:moreAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self refreshButtonPressed];
}

#pragma mark - 刷新
- (void)startScanDevice {
    self.refreshButton.selected = NO;
    [self refreshButtonPressed];
}

- (void)needRefreshList {
    //标记需要刷新
    self.isNeedRefresh = YES;
    //唤醒runloop
    CFRunLoopWakeUp(CFRunLoopGetMain());
}

- (void)runloopObserver {
    @weakify(self);
    __block NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    self.observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        @strongify(self);
        if (activity == kCFRunLoopBeforeWaiting) {
            //runloop空闲的时候刷新需要处理的列表,但是需要控制刷新频率
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            if (currentInterval - timeInterval < kRefreshInterval) {
                return;
            }
            timeInterval = currentInterval;
            if (self.isNeedRefresh) {
                [self.tableView reloadData];
                [self.titleLabel setText:[NSString stringWithFormat:@"DEVICE(%@)",[NSString stringWithFormat:@"%ld",(long)self.dataList.count]]];
                self.isNeedRefresh = NO;
            }
        }
    });
    //添加监听，模式为kCFRunLoopCommonModes
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
}

- (void)updateData:(MKCPScanInfoCellModel *)dataModel {
    if (ValidStr(self.buttonModel.searchCondition)) {
        //如果打开了过滤，先看是否需要过滤设备名字
        //如果是设备信息帧,判断mac和名字是否符合要求
        if ([dataModel.rssi integerValue] >= self.buttonModel.searchRssi) {
            [self filterDeviceWithSearchName:dataModel];
        }
        return;
    }
    if (self.buttonModel.searchRssi > self.buttonModel.minSearchRssi) {
        //开启rssi过滤
        if ([dataModel.rssi integerValue] >= self.buttonModel.searchRssi) {
            [self processDevice:dataModel];
        }
        return;
    }
    [self processDevice:dataModel];
}

/**
 通过设备名称和mac地址过滤设备，这个时候肯定开启了rssi
 
 @param beacon 设备
 */
- (void)filterDeviceWithSearchName:(MKCPScanInfoCellModel *)dataModel {
    if ([[dataModel.deviceName uppercaseString] containsString:[self.buttonModel.searchCondition uppercaseString]]) {
        //如果设备名称包含搜索条件，则加入
        [self processDevice:dataModel];
    }
}

- (void)processDevice:(MKCPScanInfoCellModel *)dataModel {
    //查看数据源中是否已经存在相关设备
    NSString *identy = dataModel.peripheral.identifier.UUIDString;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identy];
    NSArray *array = [self.dataList filteredArrayUsingPredicate:predicate];
    BOOL contain = ValidArray(array);
    if (contain) {
        //如果是已经存在了，替换
        [self dataExistDataSource:dataModel];
        return;
    }
    //不存在，则加入
    [self dataNoExistDataSource:dataModel];
}

/**
 将扫描到的设备加入到数据源
 
 @param scanDataModel 扫描到的设备
 */
- (void)dataNoExistDataSource:(MKCPScanInfoCellModel *)scanDataModel{
    [self.dataList addObject:scanDataModel];
    [self needRefreshList];
}

/**
 如果是已经存在了，直接替换
 
 @param scanDataModel  新扫描到的数据帧
 */
- (void)dataExistDataSource:(MKCPScanInfoCellModel *)scanDataModel {
    NSInteger currentIndex = 0;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKCPScanInfoCellModel *dataModel = self.dataList[i];
        if ([dataModel.deviceName isEqualToString:scanDataModel.deviceName]) {
            currentIndex = i;
            break;
        }
    }
    MKCPScanInfoCellModel *dataModel = self.dataList[currentIndex];
    [self.dataList replaceObjectAtIndex:currentIndex withObject:scanDataModel];
    [self needRefreshList];
}

#pragma mark - 连接设备

- (void)connectPeripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
    [[MKCPCentralManager shared] stopScan];
    [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
    [[MKCPCentralManager shared] readLockStateWithPeripheral:peripheral sucBlock:^(NSString *lockState) {
        [[MKHudManager share] hide];
        if ([lockState isEqualToString:@"00"]) {
            //密码登录
            [self showPasswordAlert:peripheral];
            return ;
        }
        if ([lockState isEqualToString:@"02"]) {
            //免密码登录
            [self connectDeviceWithoutPassword:peripheral];
            return;
        }
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self connectFailed];
    }];
}

- (void)connectDeviceWithoutPassword:(CBPeripheral *)peripheral{
    MKProgressView *progressView = [[MKProgressView alloc] initWithTitle:@"Connecting..." message:@"Make sure your phone and device are as close as possible."];
    [progressView show];
    [[MKCPConnectManager shared] connectPeripheral:peripheral password:@"" progressBlock:^(float progress) {
        [progressView setProgress:(progress * 0.01) animated:NO];
    } sucBlock:^{
        [progressView dismiss];
        [self performSelector:@selector(pushTabBarPage) withObject:nil afterDelay:0.3f];
    } failedBlock:^(NSError * _Nonnull error) {
        [progressView dismiss];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self connectFailed];
    }];
}

- (void)connectDeviceWithPassword:(CBPeripheral *)peripheral{
    NSString *password = self.passwordField.text;
    if (!ValidStr(password) || password.length > 16) {
        [self.view showCentralToast:@"Password incorrect!"];
        return;
    }
    MKProgressView *progressView = [[MKProgressView alloc] initWithTitle:@"Connecting..." message:@"Make sure your phone and device are as close as possible."];
    [progressView show];
    
    [[MKCPConnectManager shared] connectPeripheral:peripheral password:password progressBlock:^(float progress) {
        [progressView setProgress:(progress * 0.01) animated:NO];
    } sucBlock:^{
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"mk_cp_localPasswordKey"];
        [progressView dismiss];
        [self performSelector:@selector(pushTabBarPage) withObject:nil afterDelay:0.3f];
    } failedBlock:^(NSError * _Nonnull error) {
        [progressView dismiss];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self connectFailed];
    }];
}

- (void)pushTabBarPage {
    MKCPTabBarController *vc = [[MKCPTabBarController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    @weakify(self);
    [self hh_presentViewController:vc presentStyle:HHPresentStyleErected completion:^{
        @strongify(self);
        vc.delegate = self;
    }];
}

- (void)connectFailed {
    self.refreshButton.selected = NO;
    [self refreshButtonPressed];
}

- (void)showDeviceTypeErrorAlert {
    NSString *msg = @"Oops! Something went wrong. Please check the device version or contact MOKO.";
    MKAlertController *alertController = [MKAlertController alertControllerWithTitle:@""
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:moreAction];
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

- (void)showPasswordAlert:(CBPeripheral *)peripheral{
    NSString *alertTitle = @"Please enter password.";
    MKAlertController *alertController = [MKAlertController alertControllerWithTitle:alertTitle
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        @strongify(self);
        self.passwordField = nil;
        self.passwordField = textField;
        if (ValidStr([[NSUserDefaults standardUserDefaults] objectForKey:@"mk_cp_localPasswordKey"])) {
            textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"mk_cp_localPasswordKey"];
        }
        self.passwordField.placeholder = @"No more than 16 characters.";
        [textField addTarget:self action:@selector(passwordInput) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self connectFailed];
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self connectDeviceWithPassword:peripheral];
    }];
    [alertController addAction:moreAction];
    
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}
/**
 监听输入的密码
 */
- (void)passwordInput{
    NSString *tempInputString = self.passwordField.text;
    if (!ValidStr(tempInputString)) {
        self.passwordField.text = @"";
        return;
    }
    self.passwordField.text = (tempInputString.length > 16 ? [tempInputString substringToIndex:16] : tempInputString);
}

#pragma mark -
- (void)startRefresh {
    self.searchButton.dataModel = self.buttonModel;
    [self runloopObserver];
    [MKCPCentralManager shared].delegate = self;
    [self performSelector:@selector(showCentralStatus) withObject:nil afterDelay:.5f];
}

#pragma mark - UI
- (void)loadSubViews {
    [self.view setBackgroundColor:RGBCOLOR(237, 243, 250)];
    [self.rightButton setImage:LOADICON(@"MKMThreeProbe", @"MKCPScanViewController", @"cp_scanRightAboutIcon.png") forState:UIControlStateNormal];
    self.titleLabel.text = @"DEVICE(0)";
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = RGBCOLOR(237, 243, 250);
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(searchButtonHeight + 2 * 15.f);
    }];
    [self.refreshButton addSubview:self.refreshIcon];
    [topView addSubview:self.refreshButton];
    [self.refreshIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.refreshButton.mas_centerX);
        make.centerY.mas_equalTo(self.refreshButton.mas_centerY);
        make.width.mas_equalTo(22.f);
        make.height.mas_equalTo(22.f);
    }];
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(40.f);
    }];
    [topView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.refreshButton.mas_left).mas_offset(-10.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(searchButtonHeight);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(topView.mas_bottom);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-5.f);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIImageView *)refreshIcon {
    if (!_refreshIcon) {
        _refreshIcon = [[UIImageView alloc] init];
        _refreshIcon.image = LOADICON(@"MKMThreeProbe", @"MKCPScanViewController", @"cp_scan_refreshIcon.png");
    }
    return _refreshIcon;
}

- (MKCPScanSearchButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[MKCPScanSearchButton alloc] init];
        _searchButton.delegate = self;
    }
    return _searchButton;
}

- (MKCPScanSearchButtonModel *)buttonModel {
    if (!_buttonModel) {
        _buttonModel = [[MKCPScanSearchButtonModel alloc] init];
        _buttonModel.placeholder = @"Edit Filter";
        _buttonModel.minSearchRssi = -100;
        _buttonModel.searchRssi = -100;
    }
    return _buttonModel;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton addTarget:self
                           action:@selector(refreshButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

@end
