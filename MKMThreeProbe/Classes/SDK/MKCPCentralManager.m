//
//  MKCPCentralManager.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPCentralManager.h"

#import "MKBLEBaseCentralManager.h"
#import "MKBLEBaseSDKDefines.h"
#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseLogManager.h"

#import "MKCPPeripheral.h"
#import "MKCPOperation.h"
#import "MKCPTaskAdopter.h"
#import "MKCPAdopter.h"
#import "CBPeripheral+MKCPAdd.h"
#import "MKCPService.h"

static NSString *const mk_cp_logName = @"mk_cp_bleLog";

NSString *const mk_cp_receiveThreeAxisAccelerometerDataNotification = @"mk_cp_receiveThreeAxisAccelerometerDataNotification";
NSString *const mk_cp_receiveHTDataNotification = @"mk_cp_receiveHTDataNotification";
NSString *const mk_cp_receiveTemperatureDataNotification = @"mk_cp_receiveTemperatureDataNotification";
NSString *const mk_cp_receiveWaterLeakageDetectionDataNotification = @"mk_cp_receiveWaterLeakageDetectionDataNotification";
NSString *const mk_cp_deviceDisconnectTypeNotification = @"mk_cp_deviceDisconnectTypeNotification";
NSString *const mk_cp_peripheralConnectStateChangedNotification = @"mk_cp_peripheralConnectStateChangedNotification";
NSString *const mk_cp_centralManagerStateChangedNotification = @"mk_cp_centralManagerStateChangedNotification";
NSString *const mk_cp_peripheralLockStateChangedNotification = @"mk_cp_peripheralLockStateChangedNotification";


static MKCPCentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface MKCPCentralManager ()

@property (nonatomic, assign)mk_cp_centralConnectStatus connectState;

@property (nonatomic, assign)mk_cp_lockState lockState;

@property (nonatomic, assign)BOOL readingLockState;

@property (nonatomic, copy)void (^sucBlock)(CBPeripheral *peripheral);

@property (nonatomic, copy)void (^failedBlock)(NSError *error);

@property (nonatomic, copy)void (^progressBlock)(float progress);

@property (nonatomic, copy)void (^readLockStateBlock)(NSString *lockState);

@property (nonatomic, copy)NSString *password;

@end

@implementation MKCPCentralManager

- (instancetype)init {
    if (self = [super init]) {
        [[MKBLEBaseCentralManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKCPCentralManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKCPCentralManager new];
        }
    });
    return manager;
}

+ (void)sharedDealloc {
    [MKBLEBaseCentralManager singleDealloc];
    manager = nil;
    onceToken = 0;
}

+ (void)removeFromCentralList {
    [[MKBLEBaseCentralManager shared] removeDataManager:manager];
    manager = nil;
    onceToken = 0;
}

#pragma mark - MKBLEBaseScanProtocol
- (void)MKBLEBaseCentralManagerDiscoverPeripheral:(CBPeripheral *)peripheral
                                advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                                             RSSI:(NSNumber *)RSSI {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *dic = [self parseModelWithRssi:RSSI advDic:advertisementData peripheral:peripheral];
        if (!MKValidDict(dic)) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(mk_cp_receiveDevicePara:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mk_cp_receiveDevicePara:dic];
            });
        }
    });
}

- (void)MKBLEBaseCentralManagerStartScan {
    if ([self.delegate respondsToSelector:@selector(mk_cp_startScan)]) {
        [self.delegate mk_cp_startScan];
    }
}

- (void)MKBLEBaseCentralManagerStopScan {
    if ([self.delegate respondsToSelector:@selector(mk_cp_stopScan)]) {
        [self.delegate mk_cp_stopScan];
    }
}

#pragma mark - MKBLEBaseCentralManagerStateProtocol
- (void)MKBLEBaseCentralManagerStateChanged:(MKCentralManagerState)centralManagerState {
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_centralManagerStateChangedNotification object:nil];
}

