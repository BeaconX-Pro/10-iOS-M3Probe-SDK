//
//  MKCPInterface+MKCPConfig.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPInterface+MKCPConfig.h"

#import "MKBLEBaseSDKDefines.h"
#import "MKBLEBaseSDKAdopter.h"

#import "CBPeripheral+MKCPAdd.h"
#import "MKCPCentralManager.h"
#import "MKCPOperationID.h"
#import "MKCPAdopter.h"

#define centralManager [MKCPCentralManager shared]
#define peripheral [MKCPCentralManager shared].peripheral

@implementation MKCPInterface (MKCPConfig)

+ (void)cp_configNewPassword:(NSString *)newPassword
             originalPassword:(NSString *)originalPassword
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (![MKCPAdopter isPassword:newPassword] || ![MKCPAdopter isPassword:originalPassword]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    //写入0x00加上16字节新的密码（用户要对新的密码进行加密，然后发送，加密的密钥是旧的密码，也就是当前密码），发送之后，设备变为LOCKED状态。
    NSString *oldTempString = @"";
    for (NSInteger i = 0; i < originalPassword.length; i ++) {
        int asciiCode = [originalPassword characterAtIndex:i];
        oldTempString = [oldTempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSData *oldPasswordData = [MKBLEBaseSDKAdopter stringToData:oldTempString];
    NSString *newTempString = @"";
    for (NSInteger i = 0; i < newPassword.length; i ++) {
        int asciiCode = [newPassword characterAtIndex:i];
        newTempString = [newTempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSData *newPasswordData = [MKBLEBaseSDKAdopter stringToData:newTempString];
    Byte byte[16] = {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
    NSData *oldSupplyData = [NSData dataWithBytes:byte length:(16 - oldPasswordData.length)];
    NSData *newSupplyData = [NSData dataWithBytes:byte length:(16 - newPasswordData.length)];
    
    NSMutableData *oldData = [[NSMutableData alloc] init];
    [oldData appendData:oldPasswordData];
    [oldData appendData:oldSupplyData];
    
    NSMutableData *newData = [[NSMutableData alloc] init];
    [newData appendData:newPasswordData];
    [newData appendData:newSupplyData];
    
    NSData *encryptData = [MKCPAdopter AES128EncryptWithSourceData:newData keyData:oldData];
    if (!MKValidData(encryptData) || encryptData.length != 16) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSMutableData *commandData = [[NSMutableData alloc] init];
    Byte headerB[1] = {0x00};
    [commandData appendData:[NSData dataWithBytes:headerB length:1]];
    [commandData appendData:encryptData];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigLockStateOperation
                          commandData:[MKBLEBaseSDKAdopter hexStringFromData:commandData]
                       characteristic:peripheral.cp_lockState
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_factoryDataResetWithSucBlock:(void (^)(id returnData))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_cp_taskConfigFactoryResetOperation
                          commandData:@"0b"
                       characteristic:peripheral.cp_factoryReset
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configLockState:(mk_cp_lockState)lockState
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = @"00";
    if (lockState == mk_cp_lockStateOpen) {
        commandString = @"01";
    }else if (lockState == mk_cp_lockStateUnlockAutoMaticRelockDisabled){
        commandString = @"02";
    }
    [centralManager addTaskWithTaskID:mk_cp_taskConfigLockStateOperation
                          commandData:commandString
                       characteristic:peripheral.cp_lockState
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configPowerOffWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_cp_taskConfigPowerOffOperation
                          commandData:@"ea260000"
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configConnectStatus:(BOOL)connectEnable
                       sucBlock:(void (^)(id returnData))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_cp_taskConfigConnectEnableOperation
                          commandData:(connectEnable ? @"01" : @"00")
                       characteristic:peripheral.cp_remainConnectable
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configActiveSlot:(mk_cp_activeSlotNo)slotNo
                    sucBlock:(void (^)(id returnData))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *slotNumber = [self fetchSlotNumber:slotNo];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigActiveSlotOperation
                          commandData:slotNumber
                       characteristic:peripheral.cp_activeSlot
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configAdvTxPower:(NSInteger)advTxPower
                    sucBlock:(void (^)(id returnData))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock {
    if (advTxPower < -100 || advTxPower > 20) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *advPower = [MKBLEBaseSDKAdopter hexStringFromSignedNumber:advTxPower];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigAdvTxPowerOperation
                          commandData:advPower
                       characteristic:peripheral.cp_advertisedTxPower
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configRadioTxPower:(mk_cp_slotRadioTxPower )power
                      sucBlock:(void (^)(id returnData))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = [self fetchTxPower:power];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigRadioTxPowerOperation
                          commandData:commandString
                       characteristic:peripheral.cp_radioTxPower
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configAdvInterval:(NSInteger)interval
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 1 || interval > 100) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *advInterval = [MKBLEBaseSDKAdopter fetchHexValue:(interval * 100) byteLen:2];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigAdvertisingIntervalOperation
                          commandData:advInterval
                       characteristic:peripheral.cp_advertisingInterval
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configDeviceInfoAdvDataWithDeviceName:(NSString *)deviceName
                                         sucBlock:(void (^)(id returnData))sucBlock
                                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (!deviceName || deviceName.length > 10) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < deviceName.length; i ++) {
        int asciiCode = [deviceName characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSString *commandString = [@"80" stringByAppendingString:tempString];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigAdvSlotDataOperation
                          commandData:commandString
                       characteristic:peripheral.cp_advSlotData
                         sucBlock:^(id  _Nonnull returnData) {
                             [NSThread sleepForTimeInterval:0.1f];
                             if (sucBlock) {
                                 sucBlock(returnData);
                             }
                         } failedBlock:failedBlock];
}

+ (void)cp_configThreeAxisDataParams:(mk_cp_threeAxisDataRate)dataRate
                         acceleration:(mk_cp_threeAxisDataAG)acceleration
                          sensitivity:(NSInteger)sensitivity
                             sucBlock:(void (^)(id returnData))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    if (sensitivity < 1 || sensitivity > 255) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *rate = [self fetchThreeAxisDataRate:dataRate];
    NSString *ag = [self fetchThreeAxisDataAG:acceleration];
    NSString *sen = [MKBLEBaseSDKAdopter fetchHexValue:sensitivity byteLen:1];
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"ea310003",rate,ag,sen];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigThreeAxisParamsOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configHTSamplingRate:(NSInteger)rate
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    if (rate < 1 || rate > 65535) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *rateString = [MKBLEBaseSDKAdopter fetchHexValue:rate byteLen:2];
    NSString *commandString = [@"ea330002" stringByAppendingString:rateString];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigHTSamplingRateOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configButtonPowerStatus:(BOOL)isOn
                           sucBlock:(void (^)(id returnData))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOn ? @"ea38000101" : @"ea38000100");
    [centralManager addTaskWithTaskID:mk_cp_taskConfigButtonPowerStatusOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configWaterLeakageDetectionInterval:(NSInteger)interval
                                      sucBlock:(void (^)(id returnData))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 1 || interval > 86400) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *valueString = [MKBLEBaseSDKAdopter fetchHexValue:interval byteLen:3];
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"ea540003",valueString];
    [centralManager addTaskWithTaskID:mk_cp_taskConfigWaterLeakageDetectionIntervalOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configLEDTriggerStatus:(BOOL)isOn
                          sucBlock:(void (^)(id returnData))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOn ? @"ea57000101" : @"ea57000100");
    [centralManager addTaskWithTaskID:mk_cp_taskConfigLEDTriggerStatusOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_configResetBeaconByButtonStatus:(BOOL)isOn
                                   sucBlock:(void (^)(id returnData))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOn ? @"ea58000101" : @"ea58000100");
    [centralManager addTaskWithTaskID:mk_cp_taskConfigResetBeaconByButtonStatusOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

#pragma mark - private method
+ (NSString *)fetchSlotNumber:(mk_cp_activeSlotNo)slotNo{
    switch (slotNo) {
        case mk_cp_activeSlot1:
            return @"00";
        case mk_cp_activeSlot2:
            return @"01";
        case mk_cp_activeSlot3:
            return @"02";
        case mk_cp_activeSlot4:
            return @"03";
        case mk_cp_activeSlot5:
            return @"04";
        case mk_cp_activeSlot6:
            return @"05";
    }
}

+ (NSString *)fetchTxPower:(mk_cp_slotRadioTxPower)radioPower{
    switch (radioPower) {
        case mk_cp_slotRadioTxPower4dBm:
            return @"04";
            
        case mk_cp_slotRadioTxPower3dBm:
            return @"03";
            
        case mk_cp_slotRadioTxPower0dBm:
            return @"00";
            
        case mk_cp_slotRadioTxPowerNeg4dBm:
            return @"fc";
            
        case mk_cp_slotRadioTxPowerNeg8dBm:
            return @"f8";
            
        case mk_cp_slotRadioTxPowerNeg12dBm:
            return @"f4";
            
        case mk_cp_slotRadioTxPowerNeg16dBm:
            return @"f0";
            
        case mk_cp_slotRadioTxPowerNeg20dBm:
            return @"ec";
            
        case mk_cp_slotRadioTxPowerNeg40dBm:
            return @"d8";
    }
}

+ (NSString *)fetchThreeAxisDataRate:(mk_cp_threeAxisDataRate)dataRate {
    switch (dataRate) {
        case mk_cp_threeAxisDataRate1hz:
            return @"00";
        case mk_cp_threeAxisDataRate10hz:
            return @"01";
        case mk_cp_threeAxisDataRate25hz:
            return @"02";
        case mk_cp_threeAxisDataRate50hz:
            return @"03";
        case mk_cp_threeAxisDataRate100hz:
            return @"04";
    }
}

+ (NSString *)fetchThreeAxisDataAG:(mk_cp_threeAxisDataAG)ag {
    switch (ag) {
        case mk_cp_threeAxisDataAG0:
            return @"00";
        case mk_cp_threeAxisDataAG1:
            return @"01";
        case mk_cp_threeAxisDataAG2:
            return @"02";
        case mk_cp_threeAxisDataAG3:
            return @"03";
    }
}

+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block {
    MKBLEBase_main_safe(^{
        if (block) {
            NSError *error = [MKBLEBaseSDKAdopter getErrorWithCode:-999 message:@"Params error"];
            block(error);
        }
    });
}

+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block{
    MKBLEBase_main_safe(^{
        if (block) {
            NSError *error = [MKBLEBaseSDKAdopter getErrorWithCode:-10001 message:@"Set parameter error"];
            block(error);
        }
    });
}

@end
