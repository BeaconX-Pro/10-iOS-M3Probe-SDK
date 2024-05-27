//
//  MKCPTaskAdopter.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPTaskAdopter.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseSDKDefines.h"

#import "MKCPOperationID.h"
#import "MKCPAdopter.h"
#import "MKCPService.h"

@implementation MKCPTaskAdopter

+ (NSDictionary *)parseReadDataWithCharacteristic:(CBCharacteristic *)characteristic {
    NSData *readData = characteristic.value;
    if (!MKValidData(readData)) {
        return @{};
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_modeIDUUID]]){
        //产品型号信息
        return [self modeIDData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_productionDateUUID]]){
        //生产日期
        return [self productionDate:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_firmwareUUID]]){
        //固件信息
        return [self firmwareData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_hardwareUUID]]){
        //硬件信息
        return [self hardwareData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_softwareUUID]]){
        //软件版本
        return [self softwareData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_vendorUUID]]){
        //厂商信息
        return [self vendorData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_activeSlotUUID]]){
        //获取当前活跃的通道
        return [self activeSlot:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advertisingIntervalUUID]]){
        //获取当前活跃通道的广播间隔
        return [self slotAdvertisingInterval:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_radioTxPowerUUID]]){
        //获取当前活跃通道的发射功率
        return [self radioTxPower:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advertisedTxPowerUUID]]){
        //获取当前活跃通道的广播功率
        return [self advTxPower:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_lockStateUUID]]){
        return [self lockState:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_unlockUUID]]){
        return [self unlockData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advSlotDataUUID]]){
        //获取当前活跃通道的广播信息
        return [self advDataWithOriData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_factoryResetUUID]]){
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_notifyUUID]]){
        return [self customData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_voltageUUID]]){
        //电池服务
        return [self batteryData:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_deviceTypeUUID]]) {
        //读取设备类型
        return [self parseDeviceType:readData];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_remainConnectableUUID]]) {
        //可连接状态
        return [self parseConnectStatus:readData];
    }
    return @{};
}

+ (NSDictionary *)parseWriteDataWithCharacteristic:(CBCharacteristic *)characteristic {
    if (!characteristic) {
        return nil;
    }
    mk_cp_taskOperationID operationID = mk_cp_defaultTaskOperationID;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_activeSlotUUID]]){
        operationID = mk_cp_taskConfigActiveSlotOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advertisingIntervalUUID]]){
        operationID = mk_cp_taskConfigAdvertisingIntervalOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_radioTxPowerUUID]]){
        operationID = mk_cp_taskConfigRadioTxPowerOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advertisedTxPowerUUID]]){
        operationID = mk_cp_taskConfigAdvTxPowerOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_lockStateUUID]]){
        //重置密码
        operationID = mk_cp_taskConfigLockStateOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_unlockUUID]]){
        //设置unlock状态
        operationID = mk_cp_taskConfigUnlockOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advSlotDataUUID]]){
        //设置广播数据
        operationID = mk_cp_taskConfigAdvSlotDataOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_factoryResetUUID]]){
        //恢复出厂设置
        operationID = mk_cp_taskConfigFactoryResetOperation;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_remainConnectableUUID]]) {
        //可连接状态
        operationID = mk_cp_taskConfigConnectEnableOperation;
    }
    return [self dataParserGetDataSuccess:@{@"success":@(YES)} operationID:operationID];
}

#pragma mark - private method

+ (NSDictionary *)modeIDData:(NSData *)data{
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{@"modeID":tempString};
    return [self dataParserGetDataSuccess:dic operationID:mk_cp_taskReadModeIDOperation];
}

+ (NSDictionary *)productionDate:(NSData *)data{
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{@"productionDate":tempString};
    return [self dataParserGetDataSuccess:dic operationID:mk_cp_taskReadProductionDateOperation];
}

+ (NSDictionary *)firmwareData:(NSData *)data{
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{@"firmware":tempString};
    return [self dataParserGetDataSuccess:dic operationID:mk_cp_taskReadFirmwareOperation];
}

+ (NSDictionary *)hardwareData:(NSData *)data{
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{@"hardware":tempString};
    return [self dataParserGetDataSuccess:dic operationID:mk_cp_taskReadHardwareOperation];
}

+ (NSDictionary *)softwareData:(NSData *)data{
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{@"software":tempString};
    return [self dataParserGetDataSuccess:dic operationID:mk_cp_taskReadSoftwareOperation];
}

+ (NSDictionary *)vendorData:(NSData *)data{
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{@"vendor":tempString};
    return [self dataParserGetDataSuccess:dic operationID:mk_cp_taskReadVendorOperation];
}

+ (NSDictionary *)batteryData:(NSData *)data{
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    if (!MKValidStr(content) || content.length != 4) {
        return nil;
    }
    NSString *battery = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 4)];
    return [self dataParserGetDataSuccess:@{@"battery":battery} operationID:mk_cp_taskReadBatteryOperation];
}