- (void)MKBLEBasePeripheralConnectStateChanged:(MKPeripheralConnectState)connectState {
    if (self.readingLockState) {
        //正在读取lockState的时候不对连接状态做出回调
        return;
    }
    //连接成功的判断必须是发送密码成功之后
    if (connectState == MKPeripheralConnectStateUnknow) {
        self.connectState = mk_cp_centralConnectStatusUnknow;
    }else if (connectState == MKPeripheralConnectStateConnecting) {
        self.connectState = mk_cp_centralConnectStatusConnecting;
    }else if (connectState == MKPeripheralConnectStateDisconnect) {
        self.connectState = mk_cp_centralConnectStatusDisconnect;
    }else if (connectState == MKPeripheralConnectStateConnectedFailed) {
        self.connectState = mk_cp_centralConnectStatusConnectedFailed;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_peripheralConnectStateChangedNotification object:nil];
}

#pragma mark - MKBLEBaseCentralManagerProtocol
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++接收数据出错");
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_disconnectListenUUID]]) {
        //设备断开原因
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        MKBLEBase_main_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_deviceDisconnectTypeNotification
                                                                object:nil
                                                              userInfo:@{@"type":content}];
        });
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_notifyUUID]]) {
        //判断是否是lockState改变通知
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        if (content.length > 6 && [[content substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"eb63"]) {
            NSString *state = [content substringFromIndex:(content.length - 2)];
            mk_cp_lockState lockState = mk_cp_lockStateUnknow;
            if ([state isEqualToString:@"00"]) {
                //锁定状态
                lockState = mk_cp_lockStateLock;
            }else if ([state isEqualToString:@"01"]){
                lockState = mk_cp_lockStateOpen;
            }else if ([state isEqualToString:@"02"]){
                lockState = mk_cp_lockStateUnlockAutoMaticRelockDisabled;
            }
            [self updateLockState:lockState];
            return;
        }
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_threeSensorUUID]]) {
        //监听的三轴加速度数据
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        if (content.length >= 12) {
            NSMutableArray *dataList = [NSMutableArray array];
            for (NSInteger i = 0; i < content.length / 12; i ++) {
                NSString *subContent = [[content substringWithRange:NSMakeRange(i * 12, 12)] uppercaseString];
                NSDictionary *dic = @{
                                      @"x-Data":[subContent substringWithRange:NSMakeRange(0, 4)],
                                      @"y-Data":[subContent substringWithRange:NSMakeRange(4, 4)],
                                      @"z-Data":[subContent substringWithRange:NSMakeRange(8, 4)],
                                      };
                [dataList addObject:dic];
            }
            MKBLEBase_main_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_receiveThreeAxisAccelerometerDataNotification
                                                                    object:nil
                                                                  userInfo:@{@"axisData":dataList}];
            });
        }
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_temperatureHumidityUUID]]) {
        //监听的温湿度数据
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        if (content.length == 8) {
            NSInteger tempTemp = [[MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(0, 4)]] integerValue];
            NSInteger tempHui = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(4, 4)];
            NSString *temperature = [NSString stringWithFormat:@"%.1f",(tempTemp * 0.1)];
            NSString *humidity = [NSString stringWithFormat:@"%.1f",(tempHui * 0.1)];
            NSDictionary *htData = @{
                                     @"temperature":temperature,
                                     @"humidity":humidity,
                                     };
            MKBLEBase_main_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_receiveHTDataNotification
                                                                    object:nil
                                                                  userInfo:htData];
            });
        }
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_waterLeakageUUID]]) {
        //监听的漏水状态
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        if (content.length == 2) {
            BOOL leakage = [content isEqualToString:@"01"];
            NSDictionary *htData = @{
                                     @"leakage":@(leakage),
                                     };
            MKBLEBase_main_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_receiveWaterLeakageDetectionDataNotification
                                                                    object:nil
                                                                  userInfo:htData];
            });
        }
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_temperatureUUID]]) {
        //监听的温度数据
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        if (content.length == 4) {
            NSInteger tempTemp = [[MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(0, 4)]] integerValue];
            NSString *temperature = [NSString stringWithFormat:@"%.1f",(tempTemp * 0.1)];
            NSDictionary *htData = @{
                                     @"temperature":temperature,
                                     };
            MKBLEBase_main_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_receiveTemperatureDataNotification
                                                                    object:nil
                                                                  userInfo:htData];
            });
        }
        return;
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++发送数据出错");
        return;
    }
    
}

