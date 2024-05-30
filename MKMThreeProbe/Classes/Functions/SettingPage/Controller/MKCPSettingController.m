//
//  MKCPSettingController.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/25.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPSettingController.h"

#import "MLInputDodger.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKNormalTextCell.h"
#import "MKAlertView.h"

#import "MKCPConnectManager.h"

#import "MKCPInterface+MKCPConfig.h"
#import "MKCPInterface.h"

#import "MKCPSensorConfigController.h"
#import "MKCPQuickSwitchController.h"
#import "MKCPUpdateController.h"
#import "MKCPAdvConfigController.h"

@interface MKCPSettingController ()<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, copy)NSString *passwordAsciiStr;

@property (nonatomic, copy)NSString *confirmAsciiStr;

@property (nonatomic, assign)BOOL dfuModule;

@end

@implementation MKCPSettingController

- (void)dealloc {
    NSLog(@"MKCPSettingController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    if (self.dfuModule) {
        return;
    }
    [self loadSection1Datas];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSection0Datas];
    [self loadSection2Datas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceStartDFUProcess)
                                                 name:@"mk_cp_startDfuProcessNotification"
                                               object:nil];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_cp_popToRootViewControllerNotification" object:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNormalTextCellModel *cellModel = nil;
    
    if (indexPath.section == 0) {
        cellModel = self.section0List[indexPath.row];
    }else if (indexPath.section == 1) {
        cellModel = self.section1List[indexPath.row];
    }else if (indexPath.section == 2) {
        cellModel = self.section2List[indexPath.row];
    }
    if (ValidStr(cellModel.methodName) && [self respondsToSelector:NSSelectorFromString(cellModel.methodName)]) {
        [self performSelector:NSSelectorFromString(cellModel.methodName) withObject:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return self.section1List.count;
    }
    if (section == 2) {
        return self.section2List.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        return cell;
    }
    if (indexPath.section == 1) {
        MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section1List[indexPath.row];
        return cell;
    }
    MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
    cell.dataModel = self.section2List[indexPath.row];
    return cell;
}

#pragma mark - note
- (void)deviceStartDFUProcess {
    self.dfuModule = YES;
}

#pragma mark - section0
- (void)loadSection0Datas {
    MKNormalTextCellModel *cellModel1 = [[MKNormalTextCellModel alloc] init];
    cellModel1.showRightIcon = YES;
    cellModel1.leftMsg = @"Sensor configurations";
    cellModel1.methodName = @"pushSensorConfigPage";
    [self.section0List addObject:cellModel1];
    
    MKNormalTextCellModel *cellModel2 = [[MKNormalTextCellModel alloc] init];
    cellModel2.showRightIcon = YES;
    cellModel2.leftMsg = @"ADV configurations";
    cellModel2.methodName = @"pushAdvconfigPage";
    [self.section0List addObject:cellModel2];
    
    MKNormalTextCellModel *cellModel3 = [[MKNormalTextCellModel alloc] init];
    cellModel3.showRightIcon = YES;
    cellModel3.leftMsg = @"Quick switch";
    cellModel3.methodName = @"pushQuickSwitchPage";
    [self.section0List addObject:cellModel3];
}