+ (NSDictionary *)lockState:(NSData *)data{
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    if (!MKValidStr(content) || content.length != 2) {
        return nil;
    }
    return [self dataParserGetDataSuccess:@{@"lockState":content} operationID:mk_cp_taskReadLockStateOperation];
}

+ (NSDictionary *)unlockData:(NSData *)data{
    if (data.length != 16) {
        return nil;
    }
    return [self dataParserGetDataSuccess:@{@"RAND_DATA_ARRAY":data}
                              operationID:mk_cp_taskReadUnlockOperation];
}

+ (NSDictionary *)activeSlot:(NSData *)data{
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    if (!MKValidStr(content) || content.length != 2) {
        return nil;
    }
    return [self dataParserGetDataSuccess:@{@"activeSlot":content} operationID:mk_cp_taskReadActiveSlotOperation];
}

+ (NSDictionary *)advDataWithOriData:(NSData *)data{
    NSString *type = [MKBLEBaseSDKAdopter hexStringFromData:[data subdataWithRange:NSMakeRange(0, 1)]];
    if (![type isEqualToString:@"80"]) {
        return @{};
    }
    
    NSString *nameString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, data.length - 1)] encoding:NSUTF8StringEncoding];
    NSDictionary *returnData = @{
        @"deviceName":(MKValidStr(nameString) ? nameString : @"")
                                 };
    return [self dataParserGetDataSuccess:returnData operationID:mk_cp_taskReadAdvSlotDataOperation];
}

+ (NSDictionary *)slotAdvertisingInterval:(NSData *)data{
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    if (!MKValidStr(content) || content.length != 4) {
        return nil;
    }
    NSString *advInterval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 4)];
    return [self dataParserGetDataSuccess:@{@"advertisingInterval":advInterval}
                              operationID:mk_cp_taskReadAdvertisingIntervalOperation];
}

+ (NSDictionary *)radioTxPower:(NSData *)data{
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    NSString *power = [MKCPAdopter fetchTxPowerWithContent:content];
    return [self dataParserGetDataSuccess:@{@"radioTxPower":power} operationID:mk_cp_taskReadRadioTxPowerOperation];
}

+ (NSDictionary *)advTxPower:(NSData *)contentData{
    const unsigned char *cData = [contentData bytes];
    unsigned char *data;
    data = malloc(sizeof(unsigned char) * contentData.length);
    if (!data) {
        return nil;
    }
    for (int i = 0; i < contentData.length; i++) {
        data[i] = *cData++;
    }
    unsigned char txPowerChar = *(data);
    NSNumber *txNumber = @(0);
    if (txPowerChar & 0x80) {
        txNumber = [NSNumber numberWithInt:(- 0x100 + txPowerChar)];
    }
    else {
        txNumber = [NSNumber numberWithInt:txPowerChar];
    }
    NSString *power = [NSString stringWithFormat:@"%ld",(long)[txNumber integerValue]];
    return [self dataParserGetDataSuccess:@{@"advTxPower":power} operationID:mk_cp_taskReadAdvTxPowerOperation];
}

+ (NSDictionary *)parseDeviceType:(NSData *)data {
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    return [self dataParserGetDataSuccess:@{@"deviceType":content} operationID:mk_cp_taskReadDeviceTypeOperation];
}