#pragma mark - public method
- (CBCentralManager *)centralManager {
    return [MKBLEBaseCentralManager shared].centralManager;
}

- (CBPeripheral *)peripheral {
    return [MKBLEBaseCentralManager shared].peripheral;
}

- (mk_cp_centralManagerStatus )centralStatus {
    return ([MKBLEBaseCentralManager shared].centralStatus == MKCentralManagerStateEnable)
    ? mk_cp_centralManagerStatusEnable
    : mk_cp_centralManagerStatusUnable;
}

- (void)startScan {
    [[MKBLEBaseCentralManager shared] scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FEAB"]]
                                                             options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
}

- (void)stopScan {
    [[MKBLEBaseCentralManager shared] stopScan];
}

- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                 password:(nonnull NSString *)password
            progressBlock:(void (^)(float progress))progressBlock
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (![MKBLEBaseSDKAdopter asciiString:password] || password.length > 16) {
        [self operationFailedBlockWithMsg:@"Password incorrect!" failedBlock:failedBlock];
        return;
    }
    self.password = nil;
    self.password = password;
    [self connectPeripheral:peripheral
              progressBlock:progressBlock
                   sucBlock:sucBlock
                failedBlock:failedBlock];
}

- (void)readLockStateWithPeripheral:(nonnull CBPeripheral *)peripheral
                           sucBlock:(void (^)(NSString *lockState))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    if (self.readingLockState) {
        [self operationFailedBlockWithMsg:@"Device is busy now" failedBlock:failedBlock];
        return;
    }
    self.readingLockState = YES;
    self.sucBlock = nil;
    self.failedBlock = nil;
    self.progressBlock = nil;
    __weak typeof(self) weakSelf = self;
    self.readLockStateBlock = ^(NSString *lockState) {
        __strong typeof(self) sself = weakSelf;
        [sself clearAllParams];
        if (sucBlock) {
            MKBLEBase_main_safe(^{sucBlock(lockState);});
        }
    };
    MKCPPeripheral *bxpPeripheral = [[MKCPPeripheral alloc] initWithPeripheral:peripheral];
    [[MKBLEBaseCentralManager shared] connectDevice:bxpPeripheral sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        [self sendPasswordToDevice];
    } failedBlock:^(NSError * _Nonnull error) {
        __strong typeof(self) sself = weakSelf;
        [sself clearAllParams];
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
            progressBlock:(void (^)(float progress))progressBlock
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (self.readingLockState) {
        [self operationFailedBlockWithMsg:@"Device is busy now" failedBlock:failedBlock];
        return;
    }
    if (!peripheral) {
        [MKBLEBaseSDKAdopter operationConnectFailedBlock:failedBlock];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self connect:peripheral progressBlock:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        __strong typeof(self) sself = weakSelf;
        [sself clearAllParams];
        if (sucBlock) {
            sucBlock(peripheral);
        }
    } failedBlock:^(NSError * _Nonnull error) {
        __strong typeof(self) sself = weakSelf;
        [sself clearAllParams];
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

- (void)disconnect {
    [[MKBLEBaseCentralManager shared] disconnect];
}

- (void)addTaskWithTaskID:(mk_cp_taskOperationID)operationID
              commandData:(NSString *)commandData
           characteristic:(CBCharacteristic *)characteristic
                 sucBlock:(void (^)(id returnData))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    MKCPOperation *operation = [self generateOperationWithOperationID:operationID
                                                           commandData:commandData
                                                        characteristic:characteristic
                                                              sucBlock:sucBlock
                                                           failedBlock:failedBlock];
    [[MKBLEBaseCentralManager shared] addOperation:operation];
}

- (void)addReadTaskWithTaskID:(mk_cp_taskOperationID)operationID
               characteristic:(CBCharacteristic *)characteristic
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    MKCPOperation *operation = [self generateReadOperationWithID:operationID
                                                   characteristic:characteristic
                                                         sucBlock:sucBlock
                                                      failedBlock:failedBlock];
    [[MKBLEBaseCentralManager shared] addOperation:operation];
}