#pragma mark - 传感器设置
- (void)pushSensorConfigPage {
    MKCPSensorConfigController *vc = [[MKCPSensorConfigController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 广播参数配置
- (void)pushAdvconfigPage {
    MKCPAdvConfigController *vc = [[MKCPAdvConfigController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 开关状态设置
- (void)pushQuickSwitchPage {
    MKCPQuickSwitchController *vc = [[MKCPQuickSwitchController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - App命令关机设备
- (void)powerOff{
    @weakify(self);
    MKAlertViewAction *cancelAction = [[MKAlertViewAction alloc] initWithTitle:@"Cancel" handler:^{
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    MKAlertViewAction *confirmAction = [[MKAlertViewAction alloc] initWithTitle:@"OK" handler:^{
        @strongify(self);
        [self commandPowerOff];
    }];
    NSString *msg = @"Are you sure to turn off the Beacon?Please make sure the Beacon has a button to turn on!";
    MKAlertView *alertView = [[MKAlertView alloc] init];
    [alertView addAction:cancelAction];
    [alertView addAction:confirmAction];
    [alertView showAlertWithTitle:@"Warning!" message:msg notificationName:@"mk_cp_needDismissAlert"];
}

- (void)commandPowerOff{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    @weakify(self);
    [MKCPInterface cp_configPowerOffWithSucBlock:^(id returnData) {
        [[MKHudManager share] hide];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_cp_powerOffNotification" object:nil];
    } failedBlock:^(NSError *error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - section1
- (void)loadSection1Datas {
    [self.section1List removeAllObjects];
    if ([MKCPConnectManager shared].passwordVerification) {
        MKNormalTextCellModel *resetModel = [[MKNormalTextCellModel alloc] init];
        resetModel.leftMsg = @"Reset Beacon";
        resetModel.showRightIcon = YES;
        resetModel.methodName = @"factoryReset";
        [self.section1List addObject:resetModel];
    }
    if (ValidStr([MKCPConnectManager shared].password) && [MKCPConnectManager shared].passwordVerification) {
        //是否能够修改密码取决于用户是否是输入密码这种情况进来的
        MKNormalTextCellModel *passwordModel = [[MKNormalTextCellModel alloc] init];
        passwordModel.leftMsg = @"Modify password";
        passwordModel.showRightIcon = YES;
        passwordModel.methodName = @"configPassword";
        [self.section1List addObject:passwordModel];
    }
}

#pragma mark - 设置密码
- (void)configPassword{
    
    @weakify(self);
    MKAlertViewAction *cancelAction = [[MKAlertViewAction alloc] initWithTitle:@"Cancel" handler:^{
    }];
    
    MKAlertViewAction *confirmAction = [[MKAlertViewAction alloc] initWithTitle:@"OK" handler:^{
        @strongify(self);
        [self setPasswordToDevice];
    }];
    MKAlertViewTextField *passwordField = [[MKAlertViewTextField alloc] initWithTextValue:@""
                                                                              placeholder:@"Enter new password"
                                                                            textFieldType:mk_normal
                                                                                maxLength:16
                                                                                  handler:^(NSString * _Nonnull text) {
        @strongify(self);
        self.passwordAsciiStr = text;
    }];
    
    MKAlertViewTextField *confirmField = [[MKAlertViewTextField alloc] initWithTextValue:@""
                                                                             placeholder:@"Enter new password again"
                                                                           textFieldType:mk_normal
                                                                               maxLength:16
                                                                                 handler:^(NSString * _Nonnull text) {
        @strongify(self);
        self.confirmAsciiStr = text;
    }];
    
    NSString *msg = @"Note:The password should not be exceed 16 characters in length.";
    MKAlertView *alertView = [[MKAlertView alloc] init];
    [alertView addAction:cancelAction];
    [alertView addAction:confirmAction];
    [alertView addTextField:passwordField];
    [alertView addTextField:confirmField];
    [alertView showAlertWithTitle:@"Modify password" message:msg notificationName:@"mk_cp_needDismissAlert"];
}

- (void)setPasswordToDevice{
    NSString *password = self.passwordAsciiStr;
    NSString *confirmpassword = self.confirmAsciiStr;
    if (!ValidStr(password) || !ValidStr(confirmpassword) || password.length > 16 || confirmpassword.length > 16) {
        [self.view showCentralToast:@"Length error."];
        return;
    }
    if (![password isEqualToString:confirmpassword]) {
        [self.view showCentralToast:@"Password not match! Please try again."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    [MKCPInterface cp_configNewPassword:password originalPassword:[MKCPConnectManager shared].password sucBlock:^(id  _Nonnull returnData) {
        [[MKHudManager share] hide];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_cp_modifyPasswordSuccessNotification" object:nil];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 恢复出厂设置
- (void)factoryReset{
    @weakify(self);
    MKAlertViewAction *cancelAction = [[MKAlertViewAction alloc] initWithTitle:@"Cancel" handler:^{
    }];
    
    MKAlertViewAction *confirmAction = [[MKAlertViewAction alloc] initWithTitle:@"OK" handler:^{
        @strongify(self);
        [self sendResetCommandToDevice];
    }];
    NSString *msg = @"Are you sure to reset the Beacon？";
    MKAlertView *alertView = [[MKAlertView alloc] init];
    [alertView addAction:cancelAction];
    [alertView addAction:confirmAction];
    [alertView showAlertWithTitle:@"Warning!" message:msg notificationName:@"mk_cp_needDismissAlert"];
}

- (void)sendResetCommandToDevice{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    [MKCPInterface cp_factoryDataResetWithSucBlock:^(id returnData) {
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - section2
- (void)loadSection2Datas {
    MKNormalTextCellModel *dfuModel = [[MKNormalTextCellModel alloc] init];
    dfuModel.leftMsg = @"DFU";
    dfuModel.showRightIcon = YES;
    dfuModel.methodName = @"pushDFUPage";
    [self.section2List addObject:dfuModel];
}

- (void)pushDFUPage {
    MKCPUpdateController *vc = [[MKCPUpdateController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI

- (void)loadSubViews {
    self.defaultTitle = @"SETTING";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-49.f);
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

- (NSMutableArray *)section0List {
    if (!_section0List) {
        _section0List = [NSMutableArray array];
    }
    return _section0List;
}

- (NSMutableArray *)section1List {
    if (!_section1List) {
        _section1List = [NSMutableArray array];
    }
    return _section1List;
}

- (NSMutableArray *)section2List {
    if (!_section2List) {
        _section2List = [NSMutableArray array];
    }
    return _section2List;
}

@end