+ (NSDictionary *)customData:(NSData *)data{
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    if (!MKValidStr(content) || content.length < 8) {
        return nil;
    }
    //配置信息，eb开头
    NSString *ackHeader = [content substringToIndex:2];
    if ([ackHeader isEqualToString:@"ec"]) {
        //多包数据
        return [self parseMultiPacketData:content];
    }
    NSInteger len = strtoul([[content substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16);
    if (content.length != 2 * len + 8) {
        return nil;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    mk_cp_taskOperationID operationID = mk_cp_defaultTaskOperationID;
    NSDictionary *returnDic = nil;
    if ([function isEqualToString:@"20"] && content.length == 20) {
        //mac地址
        NSString *tempMac = [[content substringWithRange:NSMakeRange(8, 12)] uppercaseString];
        NSString *macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[tempMac substringWithRange:NSMakeRange(0, 2)],[tempMac substringWithRange:NSMakeRange(2, 2)],[tempMac substringWithRange:NSMakeRange(4, 2)],[tempMac substringWithRange:NSMakeRange(6, 2)],[tempMac substringWithRange:NSMakeRange(8, 2)],[tempMac substringWithRange:NSMakeRange(10, 2)]];
        operationID = mk_cp_taskReadMacAddressOperation;
        returnDic = @{@"macAddress":macAddress};
    }else if ([function isEqualToString:@"21"] && content.length == 14){
        //读取三轴传感器参数
        operationID = mk_cp_taskReadThreeAxisParamsOperation;
        returnDic = @{
                      @"samplingRate":[content substringWithRange:NSMakeRange(8, 2)],
                      @"gravityReference":[content substringWithRange:NSMakeRange(10, 2)],
                      @"sensitivity":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 2)],
                      };
    }else if ([function isEqualToString:@"23"] && content.length == 12){
        //读取温湿度采样率
        operationID = mk_cp_taskReadHTSamplingRateOperation;
        returnDic = @{
                      @"samplingRate":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 4)],
                      };
    }else if ([function isEqualToString:@"26"] && content.length == 8){
        //关机
        operationID = mk_cp_taskConfigPowerOffOperation;
        returnDic = @{@"success":@(YES)};
    }else if ([function isEqualToString:@"28"] && content.length == 10){
        //读取按键关机状态
        operationID = mk_cp_taskReadButtonPowerStatusOperation;
        returnDic = @{
            @"isOn":@([[content substringWithRange:NSMakeRange(8, 2)] isEqualToString:@"01"]),
        };
    }else if ([function isEqualToString:@"31"] && content.length == 8){
        //设置三轴传感器参数
        operationID = mk_cp_taskConfigThreeAxisParamsOperation;
        returnDic = @{@"success":@(YES)};
    }else if ([function isEqualToString:@"33"] && content.length == 8){
        //设置温湿度采样率
        operationID = mk_cp_taskConfigHTSamplingRateOperation;
        returnDic = @{@"success":@(YES)};
    }else if ([function isEqualToString:@"38"] && content.length == 8){
        //设置按键关机状态
        operationID = mk_cp_taskConfigButtonPowerStatusOperation;
        returnDic = @{@"success":@(YES)};
    }else if ([function isEqualToString:@"54"] && content.length == 8){
        //配置漏水状态采集间隔
        operationID = mk_cp_taskConfigWaterLeakageDetectionIntervalOperation;
        returnDic = @{@"success":@(YES)};
    }else if ([function isEqualToString:@"44"]){
        //读取漏水状态采集间隔
        operationID = mk_cp_taskReadWaterLeakageDetectionIntervalOperation;
        returnDic = @{
                      @"interval":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 6)],
                      };
    }else if ([function isEqualToString:@"47"] && content.length == 10) {
        //读取LED触发提醒
        BOOL isOn = [[content substringWithRange:NSMakeRange(8, 2)] isEqualToString:@"01"];
        returnDic = @{
            @"isOn":@(isOn),
        };
        operationID = mk_cp_taskReadLEDTriggerStatusOperation;
    }else if ([function isEqualToString:@"48"] && content.length == 10) {
        //读取设备是否可以按键开关机
        BOOL isOn = [[content substringWithRange:NSMakeRange(8, 2)] isEqualToString:@"01"];
        returnDic = @{
            @"isOn":@(isOn),
        };
        operationID = mk_cp_taskReadResetBeaconByButtonStatusOperation;
    }else if ([function isEqualToString:@"4e"] && content.length >= 10){
        //读取生产日期
        operationID = mk_cp_taskReadProductionDateOperation;
        NSString *year = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 4)];
        NSString *month = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
        if (month.length == 1) {
            month = [@"0" stringByAppendingString:month];
        }
        NSString *day = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
        if (day.length == 1) {
            day = [@"0" stringByAppendingString:day];
        }
        NSString *productDate = [NSString stringWithFormat:@"%@/%@/%@",year,month,day];
        returnDic = @{@"productionDate":productDate};
    }else if ([function isEqualToString:@"57"] && content.length == 8) {
        //设置LED触发提醒
        operationID = mk_cp_taskConfigLEDTriggerStatusOperation;
        returnDic = @{@"success":@(YES)};
    }else if ([function isEqualToString:@"58"] && content.length == 8) {
        //设置设备是否可以按键开关机
        operationID = mk_cp_taskConfigResetBeaconByButtonStatusOperation;
        returnDic = @{@"success":@(YES)};
    }
    return [self dataParserGetDataSuccess:returnDic operationID:operationID];
}

+ (NSDictionary *)parseConnectStatus:(NSData *)data {
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:data];
    return [self dataParserGetDataSuccess:@{@"connectEnable":@(![content isEqualToString:@"00"])} operationID:mk_cp_taskReadConnectEnableOperation];
}

+ (NSDictionary *)parseMultiPacketData:(NSString *)content {
    NSString *cmd = [content substringWithRange:NSMakeRange(4, 2)];
    mk_cp_taskOperationID operationID = mk_cp_defaultTaskOperationID;
    NSDictionary *returnDic = nil;
    if ([cmd isEqualToString:@"4c"]) {
        //历史温湿度数据
        returnDic = [MKCPAdopter parseHistoryHTData:[content substringFromIndex:6]];
    }
    return [self dataParserGetDataSuccess:returnDic operationID:operationID];
}

#pragma mark - Private method
+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(mk_cp_taskOperationID)operationID{
    if (!returnData) {
        return nil;
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

@end