- (BOOL)notifyThreeAxisAcceleration:(BOOL)notify {
    if (self.connectState != mk_cp_centralConnectStatusConnected || self.peripheral == nil || self.peripheral.cp_threeSensor == nil) {
        return NO;
    }
    [self.peripheral setNotifyValue:notify forCharacteristic:self.peripheral.cp_threeSensor];
    return YES;
}

- (BOOL)notifyTHData:(BOOL)notify {
    if (self.connectState != mk_cp_centralConnectStatusConnected || self.peripheral == nil || self.peripheral.cp_temperatureHumidity == nil) {
        return NO;
    }
    [self.peripheral setNotifyValue:notify forCharacteristic:self.peripheral.cp_temperatureHumidity];
    return YES;
}

- (BOOL)notifyTemperatureData:(BOOL)notify {
    if (self.connectState != mk_cp_centralConnectStatusConnected || self.peripheral == nil || self.peripheral.cp_temperature == nil) {
        return NO;
    }
    [self.peripheral setNotifyValue:notify forCharacteristic:self.peripheral.cp_temperature];
    return YES;
}

- (BOOL)notifyWaterLeakageDetectionData:(BOOL)notify {
    if (self.connectState != mk_cp_centralConnectStatusConnected || self.peripheral == nil || self.peripheral.cp_waterLeakage == nil) {
        return NO;
    }
    [self.peripheral setNotifyValue:notify forCharacteristic:self.peripheral.cp_waterLeakage];
    return YES;
}

#pragma mark - 解锁过程
- (void)updateConnectProgress:(float)progress{
    MKBLEBase_main_safe(^{
        if (self.progressBlock) {
            self.progressBlock(progress);
        }
    });
}
- (void)sendPasswordToDevice{
    dispatch_async(dispatch_queue_create("unlockEddystoneQueue", 0), ^{
        mk_cp_lockState lockState = [self fetchLockState];
        if (self.readingLockState) {
            //读取lockState操作，不需要进行后续步骤
            //读取完数据之后断开连接
            [[MKBLEBaseCentralManager shared] disconnect];
            self.readingLockState = NO;
            if (self.readLockStateBlock) {
                NSString *lockInfo = @"00";
                if (lockState == mk_cp_lockStateUnlockAutoMaticRelockDisabled) {
                    lockInfo = @"02";
                }
                MKBLEBase_main_safe(^{
                    self.readLockStateBlock(lockInfo);
                });
            }
            return ;
        }
        [self updateLockState:lockState];
        [self updateConnectProgress:50.f];
        if (lockState == mk_cp_lockStateUnknow) {
            [MKBLEBaseSDKAdopter operationConnectFailedBlock:self.failedBlock];
            self.readingLockState = NO;
            [[MKBLEBaseCentralManager shared] disconnect];
            return;
        }
        if (lockState == mk_cp_lockStateLock) {
            //锁定状态
            //先读取设备的unlock数据，返回16位的随机key
            NSData *randKey = [self fetchRandDataArray];
            [self updateConnectProgress:65.f];
            if (!MKValidData(randKey) || randKey.length != 16) {
                [MKBLEBaseSDKAdopter operationConnectFailedBlock:self.failedBlock];
                self.readingLockState = NO;
                [[MKBLEBaseCentralManager shared] disconnect];
                return;
            }
            NSData *keyToUnlock = [MKCPAdopter fetchKeyToUnlockWithPassword:self.password randKey:randKey];
            if (!MKValidData(keyToUnlock)) {
                [MKBLEBaseSDKAdopter operationConnectFailedBlock:self.failedBlock];
                self.readingLockState = NO;
                [[MKBLEBaseCentralManager shared] disconnect];
                return;
            }
            //当前密码与unlock返回的16位key进行aes128加密之后生成对应的解锁码，发送给设备的unlock特征进行解锁
            BOOL sendToUnlockSuccess = [self sendKeyToUnlock:keyToUnlock];
            [self updateConnectProgress:80.f];
            if (!sendToUnlockSuccess) {
                [MKBLEBaseSDKAdopter operationConnectFailedBlock:self.failedBlock];
                self.readingLockState = NO;
                [[MKBLEBaseCentralManager shared] disconnect];
                return;
            }
            //解锁码发送给设备之后，再次获取设备的锁定状态，看看是否解锁成功
            mk_cp_lockState newLockState = [self fetchLockState];
            [self updateLockState:newLockState];
            [self updateConnectProgress:100.f];
            if (newLockState == mk_cp_lockStateUnknow || newLockState == mk_cp_lockStateLock) {
                [self operationFailedBlockWithMsg:@"Password incorrect!" failedBlock:self.failedBlock];
                self.readingLockState = NO;
                [[MKBLEBaseCentralManager shared] disconnect];
                return;
            }
            self.readingLockState = NO;
            [self connectDeviecSuccess];
            return;
        }
        self.readingLockState = NO;
        [self connectDeviecSuccess];
    });
    
}

