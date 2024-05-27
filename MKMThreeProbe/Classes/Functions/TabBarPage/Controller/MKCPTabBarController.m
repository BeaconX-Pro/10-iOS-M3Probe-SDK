//
//  MKCPTabBarController.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/25.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPTabBarController.h"

#import "MKMacroDefines.h"
#import "MKBaseNavigationController.h"

#import "MKAlertController.h"

#import "MKBLEBaseLogManager.h"

#import "MKBXDeviceInfoController.h"

#import "MKCPSensorController.h"
#import "MKCPSettingController.h"

#import "MKCPCentralManager.h"

#import "MKCPConnectManager.h"

#import "MKCPDeviceInfoModel.h"

@interface MKCPTabBarController ()

@property (nonatomic, assign)BOOL disconnectType;

@end

@implementation MKCPTabBarController

- (void)dealloc {
    NSLog(@"MKCPTabBarController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MKCPConnectManager shared] clearParams];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (![[self.navigationController viewControllers] containsObject:self]){
        [[MKCPCentralManager shared] disconnect];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubPages];
    [self addNotifications];
}

#pragma mark - notes
- (void)gotoScanPage {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(mk_cp_needResetScanDelegate:)]) {
            [self.delegate mk_cp_needResetScanDelegate:NO];
        }
    }];
}

- (void)dfuUpdateComplete {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(mk_cp_needResetScanDelegate:)]) {
            [self.delegate mk_cp_needResetScanDelegate:YES];
        }
    }];
}

- (void)centralManagerStateChanged {
    if (self.disconnectType) {
        return;
    }
    if ([MKCPCentralManager shared].centralStatus != mk_cp_centralManagerStatusEnable) {
        [self showAlertWithMsg:@"The current system of bluetooth is not available!" title:@"Dismiss"];
    }
}

- (void)deviceConnectStateChanged {
    if (self.disconnectType) {
        return;
    }
    [self showAlertWithMsg:@"The device is disconnected." title:@"Dismiss"];
    return;
}

- (void)deviceLockStateChanged {
    if (self.disconnectType) {
        return;
    }
    if ([MKCPCentralManager shared].lockState != mk_cp_lockStateOpen
        && [MKCPCentralManager shared].lockState != mk_cp_lockStateUnlockAutoMaticRelockDisabled
        && [MKCPCentralManager shared].connectState == mk_cp_centralConnectStatusConnected) {
        [self showAlertWithMsg:@"The device is locked!" title:@"Dismiss"];
    }
}

- (void)disconnectTypeNotification:(NSNotification *)note {
    NSString *type = note.userInfo[@"type"];
    //00一分钟之内没有输入密码,01修改密码成功，02:设备恢复出厂设置
    self.disconnectType = YES;
    if ([type isEqualToString:@"01"]) {
        [self showAlertWithMsg:@"Modify password success! Please reconnect the Device." title:@""];
        return;
    }
    if ([type isEqualToString:@"02"]) {
        [self showAlertWithMsg:@"Reset success!Beacon is disconnected." title:@""];
        return;
    }
}

- (void)devicePowerOff {
    if (self.disconnectType) {
        return;
    }
    [self showAlertWithMsg:@"The device is turned off" title:@"Dismiss"];
}

#pragma mark - private method

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoScanPage)
                                                 name:@"mk_cp_popToRootViewControllerNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dfuUpdateComplete)
                                                 name:@"mk_cp_centralDeallocNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disconnectTypeNotification:)
                                                 name:@"mk_cp_deviceDisconnectTypeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceConnectStateChanged)
                                                 name:mk_cp_peripheralConnectStateChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(centralManagerStateChanged)
                                                 name:mk_cp_centralManagerStateChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceLockStateChanged)
                                                 name:mk_cp_peripheralLockStateChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devicePowerOff)
                                                 name:@"mk_cp_powerOffNotification"
                                               object:nil];
}

- (void)showAlertWithMsg:(NSString *)msg title:(NSString *)title{
    MKAlertController *alertController = [MKAlertController alertControllerWithTitle:title
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self gotoScanPage];
    }];
    [alertController addAction:moreAction];
    
    //让setting页面推出的alert消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_cp_needDismissAlert" object:nil];
    //让所有MKPickView消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_customUIModule_dismissPickView" object:nil];
    [self performSelector:@selector(presentAlert:) withObject:alertController afterDelay:1.2f];
}

- (void)presentAlert:(UIAlertController *)alert {
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -

- (void)loadSubPages {
    MKCPSensorController *slotPage = [[MKCPSensorController alloc] init];
    slotPage.tabBarItem.title = @"SENSOR";
    slotPage.tabBarItem.image = LOADICON(@"MKMThreeProbe", @"MKCPTabBarController", @"cp_slotTabBarItemUnselected.png");
    slotPage.tabBarItem.selectedImage = LOADICON(@"MKMThreeProbe", @"MKCPTabBarController", @"cp_slotTabBarItemSelected.png");
    MKBaseNavigationController *slotNav = [[MKBaseNavigationController alloc] initWithRootViewController:slotPage];

    MKCPSettingController *settingPage = [[MKCPSettingController alloc] init];
    settingPage.tabBarItem.title = @"SETTING";
    settingPage.tabBarItem.image = LOADICON(@"MKMThreeProbe", @"MKCPTabBarController", @"cp_settingTabBarItemUnselected.png");
    settingPage.tabBarItem.selectedImage = LOADICON(@"MKMThreeProbe", @"MKCPTabBarController", @"cp_settingTabBarItemSelected.png");
    MKBaseNavigationController *settingNav = [[MKBaseNavigationController alloc] initWithRootViewController:settingPage];

    MKBXDeviceInfoController *devicePage = [[MKBXDeviceInfoController alloc] init];
    devicePage.tabBarItem.title = @"DEVICE";
    devicePage.tabBarItem.image = LOADICON(@"MKMThreeProbe", @"MKCPTabBarController", @"cp_deviceTabBarItemUnselected.png");
    devicePage.tabBarItem.selectedImage = LOADICON(@"MKMThreeProbe", @"MKCPTabBarController", @"cp_deviceTabBarItemSelected.png");
    devicePage.dataModel = [[MKCPDeviceInfoModel alloc] init];
    @weakify(self);
    devicePage.leftButtonActionBlock = ^{
        @strongify(self);
        [self gotoScanPage];
    };
    MKBaseNavigationController *deviceNav = [[MKBaseNavigationController alloc] initWithRootViewController:devicePage];
    
    self.viewControllers = @[slotNav,settingNav,deviceNav];
}

@end