- (void)connectDeviecSuccess {
    MKBLEBase_main_safe(^{
        self.connectState = mk_cp_centralConnectStatusConnected;
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_peripheralConnectStateChangedNotification
                                                            object:nil];
        
        if (self.sucBlock) {
            self.sucBlock([MKBLEBaseCentralManager shared].peripheral);
        }
    });
}

- (mk_cp_lockState)fetchLockState{
    __block mk_cp_lockState lockState = mk_cp_lockStateUnknow;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __weak typeof(self) weakSelf = self;
    MKCPOperation *operation = [[MKCPOperation alloc] initOperationWithID:mk_cp_taskReadLockStateOperation commandBlock:^{
        __strong typeof(self) sself = weakSelf;
        [sself.peripheral readValueForCharacteristic:sself.peripheral.cp_lockState];
    } completeBlock:^(NSError *error, id returnData) {
        if (!error) {
            NSString *state = returnData[@"lockState"];
            if ([state isEqualToString:@"00"]) {
                //锁定状态
                lockState = mk_cp_lockStateLock;
            }else if ([state isEqualToString:@"01"]){
                lockState = mk_cp_lockStateOpen;
            }else if ([state isEqualToString:@"02"]){
                lockState = mk_cp_lockStateUnlockAutoMaticRelockDisabled;
            }else{
                lockState = mk_cp_lockStateUnknow;
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[MKBLEBaseCentralManager shared] addOperation:operation];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return lockState;
}

- (NSData *)fetchRandDataArray{
    __block NSData *RAND_DATA_ARRAY = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __weak typeof(self) weakSelf = self;
    MKCPOperation *operation = [[MKCPOperation alloc] initOperationWithID:mk_cp_taskReadUnlockOperation commandBlock:^{
        __strong typeof(self) sself = weakSelf;
        [sself.peripheral readValueForCharacteristic:sself.peripheral.cp_unlock];
    } completeBlock:^(NSError *error, id returnData) {
        if (!error) {
            RAND_DATA_ARRAY = returnData[@"RAND_DATA_ARRAY"];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    if (!operation) {
        return RAND_DATA_ARRAY;
    }
    [[MKBLEBaseCentralManager shared] addOperation:operation];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return RAND_DATA_ARRAY;
}

- (BOOL)sendKeyToUnlock:(NSData *)keyData{
    if (!self.peripheral || !self.peripheral.cp_unlock) {
        return NO;
    }
    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __weak typeof(self) weakSelf = self;
    MKCPOperation *operation = [[MKCPOperation alloc] initOperationWithID:mk_cp_taskConfigUnlockOperation commandBlock:^{
        __strong typeof(self) sself = weakSelf;
        [sself.peripheral writeValue:keyData forCharacteristic:sself.peripheral.cp_unlock type:CBCharacteristicWriteWithResponse];
    } completeBlock:^(NSError *error, id returnData) {
        if (!error) {
            success = YES;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[MKBLEBaseCentralManager shared] addOperation:operation];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - communication method
- (MKCPOperation *)generateOperationWithOperationID:(mk_cp_taskOperationID)operationID
                                         commandData:(NSString *)commandData
                                      characteristic:(CBCharacteristic *)characteristic
                                            sucBlock:(void (^)(id returnData))sucBlock
                                         failedBlock:(void (^)(NSError *error))failedBlock {
    if (![[MKBLEBaseCentralManager shared] readyToCommunication]) {
        [self operationFailedBlockWithMsg:@"The current connection device is in disconnect" failedBlock:failedBlock];
        return nil;
    }
    if (!MKValidStr(commandData)) {
        [self operationFailedBlockWithMsg:@"Input parameter error" failedBlock:failedBlock];
        return nil;
    }
    if (!characteristic) {
        [self operationFailedBlockWithMsg:@"Characteristic error" failedBlock:failedBlock];
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    MKCPOperation *operation = [[MKCPOperation alloc] initOperationWithID:operationID commandBlock:^{
        [[MKBLEBaseCentralManager shared] sendDataToPeripheral:commandData characteristic:characteristic type:CBCharacteristicWriteWithResponse];
    } completeBlock:^(NSError *error, id returnData) {
        __strong typeof(self) sself = weakSelf;
        [sself parseTaskResult:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
    }];
    return operation;
}

- (MKCPOperation *)generateReadOperationWithID:(mk_cp_taskOperationID)operationID
                                 characteristic:(CBCharacteristic *)characteristic
                                       sucBlock:(void (^)(id returnData))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (![[MKBLEBaseCentralManager shared] readyToCommunication]) {
        [self operationFailedBlockWithMsg:@"The current connection device is in disconnect" failedBlock:failedBlock];
        return nil;
    }
    if (!characteristic) {
        [self operationFailedBlockWithMsg:@"Characteristic error" failedBlock:failedBlock];
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    MKCPOperation *operation = [[MKCPOperation alloc] initOperationWithID:operationID commandBlock:^{
        [[MKBLEBaseCentralManager shared].peripheral readValueForCharacteristic:characteristic];
    } completeBlock:^(NSError *error, id returnData) {
        __strong typeof(self) sself = weakSelf;
        [sself parseTaskResult:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
    }];
    return operation;
}

- (void)parseTaskResult:(NSError *)error
             returnData:(id)returnData
               sucBlock:(void (^)(id returnData))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock {
    if (error) {
        MKBLEBase_main_safe(^{
            if (failedBlock) {
                failedBlock(error);
            }
        });
        return ;
    }
    if (!returnData) {
        [self operationFailedBlockWithMsg:@"Request data error" failedBlock:failedBlock];
        return ;
    }
    NSDictionary *resultDic = @{@"msg":@"success",
                                @"code":@"1",
                                @"result":returnData,
                                };
    MKBLEBase_main_safe(^{
        if (sucBlock) {
            sucBlock(resultDic);
        }
    });
}

#pragma mark - private method
- (void)connect:(CBPeripheral *)peripheral
  progressBlock:(void (^)(float progress))progressBlock
       sucBlock:(void (^)(CBPeripheral * _Nonnull peripheral))sucBlock
    failedBlock:(void (^)(NSError * _Nonnull error))failedBlock {
    self.sucBlock = nil;
    self.sucBlock = sucBlock;
    self.failedBlock = nil;
    self.failedBlock = failedBlock;
    self.progressBlock = nil;
    self.progressBlock = progressBlock;
    [self updateConnectProgress:5.f];
    MKCPPeripheral *bxpPeripheral = [[MKCPPeripheral alloc] initWithPeripheral:peripheral];
    [[MKBLEBaseCentralManager shared] connectDevice:bxpPeripheral sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        [self updateConnectProgress:30.f];
        [self sendPasswordToDevice];
    } failedBlock:failedBlock];
}

- (void)updateLockState:(mk_cp_lockState)lockState {
    self.lockState = lockState;
    MKBLEBase_main_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_cp_peripheralLockStateChangedNotification
                                                            object:nil
                                                          userInfo:@{}];
    });
}

- (void)clearAllParams {
    self.sucBlock = nil;
    self.failedBlock = nil;
    self.progressBlock = nil;
    self.readLockStateBlock = nil;
    self.readingLockState = NO;
}

- (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.BXPCentralManager"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    MKBLEBase_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

- (NSDictionary *)parseModelWithRssi:(NSNumber *)rssi 
                              advDic:(NSDictionary *)advDic
                          peripheral:(CBPeripheral *)peripheral {
    NSDictionary *manuParams = advDic[CBAdvertisementDataServiceDataKey];
    NSData *manufacturerData = manuParams[[CBUUID UUIDWithString:@"FEAB"]];
    if (!MKValidData(manufacturerData)) {
        return @{};
    }
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:manufacturerData];
    
    NSString *deviceType = [content substringWithRange:NSMakeRange(0, 2)];
    
    if (![deviceType isEqualToString:@"80"]) {
        return @{};
    }
    
    NSLog(@"%@",advDic);
    
    BOOL waterLeakage = [[content substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"01"];
    
    BOOL supportT = ![[content substringWithRange:NSMakeRange(4, 4)].uppercaseString isEqualToString:@"FFFF"];
    NSNumber *tempT = [MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(4, 4)]];
    NSString *temperature = [NSString stringWithFormat:@"%.1f",[tempT integerValue] * 0.1];
    
    BOOL supportH = ![[content substringWithRange:NSMakeRange(8, 4)].uppercaseString isEqualToString:@"FFFF"];
    NSNumber *tempH = [MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(8, 4)]];
    NSString *humidity = [NSString stringWithFormat:@"%.1f",[tempH integerValue] * 0.1];
    
    BOOL supportTof = ![[content substringWithRange:NSMakeRange(12, 4)].uppercaseString isEqualToString:@"FFFF"];
    NSString *tofRanging = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 4)];
    
    [self logToLocal:[@"扫描到设备:" stringByAppendingString:content]];
     
    
    return @{
        @"rssi":rssi,
        @"peripheral":peripheral,
        @"waterLeakage":@(waterLeakage),
        @"deviceName":(advDic[CBAdvertisementDataLocalNameKey] ? advDic[CBAdvertisementDataLocalNameKey] : @""),
        @"supportT":@(supportT),
        @"temperature":temperature,
        @"supportH":@(supportH),
        @"humidity":humidity,
        @"supportTof":@(supportTof),
        @"tofRanging":tofRanging,
        @"connectable":advDic[CBAdvertisementDataIsConnectable],
    };
}

- (void)saveToLogData:(NSString *)string appToDevice:(BOOL)app {
    if (!MKValidStr(string)) {
        return;
    }
    NSString *fuction = (app ? @"App To Device" : @"Device To App");
    NSString *recordString = [NSString stringWithFormat:@"%@---->%@",fuction,string];
    [self logToLocal:recordString];
}

- (void)logToLocal:(NSString *)string {
    if (!MKValidStr(string)) {
        return;
    }
    [MKBLEBaseLogManager saveDataWithFileName:mk_cp_logName dataList:@[string]];
}

@end
